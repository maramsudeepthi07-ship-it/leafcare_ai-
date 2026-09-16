import os
import json

from dotenv import load_dotenv
from openai import OpenAI


# ============================================================
# LOAD ENVIRONMENT
# ============================================================

load_dotenv()


# ============================================================
# OPENAI API KEY
# ============================================================

OPENAI_API_KEY = os.getenv(
    "OPENAI_API_KEY"
)


# ============================================================
# OPENAI CLIENT
# ============================================================

client = None

if OPENAI_API_KEY:
    client = OpenAI(
        api_key=OPENAI_API_KEY
    )
    print(
        "OpenAI Treatment AI configured."
    )
else:
    print(
        "WARNING: OPENAI_API_KEY is not configured."
    )


# ============================================================
# DEFAULT ADVICE
# ============================================================

def default_advice():

    return {

        "treatment": [

            "Isolate the affected plant or avoid spreading infected plant material.",

            "Remove severely affected leaves using clean tools where appropriate.",

            "Avoid excessive watering and prolonged moisture on the leaves.",

            "Monitor the plant closely and confirm the disease before applying a specific chemical treatment.",
        ],

        "prevention": [

            "Inspect plants regularly for spots, discoloration, pests, or unusual growth.",

            "Maintain proper watering and avoid waterlogging.",

            "Maintain good air circulation around plants.",

            "Remove fallen or infected plant material from around the plant.",
        ],
    }


# ============================================================
# GENERATE AI TREATMENT
# ============================================================

def generate_treatment(

    plant_name,
    scientific_name,
    disease,
    disease_confidence,
    symptoms,

):

    # ========================================================
    # CHECK API
    # ========================================================

    if not client:

        return default_advice()


    try:

        print()
        print("=" * 70)
        print("RUNNING OPENAI TREATMENT AI")
        print("=" * 70)


        # ====================================================
        # AI INSTRUCTIONS
        # ====================================================

        prompt = f"""
You are an agricultural plant health assistant.

A plant identification and disease AI system produced the
following result.

Plant:
{plant_name}

Scientific name:
{scientific_name}

Possible disease:
{disease}

Disease confidence:
{disease_confidence}%

Observed symptoms:
{symptoms}


Generate practical and conservative advice.

IMPORTANT RULES:

- The disease diagnosis is not guaranteed.
- Do not claim certainty.
- Give practical treatment actions suitable for a farmer.
- Include cultural and plant-care actions.
- Do not invent pesticide concentrations or chemical dosages.
- Do not recommend illegal or restricted chemicals.
- If chemical treatment may be required, tell the user to
  confirm the disease and follow locally approved agricultural
  guidance and the product label.
- Keep each item short and easy to understand.

Return ONLY valid JSON in exactly this format:

{{
    "treatment": [
        "treatment step",
        "treatment step",
        "treatment step",
        "treatment step"
    ],
    "prevention": [
        "prevention step",
        "prevention step",
        "prevention step",
        "prevention step"
    ]
}}
"""


        # ====================================================
        # OPENAI REQUEST
        # ====================================================

        response = client.responses.create(

            model="gpt-5-mini",

            input=prompt,

            store=False,

            text={
                "format": {
                    "type": "json_object"
                }
            },
        )


        # ====================================================
        # GET OUTPUT
        # ====================================================

        output_text = response.output_text


        print()
        print("OPENAI TREATMENT RESPONSE:")
        print(output_text)


        # ====================================================
        # PARSE JSON
        # ====================================================

        result = json.loads(
            output_text
        )


        treatment = result.get(
            "treatment",
            []
        )


        prevention = result.get(
            "prevention",
            []
        )


        # ====================================================
        # VALIDATE
        # ====================================================

        if not isinstance(
            treatment,
            list
        ):

            treatment = []


        if not isinstance(
            prevention,
            list
        ):

            prevention = []


        treatment = [

            str(item).strip()

            for item in treatment

            if str(item).strip()
        ]


        prevention = [

            str(item).strip()

            for item in prevention

            if str(item).strip()
        ]


        # ====================================================
        # FALLBACK
        # ====================================================

        defaults = default_advice()


        if not treatment:

            treatment = defaults[
                "treatment"
            ]


        if not prevention:

            prevention = defaults[
                "prevention"
            ]


        # ====================================================
        # RETURN RESULT
        # ====================================================

        return {

            "treatment":
                treatment,

            "prevention":
                prevention,
        }


    except Exception as e:

        print()
        print("=" * 70)
        print("OPENAI TREATMENT AI ERROR")
        print("=" * 70)

        print(
            type(e).__name__
        )

        print(
            str(e)
        )

        print("=" * 70)


        return default_advice()