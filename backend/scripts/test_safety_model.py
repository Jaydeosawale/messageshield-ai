from pathlib import Path
import joblib


# =========================================
# PATHS
# =========================================

BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "safety_model.joblib"
)


# =========================================
# TEST MESSAGES
# =========================================

TEST_MESSAGES = [

    # =====================================
    # UNSEEN SCAM MESSAGES
    # =====================================

    {
        "expected": "SCAM",
        "message": (
            "Your SBI account will be blocked. "
            "Click here immediately to update KYC."
        ),
    },

    {
        "expected": "SCAM",
        "message": (
            "Share the OTP sent to your phone "
            "to receive your refund."
        ),
    },

    {
        "expected": "SCAM",
        "message": (
            "You have won Rs 50,000. "
            "Pay a processing fee to claim your prize."
        ),
    },

    {
        "expected": "SCAM",
        "message": (
            "Enter your UPI PIN to receive cashback."
        ),
    },

    {
        "expected": "SCAM",
        "message": (
            "Your parcel is held. "
            "Pay Rs 25 immediately using this link."
        ),
    },

    # =====================================
    # UNSEEN SAFE MESSAGES
    # =====================================

    {
        "expected": "SAFE",
        "message": (
            "Your bank account has been credited "
            "with Rs 5000."
        ),
    },

    {
        "expected": "SAFE",
        "message": (
            "Your OTP is 482910. "
            "Do not share it with anyone."
        ),
    },

    {
        "expected": "SAFE",
        "message": (
            "Your electricity bill is due next week."
        ),
    },

    {
        "expected": "SAFE",
        "message": (
            "Your Amazon order has been "
            "delivered successfully."
        ),
    },

    {
        "expected": "SAFE",
        "message": (
            "Let's meet at 6 PM tomorrow."
        ),
    },
]


# =========================================
# MAIN
# =========================================

def main():

    # -------------------------------------
    # Load model
    # -------------------------------------

    if not MODEL_PATH.exists():
        raise FileNotFoundError(
            f"Model not found: {MODEL_PATH}"
        )

    model = joblib.load(MODEL_PATH)

    print("\n" + "=" * 70)
    print("MESSAGE SHIELD SAFETY MODEL")
    print("UNSEEN MESSAGE TEST")
    print("=" * 70)

    print("\nModel classes:")
    print(model.classes_)

    total = 0
    correct = 0

    # -------------------------------------
    # Test each message
    # -------------------------------------

    for index, item in enumerate(
        TEST_MESSAGES,
        start=1,
    ):

        message = item["message"]
        expected = item["expected"]

        # Prediction
        prediction = model.predict(
            [message]
        )[0]

        # Probabilities
        probabilities = model.predict_proba(
            [message]
        )[0]

        probability_map = dict(
            zip(
                model.classes_,
                probabilities,
            )
        )

        # Confidence
        confidence = max(
            probabilities
        )

        # Correct / incorrect
        is_correct = (
            prediction == expected
        )

        total += 1

        if is_correct:
            correct += 1

        # ---------------------------------
        # Print result
        # ---------------------------------

        print("\n" + "-" * 70)

        print(f"TEST #{index}")

        print("\nMESSAGE:")
        print(message)

        print("\nEXPECTED:")
        print(expected)

        print("\nPREDICTION:")
        print(prediction)

        print("\nPROBABILITIES:")

        for label, probability in sorted(
            probability_map.items()
        ):
            print(
                f"{label}: "
                f"{probability:.4f} "
                f"({probability * 100:.2f}%)"
            )

        print("\nMODEL CONFIDENCE:")
        print(
            f"{confidence:.4f} "
            f"({confidence * 100:.2f}%)"
        )

        print("\nRESULT:")

        if is_correct:
            print("CORRECT")
        else:
            print("WRONG")

    # =====================================
    # FINAL SUMMARY
    # =====================================

    accuracy = correct / total

    print("\n" + "=" * 70)
    print("FINAL UNSEEN TEST SUMMARY")
    print("=" * 70)

    print(f"\nTotal tests: {total}")
    print(f"Correct:     {correct}")
    print(f"Wrong:       {total - correct}")

    print(
        f"Accuracy:    "
        f"{accuracy:.4f} "
        f"({accuracy * 100:.2f}%)"
    )

    print("\n" + "=" * 70)


# =========================================
# ENTRY POINT
# =========================================

if __name__ == "__main__":
    main()