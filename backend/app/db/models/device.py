# device.py - Connected devices storage
from sqlalchemy import Column, Integer, String, Enum, Boolean, DateTime, ForeignKey, Float
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base import Base
import enum

class DeviceType(enum.Enum):
    camera = "camera"
    phone = "phone"
    smart_lock = "smart_lock"
    sensor = "sensor"
    # ... etc.

class DeviceStatus(enum.Enum):
    online = "online"
    offline = "offline"
    low_battery = "low_battery"

class Device(Base):
    __tablename__ = "devices"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String, nullable=False)
    device_id = Column(String, unique=True, index=True)  # Unique hardware ID
    type = Column(Enum(DeviceType), nullable=False)
    location = Column(String, nullable=True)
    status = Column(Enum(DeviceStatus), default=DeviceStatus.online)
    battery_level = Column(Float, nullable=True)  # 0.0 to 1.0
    last_seen = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    owner = relationship("User", back_populates="devices")
