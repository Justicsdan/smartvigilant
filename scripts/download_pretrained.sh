#!/bin/bash
mkdir -p data/pretrained

echo "Downloading latest production models..."

# Example: YOLOv11 nano for motion
wget -O data/pretrained/smart_motion.pt https://github.com/ultralytics/assets/releases/download/v8.3.0/yolov11n.pt

# Deepfake detector
wget -O data/pretrained/smart_deepfake.onnx https://huggingface.co/prithivMLmods/Deep-Fake-Detector-v2-Model/resolve/main/model.onnx

echo "Pretrained models downloaded"
