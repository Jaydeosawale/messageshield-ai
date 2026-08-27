import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v10.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v11.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V11 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW JOB EXAMPLES
# ==========================================================

new_job_messages = [

    # ------------------------------------------------------
    # FAKE JOB SELECTION / OFFER
    # ------------------------------------------------------

    "Congratulations, you have been selected for the position.",
    "You have been chosen for an immediate job opportunity.",
    "Your job application has been approved without an interview.",
    "You have been selected for a high salary work from home job.",
    "Congratulations, your employment has been confirmed.",
    "You are eligible for immediate joining at our company.",
    "Your job offer has been approved. Complete the next step now.",
    "You have been shortlisted for a premium job opportunity.",
    "Your appointment letter is ready for processing.",
    "You have been selected based on your profile.",
    "Congratulations, your job has been confirmed immediately.",
    "Our company has approved your application without further screening.",
    "You have been selected for an urgent vacancy.",
    "Your employment opportunity is waiting for confirmation.",

    # ------------------------------------------------------
    # REGISTRATION / PROCESSING FEES
    # ------------------------------------------------------

    "Pay the registration fee immediately to confirm your job.",
    "A processing fee is required before your appointment letter is issued.",
    "Send the verification payment to continue your job application.",
    "Pay the joining fee now to secure your position.",
    "Your application requires a small processing payment.",
    "Transfer the registration amount to activate your job offer.",
    "Pay the documentation fee before your employment can be confirmed.",
    "A verification charge is pending for your job application.",
    "Send the required fee immediately to complete registration.",
    "Your appointment letter will be released after payment.",
    "A training fee must be paid before joining.",
    "Transfer the required amount to complete employment verification.",
    "Pay the recruitment fee to secure your selected position.",
    "Your job confirmation requires an immediate payment.",

    # ------------------------------------------------------
    # WORK FROM HOME / EASY MONEY
    # ------------------------------------------------------

    "Work from home and earn Rs 5000 every day.",
    "Earn money from home with only two hours of work.",
    "Start working online and receive a guaranteed daily income.",
    "Earn Rs 3000 daily from simple work at home.",
    "No experience is required for this high paying online job.",
    "Work from your phone and earn money every day.",
    "Start today and receive your first payment immediately.",
    "Simple online tasks can help you earn daily income.",
    "Work flexible hours and earn guaranteed weekly payments.",
    "Our home based job offers immediate earnings.",
    "Start an easy online job with no previous experience.",
    "Earn money by completing simple tasks from home.",
    "Get paid daily for working a few hours online.",
    "Join our remote work program and start earning today.",

    # ------------------------------------------------------
    # URGENT VACANCIES / LIMITED POSITIONS
    # ------------------------------------------------------

    "Only a few job vacancies are remaining. Apply immediately.",
    "This job opportunity closes today.",
    "Limited positions are available. Confirm your job now.",
    "Apply immediately before all vacancies are filled.",
    "Your job offer will expire tonight.",
    "Only selected candidates can join this opportunity.",
    "Urgent hiring is taking place today only.",
    "Last chance to secure your job opportunity.",
    "The company is hiring immediately for limited positions.",
    "Complete your registration before the vacancy closes.",
    "Apply now to avoid missing this job opportunity.",
    "Today is the final day to confirm your position.",
    "Limited seats are available for immediate joining.",
    "Act quickly to secure your employment offer.",

    # ------------------------------------------------------
    # FAKE GOVERNMENT / HIGH SALARY JOBS
    # ------------------------------------------------------

    "Government job confirmed. Pay the processing amount now.",
    "You have been selected for a government position without examination.",
    "A government vacancy is available with immediate joining.",
    "Pay the required fee to receive your government appointment letter.",
    "Your government job has been approved.",
    "Secure a permanent government position by completing payment.",
    "You have been selected for a high salary government role.",
    "Government recruitment is open for immediate joining.",
    "Pay now to confirm your government employment.",
    "A government department has selected you for a position.",
    "Complete payment to receive your government joining instructions.",
    "Get a permanent job with guaranteed monthly salary.",
    "Your government employment application has been approved.",
    "Pay the verification charge for your government job.",

    # ------------------------------------------------------
    # DOCUMENT / BANK DETAILS REQUESTS
    # ------------------------------------------------------

    "Share your bank details to receive your first salary.",
    "Send your identity documents immediately for job verification.",
    "Provide your Aadhaar and PAN details to complete joining.",
    "Your employer needs your bank account information urgently.",
    "Upload your documents and pay the verification amount.",
    "Send your personal details to receive the appointment letter.",
    "Provide your banking information for salary activation.",
    "Your documents require immediate verification payment.",
    "Share your identification details to continue the recruitment.",
    "Send your bank account number for employment confirmation.",
]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 80

print()
print(
    f"New JOB examples: "
    f"{len(new_job_messages)}"
)

if len(new_job_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new JOB examples."
    )


# ==========================================================
# PREVENT DUPLICATES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

duplicates = []

for message in new_job_messages:

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

for message in new_job_messages:

    data.append(
        {
            "message": message,
            "category": "JOB",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

job_count = sum(
    1
    for item in data
    if item["category"] == "JOB"
)

print()
print(
    f"Final JOB count: "
    f"{job_count}"
)

if job_count != 100:
    raise ValueError(
        "Expected final JOB count "
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
