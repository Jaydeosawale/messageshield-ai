from pathlib import Path
import joblib


BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "safety_model_v5.joblib"
)


def main():

    print("\n" + "=" * 70)
    print("MESSAGE SHIELD SAFETY MODEL V5")
    print("REALISTIC UNSEEN MESSAGE TEST")
    print("=" * 70)

    model = joblib.load(MODEL_PATH)

    tests = [

        # --------------------------------------------------
        # BANKING SCAMS
        # --------------------------------------------------
        {
            "message": (
                "Dear customer, your bank account has been frozen "
                "due to suspicious activity. Update your KYC now "
                "to avoid permanent closure."
            ),
            "expected": "SCAM",
        },

        {
            "message": (
                "Your account has been debited Rs 2,500. "
                "If you did not make this transaction, "
                "contact your bank using the official app."
            ),
            "expected": "SAFE",
        },

        # --------------------------------------------------
        # DELIVERY
        # --------------------------------------------------
        {
            "message": (
                "Your parcel could not be delivered. "
                "Pay a small re-delivery fee immediately "
                "to avoid cancellation."
            ),
            "expected": "SCAM",
        },

        {
            "message": (
                "Your shipment has arrived at the local facility "
                "and is scheduled for delivery tomorrow."
            ),
            "expected": "SAFE",
        },

        # --------------------------------------------------
        # OTP
        # --------------------------------------------------
        {
            "message": (
                "I am calling from customer support. "
                "Please tell me the OTP you just received "
                "to verify your identity."
            ),
            "expected": "SCAM",
        },

        {
            "message": (
                "Your verification code is 654321. "
                "Do not share this code with anyone."
            ),
            "expected": "SAFE",
        },

        # --------------------------------------------------
        # UPI / PAYMENT
        # --------------------------------------------------
        {
            "message": (
                "You have won a cashback reward. "
                "Enter your UPI PIN to receive the money."
            ),
            "expected": "SCAM",
        },

        {
            "message": (
                "Your UPI payment of Rs 850 was successful."
            ),
            "expected": "SAFE",
        },

        # --------------------------------------------------
        # JOB SCAMS
        # --------------------------------------------------
        {
            "message": (
                "Congratulations! You have been selected for a job. "
                "Pay Rs 1,999 registration fees today to confirm "
                "your position."
            ),
            "expected": "SCAM",
        },

        {
            "message": (
                "Your interview is scheduled for Friday at 11 AM. "
                "Please join using the official meeting invitation."
            ),
            "expected": "SAFE",
        },

        # --------------------------------------------------
        # INVESTMENT SCAMS
        # --------------------------------------------------
        {
            "message": (
                "Guaranteed 300 percent returns in just 7 days. "
                "Invest today before this exclusive opportunity closes."
            ),
            "expected": "SCAM",
        },

        {
            "message": (
                "Your mutual fund monthly statement is now available "
                "in the official investment app."
            ),
            "expected": "SAFE",
        },

        # --------------------------------------------------
        # IMPERSONATION
        # --------------------------------------------------
        {
            "message": (
                "This is the police department. "
                "Your Aadhaar is connected to illegal activity. "
                "Transfer money immediately for verification."
            ),
            "expected": "SCAM",
        },

        {
            "message": (
                "Reminder: Your government document appointment "
                "is scheduled for next Monday."
            ),
            "expected": "SAFE",
        },

        # --------------------------------------------------
        # GENERAL
        # --------------------------------------------------
        {
            "message": (
                "Hi, I will call you after I finish work."
            ),
            "expected": "SAFE",
        },
    ]

    correct = 0

    for index, test in enumerate(tests, start=1):

        message = test["message"]
        expected = test["expected"]

        probabilities = model.predict_proba([message])[0]
        prediction = model.predict([message])[0]

        classes = model.classes_

        probability_map = {
            label: float(probability)
            for label, probability
            in zip(classes, probabilities)
        }

        confidence = max(probability_map.values())

        print("\n" + "-" * 70)
        print(f"TEST #{index}")

        print("\nMESSAGE:")
        print(message)

        print("\nEXPECTED:")
        print(expected)

        print("\nPREDICTION:")
        print(prediction)

        print("\nPROBABILITIES:")

        for label, probability in probability_map.items():
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

        if prediction == expected:
            print("\nRESULT:")
            print("CORRECT")
            correct += 1
        else:
            print("\nRESULT:")
            print("WRONG")

    total = len(tests)
    accuracy = correct / total

    print("\n" + "=" * 70)
    print("FINAL UNSEEN TEST SUMMARY")
    print("=" * 70)

    print(f"\nTotal tests: {total}")
    print(f"Correct:     {correct}")
    print(f"Wrong:       {total - correct}")
    print(
        f"Accuracy:    {accuracy:.4f} "
        f"({accuracy * 100:.2f}%)"
    )

    print("\n" + "=" * 70)


if __name__ == "__main__":
    main()