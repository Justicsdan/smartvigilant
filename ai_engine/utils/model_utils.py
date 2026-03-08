# model_utils.py - Unified model loading, export, and optimization
import torch
import onnxruntime as ort
import tensorflow as tf
import os
from typing import Union
import logging

logger = logging.getLogger(__name__)

def load_model(model_path: str, framework: str = 'torch') -> Union[torch.nn.Module, ort.InferenceSession, tf.lite.Interpreter]:
    """
    Load any supported model format safely
    """
    try:
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model not found: {model_path}")
        
        if framework == 'torch' or model_path.endswith('.pt'):
            model = torch.load(model_path, map_location='cpu')
            model.eval()
            return model
        
        elif model_path.endswith('.onnx'):
            session = ort.InferenceSession(model_path, providers=['CUDAExecutionProvider', 'CPUExecutionProvider'])
            return session
        
        elif model_path.endswith('.tflite'):
            interpreter = tf.lite.Interpreter(model_path=model_path)
            interpreter.allocate_tensors()
            return interpreter
        
        else:
            raise ValueError(f"Unsupported model format: {model_path}")
    
    except Exception as e:
        logger.error(f"Failed to load model {model_path}: {e}")
        raise

def export_to_onnx(model: torch.nn.Module, dummy_input, output_path: str):
    """
    Export PyTorch model to ONNX with best practices
    """
    torch.onnx.export(
        model,
        dummy_input,
        output_path,
        export_params=True,
        opset_version=18,
        do_constant_folding=True,
        input_names=['input'],
        output_names=['output'],
        dynamic_axes={'input': {0: 'batch_size'}, 'output': {0: 'batch_size'}}
    )
    logger.info(f"Exported model to ONNX: {output_path}")

def get_model_size_mb(model_path: str) -> float:
    """Utility to monitor model size"""
    return os.path.getsize(model_path) / (1024 * 1024)
