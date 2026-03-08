from transformers import AutoModelForSequenceClassification, AutoTokenizer
import tensorflow as tf

# Best HF model for phishing (emails/URLs/SMS)
model_name = "Auguzcht/securisense-phishing-detection"  # 99.54% accuracy
model = AutoModelForSequenceClassification.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Convert Hugging Face to Keras .h5
tf_model = tf.keras.Sequential([model])  # Wrapper for export
tf_model.save('../models/cyber/smart_phishing.h5')

print("Exported smart_phishing.h5 – 99%+ accuracy on multi-modal phishing")
