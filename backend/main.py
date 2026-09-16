from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from PIL import Image
from dotenv import load_dotenv

from models.disease_model import disease_model
from models.treatment_ai import generate_treatment

import os
import io
import requests
import tempfile


# ============================================================
# LOAD ENVIRONMENT
# ============================================================

load_dotenv()


PLANTNET_API_KEY = os.getenv(
    "PLANTNET_API_KEY"
)


# ============================================================
# PLANTNET URL
# ============================================================

PLANTNET_URL = (
    "https://my-api.plantnet.org/v2/identify/k-world-flora"
)


# ============================================================
# FASTAPI APP
# ============================================================

app = FastAPI(
    title="LeafCare AI Backend"
)


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# HOME
# ============================================================

@app.get("/")
def home():

    return {

        "status":
            "success",

        "message":
            "LeafCare AI backend is running",

        "ai_service":
            "PlantNet + Kindwise",
    }


# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/health")
def health():

    return {

        "status":
            "healthy",

        "plantnet_configured":
            bool(PLANTNET_API_KEY),

        "kindwise_configured":
            disease_model is not None,
    }


# ============================================================
# PREDICT / ANALYZE LEAF
# ============================================================

@app.post("/predict")
async def predict(
    file: UploadFile = File(...)
):

    # ========================================================
    # CHECK PLANTNET API KEY
    # ========================================================

    if not PLANTNET_API_KEY:

        return {

            "success":
                False,

            "message":
                "PlantNet API key is not configured.",

            "error":
                "API_KEY_MISSING",
        }


    try:

        # ====================================================
        # READ IMAGE
        # ====================================================

        image_data = await file.read()


        if not image_data:

            return {

                "success":
                    False,

                "message":
                    "No image was received.",

                "error":
                    "EMPTY_IMAGE",
            }


        print()
        print("=" * 70)
        print("LEAF ANALYSIS REQUEST")
        print("=" * 70)

        print(
            "AI SERVICE: PlantNet + Kindwise"
        )

        print(
            "PROJECT: World flora"
        )

        print(
            "Filename:",
            file.filename
        )

        print(
            "Content type:",
            file.content_type
        )

        print(
            "Image size:",
            len(image_data),
            "bytes"
        )


        # ====================================================
        # VALIDATE IMAGE
        # ====================================================

        try:

            image = Image.open(
                io.BytesIO(image_data)
            )

            image.verify()


        except Exception as e:

            print(
                "IMAGE VALIDATION ERROR:",
                e
            )

            return {

                "success":
                    False,

                "message":
                    "Invalid image file.",

                "error":
                    "INVALID_IMAGE",

                "details":
                    str(e),
            }


        # ====================================================
        # GET IMAGE INFORMATION
        # ====================================================

        try:

            image = Image.open(
                io.BytesIO(image_data)
            )

            print(
                "Image format:",
                image.format
            )

            print(
                "Image size:",
                image.size
            )


        except Exception:

            pass


        # ====================================================
        # PLANTNET REQUEST
        # ====================================================

        print()

        print(
            "Sending request to PlantNet..."
        )


        params = {

            "api-key":
                PLANTNET_API_KEY,
        }


        files = {

            "images": (

                file.filename
                or "leaf.jpg",

                image_data,

                file.content_type
                or "image/jpeg",
            ),
        }


        response = requests.post(

            PLANTNET_URL,

            params=params,

            data={

                "organs":
                    "leaf",
            },

            files=files,

            timeout=90,
        )


        # ====================================================
        # PRINT PLANTNET STATUS
        # ====================================================

        print()

        print(
            "PlantNet HTTP STATUS:",
            response.status_code
        )


        # ====================================================
        # HANDLE PLANTNET ERROR
        # ====================================================

        if response.status_code not in (
            200,
            201,
        ):

            print(
                "PlantNet ERROR:"
            )

            print(
                response.text[:5000]
            )


            return {

                "success":
                    False,

                "message":
                    "PlantNet rejected the request.",

                "error":
                    "PLANTNET_API_ERROR",

                "status_code":
                    response.status_code,

                "details":
                    response.text,
            }


        # ====================================================
        # PARSE PLANTNET JSON
        # ====================================================

        try:

            data = response.json()


        except Exception as e:

            return {

                "success":
                    False,

                "message":
                    "PlantNet returned invalid JSON.",

                "error":
                    "INVALID_API_RESPONSE",

                "details":
                    str(e),

                "raw_response":
                    response.text[:5000],
            }


        # ====================================================
        # IDENTIFICATION RESULTS
        # ====================================================

        results = data.get(
            "results",
            []
        )


        if not results:

            return {

                "success":
                    False,

                "message":
                    (
                        "PlantNet could not identify "
                        "this plant."
                    ),

                "error":
                    "NO_IDENTIFICATION",
            }


        # ====================================================
        # TOP PLANT RESULT
        # ====================================================

        top_result = results[0]


        try:

            score = float(

                top_result.get(
                    "score",
                    0.0,
                )
            )


        except Exception:

            score = 0.0


        species = top_result.get(
            "species",
            {}
        )


        # ====================================================
        # SCIENTIFIC NAME
        # ====================================================

        scientific_name = (

            species.get(
                "scientificNameWithoutAuthor"
            )

            or

            species.get(
                "scientificName"
            )

            or

            "Unknown plant"
        )


        # ====================================================
        # COMMON NAMES
        # ====================================================

        common_names = species.get(
            "commonNames",
            []
        )


        if isinstance(
            common_names,
            list
        ):

            common_names = [

                str(name).strip()

                for name
                in common_names

                if str(name).strip()
            ]


        else:

            common_names = []


        # ====================================================
        # DISPLAY PLANT NAME
        # ====================================================

        if common_names:

            plant_name = (
                common_names[0]
            )


        else:

            plant_name = (
                scientific_name
            )


        # ====================================================
        # PLANT CONFIDENCE
        # ====================================================

        confidence = round(
            score * 100,
            2
        )


        # ====================================================
        # IDENTIFICATION STATUS
        # ====================================================

        if score >= 0.80:

            identification_status = (
                "High confidence"
            )


        elif score >= 0.50:

            identification_status = (
                "Moderate confidence"
            )


        elif score >= 0.25:

            identification_status = (
                "Low confidence"
            )


        else:

            identification_status = (
                "Very low confidence"
            )


        # ====================================================
        # ALTERNATIVE PLANTS
        # ====================================================

        alternatives = []


        for item in results[:5]:

            item_species = item.get(
                "species",
                {}
            )


            # ------------------------------------------------
            # SCIENTIFIC NAME
            # ------------------------------------------------

            item_scientific_name = (

                item_species.get(
                    "scientificNameWithoutAuthor"
                )

                or

                item_species.get(
                    "scientificName"
                )

                or

                "Unknown"
            )


            # ------------------------------------------------
            # COMMON NAMES
            # ------------------------------------------------

            item_common_names = (

                item_species.get(
                    "commonNames",
                    []
                )
            )


            if isinstance(
                item_common_names,
                list
            ):

                item_common_names = [

                    str(name).strip()

                    for name
                    in item_common_names

                    if str(name).strip()
                ]


            else:

                item_common_names = []


            # ------------------------------------------------
            # CONFIDENCE
            # ------------------------------------------------

            try:

                item_score = float(

                    item.get(
                        "score",
                        0.0,
                    )
                )


            except Exception:

                item_score = 0.0


            # ------------------------------------------------
            # ADD ALTERNATIVE
            # ------------------------------------------------

            alternatives.append(

                {

                    "name":

                        (

                            item_common_names[0]

                            if item_common_names

                            else item_scientific_name
                        ),

                    "scientific_name":
                        item_scientific_name,

                    "confidence":

                        round(
                            item_score * 100,
                            2,
                        ),
                }
            )


        # ====================================================
        # DISEASE ANALYSIS
        # ====================================================

        print()
        print("=" * 70)

        print(
            "RUNNING KINDWISE PLANT HEALTH AI"
        )

        print("=" * 70)


        disease_result = None

        temp_image_path = None


        try:

            # ------------------------------------------------
            # CREATE TEMPORARY IMAGE
            # ------------------------------------------------

            suffix = ".jpg"


            if file.filename:

                extension = os.path.splitext(
                    file.filename
                )[1]


                if extension:

                    suffix = extension


            temp_file = tempfile.NamedTemporaryFile(

                delete=False,

                suffix=suffix,
            )


            temp_image_path = (
                temp_file.name
            )


            temp_file.write(
                image_data
            )


            temp_file.close()


            # ------------------------------------------------
            # RUN KINDWISE DISEASE MODEL
            # ------------------------------------------------

            disease_result = (
                disease_model.predict(
                    temp_image_path
                )
            )


            print()

            print(
                "DISEASE RESULT:"
            )

            print(
                disease_result
            )


        except Exception as e:

            print()

            print(
                "DISEASE MODEL ERROR:"
            )

            print(
                type(e).__name__
            )

            print(
                str(e)
            )


            disease_result = {

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
                    (
                        "The plant health analysis "
                        "could not be completed."
                    ),

                "treatment":
                    [],

                "prevention":
                    [],
            }


        finally:

            # ------------------------------------------------
            # DELETE TEMP IMAGE
            # ------------------------------------------------

            if (

                temp_image_path

                and

                os.path.exists(
                    temp_image_path
                )
            ):

                try:

                    os.remove(
                        temp_image_path
                    )


                except Exception:

                    pass


        # ====================================================
        # ENSURE DISEASE RESULT EXISTS
        # ====================================================

        if disease_result is None:

            disease_result = {

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
                    "No health result available.",

                "treatment":
                    [],

                "prevention":
                    [],
            }


        # ====================================================
        # EXTRACT DISEASE RESULT
        # ====================================================

        disease = disease_result.get(

            "disease",

            "Disease analysis unavailable"
        )


        disease_confidence = float(

            disease_result.get(
                "disease_confidence",
                0.0,
            )
        )


        healthy_probability = float(

            disease_result.get(
                "healthy_probability",
                0.0,
            )
        )


        health_status = disease_result.get(

            "health_status",

            "Unable to determine"
        )


        severity = disease_result.get(

            "severity",

            "Not evaluated"
        )


        symptoms = disease_result.get(
            "symptoms",
            ""
        )


        treatment = disease_result.get(
            "treatment",
            []
        )


        prevention = disease_result.get(
            "prevention",
            []
        )


        # ====================================================
        # OPENAI AI TREATMENT
        # ====================================================

        disease_text = str(disease).lower()


        disease_unavailable = (
            "unavailable" in disease_text
            or "unable to determine" in str(
                health_status
            ).lower()
        )


        healthy_result = (
            health_status == "Healthy"
            or "no significant disease" in disease_text
        )


        # Generate AI treatment only when a possible disease
        # has actually been detected.
        if not disease_unavailable and not healthy_result:

            print()
            print("=" * 70)
            print("GENERATING AI TREATMENT ADVICE")
            print("=" * 70)


            ai_advice = generate_treatment(

                plant_name=plant_name,

                scientific_name=scientific_name,

                disease=disease,

                disease_confidence=disease_confidence,

                symptoms=symptoms,
            )


            # Replace existing treatment with AI-generated advice

            treatment = ai_advice.get(
                "treatment",
                treatment,
            )


            prevention = ai_advice.get(
                "prevention",
                prevention,
            )


        # ====================================================
        # DEFAULT HEALTH MESSAGE
        # ====================================================

        if not symptoms:

            if health_status == "Healthy":

                symptoms = (

                    "No significant signs of disease "
                    "were detected in the uploaded leaf."
                )


            elif health_status == (
                "Disease detected"
            ):

                symptoms = (

                    f"The AI detected "
                    f"'{disease}' with "

                    f"approximately "
                    f"{disease_confidence:.2f}% "

                    "confidence."
                )


            else:

                symptoms = (

                    "The disease model could not "
                    "reliably determine the health "
                    "condition of this leaf."
                )


        # ====================================================
        # DEFAULT PREVENTION
        # ====================================================

        if not prevention:

            if health_status == "Healthy":

                prevention = [

                    "Continue regular monitoring.",

                    "Provide appropriate water and sunlight.",

                    "Inspect leaves regularly for pests.",

                    "Maintain proper air circulation.",
                ]


        # ====================================================
        # FINAL RESPONSE
        # ====================================================

        final_response = {


            # ------------------------------------------------
            # SUCCESS
            # ------------------------------------------------

            "success":
                True,


            # ------------------------------------------------
            # PLANT IDENTIFICATION
            # ------------------------------------------------

            "plant":
                plant_name,

            "common_name":
                plant_name,

            "scientific_name":
                scientific_name,

            "confidence":
                confidence,

            "plant_confidence":
                confidence,

            "identification_status":
                identification_status,


            # ------------------------------------------------
            # ALTERNATIVES
            # ------------------------------------------------

            "alternatives":
                alternatives,


            # ------------------------------------------------
            # DISEASE INFORMATION
            # ------------------------------------------------

            "disease":
                disease,

            "disease_confidence":
                disease_confidence,

            "healthy_probability":
                healthy_probability,

            "health_status":
                health_status,

            "severity":
                severity,


            # ------------------------------------------------
            # INFORMATION
            # ------------------------------------------------

            "symptoms":
                symptoms,

            "treatment":
                treatment,

            "prevention":
                prevention,


            # ------------------------------------------------
            # EXPERT ADVICE
            # ------------------------------------------------

            "expert_advice":

                (

                    "Plant identification is "
                    "performed by PlantNet and "
                    "plant health analysis is "
                    "performed by Kindwise AI. "

                    "AI results should be treated "
                    "as an indication and not a "
                    "guaranteed diagnosis."
                ),


            # ------------------------------------------------
            # MESSAGE
            # ------------------------------------------------

            "message":

                (

                    "Plant identification and "
                    "health analysis completed "
                    "successfully."
                ),
        }


        # ====================================================
        # PRINT FINAL RESULT
        # ====================================================

        print()

        print("=" * 70)

        print(
            "FINAL RESULT"
        )

        print("=" * 70)

        print(
            final_response
        )

        print("=" * 70)

        print()


        return final_response


    # ========================================================
    # TIMEOUT ERROR
    # ========================================================

    except requests.exceptions.Timeout:

        print(
            "ERROR: PlantNet request timed out."
        )


        return {

            "success":
                False,

            "message":

                (

                    "PlantNet request timed out. "
                    "Please try again."
                ),

            "error":
                "API_TIMEOUT",
        }


    # ========================================================
    # CONNECTION ERROR
    # ========================================================

    except requests.exceptions.ConnectionError as e:

        print(

            "ERROR: Could not connect "
            "to PlantNet:",

            e,
        )


        return {

            "success":
                False,

            "message":

                (

                    "Could not connect "
                    "to PlantNet."
                ),

            "error":
                "API_CONNECTION_ERROR",

            "details":
                str(e),
        }


    # ========================================================
    # REQUEST ERROR
    # ========================================================

    except requests.exceptions.RequestException as e:

        print(
            "REQUEST ERROR:",
            e
        )


        return {

            "success":
                False,

            "message":
                "PlantNet request failed.",

            "error":
                "API_REQUEST_ERROR",

            "details":
                str(e),
        }


    # ========================================================
    # GENERAL ERROR
    # ========================================================

    except Exception as e:

        print()

        print("=" * 70)

        print(
            "BACKEND ERROR"
        )

        print("=" * 70)

        print(
            type(e).__name__
        )

        print(
            str(e)
        )

        print("=" * 70)

        print()


        return {

            "success":
                False,

            "message":
                "Prediction failed.",

            "error":
                type(e).__name__,

            "details":
                str(e),
        }