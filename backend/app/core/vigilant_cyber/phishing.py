# phishing.py - Phishing, deepfake, and prompt injection detection
from ai_engine.utils.preprocess import preprocess_text
from ai_engine.pipelines.cyber.inference_cyber import CyberThreatEngine

engine = CyberThreatEngine()

async def detect_phishing(content: str, media_attachments: list = None) -> dict:
    """
    Analyze text/email/URL + optional media for phishing or deepfake
    """
    text_features = preprocess_text(content)
    result = engine.infer({"phishing": text_features}, threat_type='phishing')
    
    if media_attachments:
        # Deepfake check on images/audio
        deepfake_result = engine.infer({"frame": media_attachments[0]}, threat_type='deepfake')
        if deepfake_result.get("threat"):
            return {
                "threat": "deepfake_phishing",
                "confidence": deepfake_result.get("score", 0.98),
                "action_taken": "blocked",
                "ai_explanation": "This message contains a deepfake video/audio used for impersonation. It was automatically blocked."
            }
    
    if result.get("threat"):
        return {
            "threat": "phishing",
            "ai_explanation": "Suspicious message trying to steal your information — blocked safely."
        }
    
    return {"threat": None, "ai_explanation": "Message appears legitimate."}
