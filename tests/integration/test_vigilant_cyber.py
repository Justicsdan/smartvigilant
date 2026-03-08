import numpy as np
from app.core.services.scanner import scanner

def test_full_cyber_scan_flow():
    # Mock network features
    features = np.random.rand(50).astype(np.float32)
    result = scanner.scan_network_traffic(features)
    
    assert "type" in result
    assert result["type"] == "network_anomaly"
    assert "details" in result
    assert "anomaly_score" in result["details"]
