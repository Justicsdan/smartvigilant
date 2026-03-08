# vigilant_alert.py - Unified alert model for cyber & human threats
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum

class AlertSeverity(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"
    critical = "critical"

class AlertType(str, Enum):
    malware = "malware"
    phishing = "phishing"
    deepfake = "deepfake"
    agentic_attack = "agentic_attack"
    network_anomaly = "network_anomaly"
    intruder = "intruder"
    unknown_person = "unknown_person"
    suspicious_behavior = "suspicious_behavior"
    natural_disaster = "natural_disaster"
    health_emergency = "health_emergency"
    panic = "panic"
    system = "system"

class VigilantAlertBase(BaseModel):
    title: str
    ai_explanation: str
    severity: AlertSeverity
    type: AlertType
    resolved: bool = False
    metadata: Optional[Dict[str, Any]] = None

class VigilantAlertCreate(VigilantAlertBase):
    user_id: str

class VigilantAlert(VigilantAlertBase):
    id: str
    timestamp: datetime
    user_id: str

    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

# Response for history/list
class AlertHistoryResponse(BaseModel):
    alerts: list[VigilantAlert]
    total: int
    unread: int
