from fastapi import APIRouter
from app.core.ai_engine import AgenticDetector

router = APIRouter()
detector = AgenticDetector()

@router.post("/detect-agentic")
async def detect_agentic(sequence: list[list[float]]):
    result = detector.detect(np.array(sequence))
    return result
