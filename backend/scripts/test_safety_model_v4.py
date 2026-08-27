from pathlib import Path
import joblib


BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "safety_model_v4.joblib"
)


def main():

    model = joblib.load(MODEL_PATH)

    tests = [

        # DELIVERY SCAMS
        (
            "Your parcel is held. Pay Rs 25 immediately using this link.",
            "SCAM",
        ),
        (
            "Your package is on hold. Pay Rs 50 immediately to release it.",
            "SCAM",
        ),
        (
            "Delivery failed. Click this link and pay the re-delivery charge.",
            "SCAM",
        ),
        (
            "Customs duty is pending. Pay now to receive your parcel.",
            "SCAM",
        ),
        (
            "Your parcel will be returned unless you pay the processing fee.",
            "SCAM",
        ),

        # SAFE DELIVERY
        (
            "Your package has been delivered successfully.",
            "SAFE",
        ),
        (
            "Your order is expected to arrive tomorrow.",
            "SAFE",
        ),
        (
            "Your shipment has been dispatched.",
            "SAFE",
        ),
        (
            "Delivery agent will arrive between 2 PM and 4 PM.",
            "SAFE",
        ),

        # OTHER SCAMS
        (
            "Share the OTP sent to your phone to receive your refund.",
            "SCAM",
        ),
        (
            "Enter your UPI PIN to receive cashback.",
            "SCAM",
        ),
        (
            "You won Rs 50000. Pay a processing fee to claim your prize.",
            "SCAM",
        ),

        # SAFE
        (
            "Your bank account has been credited with Rs 5000.",
            "SAFE",
        ),
        (
            "Your OTP is 482910. Do not share it with anyone.",
            "SAFE",
        ),
        (
            "Let's meet at 6 PM tomorrow.",
            "SAFE",
        ),
    ]

    classes = model.classes_

    correct = 0
    wrong = 0

    print("\n" + "=" * 70)
    print("MESSAGE SHIELD SAFETY MODEL V4")
    print("UNSEEN MESSAGE TEST")
    print("=" * 70)

    for index, (message, expected) in enumerate(
        tests,
        start=1,
    ):

        probabilities = model.predict_proba([message])[0]

        prediction = model.predict([message])[0]

        probability_map = {
            label: float(probability)
            for label, probability in zip(
                classes,
                probabilities,
            )
        }

        confidence = max(probability_map.values())

        result = (
            "CORRECT"
            if prediction == expected
            else "WRONG"
        )

        if prediction == expected:
            correct += 1
        else:
            wrong += 1

        print("\n" + "-" * 70)
        print(f"TEST #{index}")

        print("\nMESSAGE:")
        print(message)

        print("\nEXPECTED:")
        print(expected)

        print("\nPREDICTION:")
        print(prediction)

        print("\nPROBABILITIES:")

        for label in classes:
            probability = probability_map[label]

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
        print(result)

    total = correct + wrong
    accuracy = correct / total

    print("\n" + "=" * 70)
    print("FINAL UNSEEN TEST SUMMARY")
    print("=" * 70)

    print(f"\nTotal tests: {total}")
    print(f"Correct:     {correct}")
    print(f"Wrong:       {wrong}")
    print(
        f"Accuracy:    "
        f"{accuracy:.4f} "
        f"({accuracy * 100:.2f}%)"
    )

    print("\n" + "=" * 70)


if __name__ == "__main__":
    main()