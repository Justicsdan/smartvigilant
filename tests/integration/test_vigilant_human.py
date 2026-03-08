import numpy as np
from app.core.services.scanner import scanner

def test_full_human_scan_flow():
    # Mock camera frame
    frame = np.random.randint(0, 255, (640, 640, 3), dtype=np.uint8)
    result = scanner.scan_video_frame(frame)
    
    assert result["type"] == "video_frame"
    assert "deepfake" in result["details"]["sources"]
    assert "ai_threat" in result["details"]["sources"]
    assert "motion" in result["details"]["sources"]
