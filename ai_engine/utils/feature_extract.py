# feature_extract.py - Extract rich features for cyber & human threats
import numpy as np
import cv2
from insightface.app import FaceAnalysis
import torch
import librosa  # For audio deepfake features
import logging

logger = logging.getLogger(__name__)

# Global face analyzer (buffalo_l loaded once)
FACE_ANALYZER = FaceAnalysis(name='buffalo_l', root='../../models/human/pretrained_insightface')
FACE_ANALYZER.prepare(ctx_id=0)

def extract_face_embedding(frame: np.ndarray) -> Union[np.ndarray, None]:
    """
    Extract 512-dim embedding using ArcFace (for recognition + deepfake resistance)
    """
    try:
        faces = FACE_ANALYZER.get(frame)
        if len(faces) > 0:
            return faces[0].normed_embedding  # L2-normalized
        return None
    except Exception as e:
        logger.error(f"Face embedding extraction failed: {e}")
        return None

def extract_motion_features(video_clip: np.ndarray) -> np.ndarray:
    """
    Extract optical flow or frame diff features for behavior analysis
    """
    try:
        gray_frames = [cv2.cvtColor(f, cv2.COLOR_BGR2GRAY) for f in video_clip]
        flows = []
        for i in range(1, len(gray_frames)):
            flow = cv2.calcOpticalFlowFarneback(gray_frames[i-1], gray_frames[i], None, 0.5, 3, 15, 3, 5, 1.2, 0)
            mag, _ = cv2.cartToPolar(flow[...,0], flow[...,1])
            flows.append(mag.mean())
        return np.array(flows) if flows else np.zeros(10)
    except:
        return np.zeros(10)

def extract_audio_features_for_deepfake(audio_path: str) -> np.ndarray:
    """
    Extract MFCCs + spectrogram stats for voice deepfake detection
    """
    try:
        y, sr = librosa.load(audio_path, sr=16000)
        mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=40)
        return np.concatenate([mfccs.mean(axis=1), mfccs.std(axis=1)])
    except:
        return np.zeros(80)
