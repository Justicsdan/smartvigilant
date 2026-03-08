# device.py - Device management models
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum

class DeviceType(str, Enum):
    camera = "camera"
    phone = "phone"
    tablet = "tablet"
    smart_lock = "smart_lock"
    sensor = "sensor"
    computer = "computer"
    wearable = "wearable"

class DeviceStatus(str, Enum):
    online = "online"
    offline = "offline"
    low_battery = "low_battery"
    updating = "updating"
    error = "error"

class VigilantDeviceBase(BaseModel):
    name: str
    type: DeviceType
    location: Optional[str] = None
    capabilities: Optional[Dict[str, Any]] = None

class VigilantDeviceCreate(VigilantDeviceBase):
    user_id: str

class VigilantDeviceUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    status: Optional[DeviceStatus] = None

class VigilantDeviceResponse(VigilantDeviceBase):
    id: str
    status: DeviceStatus
    last_seen: datetime
    battery_level: Optional[float] = None  # 0.0 to 1.0
    is_online: bool

    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

class DeviceListResponse(BaseModel):
    devices: list[VigilantDeviceResponse]
    total: int
    online_count: int
