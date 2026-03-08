# motion.py - Motion detection and loitering analysis
from ai_engine.pipelines.human.inference_human import HumanSecurityEngine

human_engine = HumanSecurityEngine()

async def analyze_motion(video_clip: bytes) -> dict:
    """
    Detect motion and classify as normal or suspicious (loitering)
    """
    results = human_engine.detect_motion(video_clip)
    
    if results["threat"]:
        return {
            "threat": "suspicious_motion",
            "details": results,
            "ai_explanation": "Unusual loitering pattern detected near your property. Recording saved."
        }
    
    return {"threat": None, "ai_explanation": "Normal activity detected."}
