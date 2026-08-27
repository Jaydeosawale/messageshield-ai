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
    / "messages_test_v1.json"
)

OUTPUT_PATH = (
    BASE_DIR
    / "data"
    / "messages_test_v2.json"
)


# ==========================================================
# EXPECTED CONFIGURATION
# ==========================================================

EXPECTED_TOTAL = 200

EXPECTED_CATEGORIES = {
    "BANKING": 20,
    "DELIVERY": 20,
    "GENERAL": 20,
    "IMPERSONATION": 20,
    "INVESTMENT": 20,
    "JOB": 20,
    "OTP": 20,
    "PAYMENT": 20,
    "PHISHING": 20,
    "PROMOTION": 20,
}

VALID_SAFETY_LABELS = {
    "SAFE",
    "SCAM",
}


# ==========================================================
# EXPLICIT SCAM CATEGORIES
# ==========================================================

ALWAYS_SCAM_CATEGORIES = {
    "IMPERSONATION",
    "PHISHING",
}


# ==========================================================
# LOAD DATA
# ==========================================================

print()
print("=" * 60)
print("MESSAGE SHIELD TEST DATASET V2 BUILDER")
print("=" * 60)

if not INPUT_PATH.exists():

    raise FileNotFoundError(
        f"Input dataset not found:\n{INPUT_PATH}"
    )


with open(
    INPUT_PATH,
    "r",
    encoding="utf-8",
) as file:

    data = json.load(file)


print()
print(
    f"Input examples loaded: "
    f"{len(data)}"
)


# ==========================================================
# VALIDATE INPUT TOTAL
# ==========================================================

if len(data) != EXPECTED_TOTAL:

    raise ValueError(
        f"Expected exactly "
        f"{EXPECTED_TOTAL} input examples, "
        f"but found {len(data)}."
    )


# ==========================================================
# VALIDATE INPUT STRUCTURE
# ==========================================================

for index, item in enumerate(data):

    if "message" not in item:

        raise ValueError(
            f"Example {index} "
            f"is missing 'message'."
        )

    if "category" not in item:

        raise ValueError(
            f"Example {index} "
            f"is missing 'category'."
        )

    if not isinstance(
        item["message"],
        str,
    ):

        raise ValueError(
            f"Example {index} "
            f"has invalid message type."
        )

    if not item["message"].strip():

        raise ValueError(
            f"Example {index} "
            f"has an empty message."
        )


# ==========================================================
# VALIDATE CATEGORY DISTRIBUTION
# ==========================================================

category_counts = Counter(
    item["category"]
    for item in data
)


print()
print("INPUT CATEGORY DISTRIBUTION")

for category in sorted(
    category_counts
):

    print(
        f"{category}: "
        f"{category_counts[category]}"
    )


for category, expected_count in (
    EXPECTED_CATEGORIES.items()
):

    actual_count = (
        category_counts.get(
            category,
            0,
        )
    )

    if actual_count != expected_count:

        raise ValueError(
            f"Category {category} "
            f"expected {expected_count}, "
            f"found {actual_count}."
        )


# ==========================================================
# DETECT DUPLICATES
# ==========================================================

seen_messages = {}

duplicates = []

for index, item in enumerate(data):

    normalized = (
        item["message"]
        .strip()
        .lower()
    )

    if normalized in seen_messages:

        duplicates.append(
            {
                "first_index": (
                    seen_messages[normalized]
                ),
                "duplicate_index": index,
                "message": item["message"],
            }
        )

    else:

        seen_messages[
            normalized
        ] = index


if duplicates:

    print()
    print("DUPLICATE MESSAGES FOUND:")

    for duplicate in duplicates:

        print()

        print(
            f"First index: "
            f"{duplicate['first_index']}"
        )

        print(
            f"Duplicate index: "
            f"{duplicate['duplicate_index']}"
        )

        print(
            f"Message: "
            f"{duplicate['message']}"
        )

    raise ValueError(
        "Duplicate messages found "
        "in test dataset."
    )


print()
print(
    "Duplicate validation: PASSED"
)


# ==========================================================
# SAFETY LABELING RULES
# ==========================================================

def determine_safety_label(
    message: str,
    category: str,
):
    """
    Assign explicit SAFE or SCAM labels.

    Category is used only as a starting point.
    Message content determines mixed-category cases.
    """

    message_lower = (
        message.lower()
    )

    # ------------------------------------------------------
    # ALWAYS SCAM
    # ------------------------------------------------------

    if category in ALWAYS_SCAM_CATEGORIES:

        return "SCAM"


    # ------------------------------------------------------
    # GENERAL
    # ------------------------------------------------------

    if category == "GENERAL":

        return "SAFE"


    # ------------------------------------------------------
    # BANKING
    # ------------------------------------------------------

    if category == "BANKING":

        return "SAFE"


    # ------------------------------------------------------
    # DELIVERY
    # ------------------------------------------------------

    if category == "DELIVERY":

        scam_patterns = [

            "pay rs",

            "pay now",

            "pay the",

            "payment",

            "fee",

            "transfer money",

            "send money",

            "release your",

            "blocked",

            "destroyed",

            "cancelled",

            "return",

        ]

        if any(
            pattern in message_lower
            for pattern in scam_patterns
        ):

            return "SCAM"

        return "SAFE"


    # ------------------------------------------------------
    # OTP
    # ------------------------------------------------------

    if category == "OTP":

        scam_patterns = [

            "share your otp",

            "share the otp",

            "send the otp",

            "provide the otp",

            "tell me the otp",

            "forward the otp",

            "share otp",

            "send otp",

            "provide otp",

            "tell me otp",

            "share the code",

            "send the code",

            "provide the code",

        ]

        if any(
            pattern in message_lower
            for pattern in scam_patterns
        ):

            return "SCAM"

        return "SAFE"


    # ------------------------------------------------------
    # PAYMENT
    # ------------------------------------------------------

    if category == "PAYMENT":

        scam_patterns = [

            "pay now",

            "pay rs",

            "transfer money",

            "send money",

            "cashback",

            "refund fee",

            "verification amount",

            "scan the qr",

            "upi pin",

            "receive money",

            "claim your",

        ]

        if any(
            pattern in message_lower
            for pattern in scam_patterns
        ):

            return "SCAM"

        return "SAFE"


    # ------------------------------------------------------
    # INVESTMENT
    # ------------------------------------------------------

    if category == "INVESTMENT":

        scam_patterns = [

            "guaranteed return",

            "guaranteed returns",

            "assured returns",

            "guarantee",

            "guarantees",

            "profit regardless",

            "grow rapidly",

            "exclusive opportunity",

            "secure your place",

            "special wealth",

            "automated trading",

        ]

        if any(
            pattern in message_lower
            for pattern in scam_patterns
        ):

            return "SCAM"

        return "SAFE"


    # ------------------------------------------------------
    # JOB
    # ------------------------------------------------------

    if category == "JOB":

        scam_patterns = [

            "pay a processing fee",

            "paying the registration",

            "registration charge",

            "joining payment",

            "verification fee",

            "deposit before",

            "payment before",

            "application charge",

            "processing fee",

            "training charge",

            "fee payment",

            "send money",

            "pay the",

        ]

        if any(
            pattern in message_lower
            for pattern in scam_patterns
        ):

            return "SCAM"

        return "SAFE"


    # ------------------------------------------------------
    # PROMOTION
    # ------------------------------------------------------

    if category == "PROMOTION":

        scam_patterns = [

            "you have won",

            "claim your prize",

            "guaranteed reward",

            "pay to claim",

            "send money",

            "transfer money",

            "processing fee",

        ]

        if any(
            pattern in message_lower
            for pattern in scam_patterns
        ):

            return "SCAM"

        return "SAFE"


    raise ValueError(
        f"Unknown category: {category}"
    )


# ==========================================================
# BUILD V2 DATASET
# ==========================================================

final_data = []


for item in data:

    message = (
        item["message"]
        .strip()
    )

    category = (
        item["category"]
        .strip()
        .upper()
    )

    safety_label = (
        determine_safety_label(
            message,
            category,
        )
    )

    final_data.append(
        {
            "message": message,
            "category": category,
            "safety_label": safety_label,
        }
    )


# ==========================================================
# VALIDATE FINAL TOTAL
# ==========================================================

if len(final_data) != EXPECTED_TOTAL:

    raise ValueError(
        f"Expected final total "
        f"{EXPECTED_TOTAL}, "
        f"found {len(final_data)}."
    )


# ==========================================================
# VALIDATE SAFETY LABELS
# ==========================================================

for index, item in enumerate(final_data):

    safety_label = (
        item.get(
            "safety_label"
        )
    )

    if safety_label not in (
        VALID_SAFETY_LABELS
    ):

        raise ValueError(
            f"Invalid safety label "
            f"at index {index}: "
            f"{safety_label}"
        )


print()
print(
    "Safety label validation: PASSED"
)


# ==========================================================
# FINAL CATEGORY DISTRIBUTION
# ==========================================================

final_category_counts = Counter(
    item["category"]
    for item in final_data
)


print()
print("=" * 60)
print(
    "FINAL CATEGORY DISTRIBUTION"
)
print("=" * 60)

for category in sorted(
    EXPECTED_CATEGORIES
):

    count = (
        final_category_counts[
            category
        ]
    )

    print(
        f"{category}: {count}"
    )

    if count != (
        EXPECTED_CATEGORIES[
            category
        ]
    ):

        raise ValueError(
            f"Final category validation "
            f"failed for {category}."
        )


# ==========================================================
# SAFETY DISTRIBUTION
# ==========================================================

safety_counts = Counter(
    item["safety_label"]
    for item in final_data
)


print()
print("=" * 60)
print(
    "SAFE / SCAM DISTRIBUTION"
)
print("=" * 60)

print(
    f"SAFE: "
    f"{safety_counts.get('SAFE', 0)}"
)

print(
    f"SCAM: "
    f"{safety_counts.get('SCAM', 0)}"
)


# ==========================================================
# VALIDATE SAFE / SCAM TOTAL
# ==========================================================

safety_total = sum(
    safety_counts.values()
)

if safety_total != EXPECTED_TOTAL:

    raise ValueError(
        "Safety label total "
        "does not match dataset total."
    )


if safety_counts.get(
    "SAFE",
    0,
) == 0:

    raise ValueError(
        "No SAFE examples found."
    )


if safety_counts.get(
    "SCAM",
    0,
) == 0:

    raise ValueError(
        "No SCAM examples found."
    )


# ==========================================================
# VALIDATE FINAL STRUCTURE
# ==========================================================

for index, item in enumerate(final_data):

    required_fields = {

        "message",

        "category",

        "safety_label",

    }

    missing_fields = (
        required_fields
        - set(item.keys())
    )

    if missing_fields:

        raise ValueError(
            f"Example {index} "
            f"is missing fields: "
            f"{missing_fields}"
        )


print()
print(
    "Final structure validation: PASSED"
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
        final_data,
        file,
        indent=4,
        ensure_ascii=False,
    )


print()
print(
    f"Total test examples: "
    f"{len(final_data)}"
)

print()
print("Test dataset saved to:")

print(
    OUTPUT_PATH
)

print()
print("=" * 60)
print("BUILD COMPLETE")
print("=" * 60)
