import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v8.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v9.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V9 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW IMPERSONATION EXAMPLES
# ==========================================================

new_impersonation_messages = [

    # ------------------------------------------------------
    # BANK / FINANCIAL IMPERSONATION
    # ------------------------------------------------------

    "I am calling from your bank security team. Share your OTP immediately.",
    "This is the bank verification department. Provide your card number.",
    "I am a bank officer. Please confirm your account PIN.",
    "Our bank manager needs your OTP to verify your identity.",
    "This is the fraud department from your bank. Transfer money to secure your account.",
    "I am from the bank customer support team. Share your CVV for verification.",
    "Your bank relationship manager is requesting your account details.",
    "This is your bank executive. Send your debit card information now.",
    "I work with your bank. Please provide the verification code.",
    "The bank security officer is asking you to confirm your UPI PIN.",
    "I am from the official bank helpline. Share the OTP you received.",
    "This is the bank account department. Verify your card details immediately.",
    "I am your bank manager. Send your account number for verification.",
    "The bank fraud team requires your OTP to investigate this case.",
    "I am calling from your bank branch. Provide your PIN immediately.",

    # ------------------------------------------------------
    # GOVERNMENT / POLICE IMPERSONATION
    # ------------------------------------------------------

    "This is the police department. Pay the fine immediately.",
    "I am a police officer. Your account is under investigation.",
    "This is the cyber crime department. Transfer money to avoid arrest.",
    "I am calling from the government office. Pay the penalty now.",
    "This is the tax department. Your payment is overdue.",
    "I am an income tax officer. Share your bank details immediately.",
    "This is the customs department. Pay the clearance charge now.",
    "I am calling from the passport office. Pay the processing fee.",
    "This is the government verification team. Send your identity details.",
    "I am from the court department. Pay immediately to avoid legal action.",
    "This is a police officer. Your name is connected to a criminal case.",
    "I am from the cyber security department. Give us access to your phone.",
    "The government authority requires an immediate payment from you.",
    "This is the official investigation department. Follow our instructions.",
    "I am a government officer. Transfer the penalty amount now.",

    # ------------------------------------------------------
    # TECH SUPPORT IMPERSONATION
    # ------------------------------------------------------

    "This is technical support. Install our application immediately.",
    "I am from customer support. Give me remote access to your phone.",
    "This is the device security team. Install the support application.",
    "I am calling from mobile support. Share your screen with us.",
    "This is technical assistance. Download the remote access app.",
    "Our support engineer needs control of your phone to fix the problem.",
    "I am from the security support team. Install this application now.",
    "This is official customer care. Allow remote access to your device.",
    "I am a technical engineer. Open the application and share your screen.",
    "The support department needs access to your phone immediately.",
    "I am calling from device support. Install the security tool.",
    "This is account support. Give us remote access to resolve the issue.",
    "I am a support executive. Share your screen for verification.",
    "The technical team needs you to install a remote assistance app.",
    "I am from customer service. Follow these steps to give us phone access.",

    # ------------------------------------------------------
    # COMPANY / HR IMPERSONATION
    # ------------------------------------------------------

    "I am your HR manager. Pay the document verification fee.",
    "This is the company recruitment department. Transfer the registration fee.",
    "I am calling from HR. Send your bank details immediately.",
    "This is your company manager. Transfer money urgently.",
    "I am from the recruitment team. Pay to confirm your job.",
    "Your HR executive is requesting an immediate payment.",
    "I am the hiring manager. Send money to complete your application.",
    "This is the company administration department. Pay the processing fee.",
    "I am your manager. Transfer the amount to this account now.",
    "The HR team requires your payment before issuing the offer letter.",
    "I am calling from the company office. Share your personal documents.",
    "This is the recruitment officer. Pay immediately to continue.",
    "I am your supervisor. Send money urgently for company work.",
    "The company verification team needs your payment now.",
    "I am from the HR department. Provide your banking details.",

    # ------------------------------------------------------
    # FAMILY / RELATIVE IMPERSONATION
    # ------------------------------------------------------

    "I am your relative. I need money urgently because of an emergency.",
    "Your family member has been arrested. Transfer money immediately.",
    "I am your friend. Please send money urgently to this account.",
    "Your brother is in trouble and needs an immediate payment.",
    "I am calling on behalf of your relative. Send money now.",
    "Your family member is in the hospital. Transfer money urgently.",
    "I am your cousin. I lost my phone and need money immediately.",
    "Your friend has asked me to collect money from you.",
    "I am your relative and I need urgent financial help.",
    "Your family member has had an accident. Send money immediately.",
    "I am calling for your friend who needs emergency assistance.",
    "Your relative is in legal trouble. Transfer money to help them.",
    "I am your family member. Please send money to my new account.",
    "Your friend is stranded and urgently needs financial support.",
    "I am calling from your relative's phone. Send money immediately.",

    # ------------------------------------------------------
    # SERVICE / ORGANIZATION IMPERSONATION
    # ------------------------------------------------------

    "This is the courier company. Pay the fee directly to our agent.",
    "I am from the electricity department. Transfer the pending amount now.",
    "This is the telecom company. Share your OTP to verify your SIM.",
    "I am calling from the insurance department. Pay the renewal fee now.",
    "This is the official customer care team. Transfer money for verification.",
    "I am from the mobile network provider. Share the code sent to your phone.",
    "This is the delivery service. Pay our representative immediately.",
    "I am from the insurance company. Provide your card details.",
    "This is the utility department. Make the payment to avoid disconnection.",
    "I am calling from the service center. Pay the repair fee now.",
    "This is the subscription support team. Share your account details.",
    "I am from the official helpdesk. Transfer money to complete verification.",
    "This is the service provider. Provide your OTP immediately.",
    "I am calling from the customer assistance department. Pay now.",
    "This is the account verification team. Follow my instructions immediately.",
]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 90

print()
print(
    f"New IMPERSONATION examples: "
    f"{len(new_impersonation_messages)}"
)

if len(new_impersonation_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new IMPERSONATION examples."
    )


# ==========================================================
# PREVENT DUPLICATES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

duplicates = []

for message in new_impersonation_messages:

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

for message in new_impersonation_messages:

    data.append(
        {
            "message": message,
            "category": "IMPERSONATION",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

impersonation_count = sum(
    1
    for item in data
    if item["category"] == "IMPERSONATION"
)

print()
print(
    f"Final IMPERSONATION count: "
    f"{impersonation_count}"
)

if impersonation_count != 100:
    raise ValueError(
        "Expected final IMPERSONATION count "
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
