import torch
import numpy as np
import os
from stable_baselines3 import PPO

MODEL_DIR = os.path.abspath("../../../models/cyber")

class AgenticDetector:
    def __init__(self):
        path = os.path.join(MODEL_DIR, "smart_agentic.pt")
        self.model = torch.load(path, map_location="cpu")
        self.model.eval()

    def detect(self, sequence: np.ndarray) -> dict:
        """
        sequence: (seq_len, feature_dim) API call or behavior sequence
        """
        with torch.no_grad():
            input_tensor = torch.tensor(sequence, dtype=torch.float32).unsqueeze(0)
            prob = torch.sigmoid(self.model(input_tensor)).item()
        return {
            "agentic_threat_probability": prob,
            "is_agentic": prob > 0.8
        }

class CounterAgent:
    def __init__(self):
        path = os.path.join(MODEL_DIR, "smart_counter_agent.pt")
        self.agent = PPO.load(path)

    def recommend_action(self, system_state: np.ndarray) -> dict:
        action, _ = self.agent.predict(system_state, deterministic=True)
        actions = ["monitor", "block_ip", "quarantine", "rollback", "alert", "patch"]
        return {"recommended_action": actions[int(action)], "action_id": int(action)}

class RedTeamSimulator:
    def __init__(self):
        path = os.path.join(MODEL_DIR, "smart_redteam.onnx")
        self.session = ort.InferenceSession(path)

    def probe(self, state: np.ndarray) -> str:
        input_name = self.session.get_inputs()[0].name
        output = self.session.run(None, {input_name: state.astype(np.float32)})[0]
        return f"Simulated vulnerability probe → action {int(output[0])}"
