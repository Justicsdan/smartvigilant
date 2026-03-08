from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from .database import Base

class ScanLog(Base):
    __tablename__ = "scan_logs"
    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=True)
    result = Column(String)
    details = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Alert(Base):
    __tablename__ = "alerts"
    id = Column(Integer, primary_key=True, index=True)
    source = Column(String)
    level = Column(String)
    message = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class ProtectedApp(Base):
    __tablename__ = "protected_apps"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True)
    token = Column(String, unique=True)
    info = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

