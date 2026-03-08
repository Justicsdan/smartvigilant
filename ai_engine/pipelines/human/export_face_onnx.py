import insightface
from insightface.app import FaceAnalysis
import onnx

# Load InsightFace app with buffalo_l (open-source high-accuracy model)
app = FaceAnalysis(name='buffalo_l', providers=['CUDAExecutionProvider', 'CPUExecutionProvider'])
app.prepare(ctx_id=0, det_size=(640, 640))

# Export recognition model to ONNX (ArcFace backbone)
model = app.models['recognition']
dummy_input = torch.randn(1, 3, 112, 112)  # Standard input size

torch.onnx.export(model, dummy_input, '../models/human/smart_face.onnx',
                  export_params=True, opset_version=18,
                  input_names=['input'], output_names=['output'])

print("Exported smart_face.onnx – InsightFace ArcFace (>99% accuracy on LFW)")
