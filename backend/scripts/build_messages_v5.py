from pathlib import Path
import json
from collections import Counter


BASE_DIR = Path(__file__).resolve().parent.parent

V4_PATH = BASE_DIR / "data" / "messages_v4.json"
OUTPUT_PATH = BASE_DIR / "data" / "messages_v5.json"


# =========================================================
# NEW V5 EXAMPLES
# =========================================================

NEW_EXAMPLES = [

    # =====================================================
    # BANKING SCAMS
    # =====================================================

    {
        "message": "Your bank account will be blocked today. Click here immediately to update your KYC.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your account has been frozen due to suspicious activity. Verify your details using this link.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Dear customer, share your debit card number to reactivate your account.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your bank manager needs your OTP to verify your account.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your ATM card will expire today. Send your card details immediately.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "A refund of Rs 10,000 is pending. Provide your bank account credentials to receive it.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your account is under investigation. Verify your PIN to avoid suspension.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Update your PAN and Aadhaar details immediately to prevent account closure.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "You are eligible for a special bank reward. Enter your card details to claim it.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },
    {
        "message": "Your bank account has unusual activity. Send the OTP to secure your account.",
        "category": "BANKING",
        "safety_label": "SCAM",
    },

    # =====================================================
    # SAFE BANKING
    # =====================================================

    {
        "message": "Your bank account has been credited with Rs 5000.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your savings account statement is available in the official mobile banking app.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your debit card transaction of Rs 1200 was successful.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your monthly bank statement has been generated successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your fixed deposit will mature on 15 September.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your cheque has been successfully cleared.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your credit card payment has been received successfully.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your bank account balance is available in the official banking application.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your account statement for this month is ready to download.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },
    {
        "message": "Your debit card has been dispatched and will arrive within five working days.",
        "category": "BANKING",
        "safety_label": "SAFE",
    },


    # =====================================================
    # JOB SCAMS
    # =====================================================

    {
        "message": "Congratulations, you have been selected for a job. Pay Rs 2000 registration fee immediately.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "Work from home and earn Rs 5000 daily. Pay a joining fee to start.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "You have been shortlisted without an interview. Send your documents and payment now.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "Government job confirmed. Pay processing charges immediately.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "Your job offer expires today. Pay the training fee now.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "Earn Rs 50,000 per month from home. Send Rs 999 to activate your account.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "You have been hired immediately. Share your bank details to receive your first salary.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "Pay the verification fee to complete your job application.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "Limited vacancies available. Transfer money now to reserve your position.",
        "category": "JOB",
        "safety_label": "SCAM",
    },
    {
        "message": "Your job is guaranteed. Complete the payment to receive your appointment letter.",
        "category": "JOB",
        "safety_label": "SCAM",
    },

    # =====================================================
    # SAFE JOB MESSAGES
    # =====================================================

    {
        "message": "Your interview is scheduled for Monday at 10 AM.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "Thank you for applying. Our recruitment team will review your application.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "You have been invited to attend an interview through the official company portal.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "Your application status has been updated to under review.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "Please join the interview meeting using the official company invitation.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "Your interview feedback will be shared within five working days.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "The recruiter has scheduled your technical interview for tomorrow.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "Your application has been received successfully.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "Please upload the requested documents through the official recruitment portal.",
        "category": "JOB",
        "safety_label": "SAFE",
    },
    {
        "message": "The company has sent you an interview confirmation email.",
        "category": "JOB",
        "safety_label": "SAFE",
    },


    # =====================================================
    # INVESTMENT SCAMS
    # =====================================================

    {
        "message": "Guaranteed 500 percent returns in 30 days. Invest now before the opportunity closes.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "Double your money in one week with our secret investment plan.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "Risk free cryptocurrency investment with guaranteed daily profit.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "Invest Rs 1000 today and receive Rs 10,000 tomorrow.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "Our expert guarantees huge stock market profits. Send money to start investing.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "Limited investment opportunity. Guaranteed returns with zero risk.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "Send funds now and our trading bot will generate daily income.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "VIP investment group guarantees 10 percent profit every day.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "Transfer Rs 5000 and receive guaranteed returns by tonight.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },
    {
        "message": "This investment has no risk and guaranteed profit. Join immediately.",
        "category": "INVESTMENT",
        "safety_label": "SCAM",
    },

    # =====================================================
    # SAFE INVESTMENT
    # =====================================================

    {
        "message": "Your mutual fund account statement is now available.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "Your SIP investment was successfully processed.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "The stock market will open at 9:15 AM tomorrow.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "Your investment portfolio report is available in the official application.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "Your mutual fund NAV has been updated.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "Your SIP installment of Rs 2000 was successfully invested.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "Your demat account statement is available for review.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "The market value of your portfolio has changed today.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "Your investment transaction has been completed successfully.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },
    {
        "message": "Please review your investment portfolio through your official broker application.",
        "category": "INVESTMENT",
        "safety_label": "SAFE",
    },


    # =====================================================
    # IMPERSONATION SCAMS
    # =====================================================

    {
        "message": "I am calling from your bank. Share your OTP immediately for verification.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "This is the police department. Your account is involved in illegal activity. Transfer money immediately.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "I am your company HR manager. Send money for document verification.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "This is customer support. Install this application so we can fix your account.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "Your relative has been arrested. Transfer money immediately to help them.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "I am from the government department. Pay the penalty now to avoid legal action.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "This is your bank executive. Please provide your card number and CVV.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "I am from technical support. Give me remote access to your phone.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "Your manager needs money urgently. Transfer it to this account immediately.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },
    {
        "message": "I am from the tax department. Pay immediately or your account will be blocked.",
        "category": "IMPERSONATION",
        "safety_label": "SCAM",
    },

    # =====================================================
    # SAFE GENERAL / OFFICIAL-LIKE MESSAGES
    # =====================================================

    {
        "message": "Please contact customer support using the phone number listed on the official website.",
        "category": "GENERAL",
        "safety_label": "SAFE",
    },
    {
        "message": "Your support request has been received and is being reviewed.",
        "category": "GENERAL",
        "safety_label": "SAFE",
    },
    {
        "message": "Your complaint reference number has been generated successfully.",
        "category": "GENERAL",
        "safety_label": "SAFE",
    },
    {
        "message": "Please visit the official office during working hours for assistance.",
        "category": "GENERAL",
        "safety_label": "SAFE",
    },
    {
        "message": "Your service request has been successfully completed.",
        "category": "GENERAL",
        "safety_label": "SAFE",
    },
]


def normalize(message: str) -> str:
    return " ".join(
        message.lower().strip().split()
    )


def main():

    print("\n===== BUILDING MESSAGE DATASET V5 =====\n")

    if not V4_PATH.exists():
        raise FileNotFoundError(
            f"V4 dataset not found: {V4_PATH}"
        )

    with open(V4_PATH, "r", encoding="utf-8") as f:
        v4_data = json.load(f)

    print(
        f"Loaded V4 dataset: "
        f"{len(v4_data)} examples"
    )

    print(
        f"New V5 examples: "
        f"{len(NEW_EXAMPLES)}"
    )

    combined = v4_data + NEW_EXAMPLES

    print(
        f"Before deduplication: "
        f"{len(combined)}"
    )

    seen = set()
    final_data = []

    for item in combined:

        key = normalize(item["message"])

        if key not in seen:
            seen.add(key)
            final_data.append(item)

    print(
        f"After deduplication: "
        f"{len(final_data)}"
    )

    category_counts = Counter(
        item["category"]
        for item in final_data
    )

    safety_counts = Counter(
        item["safety_label"]
        for item in final_data
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

    with open(
        OUTPUT_PATH,
        "w",
        encoding="utf-8",
    ) as f:
        json.dump(
            final_data,
            f,
            indent=2,
            ensure_ascii=False,
        )

    print(
        "\nSaved V5 dataset:"
    )

    print(OUTPUT_PATH)

    print(
        "\n===== COMPLETE =====\n"
    )


if __name__ == "__main__":
    main()
