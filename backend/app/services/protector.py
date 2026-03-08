# app/services/protector.py
"""
SmartVigilant protector service.

Responsibilities:
- Generate and persist protection tokens for third-party apps
- Verify tokens (for endpoint auth)
- Accept telemetry/metrics from protected apps and score them via the anomaly detector
- Decide an action (monitor, alert, isolate) and emit alerts/logs
- Provide safe placeholders for isolation/sandboxing hooks (implement platform-specific code separately)

Notes:
- This module uses the project's CRUD functions to store app registrations.
- It uses the AI anomaly predictor to score incoming telemetry.
"""

from typing import Dict, Optional, Any
import secrets
import logging
import time

from sqlalchemy.orm import Session

from ..crud import register_protected_app  # expects (db, name, token, info)
from ..ai_engine.anomaly import predict_anomaly, load_model
from ..crud import create_alert, create_scanlog  # optional logging helpers

logger = logging.getLogger("smartvigilant.protector")
logger.setLevel(logging.INFO)

# --- Configuration / thresholds (tune later) ---
ANOMALY_SCORE_THRESHOLD = -0.5  # Isolation threshold (IsolationForest decision_function score)
ALERT_SCORE_THRESHOLD = -0.15   # Score to raise an alert / attention
TOKEN_BYTE_LENGTH = 24


# --------------------
# Token & Registration
# --------------------
def generate_token(length: int = TOKEN_BYTE_LENGTH) -> str:
    """
    Generate a URL-safe token for app registration.
    """
    return secrets.token_urlsafe(length)


def register_app(db: Session, name: str, info: Optional[str] = None) -> Dict[str, str]:
    """
    Register a protected application and persist a token.
    Returns { name, token, info }.
    """
    token = generate_token()
    # Persist via CRUD layer
    app = register_protected_app(db=db, name=name, token=token, info=info)
    logger.info("Registered protected app: %s (id=%s)", app.name, app.id)
    return {"name": app.name, "token": token, "info": app.info}


def verify_token(db: Session, token: str) -> bool:
    """
    Minimal token verification against DB.
    If you want more elaborate validation (expiry, scopes), extend here.
    """
    from ..models import ProtectedApp  # lazy import to avoid circulars
    try:
        app = db.query(ProtectedApp).filter(ProtectedApp.token == token).first()
        return bool(app)
    except Exception as e:
        logger.exception("Token verification error: %s", e)
        return False


# -------------------------
# FastAPI Dependency helper
# -------------------------
# If you are wiring protector into FastAPI routes, use this dependency:
#
# from fastapi import Header, HTTPException, Depends
# def token_dependency(token: str = Header(None), db: Session = Depends(get_db)):
#     if token is None or not verify_token(db, token):
#         raise HTTPException(status_code=401, detail="Invalid or missing protection token")
#     return token
#
# This keeps endpoints protected and tied to a registered app.


# -------------------------
# Telemetry / Monitor Logic
# -------------------------
def _extract_features_from_telemetry(telemetry: Dict[str, Any]) -> list:
    """
    Convert telemetry dict into a numeric feature vector expected by the anomaly model.
    This is application-specific; here's a generic example:
      - cpu_percent
      - memory_mb
      - open_connections
      - new_process_count
      - network_tx_bytes (per interval)
    When deploying, ensure the client agent sends the same keys.

    Returns: list[float]
    """
    # default order & fallbacks (tune for your agents)
    features = [
        float(telemetry.get("cpu_percent", 0.0)),
        float(telemetry.get("memory_mb", 0.0)),
        float(telemetry.get("open_connections", 0.0)),
        float(telemetry.get("new_processes", 0.0)),
        float(telemetry.get("network_tx_bytes", 0.0)),
        float(telemetry.get("network_rx_bytes", 0.0)),
    ]
    return features


def evaluate_telemetry(telemetry: Dict[str, Any], model=None) -> Dict[str, Any]:
    """
    Score telemetry using the anomaly model.
    Returns a dict with is_anomaly(bool) and score(float).
    """
    features = _extract_features_from_telemetry(telemetry)
    model = model or load_model()
    result = predict_anomaly(features, model=model)
    # Normalize result keys: decision_function may be higher => more normal for IsolationForest.
    # We return the raw score and a simple interpretation
    return {
        "is_anomaly": result.get("is_anomaly", False),
        "score": result.get("score", 0.0),
        "features": features,
        "note": result.get("note"),
    }


# -------------------------
# Response / Action Engine
# -------------------------
def _create_alert_record(db: Session, source: str, level: str, message: str):
    """
    Convenience helper to persist alerts to DB.
    """
    try:
        create_alert(db=db, source=source, level=level, message=message)
    except Exception:
        logger.exception("Failed to persist alert")


def isolate_app_stub(app_token: str, reason: str) -> Dict[str, str]:
    """
    Placeholder for isolation actions. DO NOT implement destructive OS commands here.
    Instead provide platform-specific agent hooks that will be called to take real actions.
    Returns a descriptive dict; implementers should connect to platform agents.
    """
    # In production, send command to the host agent to:
    # - Pause network access for the monitored app
    # - Move the app's process into a sandbox (e.g., job object on Windows)
    # - Kill the process as last resort (with appropriate audit)
    logger.warning("isolate_app_stub called for token=%s reason=%s", app_token, reason)
    # Return a safe response indicating the intended action.
    return {"action": "isolate_requested", "token": app_token, "reason": reason}


def monitor_and_respond(db: Session, app_token: str, telemetry: Dict[str, Any], model=None) -> Dict[str, Any]:
    """
    Primary entry: accept telemetry from a protected app, evaluate it, log results,
    and determine an action (monitor/alert/isolate). This is synchronous and returns
    the recommended action to the caller.
    """
    start_ts = time.time()
    evaluation = evaluate_telemetry(telemetry, model=model)
    score = evaluation["score"]
    is_anom = evaluation["is_anomaly"]
    intent = "monitor"

    # Decide action thresholds
    if score <= ANOMALY_SCORE_THRESHOLD or is_anom:
        intent = "isolate"
        # create alert record
        _create_alert_record(db, source="protector", level="critical",
                             message=f"Anomalous telemetry for token={app_token} score={score} features={evaluation['features']}")
        action_result = isolate_app_stub(app_token, reason=f"Anomaly score {score}")
    elif score <= ALERT_SCORE_THRESHOLD:
        intent = "alert"
        _create_alert_record(db, source="protector", level="warning",
                             message=f"Suspicious telemetry for token={app_token} score={score} features={evaluation['features']}")
        action_result = {"action": "alert_created", "details": "Telemetry suspicious, review required."}
    else:
        intent = "monitor"
        action_result = {"action": "no_action", "details": "Telemetry within expected bounds."}

    # Optional: persist a scan log for auditing
    try:
        create_scanlog(db=db, filename=None, result=intent, details=str({"score": score, "features": evaluation["features"]}))
    except Exception:
        logger.exception("Failed to persist scan log")

    duration = time.time() - start_ts
    logger.info("monitor_and_respond token=%s intent=%s score=%.4f dt=%.3fs", app_token, intent, score, duration)

    return {
        "intent": intent,
        "score": score,
        "is_anomaly": is_anom,
        "action_result": action_result,
        "evaluation": evaluation,
    }


# -------------------------
# Lightweight SDK helpers
# -------------------------
def protection_headers_for_client(token: str) -> Dict[str, str]:
    """
    Utility that client SDKs can use when calling protected endpoints.
    E.g., headers = protection_headers_for_client(token)
    """
    return {"X-SmartVigilant-Token": token}


# -------------------------
# Example integration notes
# -------------------------
# - FastAPI route example:
#
# @router.post("/protect/telemetry")
# def telemetry_endpoint(payload: dict, token: str = Depends(token_dependency), db: Session = Depends(get_db)):
#     return monitor_and_respond(db, token, payload)
#
# - Host agent:
#   The host agent (Windows service / Linux daemon) should:
#   1. Register the app using /protect/register to get a token
#   2. Periodically send telemetry to /protect/telemetry with that token in header
#   3. Listen to commands from the server (isolated queue) to take action if requested.
#
# - Isolation / Enforcement:
#   Implement platform-specific code in the agent (do NOT run destructive OS commands from server-side).
#
# - Security:
#   Protect /protect endpoints with TLS, rate-limiting and authenticate callers. Consider mutual TLS for agents.

