# 🌿 LeafCare AI

> AI-Powered Plant Identification & Leaf Disease Detection System

LeafCare AI is an AI-powered mobile application designed to help farmers, gardeners, and plant enthusiasts identify plants, detect leaf diseases, and receive intelligent treatment recommendations from a plant image.

The application combines a **Flutter mobile frontend** with a **FastAPI backend** and AI-powered plant and disease analysis services.

---

## 🚀 Features

### 🌱 AI Plant Identification
- Capture or upload a plant/leaf image.
- Analyze the image using AI.
- Identify the most likely plant species.
- Display plant information and identification results.

### 🦠 Leaf Disease Detection
- Analyze plant leaves for possible diseases.
- Detect disease conditions from uploaded images.
- Display disease information and confidence information where available.

### 💊 AI Treatment Recommendations
- Generate treatment guidance based on the detected plant/disease.
- Provide practical recommendations for plant care.
- Uses AI-assisted analysis for treatment suggestions.

### 📱 Flutter Mobile Application
- Modern mobile interface.
- Farmer-friendly navigation.
- Plant scanning workflow.
- History and profile sections.
- Responsive UI.

### ⚡ FastAPI Backend
- REST API for image analysis.
- Handles plant identification.
- Handles disease detection.
- Connects AI services with the Flutter application.

---

## 🏗️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application |
| Dart | Flutter programming language |
| FastAPI | Backend REST API |
| Python | Backend development |
| Kindwise | Plant/disease AI services |
| PlantNet | Plant identification |
| OpenAI | AI treatment recommendations |
| Firebase | Application services |
| Git & GitHub | Version control |

---

## 📂 Project Structure

```text
leafcare_ai/
│
├── android/                 # Android application files
├── ios/                     # iOS application files
├── web/                     # Web application files
├── windows/                 # Windows application files
│
├── lib/
│   ├── data/
│   ├── models/
│   ├── screens/
│   ├── firebase_options.dart
│   └── main.dart
│
├── backend/
│   ├── models/
│   │   ├── plant_disease_model/
│   │   ├── disease_model.py
│   │   ├── plant_model.py
│   │   └── treatment_ai.py
│   └── ...
│
├── .gitignore
├── pubspec.yaml
└── README.md