# inference_human.py - Unified inference engine for human security features
import torch
import onnxruntime as ort
from ultralytics import YOLO
import cv2
import numpy as np
from insightface.app import FaceAnalysis

class HumanSecurityEngine:
    def __init__(self):
        # Motion detection
        self.motion_model = YOLO('../../../models/human/smart_motion.pt')
        
        # Face recognition
        self.face_session = ort.InferenceSession('../../../models/human/smart_face.onnx')
        self.face_app = FaceAnalysis(name='buffalo_l', root='../../../models/human/pretrained_insightface')
        self.face_app.prepare(ctx_id=0)
        
        # Disaster prediction
        self.disaster_session = ort.InferenceSession('../../../models/human/smart_disaster.onnx')
    
    def detect_motion(self, frame):
        results = self.motion_model(frame, conf=0.5, classes=[0])  # Class 0 = person
        if len(results[0].boxes) > 0:
            return {"threat": "person_detected", "boxes": results[0].boxes.xyxy.tolist(), "action": "alert"}
        return {"threat": None}
    
    def recognize_face(self, frame):
        faces = self.face_app.get(frame)
        if len(faces) > 0:
            embedding = faces[0].normed_embedding
            # Compare against known database (vector DB like FAISS)
            if is_unknown(embedding):
                return {"threat": "unknown_person", "confidence": 0.92}
        return {"threat": None}
    
    def predict_disaster(self, sensor_data: dict, satellite_img=None):
        # Preprocess sensor_data to tensor
        sensor_tensor = preprocess_sensors(sensor_data)
        
        inputs = {'sensor_data': sensor_tensor.numpy()}
        if satellite_img is not None:
            img_tensor = preprocess_image(satellite_img)
            inputs['satellite_image'] = img_tensor.numpy()
        
        preds = self.disaster_session.run(None, inputs)[0]
        risk_class = np.argmax(preds)
        risk_map = {0: "safe", 1: "flood", 2: "wildfire", 3: "earthquake"}
        
        if risk_class > 0:
            return {"threat": "natural_disaster", "type": risk_map[risk_class], "confidence": preds[0][risk_class], "action": "evacuate_prepare"}
        return {"threat": None}
    
    def infer_frame(self, frame, sensor_data=None):
        results = []
        motion = self.detect_motion(frame)
        if motion['threat']: results.append(motion)
        
        face = self.recognize_face(frame)
        if face['threat']: results.append(face)
        
        if sensor_data:
            disaster = self.predict_disaster(sensor_data)
            if disaster['threat']: results.append(disaster)
        
        return {"alerts": results, "status": "secure" if not results else "threat_detected"}

# Global engine for backend integration
human_engine = HumanSecurityEngine()
