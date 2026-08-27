import json
from pathlib import Path
from collections import Counter


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

TRAIN_DATA_PATH = (
    BASE_DIR
    / "data"
    / "messages_v15.json"
)

TEST_DATA_PATH = (
    BASE_DIR
    / "data"
    / "messages_test_v1.json"
)


# ==========================================================
# CONFIGURATION
# ==========================================================

EXPECTED_PER_CATEGORY = 20

CATEGORIES = [
    "BANKING",
    "DELIVERY",
    "GENERAL",
    "IMPERSONATION",
    "INVESTMENT",
    "JOB",
    "OTP",
    "PAYMENT",
    "PHISHING",
    "PROMOTION",
]


# ==========================================================
# INDEPENDENT TEST EXAMPLES
# IMPORTANT:
# These messages should NOT exist in messages_v15.json
# ==========================================================

test_messages = {


    # ======================================================
    # BANKING
    # ======================================================

    "BANKING": [
        "Your bank has requested additional identity documents for account verification.",
        "Please visit the branch to update your customer information.",
        "Your savings account requires verification before the review date.",
        "The bank has issued a new debit card for your account.",
        "Your account profile information has been successfully updated.",
        "Please review the latest terms for your current account.",
        "Your bank statement for the previous quarter is now available.",
        "The branch has scheduled an appointment regarding your account services.",
        "Your cheque book request has been approved by the bank.",
        "Your debit card replacement request has been processed.",
        "The bank has received your request for account modification.",
        "Your account maintenance details are available in mobile banking.",
        "Please confirm your registered address with the bank.",
        "Your banking profile requires an annual information review.",
        "The bank has completed verification of your submitted documents.",
        "Your savings account service request has been registered.",
        "A new banking service has been activated for your account.",
        "Please contact your branch regarding your account inquiry.",
        "Your account nominee details have been successfully updated.",
        "The bank has generated your annual account summary.",
    ],


    # ======================================================
    # DELIVERY
    # ======================================================

    "DELIVERY": [
        "Your courier has reached the final delivery hub.",
        "The delivery agent will arrive at your location this afternoon.",
        "Your order is currently moving between distribution centers.",
        "The package has been scanned at the destination warehouse.",
        "Your shipment is expected to reach you by Tuesday.",
        "The courier company has received your parcel from the seller.",
        "Your delivery window has been changed to tomorrow morning.",
        "The package is being sorted before final dispatch.",
        "Your order has arrived at the regional distribution center.",
        "The delivery agent was unable to contact you during the first attempt.",
        "Your parcel can be collected from the authorized pickup point.",
        "The shipment has departed from the central warehouse.",
        "Your package is scheduled for the next available delivery slot.",
        "The courier tracking status has been updated successfully.",
        "Your order is waiting for the delivery vehicle assignment.",
        "The package has reached the nearest courier office.",
        "Your shipment is currently travelling to your city.",
        "The delivery team will make another attempt tomorrow.",
        "Your parcel has been transferred to the local courier partner.",
        "Your order has completed the dispatch process.",
    ],


    # ======================================================
    # GENERAL
    # ======================================================

    "GENERAL": [
        "I will call you after I finish work.",
        "Let's have dinner together this weekend.",
        "Please remind me about the meeting tomorrow.",
        "I reached the office a little late today.",
        "Are you available for a quick conversation?",
        "The weather looks pleasant this evening.",
        "Thank you for helping me yesterday.",
        "I will send the documents later today.",
        "Let's decide the plan after everyone arrives.",
        "Please let me know when you get home.",
        "The meeting has been moved to Friday.",
        "I need to buy groceries after work.",
        "Can we talk sometime this afternoon?",
        "I will be travelling next week.",
        "Please bring your laptop to the meeting.",
        "We had lunch at a new restaurant yesterday.",
        "The event starts at seven in the evening.",
        "I forgot to reply to your message earlier.",
        "Let's meet near the office entrance.",
        "Have a safe journey and take care.",
    ],


    # ======================================================
    # IMPERSONATION
    # ======================================================

    "IMPERSONATION": [
        "I am calling from your bank security department, give me your verification code.",
        "This is the police office, transfer money immediately to clear your case.",
        "I am your company administrator, send payment for urgent account approval.",
        "Our technical team needs remote access to your phone right now.",
        "I am an officer from the tax department and require immediate payment.",
        "This is your bank relationship manager, provide your card details now.",
        "I am from customer support, install this software so I can fix your device.",
        "Your manager asked me to collect money from you urgently.",
        "I represent a government agency and need your account information.",
        "I am from the fraud investigation team, share the code sent to your phone.",
        "This is the courier office, transfer money directly to our representative.",
        "I am calling from your mobile provider and need access to your account.",
        "Our company HR department requires payment before confirming your employment.",
        "I am from official support, give me control of your computer to resolve the issue.",
        "This is a government officer, pay the required amount immediately.",
        "I am your bank executive, tell me your PIN for account verification.",
        "Your relative asked me to contact you and arrange an urgent money transfer.",
        "I am from the service center, download this application for assistance.",
        "This is the legal department, make payment now to avoid action.",
        "I am an authorized officer and need your banking credentials for verification.",
    ],


    # ======================================================
    # INVESTMENT
    # ======================================================

    "INVESTMENT": [
        "Our trading platform promises exceptional returns with minimal risk.",
        "Invest today and receive guaranteed profits every month.",
        "This exclusive investment scheme can double your capital quickly.",
        "Join our trading group for assured daily earnings.",
        "The investment opportunity closes tonight, send funds now.",
        "Our experts guarantee consistent profits from the stock market.",
        "Earn passive income every day through this special investment plan.",
        "Invest a small amount and receive large returns within weeks.",
        "This crypto opportunity offers guaranteed profits without any risk.",
        "Start trading today and watch your money grow rapidly.",
        "Our investment advisor promises fixed returns on every deposit.",
        "Limited seats remain for this high-profit trading program.",
        "Transfer funds now to activate your premium investment account.",
        "Receive guaranteed monthly income from our investment package.",
        "This market strategy promises profit regardless of market conditions.",
        "Join the private investment group before registrations close.",
        "Your investment can generate extraordinary returns in a short time.",
        "Our automated trading system guarantees profitable transactions.",
        "Invest immediately to secure your place in this exclusive opportunity.",
        "Get assured returns from our special wealth growth program.",
    ],


    # ======================================================
    # JOB
    # ======================================================

    "JOB": [
        "You have been selected for the position and must pay a processing fee.",
        "Work from home opportunities are available after paying the registration charge.",
        "Complete the payment to receive your employment confirmation.",
        "Your job application has been approved, pay the required onboarding fee.",
        "Send money to reserve your position before the vacancy closes.",
        "Pay the training charge to begin your new job.",
        "You can start earning immediately after completing the joining payment.",
        "The recruiter requires a verification fee before releasing the offer letter.",
        "A remote job is available with guaranteed income after registration payment.",
        "Pay the application charge today to secure your employment.",
        "Your selection is confirmed, complete the fee payment immediately.",
        "The company requires a deposit before starting your assigned role.",
        "Submit the joining amount to activate your employment profile.",
        "Limited job openings remain, pay now to confirm your place.",
        "Your appointment letter will be released after the processing fee is paid.",
        "Complete the payment to finish your recruitment procedure.",
        "A government position is available after payment of the service charge.",
        "Pay the required fee to receive access to the job training program.",
        "Your recruiter has approved the application, send the registration amount.",
        "Earn from home after paying the initial account activation fee.",
    ],


    # ======================================================
    # OTP
    # ======================================================

    "OTP": [
        "Your login verification code is 741852. Never share this code.",
        "Use security code 369147 to complete authentication.",
        "Your one-time verification number is 852963.",
        "The code for confirming your login is 147258.",
        "Your secure access code is 963852. Keep it private.",
        "Enter verification number 258741 to continue.",
        "Your authentication code is 654321.",
        "Do not disclose the security code 456123 to anyone.",
        "The one-time login code is 789456.",
        "Your account confirmation number is 321654.",
        "Tell me the verification code you received so I can complete the process.",
        "Please send the one-time password from your phone immediately.",
        "Share the security code sent to your mobile number.",
        "I need the OTP you received to verify your account.",
        "Forward the verification number from your message to complete the refund.",
        "Give me the code sent to your phone for confirmation.",
        "Send the authentication code immediately so the transaction can proceed.",
        "Please provide the OTP from the bank message.",
        "Share your verification number to complete account validation.",
        "Tell me the one-time code before it expires.",
    ],


    # ======================================================
    # PAYMENT
    # ======================================================

    "PAYMENT": [
        "An amount of Rs 1500 has been credited to your account.",
        "Your recent card transaction has been completed successfully.",
        "Rs 2750 was debited from your account.",
        "The payment of Rs 899 has been processed.",
        "Your bank has confirmed the successful transaction.",
        "A payment request for Rs 1200 is awaiting your approval.",
        "Your account received a credit of Rs 500.",
        "The transfer was completed successfully.",
        "Your card was charged Rs 320 for the purchase.",
        "Payment confirmation has been generated for your transaction.",
        "Enter your UPI PIN to complete the cashback process.",
        "Approve the collect request to receive the refund amount.",
        "Scan the payment code to claim your pending cashback.",
        "Your refund requires confirmation through a UPI request.",
        "Complete the UPI authorization to receive the prize money.",
        "A collect request has been sent to your UPI application.",
        "Enter your payment PIN to receive the cashback reward.",
        "Approve the transaction request to claim your refund.",
        "Your wallet payment of Rs 650 was successful.",
        "The merchant payment has been completed.",
    ],


    # ======================================================
    # PHISHING
    # ======================================================

    "PHISHING": [
        "Your account needs verification immediately: http://account-verify-alert.xyz",
        "Update your banking details now at http://secure-bank-check.xyz",
        "Claim your pending reward here: http://reward-claim-fast.xyz",
        "Your account access will expire. Visit http://account-access-reset.xyz",
        "Confirm your identity now using http://verify-user-secure.xyz",
        "Your payment information must be updated at http://payment-check.xyz",
        "Security alert detected. Verify here: http://security-review.xyz",
        "Your refund is waiting at http://refund-confirmation.xyz",
        "Reset your password immediately at http://password-secure-update.xyz",
        "Your package requires action: http://parcel-action.xyz",
        "Your account will be closed unless you visit http://account-protection.xyz",
        "Submit your KYC information at http://kyc-verification.xyz",
        "An urgent banking notice is available at http://banking-alert.xyz",
        "Your card requires verification at http://card-validation.xyz",
        "Confirm the transaction at http://transaction-secure.xyz",
        "You have won a prize. Claim it at http://winner-reward.xyz",
        "Your subscription requires payment update: http://billing-update.xyz",
        "Verify your mobile account at http://mobile-security.xyz",
        "A security problem was found. Fix it at http://account-fix.xyz",
        "Complete your account review at http://user-review.xyz",
    ],


    # ======================================================
    # PROMOTION
    # ======================================================

    "PROMOTION": [
        "Flash sale begins today with discounts across selected items.",
        "Get special savings when you shop before the weekend.",
        "A new promotional offer is available for registered customers.",
        "Save more with our limited-time shopping deal.",
        "Enjoy discounted prices on selected products this week.",
        "Special customer offers are now available in our store.",
        "Shop today and receive exciting discounts on popular items.",
        "Our seasonal sale includes deals on many products.",
        "Buy selected items now and enjoy special savings.",
        "A limited promotional campaign starts this evening.",
        "Discover exclusive deals available for a short period.",
        "Get extra savings on your next purchase.",
        "Special prices are available while stock lasts.",
        "Don't miss this week's featured shopping offers.",
        "New discounts have been added to our product collection.",
        "Enjoy a special deal on selected categories today.",
        "Our promotional event offers savings for all customers.",
        "Shop the latest offers before the campaign ends.",
        "Limited-time discounts are available on featured products.",
        "Take advantage of special prices during our current sale.",
    ],
}


# ==========================================================
# LOAD TRAINING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD INDEPENDENT TEST DATASET V1 BUILDER")
print("=" * 60)

if not TRAIN_DATA_PATH.exists():
    raise FileNotFoundError(
        f"Training dataset not found: {TRAIN_DATA_PATH}"
    )

with open(
    TRAIN_DATA_PATH,
    "r",
    encoding="utf-8",
) as file:
    training_data = json.load(file)


# ==========================================================
# BUILD TRAINING MESSAGE SET
# ==========================================================

training_messages = {
    item["message"].strip().lower()
    for item in training_data
}


print()
print(
    f"Training examples loaded: "
    f"{len(training_data)}"
)


# ==========================================================
# VALIDATE CATEGORIES
# ==========================================================

if set(test_messages.keys()) != set(CATEGORIES):
    raise ValueError(
        "Test dataset categories do not match "
        "the expected categories."
    )


# ==========================================================
# VALIDATE TEST DATA
# ==========================================================

all_test_messages = []

for category in CATEGORIES:

    messages = test_messages[category]

    print(
        f"{category}: {len(messages)}"
    )

    if len(messages) != EXPECTED_PER_CATEGORY:
        raise ValueError(
            f"{category} must contain exactly "
            f"{EXPECTED_PER_CATEGORY} examples."
        )

    all_test_messages.extend(
        messages
    )


# ==========================================================
# CHECK DUPLICATES INSIDE TEST DATA
# ==========================================================

normalized_test_messages = [
    message.strip().lower()
    for message in all_test_messages
]

duplicate_count = (
    len(normalized_test_messages)
    - len(set(normalized_test_messages))
)

if duplicate_count > 0:
    raise ValueError(
        f"Duplicate messages found inside "
        f"test dataset: {duplicate_count}"
    )


# ==========================================================
# CHECK DATA LEAKAGE
# ==========================================================

leaked_messages = []

for message in all_test_messages:

    normalized = (
        message.strip().lower()
    )

    if normalized in training_messages:
        leaked_messages.append(
            message
        )


if leaked_messages:

    print()
    print("=" * 60)
    print("DATA LEAKAGE DETECTED")
    print("=" * 60)

    for message in leaked_messages:
        print(f"- {message}")

    raise ValueError(
        "Test messages already exist in "
        "messages_v15.json"
    )


# ==========================================================
# BUILD FINAL DATASET
# ==========================================================

final_data = []

for category in CATEGORIES:

    for message in test_messages[category]:

        final_data.append(
            {
                "message": message,
                "category": category,
            }
        )


# ==========================================================
# FINAL VALIDATION
# ==========================================================

expected_total = (
    len(CATEGORIES)
    * EXPECTED_PER_CATEGORY
)

if len(final_data) != expected_total:
    raise ValueError(
        f"Expected {expected_total} test examples "
        f"but got {len(final_data)}"
    )


category_counts = Counter(
    item["category"]
    for item in final_data
)


print()
print("=" * 60)
print("FINAL TEST DATASET DISTRIBUTION")
print("=" * 60)

for category in CATEGORIES:

    count = category_counts[category]

    print(
        f"{category}: {count}"
    )


print()
print(
    f"TOTAL TEST EXAMPLES: "
    f"{len(final_data)}"
)


# ==========================================================
# SAVE DATASET
# ==========================================================

with open(
    TEST_DATA_PATH,
    "w",
    encoding="utf-8",
) as file:

    json.dump(
        final_data,
        file,
        indent=4,
        ensure_ascii=False,
    )


print()
print("Test dataset saved to:")
print(TEST_DATA_PATH)

print()
print("=" * 60)
print("BUILD COMPLETE")
print("=" * 60)