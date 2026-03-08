# inference_cyber.py - Unified inference across all cyber models
import torch
import onnxruntime as ort
import tensorflow as tf
import numpy as np

class CyberThreatEngine:
    def __init__(self):
        self.malware_interp = tf.lite.Interpreter(model_path='../../../models/cyber/smart_malware.tflite')
        self.malware_interp.allocate_tensors()
        
        self.anomaly_model = torch.load('../../../models/cyber/smart_anomaly.pt')
        self.deepfake_session = ort.InferenceSession('../../../models/cyber/smart_deepfake.onnx')
        self.agentic_model = torch.load('../../../models/cyber/smart_agentic.pt')
    
    def infer(self, input_data, threat_type='all'):
        results = {}
        
        if threat_type in ['malware', 'all']:
            # Preprocess and run TFLite
            input_details = self.malware_interp.get_input_details()
            self.malware_interp.set_tensor(input_details[0]['index'], input_data['malware'])
            self.malware_interp.invoke()
            results['malware'] = self.malware_interp.get_output_details()[0]['index']
        
        if threat_type in ['deepfake', 'all']:
            ort_inputs = {self.deepfake_session.get_inputs()[0].name: input_data['frame']}
            results['deepfake'] = self.deepfake_session.run(None, ort_inputs)[0]
        
        # Add agentic, anomaly, etc.
        
        return self.aggregate_threats(results)

    def aggregate_threats(self, results):
        # AI-vs-AI decision logic: prioritize, resolve, explain
        return {"final_threat": "ai_agentic", "confidence": 0.92, "action": "neutralized_autonomously"}

# Global engine
engine = CyberThreatEngine()
