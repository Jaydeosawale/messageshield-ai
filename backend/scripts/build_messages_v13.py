import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v12.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v13.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V13 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW PAYMENT EXAMPLES
# ==========================================================

new_payment_messages = [

    # ------------------------------------------------------
    # LEGITIMATE PAYMENT SUCCESS
    # ------------------------------------------------------

    "Your payment of Rs 500 was completed successfully.",
    "Payment of Rs 1,250 has been received successfully.",
    "Your transaction for Rs 750 was successful.",
    "Payment completed successfully for your recent purchase.",
    "Your bill payment has been processed successfully.",
    "We have received your payment of Rs 2,000.",
    "Your card payment was completed successfully.",
    "Transaction successful. Rs 1,500 has been paid.",
    "Your utility bill payment has been received.",
    "Payment confirmation: Rs 650 paid successfully.",
    "Your subscription payment was processed successfully.",
    "The transaction amount has been successfully paid.",
    "Your payment has been accepted and confirmed.",
    "Rs 2,500 payment completed successfully.",
    "Your credit card payment was successful.",
    "Payment received. Thank you for your transaction.",

    # ------------------------------------------------------
    # DEBIT / CREDIT NOTIFICATIONS
    # ------------------------------------------------------

    "Rs 500 has been debited from your bank account.",
    "Your account has been credited with Rs 2,000.",
    "An amount of Rs 750 was debited from your account.",
    "Rs 1,200 has been credited to your account.",
    "Your account was debited by ₹999.",
    "An amount of ₹3,000 has been credited successfully.",
    "Rs 450 was deducted from your bank account.",
    "Your account was credited with ₹1,500.",
    "An amount of Rs 600 has been debited successfully.",
    "Your account balance was reduced by Rs 350.",
    "A credit of Rs 2,750 has been received.",
    "Rs 875 was debited from your account.",
    "Your account has been credited with Rs 4,500.",
    "A debit of ₹1,100 was made from your account.",

    # ------------------------------------------------------
    # FAILED / PENDING PAYMENTS
    # ------------------------------------------------------

    "Your payment of Rs 800 could not be completed.",
    "The transaction failed due to insufficient balance.",
    "Your payment is currently pending.",
    "Payment unsuccessful. Please try again later.",
    "Your recent transaction could not be processed.",
    "The payment was declined by your bank.",
    "Your payment could not be completed at this time.",
    "Transaction failed. No amount has been deducted.",
    "Your UPI payment is pending.",
    "The payment was cancelled before completion.",
    "Your recent transaction was declined.",
    "Payment processing is delayed. Please check later.",

    # ------------------------------------------------------
    # LEGITIMATE UPI / DIGITAL PAYMENT
    # ------------------------------------------------------

    "Your UPI payment of Rs 450 was successful.",
    "UPI transaction completed successfully.",
    "Rs 750 was sent successfully through UPI.",
    "Your UPI transfer has been completed.",
    "Payment received through UPI successfully.",
    "Your UPI transaction is pending confirmation.",
    "A UPI payment of ₹1,000 has been processed.",
    "Your digital wallet payment was successful.",
    "Money transfer completed successfully.",
    "Your UPI transaction reference has been generated.",

    # ------------------------------------------------------
    # UPI PIN SCAMS
    # ------------------------------------------------------

    "Enter your UPI PIN to receive your refund.",
    "Provide your UPI PIN to receive Rs 5,000 cashback.",
    "Enter your UPI PIN to accept the refund payment.",
    "Use your UPI PIN to receive the reward amount.",
    "Share your UPI PIN to receive the pending payment.",
    "Enter your UPI PIN to receive the prize money.",
    "Provide the UPI PIN to receive the credited amount.",
    "Enter your PIN to accept the money transfer.",
    "Use your UPI PIN to receive your reward.",
    "Enter your UPI PIN immediately to claim Rs 10,000.",

    # ------------------------------------------------------
    # QR CODE / COLLECT REQUEST SCAMS
    # ------------------------------------------------------

    "Scan this QR code to receive your refund.",
    "Scan the QR code to receive Rs 2,000.",
    "Scan this code to collect your cashback.",
    "Use the QR code to receive your pending refund.",
    "Approve the collect request to receive your money.",
    "Accept the UPI collect request to get your refund.",
    "Approve this collect request to receive Rs 5,000.",
    "Accept the payment request to claim your prize.",
    "Approve the transaction request to receive cashback.",
    "Scan the QR code and enter your PIN to receive payment.",
    "Accept the collect request to receive the credited amount.",

    # ------------------------------------------------------
    # PAYMENT / REWARD / REFUND SCAMS
    # ------------------------------------------------------

    "You have won Rs 10,000. Complete payment verification to receive it.",
    "Pay a small fee to receive your cashback reward.",
    "Your refund requires a verification payment first.",
    "Send Rs 100 to unlock your reward money.",
    "Transfer a small amount to activate your cashback.",
    "Your prize money is ready. Pay the release charge first.",
    "Make a payment now to receive your reward.",
    "Pay the verification amount to complete your refund.",
    "Your cashback will expire unless you complete the payment.",
]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 82

print()
print(
    f"New PAYMENT examples: "
    f"{len(new_payment_messages)}"
)

if len(new_payment_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new PAYMENT examples."
    )


# ==========================================================
# PREVENT DUPLICATES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

new_messages_seen = set()
duplicates = []


for message in new_payment_messages:

    normalized = message.strip().lower()

    if normalized in existing_messages:
        duplicates.append(
            f"Already exists: {message}"
        )

    if normalized in new_messages_seen:
        duplicates.append(
            f"Duplicate inside new examples: {message}"
        )

    new_messages_seen.add(normalized)


if duplicates:

    print()
    print("Duplicate messages found:")

    for message in duplicates:
        print(f"- {message}")

    raise ValueError(
        "New examples contain duplicate messages."
    )


# ==========================================================
# ADD NEW DATA
# ==========================================================

for message in new_payment_messages:

    data.append(
        {
            "message": message,
            "category": "PAYMENT",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

payment_count = sum(
    1
    for item in data
    if item["category"] == "PAYMENT"
)

print()
print(
    f"Final PAYMENT count: "
    f"{payment_count}"
)

if payment_count != 100:
    raise ValueError(
        "Expected final PAYMENT count "
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


# ==========================================================
# FINAL OUTPUT
# ==========================================================

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