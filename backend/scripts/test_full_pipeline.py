from pathlib import Path
import sys


# ==========================================================
# ADD BACKEND ROOT TO PYTHON PATH
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

sys.path.insert(
    0,
    str(BASE_DIR),
)


# ==========================================================
# IMPORT PIPELINE COMPONENTS
# ==========================================================

from app.ml.classifier import predict_message
from app.ml.safety_classifier import predict_safety
from app.services.risk_service import assess_risk


# ==========================================================
# TEST MESSAGES
# ==========================================================

test_messages = [

    # ------------------------------------------------------
    # SAFE
    # ------------------------------------------------------

    "Hi, shall we meet tomorrow for lunch?",

    "Your electricity bill is due tomorrow.",

    "Your package has been delivered successfully.",

    # ------------------------------------------------------
    # OTP SCAM
    # ------------------------------------------------------

    "I am calling from your bank. Share the OTP immediately.",

    # ------------------------------------------------------
    # PHISHING
    # ------------------------------------------------------

    "Your bank account will be blocked today. Verify immediately at http://fake-bank.xyz",

    # ------------------------------------------------------
    # DELIVERY SCAM
    # ------------------------------------------------------

    "Your parcel is on hold. Pay Rs 50 immediately to release it.",

    # ------------------------------------------------------
    # INVESTMENT SCAM
    # ------------------------------------------------------

    "Invest Rs 5000 today and get guaranteed returns tomorrow.",

    # ------------------------------------------------------
    # JOB SCAM
    # ------------------------------------------------------

    "Congratulations, you are selected for the job. Pay Rs 2000 registration fee now.",

    # ------------------------------------------------------
    # PAYMENT SCAM
    # ------------------------------------------------------

    "Enter your UPI PIN to receive your cashback.",
]


# ==========================================================
# RUN FULL PIPELINE
# ==========================================================

print()
print("=" * 70)
print("MESSAGE SHIELD FULL PIPELINE TEST")
print("=" * 70)


for index, message in enumerate(
    test_messages,
    start=1,
):

    # ======================================================
    # 1. CATEGORY MODEL
    # ======================================================

    category_result = predict_message(
        message
    )

    category = category_result[
        "category"
    ]

    category_confidence = category_result[
        "confidence"
    ]


    # ======================================================
    # 2. SAFETY MODEL
    # ======================================================

    safety_result = predict_safety(
        message
    )

    safety_label = safety_result[
        "safety_label"
    ]

    safety_confidence = safety_result[
        "confidence"
    ]


    # ======================================================
    # 3. RISK ENGINE
    # ======================================================

    risk_result = assess_risk(
        message=message,
        category=category,
        confidence=category_confidence,
        safety_label=safety_label,
        safety_confidence=safety_confidence,
    )


    # ======================================================
    # PRINT RESULT
    # ======================================================

    print()

    print("=" * 70)

    print(
        f"TEST MESSAGE {index}"
    )

    print("=" * 70)

    print()

    print(
        "MESSAGE:"
    )

    print(
        message
    )

    print()

    print(
        "CATEGORY MODEL"
    )

    print(
        f"Category: "
        f"{category}"
    )

    print(
        f"Confidence: "
        f"{category_confidence:.4f}"
    )

    print()

    print(
        "SAFETY MODEL"
    )

    print(
        f"Safety Label: "
        f"{safety_label}"
    )

    print(
        f"Confidence: "
        f"{safety_confidence:.4f}"
    )

    print()

    print(
        "RISK ENGINE"
    )

    print(
        f"Risk: "
        f"{risk_result['risk']}"
    )

    print(
        f"Risk Score: "
        f"{risk_result['risk_score']}"
    )

    print()

    print(
        "DETECTED SIGNALS:"
    )

    for signal in risk_result[
        "signals"
    ]:

        print(
            f"- "
            f"{signal['type']}: "
            f"{signal['message']} "
            f"(+{signal['score']})"
        )


print()

print("=" * 70)
print(
    "FULL PIPELINE TEST COMPLETE"
)
print("=" * 70)