import os
import base64
import requests

from dotenv import load_dotenv


# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

load_dotenv()


# ============================================================
# KINDWISE API KEY
# ============================================================

KINDWISE_API_KEY = (
    os.getenv("KINDWISE_API_KEY")
    or os.getenv("PLANT_ID_API_KEY")
)


# ============================================================
# KINDWISE PLANT HEALTH API
# ============================================================

API_URL = "https://api.plant.id/v3/health_assessment"


print("=" * 70)
print("Loading Kindwise Plant Health AI...")
print("=" * 70)


if KINDWISE_API_KEY:
    print("Kindwise API key configured.")
else:
    print("WARNING: KINDWISE_API_KEY is not configured.")


print("=" * 70)


# ============================================================
# HELPER FUNCTIONS
# ============================================================

def safe_float(value, default=0.0):
    try:
        return float(value)
    except Exception:
        return default


def safe_list(value):

    if not isinstance(value, list):
        return []

    return [
        str(item).strip()
        for item in value
        if str(item).strip()
    ]


# ============================================================
# DISEASE MODEL
# ============================================================

class DiseaseModel:

    def predict(self, image_path):

        # ====================================================
        # CHECK API KEY
        # ====================================================

        if not KINDWISE_API_KEY:

            return {
                "disease": "Disease analysis unavailable",
                "disease_confidence": 0.0,
                "healthy_probability": 0.0,
                "health_status": "Unable to determine",
                "severity": "Not evaluated",
                "symptoms": "Kindwise API key is not configured.",
                "treatment": [],
                "prevention": [],
            }


        try:

            # ====================================================
            # READ IMAGE
            # ====================================================

            with open(image_path, "rb") as image_file:

                image_bytes = image_file.read()


            # ====================================================
            # CONVERT IMAGE TO BASE64
            # ====================================================

            image_base64 = base64.b64encode(
                image_bytes
            ).decode("utf-8")


            # ====================================================
            # HEADERS
            # ====================================================

            headers = {
                "Api-Key": KINDWISE_API_KEY,
                "Content-Type": "application/json",
            }


            # ====================================================
            # API PAYLOAD
            #
            # IMPORTANT:
            # Do NOT add "details"
            #
            # The API error confirms that "details" is
            # NOT supported by this endpoint/API plan.
            # ====================================================

            payload = {
                "images": [
                    image_base64
                ],

                "health": "only",

                "disease_model": "full",

                "symptoms": True,
            }


            # ====================================================
            # RUN KINDWISE API
            # ====================================================

            print()
            print("=" * 70)
            print("RUNNING KINDWISE PLANT HEALTH AI")
            print("=" * 70)


            response = requests.post(
                API_URL,
                headers=headers,
                json=payload,
                timeout=90,
            )


            print(
                "Kindwise HTTP status:",
                response.status_code
            )


            # ====================================================
            # HANDLE API ERROR
            # ====================================================

            if response.status_code not in (200, 201):

                print()
                print("Kindwise response:")
                print(response.text)


                return {
                    "disease": "Disease analysis unavailable",
                    "disease_confidence": 0.0,
                    "healthy_probability": 0.0,
                    "health_status": "Unable to determine",
                    "severity": "Not evaluated",
                    "symptoms": (
                        "The plant health service could not "
                        "complete the analysis."
                    ),
                    "treatment": [],
                    "prevention": [],
                }


            # ====================================================
            # PARSE RESPONSE
            # ====================================================

            result = response.json()


            print()
            print("=" * 70)
            print("KINDWISE RESPONSE")
            print("=" * 70)
            print(result)
            print("=" * 70)


            # ====================================================
            # GET RESULT
            # ====================================================

            health_result = result.get(
                "result",
                result
            )


            # ====================================================
            # HEALTH STATUS
            # ====================================================

            is_healthy_data = health_result.get(
                "is_healthy",
                {}
            )


            is_healthy = False

            healthy_probability = 0.0


            if isinstance(
                is_healthy_data,
                dict
            ):

                is_healthy = bool(
                    is_healthy_data.get(
                        "binary",
                        False
                    )
                )


                healthy_probability = round(
                    safe_float(
                        is_healthy_data.get(
                            "probability",
                            0.0
                        )
                    ) * 100,
                    2,
                )


            # ====================================================
            # DISEASE DATA
            # ====================================================

            disease_data = health_result.get(
                "disease",
                {}
            )


            if not isinstance(
                disease_data,
                dict
            ):

                disease_data = {}


            suggestions = disease_data.get(
                "suggestions",
                []
            )


            if not isinstance(
                suggestions,
                list
            ):

                suggestions = []


            # ====================================================
            # HEALTHY PLANT
            # ====================================================

            if is_healthy:

                return {
                    "disease": (
                        "No significant disease detected"
                    ),

                    "disease_confidence": 0.0,

                    "healthy_probability":
                        healthy_probability,

                    "health_status":
                        "Healthy",

                    "severity":
                        "None",

                    "symptoms": (
                        "No significant disease symptoms "
                        "were detected in the uploaded leaf."
                    ),

                    "treatment": [],

                    "prevention": [

                        "Continue regular monitoring.",

                        "Provide appropriate water and sunlight.",

                        "Avoid overwatering.",

                        "Maintain proper air circulation.",

                        "Inspect leaves regularly for pests or unusual spots.",
                    ],
                }


            # ====================================================
            # NO DISEASE SUGGESTIONS
            # ====================================================

            if not suggestions:

                return {
                    "disease":
                        "No significant disease detected",

                    "disease_confidence":
                        0.0,

                    "healthy_probability":
                        healthy_probability,

                    "health_status":
                        "No significant disease detected",

                    "severity":
                        "None",

                    "symptoms": (
                        "The AI did not return a significant "
                        "disease suggestion for this image."
                    ),

                    "treatment":
                        [],

                    "prevention": [

                        "Continue monitoring the plant regularly.",

                        "Maintain appropriate watering.",

                        "Ensure good air circulation.",

                        "Check leaves periodically for visible changes.",
                    ],
                }


            # ====================================================
            # TOP DISEASE
            # ====================================================

            top_disease = suggestions[0]


            if not isinstance(
                top_disease,
                dict
            ):

                top_disease = {}


            # ====================================================
            # DISEASE NAME
            # ====================================================

            disease_name = (
                top_disease.get("name")
                or
                "Possible plant health issue"
            )


            # ====================================================
            # DISEASE CONFIDENCE
            # ====================================================

            disease_probability = round(
                safe_float(
                    top_disease.get(
                        "probability",
                        0.0
                    )
                ) * 100,
                2,
            )


            # ====================================================
            # SYMPTOMS
            # ====================================================

            symptoms = ""


            # Direct description
            if isinstance(
                top_disease.get("description"),
                str
            ):

                symptoms = (
                    top_disease.get("description")
                    or ""
                )


            # API symptoms list
            if not symptoms:

                api_symptoms = top_disease.get(
                    "symptoms",
                    []
                )


                if isinstance(
                    api_symptoms,
                    list
                ):

                    symptoms_list = safe_list(
                        api_symptoms
                    )


                    if symptoms_list:

                        symptoms = ", ".join(
                            symptoms_list
                        )


            # Check details if API returns it naturally.
            # We are NOT requesting "details" as a modifier.
            if not symptoms:

                details = top_disease.get(
                    "details",
                    {}
                )


                if isinstance(
                    details,
                    dict
                ):

                    symptoms = (
                        details.get("description")
                        or
                        details.get("cause")
                        or
                        ""
                    )


            # Default symptoms
            if not symptoms:

                symptoms = (
                    f"The AI detected a possible plant "
                    f"health issue: {disease_name}."
                )


            # ====================================================
            # TREATMENT
            #
            # Kindwise health endpoint may not provide treatment
            # details for every API configuration.
            #
            # We only use treatment information if it is actually
            # returned by the API.
            # ====================================================

            treatment = []

            prevention = []


            # ====================================================
            # CHECK DIRECT TREATMENT
            # ====================================================

            direct_treatment = top_disease.get(
                "treatment",
                []
            )


            if isinstance(
                direct_treatment,
                list
            ):

                treatment.extend(
                    safe_list(
                        direct_treatment
                    )
                )


            elif isinstance(
                direct_treatment,
                dict
            ):

                for key in [

                    "biological",
                    "chemical",
                    "physical",
                    "cultural",
                ]:

                    treatment.extend(
                        safe_list(
                            direct_treatment.get(
                                key,
                                []
                            )
                        )
                    )


            # ====================================================
            # CHECK DETAILS IF RETURNED NATURALLY
            # ====================================================

            details = top_disease.get(
                "details",
                {}
            )


            if isinstance(
                details,
                dict
            ):

                details_treatment = details.get(
                    "treatment",
                    {}
                )


                if isinstance(
                    details_treatment,
                    list
                ):

                    treatment.extend(
                        safe_list(
                            details_treatment
                        )
                    )


                elif isinstance(
                    details_treatment,
                    dict
                ):

                    for key in [

                        "biological",
                        "chemical",
                        "physical",
                        "cultural",
                    ]:

                        treatment.extend(
                            safe_list(
                                details_treatment.get(
                                    key,
                                    []
                                )
                            )
                        )


                    prevention.extend(
                        safe_list(
                            details_treatment.get(
                                "prevention",
                                []
                            )
                        )
                    )


            # ====================================================
            # DIRECT PREVENTION
            # ====================================================

            direct_prevention = top_disease.get(
                "prevention",
                []
            )


            prevention.extend(
                safe_list(
                    direct_prevention
                )
            )


            # ====================================================
            # REMOVE DUPLICATES
            # ====================================================

            treatment = list(
                dict.fromkeys(
                    treatment
                )
            )


            prevention = list(
                dict.fromkeys(
                    prevention
                )
            )


            # ====================================================
            # DEFAULT PREVENTION
            # ====================================================

            if not prevention:

                prevention = [

                    "Remove heavily affected leaves if appropriate.",

                    "Avoid excessive watering.",

                    "Maintain good air circulation.",

                    "Avoid spreading contaminated plant material.",

                    "Monitor nearby plants for similar symptoms.",
                ]


            # ====================================================
            # IF API DOES NOT PROVIDE TREATMENT
            # ====================================================

            if not treatment:

                treatment = [

                    (
                        "Isolate the affected plant if the condition "
                        "appears to be spreading."
                    ),

                    (
                        "Remove severely affected leaves using clean "
                        "tools where appropriate."
                    ),

                    (
                        "Improve watering and air circulation "
                        "conditions."
                    ),

                    (
                        "Consult a local agricultural expert before "
                        "applying a disease-specific pesticide or "
                        "fungicide."
                    ),
                ]


            # ====================================================
            # SEVERITY
            # ====================================================

            if disease_probability >= 80:

                severity = "High"

            elif disease_probability >= 50:

                severity = "Moderate"

            else:

                severity = "Low"


            # ====================================================
            # FINAL DISEASE RESULT
            # ====================================================

            return {

                "disease":
                    str(disease_name),

                "disease_confidence":
                    disease_probability,

                "healthy_probability":
                    healthy_probability,

                "health_status":
                    "Disease detected",

                "severity":
                    severity,

                "symptoms":
                    symptoms,

                "treatment":
                    treatment,

                "prevention":
                    prevention,
            }


        # ========================================================
        # ERROR HANDLING
        # ========================================================

        except Exception as e:

            print()
            print("=" * 70)
            print("KINDWISE DISEASE MODEL ERROR")
            print("=" * 70)

            print(
                type(e).__name__
            )

            print(
                str(e)
            )

            print("=" * 70)


            return {

                "disease":
                    "Disease analysis unavailable",

                "disease_confidence":
                    0.0,

                "healthy_probability":
                    0.0,

                "health_status":
                    "Unable to determine",

                "severity":
                    "Not evaluated",

                "symptoms":
                    "The plant health AI analysis could not be completed.",

                "treatment":
                    [],

                "prevention":
                    [],
            }


# ============================================================
# GLOBAL MODEL INSTANCE
# ============================================================

disease_model = DiseaseModel()


print("=" * 70)
print("Kindwise DiseaseModel is ready.")
print("=" * 70)