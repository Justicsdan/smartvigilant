from fastapi import APIRouter
from app.core.services.protector import protector

router = APIRouter()

@router.post("/manual-block")
async def manual_block(ip: str):
    # Integrate with firewall
    return {"msg": f"IP {ip} blocked manually"}
