from pathlib import Path
import json


BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_FILE = (
    BASE_DIR / "data" / "messages_v2.json"
)

OUTPUT_FILE = (
    BASE_DIR / "data" / "messages_v3.json"
)


# ==================================================
# ORIGINAL V2 CATEGORY -> NEW MESSAGE TYPE
# ==================================================

def get_category(message, old_category):

    text = message.lower()

    # ----------------------------------------------
    # 1. PHISHING
    # Priority is important.
    # A message containing payment/refund words
    # may still primarily be a phishing attack.
    # ----------------------------------------------

    phishing_words = [
        "http://",
        "https://",
        "www.",
        "kyc",
        "account has been suspended",
        "account will be blocked",
        "verify immediately",
        "claim now",
        "secure your account here",
        "submit bank details",
        "confirm your card details",
        "update payment details",
    ]

    if any(word in text for word in phishing_words):
        return "PHISHING"

    # ----------------------------------------------
    # 2. OTP / SECURITY
    # ----------------------------------------------

    otp_words = [
        "otp",
        "one time password",
        "one-time password",
        "verification code",
        "verification otp",
    ]

    if any(word in text for word in otp_words):
        return "OTP"

    # ----------------------------------------------
    # 3. PAYMENT / UPI
    # ----------------------------------------------

    payment_words = [
        "upi",
        "upi pin",
        "payment",
        "transaction",
        "credited",
        "debited",
        "deducted",
        "refund",
        "cashback",
        "collect request",
        "qr code",
        "credit card",
    ]

    if any(word in text for word in payment_words):
        return "PAYMENT"

    # ----------------------------------------------
    # 4. DELIVERY
    # ----------------------------------------------

    delivery_words = [
        "package",
        "parcel",
        "delivery",
        "dispatched",
        "order",
    ]

    if any(word in text for word in delivery_words):
        return "DELIVERY"

    # ----------------------------------------------
    # 5. PROMOTION
    # ----------------------------------------------

    promotion_words = [
        "discount",
        "sale",
        "offer",
        "buy one get one",
        "promotion",
        "shop now",
        "save big",
    ]

    if any(word in text for word in promotion_words):
        return "PROMOTION"

    # ----------------------------------------------
    # 6. GENERAL
    # ----------------------------------------------

    return "GENERAL"

# ==================================================
# SAFETY LABEL
# ==================================================

def get_safety_label(message, old_category):

    text = message.lower()

    # ----------------------------------------------
    # Original phishing data
    # ----------------------------------------------

    if old_category == "PHISHING":
        return "SCAM"

    # ----------------------------------------------
    # OTP scam patterns
    # ----------------------------------------------

    otp_scam_patterns = [
        "share the otp",
        "send us the otp",
        "provide the otp",
        "tell me the otp",
        "forward it to me",
        "share the otp sent",
    ]

    if any(pattern in text for pattern in otp_scam_patterns):
        return "SCAM"

    # ----------------------------------------------
    # Payment scam patterns
    # ----------------------------------------------

    payment_scam_patterns = [
        "enter your upi pin",
        "scan this qr code",
        "approve the collect request",
        "reward withdrawal",
    ]

    if any(pattern in text for pattern in payment_scam_patterns):
        return "SCAM"

    # ----------------------------------------------
    # Default
    # ----------------------------------------------

    return "SAFE"


# ==================================================
# BUILD DATASET
# ==================================================

def main():

    print(
        "\n===== BUILDING MESSAGE DATASET V3 =====\n"
    )

    with open(
        INPUT_FILE,
        encoding="utf-8",
    ) as file:

        data = json.load(file)

    print(
        f"Loaded V2 dataset: {len(data)} examples"
    )

    final_data = []

    for item in data:

        message = item["message"]
        old_category = item["category"]

        category = get_category(
            message,
            old_category,
        )

        safety_label = get_safety_label(
            message,
            old_category,
        )

        final_data.append(
            {
                "message": message,
                "category": category,
                "safety_label": safety_label,
            }
        )

    # ----------------------------------------------
    # Statistics
    # ----------------------------------------------

    category_counts = {}
    safety_counts = {}

    for item in final_data:

        category = item["category"]
        safety = item["safety_label"]

        category_counts[category] = (
            category_counts.get(category, 0)
            + 1
        )

        safety_counts[safety] = (
            safety_counts.get(safety, 0)
            + 1
        )

    print("\n===== MESSAGE TYPES =====\n")

    for category, count in sorted(
        category_counts.items()
    ):

        print(
            f"{category}: {count}"
        )

    print("\n===== SAFETY LABELS =====\n")

    for safety, count in sorted(
        safety_counts.items()
    ):

        print(
            f"{safety}: {count}"
        )

    # ----------------------------------------------
    # Save
    # ----------------------------------------------

    with open(
        OUTPUT_FILE,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            final_data,
            file,
            indent=2,
            ensure_ascii=False,
        )

    print(
        f"\nSaved V3 dataset:"
    )

    print(
        OUTPUT_FILE
    )

    print(
        "\n===== COMPLETE ====="
    )


if __name__ == "__main__":
    main()
