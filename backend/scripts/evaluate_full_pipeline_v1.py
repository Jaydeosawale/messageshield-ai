from pathlib import Path
import json
import sys
from collections import Counter


# ==========================================================
# ADD BACKEND ROOT TO PYTHON PATH
# ==========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

sys.path.insert(
    0,
    str(BASE_DIR),
)


# ==========================================================
# IMPORT PIPELINE
# ==========================================================

from app.ml.classifier import predict_message
from app.ml.safety_classifier import predict_safety
from app.services.risk_service import assess_risk


# ==========================================================
# PATHS
# ==========================================================

TEST_DATA_PATH = (
    BASE_DIR
    / "data"
    / "messages_test_v1.json"
)


# ==========================================================
# EXPECTED SAFETY LABEL
# ==========================================================

SAFE_CATEGORIES = {
    "GENERAL",
}


def get_expected_safety(category: str) -> str:
    """
    Temporary evaluation mapping.

    GENERAL messages are considered SAFE.

    Other categories are treated as SCAM/risky for
    end-to-end security evaluation.

    This can be improved later when the test dataset
    contains explicit safety labels.
    """

    if category in SAFE_CATEGORIES:
        return "SAFE"

    return "SCAM"


# ==========================================================
# MAIN
# ==========================================================

def main():

    print()

    print("=" * 70)
    print("MESSAGE SHIELD FULL PIPELINE EVALUATION V1")
    print("=" * 70)


    # ======================================================
    # LOAD TEST DATA
    # ======================================================

    with open(
        TEST_DATA_PATH,
        "r",
        encoding="utf-8",
    ) as file:

        test_data = json.load(file)


    print()

    print(
        f"Total test examples: "
        f"{len(test_data)}"
    )


    # ======================================================
    # METRICS
    # ======================================================

    total_examples = 0

    category_correct = 0

    safety_correct = 0

    risk_distribution = Counter()

    category_results = Counter()

    false_negatives = []

    dangerous_failures = []

    critical_override_count = 0


    # ======================================================
    # PROCESS TEST DATA
    # ======================================================

    for item in test_data:

        message = item["message"]

        expected_category = item["category"]

        expected_safety = (
            get_expected_safety(
                expected_category
            )
        )


        # --------------------------------------------------
        # CATEGORY MODEL
        # --------------------------------------------------

        category_result = (
            predict_message(
                message
            )
        )

        predicted_category = (
            category_result["category"]
        )

        category_confidence = (
            category_result["confidence"]
        )


        # --------------------------------------------------
        # SAFETY MODEL
        # --------------------------------------------------

        safety_result = (
            predict_safety(
                message
            )
        )

        predicted_safety = (
            safety_result[
                "safety_label"
            ]
        )

        safety_confidence = (
            safety_result[
                "confidence"
            ]
        )


        # --------------------------------------------------
        # RISK ENGINE
        # --------------------------------------------------

        risk_result = (
            assess_risk(
                message=message,
                category=predicted_category,
                confidence=category_confidence,
                safety_label=predicted_safety,
                safety_confidence=safety_confidence,
            )
        )


        predicted_risk = (
            risk_result["risk"]
        )


        # ==================================================
        # UPDATE METRICS
        # ==================================================

        total_examples += 1


        # --------------------------------------------------
        # CATEGORY ACCURACY
        # --------------------------------------------------

        if (
            predicted_category
            == expected_category
        ):

            category_correct += 1


        # --------------------------------------------------
        # SAFETY ACCURACY
        # --------------------------------------------------

        if (
            predicted_safety
            == expected_safety
        ):

            safety_correct += 1


        # --------------------------------------------------
        # RISK DISTRIBUTION
        # --------------------------------------------------

        risk_distribution[
            predicted_risk
        ] += 1


        # --------------------------------------------------
        # CATEGORY RESULTS
        # --------------------------------------------------

        category_results[
            (
                expected_category,
                predicted_category,
            )
        ] += 1


        # --------------------------------------------------
        # CRITICAL OVERRIDE COUNT
        # --------------------------------------------------

        if risk_result.get(
            "critical_override",
            False,
        ):

            critical_override_count += 1


        # --------------------------------------------------
        # FALSE NEGATIVES
        #
        # Expected SCAM
        # But final risk LOW
        # --------------------------------------------------

        if (
            expected_safety == "SCAM"
            and predicted_risk == "LOW"
        ):

            false_negatives.append(
                {
                    "message": message,
                    "expected_category":
                        expected_category,
                    "predicted_category":
                        predicted_category,
                    "predicted_safety":
                        predicted_safety,
                    "risk":
                        predicted_risk,
                    "risk_score":
                        risk_result[
                            "risk_score"
                        ],
                }
            )


        # --------------------------------------------------
        # DANGEROUS FAILURES
        #
        # Expected SCAM
        # But safety model says SAFE
        # AND risk is LOW
        # --------------------------------------------------

        if (
            expected_safety == "SCAM"
            and predicted_safety == "SAFE"
            and predicted_risk == "LOW"
        ):

            dangerous_failures.append(
                {
                    "message": message,
                    "expected_category":
                        expected_category,
                    "predicted_category":
                        predicted_category,
                    "risk_score":
                        risk_result[
                            "risk_score"
                        ],
                }
            )


    # ======================================================
    # FINAL METRICS
    # ======================================================

    category_accuracy = (
        category_correct
        / total_examples
    )

    safety_accuracy = (
        safety_correct
        / total_examples
    )


    # ======================================================
    # PRINT RESULTS
    # ======================================================

    print()

    print("=" * 70)
    print("OVERALL RESULTS")
    print("=" * 70)

    print()

    print(
        f"Category Accuracy: "
        f"{category_accuracy:.4f}"
    )

    print(
        f"Safety Accuracy:   "
        f"{safety_accuracy:.4f}"
    )

    print(
        f"Critical Overrides: "
        f"{critical_override_count}"
    )


    # ======================================================
    # RISK DISTRIBUTION
    # ======================================================

    print()

    print("=" * 70)
    print("RISK DISTRIBUTION")
    print("=" * 70)

    print()

    for risk_level in [
        "LOW",
        "MEDIUM",
        "HIGH",
    ]:

        print(
            f"{risk_level}: "
            f"{risk_distribution[risk_level]}"
        )


    # ======================================================
    # FALSE NEGATIVES
    # ======================================================

    print()

    print("=" * 70)
    print(
        f"FALSE NEGATIVES: "
        f"{len(false_negatives)}"
    )
    print("=" * 70)


    for failure in false_negatives[:20]:

        print()

        print(
            "Message:"
        )

        print(
            failure["message"]
        )

        print(
            "Expected category:",
            failure[
                "expected_category"
            ],
        )

        print(
            "Predicted category:",
            failure[
                "predicted_category"
            ],
        )

        print(
            "Safety:",
            failure[
                "predicted_safety"
            ],
        )

        print(
            "Risk:",
            failure[
                "risk"
            ],
        )

        print(
            "Risk score:",
            failure[
                "risk_score"
            ],
        )


    # ======================================================
    # DANGEROUS FAILURES
    # ======================================================

    print()

    print("=" * 70)
    print(
        f"DANGEROUS FAILURES: "
        f"{len(dangerous_failures)}"
    )
    print("=" * 70)


    for failure in dangerous_failures[:20]:

        print()

        print(
            "Message:"
        )

        print(
            failure["message"]
        )

        print(
            "Expected category:",
            failure[
                "expected_category"
            ],
        )

        print(
            "Predicted category:",
            failure[
                "predicted_category"
            ],
        )

        print(
            "Risk score:",
            failure[
                "risk_score"
            ],
        )


    # ======================================================
    # SAVE REPORT
    # ======================================================

    report_path = (
        BASE_DIR
        / "models"
        / "full_pipeline_evaluation_v1.json"
    )


    report = {
        "total_examples": total_examples,
        "category_accuracy":
            float(category_accuracy),
        "safety_accuracy":
            float(safety_accuracy),
        "risk_distribution":
            dict(risk_distribution),
        "critical_overrides":
            critical_override_count,
        "false_negative_count":
            len(false_negatives),
        "dangerous_failure_count":
            len(dangerous_failures),
        "false_negatives":
            false_negatives,
        "dangerous_failures":
            dangerous_failures,
    }


    with open(
        report_path,
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            report,
            file,
            indent=4,
            ensure_ascii=False,
        )


    print()

    print(
        "Evaluation report saved to:"
    )

    print(
        report_path
    )


    print()

    print("=" * 70)
    print("EVALUATION COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()