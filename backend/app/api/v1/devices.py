# devices.py - Manage connected cameras, sensors, phones
from fastapi import APIRouter, Depends
from typing import List
from app.models.vigilant_device import VigilantDeviceResponse

router = APIRouter(prefix="/devices", tags=["Devices"])

# Mock devices
mock_devices = [
    {"id": "cam-01", "name": "Front Door", "type": "camera", "status": "online"},
    {"id": "phone-01", "name": "Family Phone", "type": "phone", "status": "online"},
    {"id": "lock-01", "name": "Smart Lock", "type": "smart_lock", "status": "online"},
]

@router.get("/", response_model=List[VigilantDeviceResponse])
async def get_devices(user: str = Depends(get_current_user)):
    return mock_devices

@router.post("/panic")
async def emergency_panic(user: str = Depends(get_current_user)):
    # In production: trigger sirens, call authorities, notify contacts
    return {"status": "EMERGENCY ALERT SENT", "timestamp": datetime.utcnow().isoformat()}
