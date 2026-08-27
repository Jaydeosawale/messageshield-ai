import json
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = BASE_DIR / "data" / "messages_v5.json"

OUTPUT_PATH = BASE_DIR / "data" / "messages_v6.json"


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW BANKING EXAMPLES
# ==========================================================

new_banking_messages = [

    # ------------------------------------------------------
    # ACCOUNT STATUS / RESTRICTIONS
    # ------------------------------------------------------

    {
        "message": "Your savings account has been temporarily restricted due to incomplete verification.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Please visit your nearest branch to complete the pending account verification process.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank account has been marked inactive due to no recent transactions.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your account will become dormant if there is no activity for the required period.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your banking profile requires an update to keep your account information current.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your account has been successfully reactivated.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank account is currently active and available for transactions.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your account status has been updated successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The account verification request submitted at your branch has been completed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank account has been placed under temporary review by the bank.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },

    # ------------------------------------------------------
    # KYC / CUSTOMER INFORMATION
    # ------------------------------------------------------

    {
        "message": "Your KYC documents have been verified successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your KYC update request has been received by the bank.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Please ensure that your registered address is updated in your bank records.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your PAN details have been successfully linked with your bank account.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your Aadhaar linking request has been processed successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The bank has updated your registered mobile number successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your email address has been updated in the bank account records.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your customer profile update has been completed successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The bank has received your request to update personal details.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your customer identification details are up to date.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },

    # ------------------------------------------------------
    # BANK STATEMENTS / RECORDS
    # ------------------------------------------------------

    {
        "message": "Your quarterly account statement is now available.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your annual bank account statement has been generated.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank statement for July is ready to view.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "A copy of your account statement has been sent to your registered email address.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your mini statement is available through the official banking service.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your account transaction history has been updated.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The requested account statement has been generated successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your account balance information is available in the official banking app.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank account summary for this month is ready.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your banking records have been updated successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },

    # ------------------------------------------------------
    # DEBIT / ATM CARD
    # ------------------------------------------------------

    {
        "message": "Your new debit card has been successfully activated.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your replacement debit card request has been processed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your ATM card replacement will be delivered to your registered address.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your debit card has been temporarily blocked following your request.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your debit card has been unblocked successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The bank has received your request for a new debit card.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your debit card renewal request is being processed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your ATM card has been successfully linked to your savings account.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your debit card PIN has been generated successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your card delivery request has been registered with the bank.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },

    # ------------------------------------------------------
    # FIXED DEPOSIT / BANK PRODUCTS
    # ------------------------------------------------------

    {
        "message": "Your fixed deposit has been opened successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your fixed deposit certificate is now available.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your fixed deposit will mature next month.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your fixed deposit has been renewed for another term.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The interest earned on your fixed deposit has been credited to your account.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your recurring deposit account has been opened successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your recurring deposit installment schedule has been updated.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank has processed the fixed deposit closure request.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The maturity amount for your deposit will be credited on the scheduled date.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your deposit account details are available in the official banking application.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },

    # ------------------------------------------------------
    # BANK SERVICE REQUESTS
    # ------------------------------------------------------

    {
        "message": "Your cheque book request has been accepted.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your cheque book will be delivered to your registered address.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The bank has successfully processed your cheque stop request.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your branch transfer request has been submitted successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your account closure request has been received by the bank.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your nomination details have been updated successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your request for a bank certificate has been processed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank branch appointment has been confirmed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The bank has registered your service request successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your banking service request is currently being processed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },

    # ------------------------------------------------------
    # SUSPICIOUS BANKING MESSAGES
    # ------------------------------------------------------

    {
        "message": "Your bank account will be closed today unless you verify your details immediately.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your account has been suspended. Update your bank details immediately to restore access.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your bank account is at risk. Provide your card information immediately.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your bank account requires urgent verification to prevent permanent closure.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your debit card will be permanently disabled unless you update your information today.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Suspicious activity has been detected on your account. Confirm your banking details immediately.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your KYC has expired. Update your banking details immediately to avoid account restrictions.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your bank profile must be verified today to continue using your account.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your bank account will be frozen unless your customer details are updated immediately.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your card services have been stopped. Provide your account details to reactivate them.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },



        # ------------------------------------------------------
    # ADDITIONAL BANKING EXAMPLES
    # ------------------------------------------------------

    {
        "message": "Your savings account interest rate has been updated.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank has successfully completed the account upgrade request.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your registered bank account has been verified successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The bank has updated your account operating instructions.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your savings account service request has been completed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank account is eligible for an account type upgrade.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your request to change the bank account nominee has been processed.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "The bank has successfully updated your communication preferences.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank account requires review of the registered customer information.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your banking relationship manager details are available in the official application.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
]


# ==========================================================
# VERIFY EXACTLY 80 NEW EXAMPLES
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V6 BUILDER")
print("=" * 60)

print()
print(
    "New BANKING examples:",
    len(new_banking_messages),
)

if len(new_banking_messages) != 80:
    raise ValueError(
        "Expected exactly 80 new BANKING examples."
    )


# ==========================================================
# PREVENT DUPLICATE MESSAGES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

unique_new_messages = []

for item in new_banking_messages:

    normalized = (
        item["message"]
        .strip()
        .lower()
    )

    if normalized not in existing_messages:
        unique_new_messages.append(item)
        existing_messages.add(normalized)

    else:
        print()
        print(
            "Duplicate skipped:"
        )
        print(
            item["message"]
        )


# ==========================================================
# ADD NEW EXAMPLES
# ==========================================================

data.extend(
    unique_new_messages
)


# ==========================================================
# SAVE DATASET V6
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
# FINAL VERIFICATION
# ==========================================================

banking_count = sum(
    1
    for item in data
    if item["category"] == "BANKING"
)

print()
print(
    "Final BANKING count:",
    banking_count,
)

print(
    "Total dataset examples:",
    len(data),
)

print()
print(
    "Dataset saved to:"
)

print(
    OUTPUT_PATH
)

print()
print("=" * 60)
print("BUILD COMPLETE")
print("=" * 60)
