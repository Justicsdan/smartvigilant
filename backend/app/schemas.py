from pydantic import BaseModel
from typing import Optional

class ScanResult(BaseModel):
    status: str
    summary: Optional[str] = None
    details: Optional[dict] = None

class AnalyzeRequest(BaseModel):
    features: list

class AnalyzeResponse(BaseModel):
    is_anomaly: bool
    score: float

class ProtectRegister(BaseModel):
    name: str
    info: Optional[str] = None

class ProtectResponse(BaseModel):
    name: str
    token: str

