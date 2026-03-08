# preprocess.py - Unified preprocessing for cyber and human pipelines
import numpy as np
import cv2
import torch
from torchvision import transforms
from transformers import AutoTokenizer
import hashlib
import logging
from typing import Union, List, Dict

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Image preprocessing for vision models (YOLO, Face, Deepfake, Disaster)
IMAGE_TRANSFORM = transforms.Compose([
    transforms.ToPILImage(),
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

# Text tokenizer for phishing / prompt attacks
PHISHING_TOKENIZER = AutoTokenizer.from_pretrained("bert-base-uncased")

def preprocess_image(frame: np.ndarray, target_size: tuple = (224, 224)) -> torch.Tensor:
    """
    Preprocess camera/satellite frame for vision models
    """
    try:
        if len(frame.shape) == 2:  # Grayscale to RGB
            frame = cv2.cvtColor(frame, cv2.COLOR_GRAY2RGB)
        elif frame.shape[2] == 4:  # RGBA to RGB
            frame = cv2.cvtColor(frame, cv2.COLOR_RGBA2RGB)
        
        frame = cv2.resize(frame, target_size)
        tensor = IMAGE_TRANSFORM(frame)
        return tensor.unsqueeze(0)  # Add batch dim
    except Exception as e:
        logger.error(f"Image preprocessing failed: {e}")
        return torch.zeros(1, 3, target_size[0], target_size[1])

def preprocess_network_packet(packet_data: bytes) -> np.ndarray:
    """
    Convert raw packet to fixed-length feature vector (e.g., for anomaly detection)
    """
    # Simple: hash + length + entropy features
    features = np.zeros(128)
    features[0] = len(packet_data)
    features[1:65] = np.frombuffer(hashlib.sha256(packet_data).digest(), dtype=np.float32)[:64]
    return features.astype(np.float32)

def preprocess_text(text: str, max_length: int = 128) -> Dict:
    """
    Tokenize text for phishing, prompt injection, or malicious email detection
    """
    try:
        encoded = PHISHING_TOKENIZER(
            text,
            padding='max_length',
            truncation=True,
            max_length=max_length,
            return_tensors='pt'
        )
        return {k: v.squeeze(0) for k, v in encoded.items()}
    except Exception as e:
        logger.warning(f"Text preprocessing failed: {e}")
        return {"input_ids": torch.zeros(max_length), "attention_mask": torch.zeros(max_length)}

def preprocess_sensor_data(sensors: Dict[str, float]) -> torch.Tensor:
    """
    Normalize sensor readings for disaster prediction (temp, humidity, seismic, etc.)
    """
    expected_keys = ['temperature', 'humidity', 'pressure', 'rainfall', 'seismic_activity']
    values = [sensors.get(k, 0.0) for k in expected_keys]
    # Min-max normalize (based on known physical ranges)
    normalized = (np.array(values) - np.array([-50, 0, 900, 0, 0])) / np.array([100, 100, 200, 500, 10])
    return torch.tensor(normalized, dtype=torch.float32).unsqueeze(0)
