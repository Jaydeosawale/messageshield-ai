import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v11.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v12.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V12 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW OTP EXAMPLES
# ==========================================================

new_otp_messages = [

    # ------------------------------------------------------
    # LEGITIMATE OTP / VERIFICATION MESSAGES
    # ------------------------------------------------------

    "Your OTP is 482910. Do not share this code with anyone.",
    "Use OTP 738421 to complete your login.",
    "Your verification code is 614829.",
    "Enter the one time password 395741 to continue.",
    "Use verification code 564321 to verify your account.",
    "Your login OTP is 918273.",
    "The OTP for your transaction is 472819.",
    "Your account verification code is 751482.",
    "Your verification OTP is 426891.",
    "Use OTP 691274 to complete the process.",
    "Your login verification code is 853127.",
    "The code 274918 is required to confirm your login.",
    "Your secure OTP is 419682.",
    "Enter verification code 732561.",
    "Your one time security code is 965214.",
    "Use code 518429 to verify your mobile number.",
    "Your OTP 684193 is valid for ten minutes.",
    "Enter the code 247861 to confirm your identity.",
    "Your authentication OTP is 391572.",

    # ------------------------------------------------------
    # OTP SHARING SCAMS
    # ------------------------------------------------------

    "Share the OTP sent to your phone immediately.",
    "Tell me the verification code you just received.",
    "Send your OTP now so we can verify your account.",
    "Please provide the one time password sent to your mobile.",
    "Share the security code to complete the verification.",
    "Tell us the OTP received on your phone.",
    "Tell the bank executive the OTP you received.",
    "Send us your one time password to process the request.",
    "Provide the OTP immediately for security verification.",
    "Share the code sent to your registered mobile number.",
    "Tell me the six digit OTP you just received.",
    "Send your account verification code now.",
    "Please provide the security OTP immediately.",
    "Share the login code to complete the account check.",
    "Tell us the OTP before it expires.",
    "Send the verification password to our representative.",
    "Provide your OTP to confirm your identity.",

    # ------------------------------------------------------
    # BANK / REFUND OTP SCAMS
    # ------------------------------------------------------

    "Your refund is ready. Share the OTP to receive the money.",
    "Send your OTP to complete the refund process.",
    "Provide the verification code to receive your cashback.",
    "Share the OTP so we can release your pending refund.",
    "Your bank executive needs the OTP for verification.",
    "Your refund will fail unless you provide the OTP.",
    "Send the OTP immediately to receive the credited amount.",
    "Provide your verification code for the refund payment.",
    "Share your OTP to unblock your bank account.",
    "Provide the security code to receive your reward money.",
    "Send the one time password to complete the bank verification.",
    "Your cashback is pending. Share the OTP immediately.",
    "Tell us the verification code to process your payment refund.",
    "Share the OTP to confirm the credit in your account.",
    "Your transaction is pending. Provide the OTP to complete it.",
    "Send your OTP now to receive the refund.",

    # ------------------------------------------------------
    # URGENT / SOCIAL ENGINEERING OTP SCAMS
    # ------------------------------------------------------

    "Share the OTP quickly or your account will be blocked.",
    "Tell me the code immediately before it expires.",
    "Your account verification will fail unless you provide the OTP.",
    "Send the OTP urgently to avoid account suspension.",
    "Share the verification code now to prevent account closure.",
    "Tell us the OTP immediately to secure your account.",
    "Provide the code quickly or your transaction will be cancelled.",
    "Your account is at risk. Share the OTP for verification.",
    "Share your OTP immediately to avoid losing access.",
    "Tell me the code before the verification request expires.",
    "Provide the OTP now to prevent your account from being frozen.",
    "Your service will be stopped unless you share the verification code.",
    "Send the one time password urgently to restore your account.",
    "Share the OTP now or your refund request will be cancelled.",
    "Tell us your security code immediately to avoid penalties.",
    "Your account will be locked. Share the code immediately.",
    "Send the OTP before time runs out.",
    "Tell the verification code now to avoid service interruption.",

    # ------------------------------------------------------
    # CUSTOMER SUPPORT / IMPERSONATION OTP SCAMS
    # ------------------------------------------------------

    "This is customer support. Please share your OTP for verification.",
    "Our support team needs your verification code to help you.",
    "The bank representative is requesting your OTP.",
    "Customer care requires your one time password to resolve the issue.",
    "Our agent needs the security code sent to your phone.",
    "Technical support requires your OTP to fix your account.",
    "The account manager needs your verification code immediately.",
    "Our executive is waiting for your OTP to complete the process.",
    "Share your one time password with the support representative.",
    "The service agent needs your OTP for account confirmation.",
    "Please tell our representative the code you received.",
    "The bank support officer requires your OTP.",
    "Our customer care team needs the login verification code.",
    "Share the security code with the official looking support agent.",

]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 84

print()
print(
    f"New OTP examples: "
    f"{len(new_otp_messages)}"
)

if len(new_otp_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new OTP examples."
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


for message in new_otp_messages:

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

for message in new_otp_messages:

    data.append(
        {
            "message": message,
            "category": "OTP",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

otp_count = sum(
    1
    for item in data
    if item["category"] == "OTP"
)

print()
print(
    f"Final OTP count: "
    f"{otp_count}"
)

if otp_count != 100:
    raise ValueError(
        "Expected final OTP count "
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
