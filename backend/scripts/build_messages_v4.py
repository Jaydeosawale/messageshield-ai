from pathlib import Path
from collections import Counter
import json


# =========================================
# PATHS
# =========================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v3.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v4.json"
)


# =========================================
# NEW DELIVERY DATA
# =========================================

NEW_MESSAGES = [

    # =====================================
    # DELIVERY SCAMS
    # =====================================

    {
        "message": "Your parcel is held. Pay Rs 25 immediately using this link.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your package is on hold. Pay the delivery fee to release it.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Delivery failed. Pay a redelivery charge immediately.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your parcel cannot be delivered until you pay the pending fee.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your shipment is waiting. Click the link and pay the delivery charge.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Pay Rs 10 now to schedule redelivery of your package.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your courier package will be returned unless payment is completed today.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "A small handling charge is required before your parcel can be delivered.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your parcel is waiting at the warehouse. Pay the pending charge now.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Customs payment is required to release your shipment. Pay immediately.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your delivery is suspended due to an unpaid fee. Complete payment now.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your package will be returned today. Pay the delivery fee to stop it.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Action required: pay the courier charge before your parcel is released.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Your shipment is blocked. Verify payment immediately to continue delivery.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },
    {
        "message": "Final notice: pay the small delivery charge to receive your package.",
        "safety_label": "SCAM",
        "category": "DELIVERY",
    },

    # =====================================
    # LEGITIMATE DELIVERY
    # =====================================

    {
        "message": "Your package has been shipped successfully.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your parcel is out for delivery today.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your order has been delivered successfully.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your shipment is expected to arrive tomorrow.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your delivery has been delayed due to weather conditions.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your package is available for pickup at the selected location.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "A delivery attempt was unsuccessful. The courier will try again tomorrow.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your shipment has reached the local delivery center.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Track your order using the tracking number in your official order details.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your courier has collected the package from the sender.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your order is being prepared for delivery.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your parcel has arrived at the destination sorting facility.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Delivery is scheduled between 2 PM and 5 PM tomorrow.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your package has been handed to the delivery partner.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
    {
        "message": "Your order is ready and will be dispatched soon.",
        "safety_label": "SAFE",
        "category": "DELIVERY",
    },
]


# =========================================
# MAIN
# =========================================

def main():

    print("\n===== BUILDING MESSAGE DATASET V4 =====\n")

    if not INPUT_PATH.exists():
        raise FileNotFoundError(
            f"V3 dataset not found: {INPUT_PATH}"
        )

    with open(INPUT_PATH, "r", encoding="utf-8") as file:
        data = json.load(file)

    print(f"Loaded V3 dataset: {len(data)} examples")

    print(
        f"New delivery examples: {len(NEW_MESSAGES)}"
    )

    combined = data + NEW_MESSAGES

    print(
        f"Before deduplication: {len(combined)}"
    )

    # -------------------------------------
    # Remove exact duplicate messages
    # -------------------------------------

    unique = []
    seen_messages = set()

    for item in combined:

        message = (
            item["message"]
            .strip()
            .lower()
        )

        if message not in seen_messages:

            seen_messages.add(message)

            unique.append(item)

    print(
        f"After deduplication: {len(unique)}"
    )

    # -------------------------------------
    # Statistics
    # -------------------------------------

    category_counts = Counter(
        item["category"]
        for item in unique
    )

    safety_counts = Counter(
        item["safety_label"]
        for item in unique
    )

    print("\n===== CATEGORY COUNTS =====\n")

    for category, count in sorted(
        category_counts.items()
    ):
        print(
            f"{category}: {count}"
        )

    print("\n===== SAFETY LABEL COUNTS =====\n")

    for label, count in sorted(
        safety_counts.items()
    ):
        print(
            f"{label}: {count}"
        )

    # -------------------------------------
    # Save
    # -------------------------------------

    with open(
        OUTPUT_PATH,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            unique,
            file,
            indent=2,
            ensure_ascii=False,
        )

    print(
        "\nSaved V4 dataset:"
    )

    print(OUTPUT_PATH)

    print(
        "\n===== COMPLETE =====\n"
    )


if __name__ == "__main__":
    main()
