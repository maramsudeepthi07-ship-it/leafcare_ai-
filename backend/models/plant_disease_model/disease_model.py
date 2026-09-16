import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image


MODEL_PATH = os.path.join(
    os.path.dirname(__file__),
    "plant_disease_efficientnet.keras"
)

CLASS_NAMES_PATH = os.path.join(
    os.path.dirname(__file__),
    "class_names.txt"
)


class DiseaseModel:

    def __init__(self):
        print("Loading LeafCare disease model...")

        self.model = tf.keras.models.load_model(MODEL_PATH)

        self.class_names = {}

        with open(CLASS_NAMES_PATH, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()

                if ":" in line:
                    index, name = line.split(":", 1)
                    self.class_names[int(index.strip())] = name.strip()

        print("Disease model loaded successfully.")
        print("Number of classes:", len(self.class_names))

    def predict(self, image_path):

        img = image.load_img(
            image_path,
            target_size=(224, 224)
        )

        img_array = image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)

        # EfficientNet preprocessing
        img_array = tf.keras.applications.efficientnet.preprocess_input(
            img_array
        )

        predictions = self.model.predict(
            img_array,
            verbose=0
        )[0]

        index = int(np.argmax(predictions))
        confidence = float(predictions[index] * 100)

        label = self.class_names.get(
            index,
            f"Unknown class ({index})"
        )

        if "___" in label:
            plant, disease = label.split("___", 1)
        else:
            plant = label
            disease = "Unknown"

        plant = plant.replace("_", " ")
        disease = disease.replace("_", " ")

        return {
            "class_index": index,
            "plant": plant,
            "disease": disease,
            "confidence": round(confidence, 2)
        }


disease_model = DiseaseModel()
