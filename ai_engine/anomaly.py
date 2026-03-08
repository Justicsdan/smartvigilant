import numpy as np
from sklearn.ensemble import IsolationForest
import joblib
import os
from ..config import settings

MODEL_DIR = os.path.dirname(settings.MODEL_PATH) or "./models"
os.makedirs(MODEL_DIR, exist_ok=True)

def train_and_save(X, model_path=settings.MODEL_PATH):
    model = IsolationForest(n_estimators=100, contamination="auto", random_state=42)
    model.fit(np.array(X))
    joblib.dump(model, model_path)
    return model

def load_model(model_path=settings.MODEL_PATH):
    if os.path.exists(model_path):
        return joblib.load(model_path)
    return None

def predict_anomaly(features, model=None):
    """
    features: list or 1D array
    returns dict { is_anomaly: bool, score: float }
    """
    arr = np.array(features).reshape(1, -1)
    model = model or load_model()
    if model is None:
        # If no trained model, treat everything as not-anomaly but with low confidence
        return {"is_anomaly": False, "score": 0.0, "note": "No model available"}
    score = model.decision_function(arr)[0]  # higher => more normal
    pred = model.predict(arr)[0]  # 1 -> normal, -1 -> anomaly
    return {"is_anomaly": bool(pred == -1), "score": float(score)}

