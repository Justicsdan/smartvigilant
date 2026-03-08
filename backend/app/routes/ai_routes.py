from fastapi import APIRouter, Depends
from ..schemas import AnalyzeRequest, AnalyzeResponse
from ..ai_engine.anomaly import predict_anomaly, load_model
from ..database import get_db
from sqlalchemy.orm import Session

router = APIRouter()

@router.post("/analyze", response_model=AnalyzeResponse)
def analyze(req: AnalyzeRequest, db: Session = Depends(get_db)):
    """
    Accepts a list of numerical features and returns anomaly probability/score.
    """
    model = load_model()
    res = predict_anomaly(req.features, model=model)
    return {"is_anomaly": res.get("is_anomaly", False), "score": res.get("score", 0.0)}

