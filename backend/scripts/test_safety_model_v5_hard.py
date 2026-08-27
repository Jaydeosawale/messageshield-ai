from pathlib import Path
import joblib


BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_PATH = (
    BASE_DIR
    / "models"
    / "safety_model_v5.joblib"
)


def main():

    print("\n" + "=" * 72)
    print("MESSAGE SHIELD SAFETY MODEL V5")
    print("HARD / ADVERSARIAL UNSEEN TEST")
    print("=" * 72)

    model = joblib.load(MODEL_PATH)

    tests = [

        # ==========================================================
        # 1. SAFE MESSAGES CONTAINING SCAM KEYWORDS
        # ==========================================================

        {
            "message": (
                "Your bank will never ask you to share your OTP "
                "or UPI PIN with anyone."
            ),
            "expected": "SAFE",
            "group": "SAFE_SCAM_KEYWORDS",
        },
        {
            "message": (
                "Beware of fake delivery messages asking you to "
                "pay a fee through suspicious links."
            ),
            "expected": "SAFE",
            "group": "SAFE_SCAM_KEYWORDS",
        },
        {
            "message": (
                "The police have warned citizens about investment "
                "scams promising guaranteed returns."
            ),
            "expected": "SAFE",
            "group": "SAFE_SCAM_KEYWORDS",
        },
        {
            "message": (
                "Do not share your Aadhaar details or bank OTP "
                "with unknown callers."
            ),
            "expected": "SAFE",
            "group": "SAFE_SCAM_KEYWORDS",
        },
        {
            "message": (
                "This message is a security warning: never enter "
                "your UPI PIN to receive money."
            ),
            "expected": "SAFE",
            "group": "SAFE_SCAM_KEYWORDS",
        },

        # ==========================================================
        # 2. SCAMS WITHOUT LINKS
        # ==========================================================

        {
            "message": (
                "I am from your bank. Please confirm the code "
                "sent to your mobile so I can stop the transaction."
            ),
            "expected": "SCAM",
            "group": "NO_LINK_SCAM",
        },
        {
            "message": (
                "Your son has been involved in an emergency. "
                "Send money immediately to help him."
            ),
            "expected": "SCAM",
            "group": "NO_LINK_SCAM",
        },
        {
            "message": (
                "Congratulations, you qualify for a government "
                "benefit. A small processing payment is required."
            ),
            "expected": "SCAM",
            "group": "NO_LINK_SCAM",
        },
        {
            "message": (
                "We found an error in your recent payment. "
                "Approve the request so we can correct it."
            ),
            "expected": "SCAM",
            "group": "NO_LINK_SCAM",
        },
        {
            "message": (
                "You were selected for remote work. "
                "Send the registration amount to begin today."
            ),
            "expected": "SCAM",
            "group": "NO_LINK_SCAM",
        },

        # ==========================================================
        # 3. HINGLISH / INDIAN ENGLISH
        # ==========================================================

        {
            "message": (
                "Aapka bank account block hone wala hai. "
                "Abhi OTP batao."
            ),
            "expected": "SCAM",
            "group": "HINGLISH",
        },
        {
            "message": (
                "Congratulations! Aapne 50,000 rupees jeete hain. "
                "Claim karne ke liye fee pay karo."
            ),
            "expected": "SCAM",
            "group": "HINGLISH",
        },
        {
            "message": (
                "Aapka parcel kal deliver hoga."
            ),
            "expected": "SAFE",
            "group": "HINGLISH",
        },
        {
            "message": (
                "Your OTP is 456789. Kisi ke saath share mat karna."
            ),
            "expected": "SAFE",
            "group": "HINGLISH",
        },

        # ==========================================================
        # 4. SHORT / MINIMAL MESSAGES
        # ==========================================================

        {
            "message": "Send OTP now.",
            "expected": "SCAM",
            "group": "SHORT",
        },
        {
            "message": "Enter UPI PIN.",
            "expected": "SCAM",
            "group": "SHORT",
        },
        {
            "message": "Payment successful.",
            "expected": "SAFE",
            "group": "SHORT",
        },
        {
            "message": "Package delivered.",
            "expected": "SAFE",
            "group": "SHORT",
        },
        {
            "message": "Call me later.",
            "expected": "SAFE",
            "group": "SHORT",
        },

        # ==========================================================
        # 5. MISSPELLINGS / EVASION
        # ==========================================================

        {
            "message": (
                "Ur bank acount wil be blokd. "
                "Shre OTP immediatly."
            ),
            "expected": "SCAM",
            "group": "MISSPELLING",
        },
        {
            "message": (
                "Entar ur UPI PIN to get cashbak."
            ),
            "expected": "SCAM",
            "group": "MISSPELLING",
        },
        {
            "message": (
                "Yor pakage has ben delivrd succesfuly."
            ),
            "expected": "SAFE",
            "group": "MISSPELLING",
        },

        # ==========================================================
        # 6. AMBIGUOUS / CONTEXTUAL
        # ==========================================================

        {
            "message": (
                "A payment request has been received."
            ),
            "expected": "SAFE",
            "group": "AMBIGUOUS",
        },
        {
            "message": (
                "Someone is asking you to approve a payment request."
            ),
            "expected": "SAFE",
            "group": "AMBIGUOUS",
        },
        {
            "message": (
                "Your account needs verification."
            ),
            "expected": "SAFE",
            "group": "AMBIGUOUS",
        },
        {
            "message": (
                "Your account needs verification. "
                "Tell me your OTP immediately."
            ),
            "expected": "SCAM",
            "group": "AMBIGUOUS",
        },

        # ==========================================================
        # 7. LONGER REALISTIC SCENARIOS
        # ==========================================================

        {
            "message": (
                "Dear customer, we detected unusual activity on "
                "your account. For your protection, please do not "
                "share any OTP, password, UPI PIN, or card details "
                "with anyone. Contact the bank through the official "
                "mobile application if you have concerns."
            ),
            "expected": "SAFE",
            "group": "LONG_CONTEXT",
        },
        {
            "message": (
                "Dear customer, we detected unusual activity on "
                "your account. To prevent your account from being "
                "blocked, immediately provide the OTP sent to your "
                "mobile and enter your UPI PIN to verify ownership."
            ),
            "expected": "SCAM",
            "group": "LONG_CONTEXT",
        },

        # ==========================================================
        # 8. IMPERSONATION
        # ==========================================================

        {
            "message": (
                "I am calling from the RBI. Your account is under "
                "investigation. Transfer money for verification."
            ),
            "expected": "SCAM",
            "group": "IMPERSONATION",
        },
        {
            "message": (
                "The bank security team will never ask you to "
                "transfer money to verify your account."
            ),
            "expected": "SAFE",
            "group": "IMPERSONATION",
        },
    ]

    correct = 0
    wrong_tests = []

    for index, test in enumerate(tests, start=1):

        message = test["message"]
        expected = test["expected"]
        group = test["group"]

        probabilities = model.predict_proba(
            [message]
        )[0]

        prediction = model.predict(
            [message]
        )[0]

        probability_map = {
            label: float(probability)
            for label, probability
            in zip(model.classes_, probabilities)
        }

        confidence = max(
            probability_map.values()
        )

        is_correct = prediction == expected

        print("\n" + "-" * 72)
        print(f"TEST #{index}")
        print(f"GROUP: {group}")

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

        print(
            "\nMODEL CONFIDENCE:"
        )

        print(
            f"{confidence:.4f} "
            f"({confidence * 100:.2f}%)"
        )

        if is_correct:
            print("\nRESULT: CORRECT")
            correct += 1
        else:
            print("\nRESULT: WRONG")

            wrong_tests.append({
                "number": index,
                "group": group,
                "message": message,
                "expected": expected,
                "prediction": prediction,
                "confidence": confidence,
            })

    total = len(tests)
    accuracy = correct / total

    print("\n" + "=" * 72)
    print("FINAL HARD TEST SUMMARY")
    print("=" * 72)

    print(f"\nTotal tests: {total}")
    print(f"Correct:     {correct}")
    print(f"Wrong:       {total - correct}")
    print(
        f"Accuracy:    {accuracy:.4f} "
        f"({accuracy * 100:.2f}%)"
    )

    print("\n" + "-" * 72)
    print("FAILURES")
    print("-" * 72)

    if not wrong_tests:
        print(
            "\nNo failures in this test suite."
        )
    else:
        for failure in wrong_tests:
            print(
                f"\nTEST #{failure['number']} "
                f"| {failure['group']}"
            )
            print(
                f"Expected: {failure['expected']}"
            )
            print(
                f"Predicted: {failure['prediction']}"
            )
            print(
                f"Confidence: "
                f"{failure['confidence']:.2%}"
            )
            print(
                f"Message: {failure['message']}"
            )

    print("\n" + "=" * 72)


if __name__ == "__main__":
    main()
