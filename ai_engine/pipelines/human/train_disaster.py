# train_disaster.py - Multimodal natural disaster risk predictor (floods, wildfires, earthquakes)
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
import logging

logging.basicConfig(level=logging.INFO)

class DisasterDataset(Dataset):
    def __init__(self, csv_path, img_dir=None):
        self.data = pd.read_csv(csv_path)  # Columns: temp, rain, seismic, wind, label (0=none,1=flood,2=wildfire,3=quake)
        self.scaler = StandardScaler()
        self.features = self.scaler.fit_transform(self.data.drop(['label', 'image_path'], axis=1))
        self.labels = self.data['label'].values
        self.img_paths = self.data['image_path'].values if 'image_path' in self.data else None
    
    def __len__(self): return len(self.data)
    
    def __getitem__(self, idx):
        sensor = torch.tensor(self.features[idx], dtype=torch.float32)
        label = torch.tensor(self.labels[idx], dtype=torch.long)
        
        if self.img_paths is not None:
            img = load_satellite_image(self.img_paths[idx])  # Preprocess to 3x224x224
            return sensor, img, label
        return sensor, label

class DisasterPredictor(nn.Module):
    def __init__(self, num_classes=4):
        super().__init__()
        # Sensor branch (time-series/weather/seismic)
        self.sensor_net = nn.Sequential(
            nn.Linear(20, 128),  # Adjust input size based on features
            nn.ReLU(),
            nn.Linear(128, 64),
            nn.ReLU()
        )
        # Image branch (satellite/radar)
        self.image_net = torch.hub.load('pytorch/vision:v0.15.0', 'resnet50', pretrained=True)
        self.image_net.fc = nn.Linear(2048, 128)
        
        # Fusion
        self.classifier = nn.Sequential(
            nn.Linear(64 + 128, 256),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(256, num_classes)
        )
    
    def forward(self, sensor, image=None):
        s_feat = self.sensor_net(sensor)
        if image is not None:
            i_feat = self.image_net(image)
            combined = torch.cat((s_feat, i_feat), dim=1)
        else:
            combined = s_feat
        return self.classifier(combined)

# Training loop
model = DisasterPredictor()
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)

# ... data loading and training ...

# Export to ONNX (with optional image input)
dummy_sensor = torch.randn(1, 20)
dummy_image = torch.randn(1, 3, 224, 224)

torch.onnx.export(
    model,
    (dummy_sensor, dummy_image),
    '../../../models/human/smart_disaster.onnx',
    export_params=True,
    opset_version=18,
    input_names=['sensor_data', 'satellite_image'],
    output_names=['risk_class'],
    dynamic_axes={
        'sensor_data': {0: 'batch'},
        'satellite_image': {0: 'batch'},
        'risk_class': {0: 'batch'}
    }
)

print("Trained and exported smart_disaster.onnx – Proactive natural disaster alerts (floods, wildfires, earthquakes)")
