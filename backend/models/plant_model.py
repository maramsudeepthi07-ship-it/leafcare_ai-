import os
import torch
from PIL import Image
from transformers import AutoImageProcessor, AutoModelForImageClassification


MODEL_NAME = "gerald29/plantclef2024"

print("Loading PlantCLEF AI model...")

processor = AutoImageProcessor.from_pretrained(MODEL_NAME)
model = AutoModelForImageClassification.from_pretrained(MODEL_NAME)

model.eval()

print("PlantCLEF AI model loaded successfully.")
print("Number of plant classes:", model.config.num_labels)


class PlantModel:

    def predict(self, image_path):

        image = Image.open(image_path).convert("RGB")

        inputs = processor(
            images=image,
            return_tensors="pt"
        )

        with torch.no_grad():
            outputs = model(**inputs)

        probabilities = torch.nn.functional.softmax(
            outputs.logits,
            dim=-1
        )

        confidence, index = torch.max(probabilities, dim=-1)

        confidence = float(confidence.item())
        index = int(index.item())

        label = model.config.id2label.get(
            index,
            f"Unknown plant ({index})"
        )

        return {
            "plant": label,
            "confidence": round(confidence * 100, 2)
        }


plant_model = PlantModel()