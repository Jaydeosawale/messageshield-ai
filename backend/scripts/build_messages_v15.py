import json
from pathlib import Path
from collections import Counter


# ==========================================================
# PATHS
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

INPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v14.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_v15.json"
)


# ==========================================================
# LOAD EXISTING DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD DATASET V15 BUILDER")
print("=" * 60)

with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:
    data = json.load(file)


# ==========================================================
# NEW PROMOTION EXAMPLES
# ==========================================================

new_promotion_messages = [

    # ------------------------------------------------------
    # DISCOUNTS
    # ------------------------------------------------------

    "Get 10 percent off on your next purchase.",
    "Enjoy 20 percent discount on selected products.",
    "Save 30 percent when you shop today.",
    "Get up to 50 percent off on selected items.",
    "Limited time discount available now.",
    "Special discount for all customers today.",
    "Save big with our exclusive discount.",
    "Extra savings available on your favorite products.",
    "Unlock amazing discounts when you shop now.",
    "Save more with our limited time sale.",
    "Get special prices on selected items.",
    "Exclusive discount available for members.",
    "Shop today and enjoy instant savings.",
    "Save up to 40 percent on your purchase.",
    "Special price reduction available now.",
    "Get great savings before the offer ends.",
    "Discount prices available for a limited time.",

    # ------------------------------------------------------
    # SALES
    # ------------------------------------------------------

    "Our weekend sale starts today.",
    "The mega sale is now live.",
    "Shop during our special seasonal sale.",
    "Big sale available on selected products.",
    "The year end sale has started.",
    "Enjoy amazing prices during our sale.",
    "Our flash sale ends tonight.",
    "Special sale prices are available now.",
    "The holiday sale is now open.",
    "Don't miss our special weekend sale.",
    "The clearance sale starts now.",
    "Great deals are available in our sale.",
    "Our special shopping event begins today.",
    "Shop more and save during the sale.",
    "Sale prices available while stocks last.",
    "Discover new deals in our latest sale.",
    "Special sale offers are ending soon.",
    "Enjoy reduced prices across selected products.",

    # ------------------------------------------------------
    # OFFERS
    # ------------------------------------------------------

    "Special offer available just for you.",
    "Don't miss this limited time offer.",
    "A new exclusive offer is now available.",
    "Claim our special shopping offer today.",
    "Enjoy this offer before it expires.",
    "Limited time offer on selected products.",
    "Get exclusive benefits with this special offer.",
    "A fantastic offer is waiting for you.",
    "Today's special offer is now live.",

    "Take advantage of our latest offer.",
    "An exclusive customer offer is available now.",
    "Shop now to enjoy this special offer.",
    "Your personalized offer is ready.",
    "New promotional offers are available today.",
    "Explore our special limited time offers.",

    # ------------------------------------------------------
    # BUY NOW / SHOP NOW
    # ------------------------------------------------------

    "Shop now and discover amazing deals.",
    "Buy now and enjoy special savings.",
    "Shop your favorite products today.",
    "Explore new products at great prices.",
    "Buy today before the offer ends.",
    "Start shopping and save more.",
    "Shop now for exclusive deals.",
    "Discover special products at discounted prices.",
    "Buy your favorites at special prices.",
    "Explore our latest collection now.",
    "Find exciting deals when you shop today.",
    "Shop selected items at reduced prices.",
    "Buy more and save more today.",
    "Start shopping before the promotion ends.",

    # ------------------------------------------------------
    # COUPONS / VOUCHERS
    # ------------------------------------------------------

    "Use your coupon to save on your next order.",
    "A special coupon is available for you.",
    "Apply the discount coupon at checkout.",
    "Get extra savings with our coupon code.",
    "Your shopping voucher is now available.",
    "Redeem your voucher on selected products.",
    "Use this promotional code to save more.",
    "A new voucher offer is available today.",
    "Apply your coupon before it expires.",
    "Get instant savings using our promo code.",
    "Your exclusive coupon is ready to use.",

    # ------------------------------------------------------
    # BUNDLE / BUY MORE
    # ------------------------------------------------------

    "Buy two products and get special savings.",
    "Buy one and get another at a reduced price.",
    "Enjoy bundle savings on selected products.",
    "Purchase more items and unlock extra discounts.",
    "Get more value with our product bundles.",
    "Buy selected products together and save.",
    "Enjoy extra savings when you buy multiple items.",
    "Special multi buy offer available now.",
    "Get a bonus item with selected purchases.",

    # ------------------------------------------------------
    # MEMBERS / LOYALTY PROMOTIONS
    # ------------------------------------------------------

    "Exclusive member deals are available today.",
    "Enjoy special benefits as a valued customer.",
    "Members can access exclusive shopping offers.",
    "Unlock loyalty rewards on your next purchase.",
    "Special customer deals are now available.",
    "Enjoy exclusive savings as a registered member.",
    "Your loyalty offer is ready to use.",
    "Get member only prices on selected products.",
    "Exclusive rewards are available for loyal customers.",
    "Enjoy special shopping benefits today.",
]


# ==========================================================
# VALIDATE NEW EXAMPLES
# ==========================================================

EXPECTED_NEW_EXAMPLES = 94

print()
print(
    f"New PROMOTION examples: "
    f"{len(new_promotion_messages)}"
)

if len(new_promotion_messages) != EXPECTED_NEW_EXAMPLES:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_NEW_EXAMPLES} new PROMOTION examples."
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

for message in new_promotion_messages:

    normalized = message.strip().lower()

    if normalized in existing_messages:
        duplicates.append(
            f"Already exists: {message}"
        )

    if normalized in new_messages_seen:
        duplicates.append(
            f"Duplicate new message: {message}"
        )

    new_messages_seen.add(normalized)


if duplicates:

    print()
    print("Duplicate messages found:")

    for message in duplicates:
        print(f"- {message}")

    raise ValueError(
        "New examples contain duplicates."
    )


# ==========================================================
# ADD NEW DATA
# ==========================================================

for message in new_promotion_messages:

    data.append(
        {
            "message": message,
            "category": "PROMOTION",
        }
    )


# ==========================================================
# VALIDATE PROMOTION COUNT
# ==========================================================

promotion_count = sum(
    1
    for item in data
    if item["category"] == "PROMOTION"
)

print()
print(
    f"Final PROMOTION count: "
    f"{promotion_count}"
)

if promotion_count != 100:
    raise ValueError(
        "Expected final PROMOTION count "
        "to be exactly 100."
    )


# ==========================================================
# VALIDATE ALL CATEGORY COUNTS
# ==========================================================

category_counts = Counter(
    item["category"]
    for item in data
)

expected_categories = [
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

print()
print("FINAL CATEGORY DISTRIBUTION:")
print()

for category in expected_categories:

    count = category_counts.get(
        category,
        0,
    )

    print(
        f"{category}: {count}"
    )

    if count != 100:
        raise ValueError(
            f"Expected {category} "
            f"to have exactly 100 examples, "
            f"but found {count}."
        )


# ==========================================================
# VALIDATE TOTAL DATASET SIZE
# ==========================================================

EXPECTED_TOTAL = 1000

print()
print(
    f"Total dataset examples: "
    f"{len(data)}"
)

if len(data) != EXPECTED_TOTAL:
    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_TOTAL} total examples."
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
print("Dataset saved to:")
print(OUTPUT_PATH)

print()
print("=" * 60)
print("BUILD COMPLETE")
print("=" * 60)
