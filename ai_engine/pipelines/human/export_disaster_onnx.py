import torch
import torch.nn as nn
import onnx
import pandas as pd  # For sensor/weather data

# Simple LSTM for time-series (flood/earthquake risk) + CNN for satellite images
class DisasterPredictor(nn.Module):
    def __init__(self):
        super().__init__()
        self.lstm = nn.LSTM(input_size=20, hidden_size=128, num_layers=2)  # Features: rain, seismic, temp
        self.cnn = nn.Sequential(nn.Conv2d(3, 64, 3), nn.ReLU(), nn.Flatten())
        self.fc = nn.Linear(128 + 64*some_size, 4)  # Classes: flood, earthquake, wildfire, none
    
    def forward(self, time_series, image):
        _, (h, _) = self.lstm(time_series)
        img_feat = self.cnn(image)
        combined = torch.cat((h[-1], img_feat), dim=1)
        return torch.softmax(self.fc(combined), dim=1)

model = DisasterPredictor()

# Train on historical data (e.g., USGS/NOAA datasets)

# Dummy inputs for export
dummy_ts = torch.randn(10, 1, 20)  # Sequence length 10
dummy_img = torch.randn(1, 3, 224, 224)

torch.onnx.export(model, (dummy_ts, dummy_img), '../models/human/smart_disaster.onnx',
                  export_params=True, opset_version=18,
                  input_names=['time_series', 'image'], output_names=['risk'])

print("Exported smart_disaster.onnx – Multimodal predictor for floods/earthquakes/wildfires")
