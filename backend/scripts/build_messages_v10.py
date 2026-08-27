import json
from pathlib import Path


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v9.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v10.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V10 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW INVESTMENT EXAMPLES
# ==========================================================

new_investment_messages = [

    # ------------------------------------------------------
    # GUARANTEED RETURNS / HIGH PROFIT
    # ------------------------------------------------------

    "Invest today and get guaranteed returns within 30 days.",
    "Earn guaranteed profits from our exclusive investment plan.",
    "Double your investment in just one week.",
    "Get high returns with absolutely no investment risk.",
    "Our investment scheme guarantees daily profit.",
    "Invest Rs 5000 and receive double the amount next month.",
    "Guaranteed monthly income is available through our investment program.",
    "Earn huge profits from this limited investment opportunity.",
    "Our experts guarantee massive profits from this investment.",
    "Turn your savings into double the amount quickly.",
    "Get guaranteed income from our premium investment platform.",
    "Invest a small amount today and earn large returns tomorrow.",
    "This investment offers risk free guaranteed profits.",
    "Join now and start earning assured daily returns.",

    # ------------------------------------------------------
    # STOCK MARKET / TRADING
    # ------------------------------------------------------

    "Our trading experts guarantee profit from every stock trade.",
    "Join our stock market group for guaranteed daily returns.",
    "Invest in our trading strategy and earn profits every day.",
    "Our trading bot automatically generates guaranteed income.",
    "Start stock trading with our expert guidance and guaranteed returns.",
    "Send money to activate your premium trading account.",
    "Earn daily income using our automated trading system.",
    "Join the VIP trading group and receive guaranteed stock tips.",
    "Our secret trading strategy can double your money.",
    "Invest in today's recommended stocks for guaranteed profit.",
    "Activate your trading account by transferring the registration amount.",
    "Our professional traders guarantee successful investments.",
    "Earn from stock trading without any previous experience.",
    "Join our private trading channel for high profit opportunities.",

    # ------------------------------------------------------
    # CRYPTOCURRENCY / DIGITAL INVESTMENT
    # ------------------------------------------------------

    "Invest in cryptocurrency and earn guaranteed daily profits.",
    "Our crypto trading platform guarantees high returns.",
    "Buy this digital currency now before the price increases.",
    "Invest in our crypto plan and double your money.",
    "Earn passive income from our automated cryptocurrency system.",
    "Transfer funds to start your cryptocurrency investment.",
    "Our crypto experts guarantee profitable trades every day.",
    "Join the exclusive crypto investment group now.",
    "Get guaranteed returns from digital currency trading.",
    "Invest in this new cryptocurrency before everyone else.",
    "Our crypto investment program has zero risk and high profit.",
    "Start earning daily income from our digital asset platform.",
    "Send money now to secure your crypto investment position.",
    "Our cryptocurrency strategy guarantees consistent profits.",
    "Invest today in digital assets and receive fast returns.",

    # ------------------------------------------------------
    # URGENT / LIMITED INVESTMENT OFFERS
    # ------------------------------------------------------

    "Limited investment opportunity available today only.",
    "Invest immediately before this profitable opportunity closes.",
    "Only a few investment positions are remaining.",
    "This exclusive investment offer expires tonight.",
    "Join now before the guaranteed return program closes.",
    "Invest today to secure your place in this opportunity.",
    "Last chance to participate in our high profit investment.",
    "Only selected investors can join this premium program.",
    "Transfer funds now before the investment deadline.",
    "This investment opportunity is closing within hours.",
    "Act immediately to receive the special investment benefits.",
    "Reserve your investment position before all slots are filled.",
    "Today is the final day to join our profit program.",
    "Limited seats are available for this exclusive investment.",
    "Invest quickly before the opportunity disappears.",

    # ------------------------------------------------------
    # PASSIVE INCOME / BUSINESS OPPORTUNITIES
    # ------------------------------------------------------

    "Earn passive income every day from our investment system.",
    "Start earning without working through our automated investment plan.",
    "Build a second income through our guaranteed investment program.",
    "Earn money while you sleep with our investment strategy.",
    "Receive daily payments from your investment account.",
    "Invest your savings and receive monthly profit payments.",
    "Join thousands of investors earning daily income.",
    "Generate extra income through our exclusive investment method.",
    "Start your passive income journey with a small investment.",
    "Our investment platform provides regular guaranteed payouts.",
    "Earn recurring profits from our managed investment service.",
    "Invest today and create a reliable source of income.",

    # ------------------------------------------------------
    # MONEY TRANSFER FOR INVESTMENT
    # ------------------------------------------------------

    "Transfer Rs 1000 to begin your investment.",
    "Send the investment amount now to activate your account.",
    "Deposit funds immediately to secure guaranteed returns.",
    "Make the initial investment payment today.",
    "Transfer money to our account to join the investment program.",
    "Pay the registration amount before starting your investment.",
    "Send Rs 5000 now and begin earning profits.",
    "Deposit the required amount to activate your investment plan.",
    "Transfer funds today to receive your investment benefits.",
    "Make payment now to reserve your investment opportunity.",
]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 80

print()
print(
    f"New INVESTMENT examples: "
    f"{len(new_investment_messages)}"
)

if len(new_investment_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new INVESTMENT examples."
    )


# ==========================================================
# PREVENT DUPLICATES
# ==========================================================

existing_messages = {
    item["message"].strip().lower()
    for item in data
}

duplicates = []

for message in new_investment_messages:

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

for message in new_investment_messages:

    data.append(
        {
            "message": message,
            "category": "INVESTMENT",
        }
    )


# ==========================================================
# VALIDATE FINAL COUNT
# ==========================================================

investment_count = sum(
    1
    for item in data
    if item["category"] == "INVESTMENT"
)

print()
print(
    f"Final INVESTMENT count: "
    f"{investment_count}"
)

if investment_count != 100:
    raise ValueError(
        "Expected final INVESTMENT count "
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