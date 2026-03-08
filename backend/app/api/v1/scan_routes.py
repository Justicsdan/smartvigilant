from fastapi import APIRouter

router = APIRouter()

@router.post("/full-scan")
async def full_system_scan():
    return {"msg": "Full scan initiated", "estimated_time": "5 minutes"}
