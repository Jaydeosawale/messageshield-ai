from app.services.analysis_service import analyze_message


class FakeDB:
    def __init__(self):
        self.objects = []

    def add(self, obj):
        self.objects.append(obj)

    def commit(self):
        pass

    def refresh(self, obj):
        # Simulate database-generated values
        obj.id = 1

        if getattr(obj, "created_at", None) is None:
            from datetime import datetime

            obj.created_at = datetime.utcnow()


fake_db = FakeDB()


tests = [
    {
        "message": (
            "Your bank account will be blocked. "
            "Update your KYC immediately."
        ),
        "user_id": 1,
    },
    {
        "message": (
            "Share the OTP sent to your phone "
            "to receive your refund."
        ),
        "user_id": 1,
    },
    {
        "message": (
            "Enter your UPI PIN to receive "
            "₹5,000 cashback."
        ),
        "user_id": 1,
    },
    {
        "message": (
            "Your package has been delivered "
            "successfully."
        ),
        "user_id": 1,
    },
    {
        "message": (
            "Your OTP is 482910. "
            "Do not share it with anyone."
        ),
        "user_id": 1,
    },
    {
        "message": (
            "Let's meet tomorrow at 6 PM."
        ),
        "user_id": 1,
    },
]


print()
print("=" * 70)
print("MESSAGE SHIELD COMPLETE ANALYSIS PIPELINE TEST")
print("=" * 70)


for index, test in enumerate(tests, start=1):

    print()
    print("-" * 70)
    print(f"TEST #{index}")
    print()

    print("INPUT MESSAGE:")
    print(test["message"])

    try:
        result = analyze_message(
            message=test["message"],
            user_id=test["user_id"],
            db=fake_db,
        )

        # ==========================================================
        # REDACTED MESSAGE
        # ==========================================================

        print()
        print("REDACTED MESSAGE:")
        print(result["safe_message"])

        # ==========================================================
        # CATEGORY RESULT
        # ==========================================================

        print()
        print("CATEGORY:")
        print(
            result["category"]["label"]
        )

        print()
        print("CATEGORY CONFIDENCE:")
        print(
            f"{result['category']['confidence']:.4f} "
            f"({result['category']['confidence'] * 100:.2f}%)"
        )

        print()
        print("CATEGORY PROBABILITIES:")

        for label, probability in (
            result["category"]["probabilities"].items()
        ):
            print(
                f"- {label}: "
                f"{probability:.4f} "
                f"({probability * 100:.2f}%)"
            )

        print()
        print("CATEGORY MODEL:")
        print(
            result["category"]["model"]
        )

        # ==========================================================
        # SAFETY RESULT
        # ==========================================================

        print()
        print("SAFETY:")
        print(
            result["safety"]["label"]
        )

        print()
        print("SAFETY CONFIDENCE:")
        print(
            f"{result['safety']['confidence']:.4f} "
            f"({result['safety']['confidence'] * 100:.2f}%)"
        )

        print()
        print("SAFETY PROBABILITIES:")

        for label, probability in (
            result["safety"]["probabilities"].items()
        ):
            print(
                f"- {label}: "
                f"{probability:.4f} "
                f"({probability * 100:.2f}%)"
            )

        print()
        print("SAFETY MODEL:")
        print(
            result["safety"]["model"]
        )

        # ==========================================================
        # RISK RESULT
        # ==========================================================

        print()
        print("FINAL RISK:")
        print(
            result["risk"]["level"]
        )

        print()
        print("RISK SCORE:")
        print(
            result["risk"]["score"]
        )

        print()
        print("RISK SIGNALS:")

        signals = result["risk"].get(
            "signals",
            [],
        )

        if not signals:
            print("- No risk signals detected")

        for signal in signals:

            signal_type = signal.get(
                "type",
                "UNKNOWN",
            )

            signal_score = signal.get(
                "score",
                0,
            )

            print(
                f"- {signal_type} | "
                f"score={signal_score}"
            )

            description = signal.get(
                "description"
            )

            if description:
                print(
                    f"  {description}"
                )

        # ==========================================================
        # DATABASE RESULT
        # ==========================================================

        print()
        print("ANALYSIS ID:")
        print(
            result["id"]
        )

        print()
        print("CREATED AT:")
        print(
            result["created_at"]
        )

    except Exception as error:

        print()
        print("ERROR:")
        print(type(error).__name__)
        print(str(error))


print()
print("=" * 70)
print("COMPLETE PIPELINE TEST FINISHED")
print("=" * 70)