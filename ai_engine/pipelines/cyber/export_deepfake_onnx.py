import torch
from deepfakebench.models import Effort  # From DeepfakeBench (ICML'25 SOTA)
import onnx

# Load pre-trained Effort model (generalizable deepfake detector)
model = Effort(pretrained=True)
model.eval()

# Dummy input (image tensor)
dummy_input = torch.randn(1, 3, 224, 224)

# Export to ONNX
torch.onnx.export(model, dummy_input, '../models/cyber/smart_deepfake.onnx',
                  export_params=True, opset_version=18,
                  input_names=['input'], output_names=['output'])

print("Exported smart_deepfake.onnx – SOTA cross-dataset deepfake detection")
