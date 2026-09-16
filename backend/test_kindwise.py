import os
from dotenv import load_dotenv
from kindwise import PlantApi


# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

load_dotenv()

API_KEY = os.getenv("KINDWISE_API_KEY")


# ============================================================
# CHECK API KEY
# ============================================================

if not API_KEY:
    print("ERROR: KINDWISE_API_KEY was not found in .env")
    raise SystemExit


# ============================================================
# TEST IMAGE
# ============================================================

IMAGE_PATH = "test_leaf.jpg"


if not os.path.exists(IMAGE_PATH):

    print()
    print("=" * 70)
    print("ERROR: TEST IMAGE NOT FOUND")
    print("=" * 70)
    print()
    print("Expected image:")
    print(os.path.abspath(IMAGE_PATH))
    print()
    print("Put an image named test_leaf.jpg")
    print("inside the backend folder.")
    print()

    raise SystemExit


# ============================================================
# START TEST
# ============================================================

print()
print("=" * 70)
print("KINDWISE PLANT HEALTH TEST")
print("=" * 70)
print()

print("Loading API...")


try:

    # ========================================================
    # CREATE KINDWISE API CLIENT
    # ========================================================

    api = PlantApi(
        api_key=API_KEY
    )


    print("Sending leaf image to Kindwise...")
    print()


    # ========================================================
    # HEALTH ASSESSMENT
    # ========================================================

    result = api.health_assessment(
        IMAGE_PATH,
        details=[
            "local_name",
            "description",
            "treatment",
            "cause",
        ],
        full_disease_list=False,
    )


    # ========================================================
    # PRINT HEALTH RESULT
    # ========================================================

    print("=" * 70)
    print("PLANT HEALTH RESULT")
    print("=" * 70)
    print()

    is_healthy = result.result.is_healthy.binary

    healthy_probability = (
        result.result.is_healthy.probability
    )


    print("Is Healthy:", is_healthy)

    print(
        "Healthy Probability:",
        round(healthy_probability * 100, 2),
        "%",
    )


    # ========================================================
    # DISEASE RESULTS
    # ========================================================

    print()
    print("=" * 70)
    print("DISEASE SUGGESTIONS")
    print("=" * 70)


    suggestions = (
        result.result.disease.suggestions
    )


    if not suggestions:

        print()
        print("No disease suggestions returned.")

    else:

        for index, disease in enumerate(
            suggestions,
            start=1,
        ):

            print()
            print("-" * 70)

            print(
                f"DISEASE {index}"
            )

            print("-" * 70)

            print(
                "Name:",
                disease.name,
            )

            print(
                "Confidence:",
                round(
                    disease.probability * 100,
                    2,
                ),
                "%",
            )


            # ------------------------------------------------
            # DETAILS
            # ------------------------------------------------

            details = getattr(
                disease,
                "details",
                None,
            )


            if details:

                if isinstance(
                    details,
                    dict,
                ):

                    print()
                    print(
                        "Cause:",
                        details.get(
                            "cause",
                            "Not available",
                        ),
                    )

                    print(
                        "Description:",
                        details.get(
                            "description",
                            "Not available",
                        ),
                    )

                    print(
                        "Treatment:",
                        details.get(
                            "treatment",
                            "Not available",
                        ),
                    )

                else:

                    print()
                    print(
                        "Details:",
                        details,
                    )


    # ========================================================
    # SUCCESS
    # ========================================================

    print()
    print("=" * 70)
    print("KINDWISE TEST COMPLETED SUCCESSFULLY")
    print("=" * 70)
    print()


# ============================================================
# ERROR HANDLING
# ============================================================

except Exception as e:

    print()
    print("=" * 70)
    print("KINDWISE TEST FAILED")
    print("=" * 70)
    print()

    print(
        "Error type:",
        type(e).__name__,
    )

    print(
        "Error:",
        str(e),
    )

    print()