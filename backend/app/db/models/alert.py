# alert.py - Persistent alert storage
from sqlalchemy import Column, Integer, String, Enum, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base import Base
import enum

class AlertSeverity(enum.Enum):
    low = "low"
    medium = "medium"
    high = "high"
    critical = "critical"

class AlertType(enum.Enum):
    malware = "malware"
    phishing = "phishing"
    deepfake = "deepfake"
    agentic_attack = "agentic_attack"
    intruder = "intruder"
    natural_disaster = "natural_disaster"
    panic = "panic"
    # ... add others as needed

class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String, nullable=False)
    ai_explanation = Column(Text, nullable=False)
    severity = Column(Enum(AlertSeverity), nullable=False)
    type = Column(Enum(AlertType), nullable=False)
    resolved = Column(Boolean, default=False)
    metadata = Column(String)  # JSON string
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)

    owner = relationship("User", back_populates="alerts")
