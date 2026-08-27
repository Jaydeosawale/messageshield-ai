from app.services.risk_service import assess_risk


TEST_CASES = [

    {
        "message": (
            "Your bank account will be blocked. "
            "Update your KYC immediately."
        ),
        "category": "BANKING",
        "confidence": 0.85,
        "safety_label": "SCAM",
        "safety_confidence": 0.90,
    },

    {
        "message": (
            "Share the OTP sent to your phone "
            "to receive your refund."
        ),
        "category": "OTP",
        "confidence": 0.90,
        "safety_label": "SCAM",
        "safety_confidence": 0.95,
    },

    {
        "message": (
            "Enter your UPI PIN to receive "
            "₹5,000 cashback."
        ),
        "category": "PAYMENT",
        "confidence": 0.90,
        "safety_label": "SCAM",
        "safety_confidence": 0.92,
    },

    {
        "message": (
            "Your parcel is held. Pay Rs 25 "
            "immediately using this link: "
            "http://delivery-update.xyz"
        ),
        "category": "DELIVERY",
        "confidence": 0.85,
        "safety_label": "SCAM",
        "safety_confidence": 0.88,
    },

    {
        "message": (
            "Your bank account has been credited "
            "with Rs 5,000."
        ),
        "category": "BANKING",
        "confidence": 0.90,
        "safety_label": "SAFE",
        "safety_confidence": 0.85,
    },

    {
        "message": (
            "Your package has been delivered "
            "successfully."
        ),
        "category": "DELIVERY",
        "confidence": 0.90,
        "safety_label": "SAFE",
        "safety_confidence": 0.90,
    },

    {
        "message": (
            "Let's meet tomorrow at 6 PM."
        ),
        "category": "GENERAL",
        "confidence": 0.90,
        "safety_label": "SAFE",
        "safety_confidence": 0.90,
    },
]


print()
print("=" * 70)
print("MESSAGE SHIELD RISK ENGINE TEST")
print("=" * 70)


for index, test in enumerate(
    TEST_CASES,
    start=1,
):

    print()
    print("-" * 70)

    print(f"TEST #{index}")

    print()
    print("MESSAGE:")
    print(test["message"])

    result = assess_risk(
        message=test["message"],
        category=test["category"],
        confidence=test["confidence"],
        safety_label=test["safety_label"],
        safety_confidence=(
            test["safety_confidence"]
        ),
    )

    print()
    print("CATEGORY:")
    print(test["category"])

    print()
    print("SAFETY:")
    print(test["safety_label"])

    print()
    print("FINAL RISK:")
    print(result["risk"])

    print()
    print("RISK SCORE:")
    print(result["risk_score"])

    print()
    print("SIGNALS:")

    for signal in result["signals"]:

        print(
            f"- {signal['type']} "
            f"| score={signal['score']}"
        )

        print(
            f"  {signal['message']}"
        )


print()
print("=" * 70)
print("TEST COMPLETE")
print("=" * 70)
