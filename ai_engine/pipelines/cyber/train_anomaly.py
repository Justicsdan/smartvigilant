# train_anomaly.py - Unsupervised anomaly detection using Anomalib (PatchCore)
from anomalib.data import Folder
from anomalib.models import Patchcore
from anomalib.engine import Engine
from pytorch_lightning import Trainer
import torch
import logging

logging.basicConfig(level=logging.INFO)

# Assume normal traffic in normal/, anomalous in anomalous/
datamodule = Folder(
    root="../../../data/cyber/network_logs/",
    normal_dir="normal",
    abnormal_dir="anomalous",
    task="classification"
)

model = Patchcore(backbone="wide_resnet50_2")

engine = Engine(
    accelerator="gpu" if torch.cuda.is_available() else "cpu",
    devices=1,
    logger=False
)

# Train on normal data only (unsupervised)
engine.fit(model=model, datamodule=datamodule)

# Save PyTorch model
torch.save(model.state_dict(), '../../../models/cyber/smart_anomaly.pt')
print("Trained and saved smart_anomaly.pt – Ready for real-time network anomaly detection")
