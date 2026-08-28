import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v6.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v7.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V7 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW DELIVERY EXAMPLES
# ==========================================================

new_delivery_messages = [

    # ------------------------------------------------------
    # NORMAL / LEGITIMATE DELIVERY
    # ------------------------------------------------------

    "Your order has been shipped and is expected to arrive tomorrow.",
    "Your package has been dispatched successfully.",
    "Your parcel is currently out for delivery.",
    "Your shipment will arrive within the next two days.",
    "Your order has reached the nearest delivery center.",
    "Your package has arrived at the local sorting facility.",
    "Your courier is scheduled for delivery today.",
    "Your order was successfully delivered to your address.",
    "Your package was delivered to your registered address.",
    "Your shipment is currently being processed for delivery.",
    "Your order has left the warehouse.",
    "Your parcel is on the way to your location.",
    "Your delivery is scheduled between 2 PM and 6 PM.",
    "Your order will be delivered by tomorrow evening.",
    "Your shipment has reached your city.",
    "Your package is waiting at the local delivery center.",
    "Your courier has been assigned to a delivery agent.",
    "Your order status has been updated to dispatched.",
    "Your package is being prepared for delivery.",
    "Your shipment has been successfully handed to the courier.",
    "Your order is expected to arrive on Monday.",
    "Your parcel will arrive within three working days.",
    "Your package has reached the destination facility.",
    "Your delivery has been rescheduled for tomorrow.",
    "Your courier could not be delivered and will be attempted again tomorrow.",
    "Your package delivery attempt was unsuccessful because no one was available.",
    "Your order is available for pickup at the official delivery center.",
    "Your parcel has been received at the regional warehouse.",
    "Your shipment is moving to the next delivery facility.",
    "Track your order using the official tracking number.",
    "Your delivery address has been confirmed successfully.",
    "Your order is scheduled for dispatch today.",
    "Your parcel is expected to arrive before 8 PM.",
    "Your shipment has cleared the sorting center.",

    # ------------------------------------------------------
    # DELIVERY SCAMS
    # ------------------------------------------------------

    "Your parcel is on hold. Pay Rs 30 immediately to release it.",
    "Your package cannot be delivered until you pay the pending charge.",
    "Pay a small delivery fee now to receive your parcel.",
    "Your shipment is waiting. Pay Rs 50 immediately.",
    "Your package will be returned unless you pay the delivery charge.",
    "Pay the customs fee immediately to receive your international package.",
    "Your courier is blocked. Make a payment now to continue delivery.",
    "Your parcel requires a Rs 25 payment before delivery.",
    "A delivery charge is pending. Pay now to avoid cancellation.",
    "Your package has been stopped. Transfer the handling fee immediately.",
    "Pay the redelivery fee now to schedule another delivery attempt.",
    "Your shipment will be cancelled if the pending fee is not paid today.",
    "Your parcel is waiting for payment confirmation.",
    "A small processing charge is required to release your package.",
    "Pay Rs 99 immediately to prevent your order from being returned.",
    "Your delivery has failed. Send payment to arrange redelivery.",
    "Your package is held due to an unpaid delivery fee.",
    "Transfer money immediately to receive your courier.",
    "Your parcel is blocked. Pay now to avoid permanent cancellation.",
    "Your shipment cannot continue until the service fee is paid.",
    "Pay the delivery charge urgently to avoid losing your package.",
    "Your order is suspended. Complete the payment immediately.",
    "Your parcel requires immediate payment for final delivery.",
    "Send Rs 40 now to release your shipment.",
    "Your courier will be returned today unless payment is completed.",
    "Pay the urgent handling charge to receive your package.",
    "Your package is waiting. Complete the payment to continue delivery.",
    "A final delivery fee is required. Pay immediately.",
    "Your parcel is pending because the delivery charge has not been paid.",
    "Make payment now to prevent your shipment from being cancelled.",
    "Your order is held at the warehouse. Pay the release fee immediately.",
    "Your package requires payment verification before it can be delivered.",
    "Pay now to unlock your parcel delivery.",
    "Your shipment will be destroyed unless the pending fee is paid today.",

]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 68

print()
print(
    f"New DELIVERY examples: "
    f"{len(new_delivery_messages)}"
)

if len(new_delivery_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new DELIVERY examples."
    )


# ==========================================================
# PREVENT DUPLICATES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

duplicates = []

for message in new_delivery_messages:

    normalized = message.strip().lower()

    if normalized in existing_messages:
        duplicates.append(message)


if duplicates:

    print()
    print("Duplicate messages found:")

    for message in duplicates:
        print(f"- {message}")

    raise ValueError(
        "New examples contain duplicates "
        "already present in the dataset."
    )


# ==========================================================
# ADD NEW DATA
# ==========================================================

for message in new_delivery_messages:

    data.append(
        {
            "message": message,
            "category": "DELIVERY",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

delivery_count = sum(
    1
    for item in data
    if item["category"] == "DELIVERY"
)

print()
print(
    f"Final DELIVERY count: "
    f"{delivery_count}"
)

if delivery_count != 100:
    raise ValueError(
        "Expected final DELIVERY count "
        "to be exactly 100."
    )


# ==========================================================
# SAVE DATASET
# ==========================================================

with open(
    OUTPUT_PATH,
    "w",
    encoding="utf-8",
) as file:

    json.dump(
        data,
        file,
        indent=4,
        ensure_ascii=False,
    )


print()
print(
    f"Total dataset examples: "
    f"{len(data)}"
)

print()
print("Dataset saved to:")
print(OUTPUT_PATH)

print()
print("=" * 60)
print("BUILD COMPLETE")
print("=" * 60)