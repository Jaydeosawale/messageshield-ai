import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v13.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v14.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V14 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW PHISHING EXAMPLES
# ==========================================================

new_phishing_messages = [

    # ------------------------------------------------------
    # BANK / KYC PHISHING
    # ------------------------------------------------------

    "Your bank account has been suspended. Verify your identity at http://bank-verify-now.xyz",
    "Update your KYC immediately using http://secure-kyc-update.xyz",
    "Your account will be blocked today. Confirm your details at http://account-check.xyz",
    "Unusual activity was detected. Secure your account at http://bank-security.xyz",
    "Your bank login has expired. Sign in again at http://secure-login.xyz",
    "Verify your PAN details immediately at http://pan-verification.xyz",
    "Your account needs urgent verification. Visit http://verify-account.xyz",
    "Update your banking information at http://bank-update.xyz",
    "Your debit card has been temporarily blocked. Reactivate it at http://card-reactivate.xyz",
    "Confirm your account information at http://customer-verify.xyz",
    "Your KYC verification is pending. Complete it at http://kyc-complete.xyz",
    "Your bank account will be frozen. Verify now at http://account-secure.xyz",
    "We detected suspicious activity. Confirm your identity at http://security-check.xyz",
    "Your account requires immediate action. Visit http://urgent-bank-update.xyz",
    "Your banking profile is incomplete. Update it at http://profile-update.xyz",
    "Verify your registered mobile number at http://mobile-verify.xyz",
    "Your account access will expire. Renew it at http://account-renew.xyz",
    "Confirm your bank details to avoid account suspension at http://verify-bank.xyz",

    # ------------------------------------------------------
    # REWARD / PRIZE PHISHING
    # ------------------------------------------------------

    "Congratulations! You won a cash reward. Claim it at http://claim-cash.xyz",
    "You have been selected for a special prize. Visit http://prize-claim.xyz",
    "Claim your reward before it expires at http://reward-now.xyz",
    "You won a free gift. Confirm your details at http://free-gift.xyz",
    "Your cashback is ready. Collect it at http://cashback-claim.xyz",
    "You are eligible for a bonus reward. Visit http://bonus-reward.xyz",
    "Congratulations! Claim your lucky prize at http://lucky-prize.xyz",

    "You have won Rs 10,000. Claim now at http://winner-claim.xyz",
    "A special offer has been reserved for you. Visit http://special-offer.xyz",
    "Your reward points are expiring. Redeem them at http://points-redeem.xyz",
    "Claim your festival prize at http://festival-reward.xyz",
    "You have been selected for a cashback reward at http://cash-reward.xyz",
    "Your free voucher is ready. Get it at http://voucher-claim.xyz",
    "Congratulations! Your prize is waiting at http://prize-center.xyz",

    # ------------------------------------------------------
    # PAYMENT / REFUND PHISHING
    # ------------------------------------------------------

    "Your refund is pending. Complete verification at http://refund-process.xyz",
    "A payment failed. Update your details at http://payment-update-now.xyz",
    "Your transaction requires confirmation at http://transaction-verify.xyz",
    "Your refund has been approved. Submit details at http://refund-claim.xyz",
    "Payment verification is required. Visit http://payment-check.xyz",
    "Your cashback payment is pending. Confirm at http://cashback-confirm.xyz",
    "Your UPI account needs verification at http://upi-verify.xyz",
    "A refund of Rs 5,000 is waiting. Claim it at http://refund-money.xyz",
    "Your payment account will be restricted. Update it at http://payment-secure.xyz",
    "Confirm your transaction immediately at http://transaction-confirm.xyz",
    "Your payment failed due to verification. Visit http://payment-help.xyz",
    "Update your billing details at http://billing-update.xyz",
    "Your refund request is ready. Complete it at http://refund-ready.xyz",
    "A payment reversal is pending. Visit http://payment-reversal.xyz",
    "Verify your UPI details at http://upi-security.xyz",

    # ------------------------------------------------------
    # DELIVERY PHISHING
    # ------------------------------------------------------

    "Your parcel is waiting. Track it at http://parcel-track.xyz",
    "Your delivery requires confirmation at http://delivery-confirm.xyz",
    "Your package cannot be delivered. Update details at http://package-update.xyz",
    "Track your shipment immediately at http://shipment-track.xyz",
    "Your parcel is on hold. Visit http://parcel-release.xyz",
    "A delivery attempt failed. Reschedule at http://redelivery-now.xyz",
    "Your order is waiting for confirmation at http://order-confirm.xyz",
    "Your package has a pending issue. Check http://delivery-alert.xyz",
    "Your shipment will be returned. Confirm at http://shipment-confirm.xyz",
    "Update your delivery address at http://address-update.xyz",
    "Your parcel requires verification at http://parcel-verify.xyz",
    "Your courier status has changed. Visit http://courier-status.xyz",

    # ------------------------------------------------------
    # ACCOUNT / PASSWORD PHISHING
    # ------------------------------------------------------

    "Your password expires today. Reset it at http://password-reset-now.xyz",
    "Your account login was detected from a new device. Check http://login-alert.xyz",
    "Your social account will be disabled. Verify at http://social-secure.xyz",
    "Confirm your email account at http://email-verify.xyz",
    "Your password needs immediate updating at http://password-update.xyz",
    "Suspicious login detected. Secure your account at http://login-security.xyz",
    "Your email storage is full. Upgrade at http://mail-storage.xyz",
    "Your account will be deleted. Verify now at http://account-restore.xyz",
    "A security update is required. Visit http://security-update.xyz",
    "Your login session has expired. Sign in at http://session-renew.xyz",
    "Verify your account ownership at http://ownership-check.xyz",
    "Your account has been limited. Restore access at http://access-restore.xyz",

    # ------------------------------------------------------
    # GOVERNMENT / TAX PHISHING
    # ------------------------------------------------------

    "Your tax refund is approved. Claim it at http://tax-refund-now.xyz",
    "Income tax verification is required. Visit http://tax-verify.xyz",
    "Your PAN has been flagged. Update details at http://pan-update.xyz",
    "Government refund payment is pending at http://gov-refund.xyz",
    "Your Aadhaar verification is incomplete. Visit http://aadhaar-check.xyz",
    "Tax information must be updated at http://tax-update.xyz",
    "Your government benefit is ready. Claim at http://benefit-claim.xyz",
    "Verify your identity for government services at http://gov-verify.xyz",
    "Your tax account requires urgent action at http://tax-alert.xyz",
    "A government payment is waiting. Visit http://payment-government.xyz",

    # ------------------------------------------------------
    # GENERIC URGENT PHISHING
    # ------------------------------------------------------

    "URGENT: Verify your account immediately at http://urgent-verify.xyz",
    "Action required now. Visit http://account-action.xyz",
    "Your service will be stopped today. Confirm at http://service-confirm.xyz",
    "Immediate verification required at http://verify-immediately.xyz",
    "Your account has an important alert. Check http://important-alert.xyz",
    "Confirm your information before midnight at http://midnight-confirm.xyz",
    "Your profile requires urgent verification at http://profile-verify.xyz",
    "Security action is required now. Visit http://security-action.xyz",
    "Click http://verify-now.xyz to prevent account closure",
    "Your account requires confirmation. Visit http://confirm-account.xyz",
]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 90

print()
print(
    f"New PHISHING examples: "
    f"{len(new_phishing_messages)}"
)

if len(new_phishing_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new PHISHING examples."
    )


# ==========================================================
# PREVENT DUPLICATES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

new_normalized = set()
duplicates = []

for message in new_phishing_messages:

    normalized = message.strip().lower()

    if normalized in existing_messages:
        duplicates.append(message)

    if normalized in new_normalized:
        duplicates.append(message)

    new_normalized.add(normalized)


if duplicates:

    print()
    print("Duplicate messages found:")

    for message in sorted(set(duplicates)):
        print(f"- {message}")

    raise ValueError(
        "New examples contain duplicates."
    )


# ==========================================================
# ADD NEW DATA
# ==========================================================

for message in new_phishing_messages:

    data.append(
        {
            "message": message,
            "category": "PHISHING",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

phishing_count = sum(
    1
    for item in data
    if item["category"] == "PHISHING"
)

print()
print(
    f"Final PHISHING count: "
    f"{phishing_count}"
)

if phishing_count != 100:
    raise ValueError(
        "Expected final PHISHING count "
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