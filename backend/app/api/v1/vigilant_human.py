# vigilant_human.py - Physical & disaster security routes
from fastapi import APIRouter, UploadFile, File, Depends
from ai_engine.pipelines.human.inference_human import HumanSecurityEngine
from ai_engine.utils.vigilant_nlp import VigilantNLP
from app.api.v1.auth import get_current_user
import asyncio

router = APIRouter(prefix="/human", tags=["Human Security"])

human_engine = HumanSecurityEngine()

@router.post("/vision/analyze")
async def analyze_frame(frame: UploadFile = File(...), user: str = Depends(get_current_user)):
    contents = await frame.read()
    # Simulate frame processing
    results = human_engine.infer_frame(contents)  # Pass numpy array in real
    
    alerts = []
    for alert in results.get("alerts", []):
        alerts.append({
            "title": alert.get("threat", "Activity Detected").replace("_", " ").title(),
            "ai_explanation": VigilantNLP.explainThreat({"type": alert.get("threat")}),
            "timestamp": datetime.utcnow().isoformat(),
            "severity": "high" if "unknown" in alert.get("threat", "") else "medium",
            "type": alert.get("threat"),
            "resolved": False
        })
    
    return {"detections": results, "alerts": alerts}

@router.post("/disaster/predict")
async def predict_disaster(sensor_data: dict, user: str = Depends(get_current_user)):
    result = human_engine.predict_disaster(sensor_data)
    if result["threat"]:
        return {
            "risk": result["type"],
            "ai_explanation": VigilantNLP.explainThreat({"type": "natural_disaster", "event": result["type"]}),
            "action": "prepare_evacuation"
        }
    return {"status": "safe"}
