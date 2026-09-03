import json
from collections import Counter
from pathlib import Path


DATA_PATH = Path("data/messages_v15.json")
OUTPUT_PATH = Path("models/category_drift_baseline.json")


def build_category_baseline() -> None:
    if not DATA_PATH.exists():
        raise FileNotFoundError(
            f"Training dataset not found: {DATA_PATH}"
        )

    with DATA_PATH.open("r", encoding="utf-8") as file:
        data = json.load(file)

    if not isinstance(data, list) or not data:
        raise ValueError("Training dataset must be a non-empty list.")

    categories = [
        item["category"]
        for item in data
        if isinstance(item, dict) and "category" in item
    ]

    if len(categories) != len(data):
        raise ValueError(
            "Every training example must contain a category."
        )

    counts = Counter(categories)
    total = len(categories)

    distribution = {
        category: count / total
        for category, count in sorted(counts.items())
    }

    baseline = {
        "dataset": DATA_PATH.name,
        "total_examples": total,
        "category_count": len(distribution),
        "categories": distribution,
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    with OUTPUT_PATH.open("w", encoding="utf-8") as file:
        json.dump(baseline, file, indent=2)
        file.write("\n")

    print("Category drift baseline created.")
    print(f"Dataset: {DATA_PATH}")
    print(f"Examples: {total}")
    print(f"Categories: {len(distribution)}")
    print(f"Output: {OUTPUT_PATH}")

    print("\nBaseline distribution:")
    for category, probability in distribution.items():
        print(f"  {category}: {probability:.2%}")


if __name__ == "__main__":
    build_category_baseline()
