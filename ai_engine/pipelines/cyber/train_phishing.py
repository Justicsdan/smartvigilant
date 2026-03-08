from transformers import AutoTokenizer, TFAutoModelForSequenceClassification
import tensorflow as tf

tokenizer = AutoTokenizer.from_pretrained("distilbert-base-uncased")
model = TFAutoModelForSequenceClassification.from_pretrained("distilbert-base-uncased", num_labels=2)

# Example phishing/benign texts
texts = ["Click here to claim your prize!", "Meeting rescheduled to 3 PM.", "Your account has been compromised"] * 300
labels = [1, 0, 1] * 300  # 1 = phishing, 0 = legit

encodings = tokenizer(texts, truncation=True, padding=True, max_length=128, return_tensors="tf")
dataset = tf.data.Dataset.from_tensor_slices((dict(encodings), labels)).shuffle(1000).batch(16)

model.compile(optimizer=tf.keras.optimizers.Adam(5e-5),
              loss=model.compute_loss,
              metrics=['accuracy'])

model.fit(dataset, epochs=3)

# Save weights
model.save_weights('../../../models/cyber/smart_phishing.h5')
print("✅ smart_phishing.h5 successfully saved!")
