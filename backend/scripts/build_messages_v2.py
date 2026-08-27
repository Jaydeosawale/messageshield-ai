from pathlib import Path
import json

import pandas as pd


# ==========================================
# Paths
# ==========================================

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_DIR = BASE_DIR / "data"
RAW_DIR = DATA_DIR / "raw"

OLD_DATASET = DATA_DIR / "messages.json"

OUTPUT_FILE = DATA_DIR / "messages_v2.json"


# ==========================================
# CSV files
# ==========================================

CSV_FILES = [
    RAW_DIR / "phishing.csv",
    RAW_DIR / "otp_fraud.csv",
    RAW_DIR / "upi_fraud.csv",
    RAW_DIR / "legitimate.csv",
]


# ==========================================
# Category mapping
# ==========================================

CATEGORY_MAPPING = {

    # ----------------------
    # Phishing
    # ----------------------
    "PHISHING": "PHISHING",

    # ----------------------
    # OTP
    # ----------------------
    "OTP_FRAUD": "OTP_OR_SECURITY",

    "OTP_NOTIFICATION": "NORMAL",

    # ----------------------
    # Payment fraud
    # ----------------------
    "UPI_PAYMENT_FRAUD": "PAYMENT",

    "QR_CODE_FRAUD": "PAYMENT",

    # Legitimate payment messages
    "UPI_TRANSACTION": "NORMAL",

    "UPI_NOTIFICATION": "NORMAL",

    "PAYMENT_CONFIRMATION": "NORMAL",

    # ----------------------
    # Legitimate messages
    # ----------------------
    "BANK_TRANSACTION": "NORMAL",

    "PERSONAL_NOTIFICATION": "NORMAL",

    "SECURITY_NOTIFICATION": "NORMAL",

    "DELIVERY_UPDATE": "NORMAL",

    "BILL_NOTIFICATION": "NORMAL",

    # ----------------------
    # Promotion
    # ----------------------
    "PROMOTION": "PROMOTION",

    "LOTTERY": "PROMOTION",

    "REWARD": "PROMOTION",
}


# ==========================================
# Load existing dataset
# ==========================================

def load_old_dataset():

    if not OLD_DATASET.exists():

        print(
            "Old dataset not found."
        )

        return []

    with open(
        OLD_DATASET,
        encoding="utf-8",
    ) as file:

        data = json.load(file)

    print(
        f"Loaded old dataset: "
        f"{len(data)} examples"
    )

    return data


# ==========================================
# Load CSV datasets
# ==========================================

def load_csv_datasets():

    examples = []

    for csv_file in CSV_FILES:

        if not csv_file.exists():

            print(
                f"WARNING: Missing file: "
                f"{csv_file}"
            )

            continue

        df = pd.read_csv(csv_file)

        print(
            f"Loaded {csv_file.name}: "
            f"{len(df)} rows"
        )

        for _, row in df.iterrows():

            text = str(
                row["text"]
            ).strip()

            raw_category = str(
                row["category"]
            ).strip().upper()

            label = str(
                row["label"]
            ).strip().upper()

            if not text:
                continue

            # --------------------------
            # Category mapping
            # --------------------------

            mapped_category = (
                CATEGORY_MAPPING.get(
                    raw_category
                )
            )

            # --------------------------
            # Fallback based on label
            # --------------------------

            if mapped_category is None:

                if label == "SAFE":
                    mapped_category = "NORMAL"

                elif label == "SCAM":
                    mapped_category = "PHISHING"

                else:
                    print(
                        "Skipping unknown row:"
                    )

                    print(
                        raw_category
                    )

                    continue

            examples.append(
                {
                    "message": text,
                    "category": mapped_category,
                }
            )

    return examples


# ==========================================
# Deduplicate
# ==========================================

def deduplicate(examples):

    seen = set()

    cleaned = []

    for item in examples:

        message = (
            item["message"]
            .strip()
        )

        normalized = (
            message
            .lower()
        )

        if normalized in seen:
            continue

        seen.add(
            normalized
        )

        cleaned.append(
            {
                "message": message,
                "category": item["category"],
            }
        )

    return cleaned


# ==========================================
# Main
# ==========================================

def main():

    print(
        "\n===== BUILDING MESSAGE DATASET V2 =====\n"
    )

    old_examples = (
        load_old_dataset()
    )

    csv_examples = (
        load_csv_datasets()
    )

    all_examples = (
        old_examples +
        csv_examples
    )

    print(
        f"\nBefore deduplication: "
        f"{len(all_examples)}"
    )

    final_examples = (
        deduplicate(
            all_examples
        )
    )

    print(
        f"After deduplication: "
        f"{len(final_examples)}"
    )

    # ----------------------
    # Statistics
    # ----------------------

    category_counts = {}

    for item in final_examples:

        category = (
            item["category"]
        )

        category_counts[
            category
        ] = (
            category_counts.get(
                category,
                0,
            )
            + 1
        )

    print(
        "\nCategory distribution:"
    )

    for category, count in sorted(
        category_counts.items()
    ):

        print(
            f"{category}: {count}"
        )

    # ----------------------
    # Save
    # ----------------------

    with open(
        OUTPUT_FILE,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            final_examples,
            file,
            indent=2,
            ensure_ascii=False,
        )

    print(
        f"\nSaved dataset to:"
    )

    print(
        OUTPUT_FILE
    )

    print(
        "\n===== COMPLETE ====="
    )


if __name__ == "__main__":
    main()
