from fastapi import APIRouter, Depends, Header, HTTPException
from ..database import get_db
from ..services.protector import monitor_and_respond, verify_token
from sqlalchemy.orm import Session

router = APIRouter()

def token_dependency(token: str = Header(None), db: Session = Depends(get_db)):
    if not token or not verify_token(db, token):
        raise HTTPException(status_code=401, detail="Invalid or missing protection token")
    return token

@router.post("/telemetry")
def telemetry_endpoint(payload: dict, token: str = Depends(token_dependency), db: Session = Depends(get_db)):
    # payload = telemetry dict from agent
    return monitor_and_respond(db=db, app_token=token, telemetry=payload)

