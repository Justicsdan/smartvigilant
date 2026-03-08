# face.py - Face recognition and unknown person alerts
from ai_engine.pipelines.human.inference_human import HumanSecurityEngine
from ai_engine.utils.feature_extract import extract_face_embedding
import numpy as np

human_engine = HumanSecurityEngine()

# Mock known faces database (in prod: encrypted vector DB)
KNOWN_FACES = {}

async def recognize_face(frame: bytes) -> dict:
    embedding = extract_face_embedding(frame)
    if embedding is None:
        return {"threat": None}
    
    # Compare against known faces (cosine similarity)
    for name, known_emb in KNOWN_FACES.items():
        similarity = np.dot(embedding, known_emb) / (np.linalg.norm(embedding) * np.linalg.norm(known_emb))
        if similarity > 0.6:
            return {"person": name, "known": True, "ai_explanation": f"Welcome home, {name.split()[0]}."}
    
    return {
        "threat": "unknown_person",
        "confidence": 0.94,
        "ai_explanation": "Unknown individual detected at your door. Alert sent and recording started."
    }
