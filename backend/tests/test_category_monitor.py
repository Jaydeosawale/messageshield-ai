from app.models.message_analysis import MessageAnalysis
from mlops.drift.category_monitor import monitor_category_model


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


def make_prediction(
    user_id,
    category,
    model_name="MessageShieldCategoryModel",
    model_version="4",
):
    return MessageAnalysis(
        user_id=user_id,
        safe_message=f"test {category}",
        category=category,
        confidence=0.90,
        probabilities={},
        safety_label="SAFE",
        safety_confidence=0.90,
        safety_probabilities={},
        risk="LOW",
        risk_score=10,
        signals=[],
        model_name=model_name,
        model_version=model_version,
        safety_model_name="MessageShieldSafetyModel",
        safety_model_version="5",
    )


def test_monitor_returns_insufficient_data_for_missing_model_version(
    db,
    seed_users,
):
    result = monitor_category_model(
        db,
        model_name="MessageShieldCategoryModel",
        model_version="4",
        limit=100,
    )

    assert result["sample_count"] == 0
    assert result["psi"] is None
    assert result["status"] == "INSUFFICIENT_DATA"
    assert result["current_distribution"] == {}


def test_monitor_calculates_normal_drift(
    db,
    seed_users,
):
    user_id = seed_users["user"].id

    rows = [
        make_prediction(user_id, category)
        for category in CATEGORIES
    ]

    db.add_all(rows)
    db.flush()

    result = monitor_category_model(
        db,
        model_name="MessageShieldCategoryModel",
        model_version="4",
        limit=10,
    )

    assert result["sample_count"] == 10
    assert result["psi"] == 0.0
    assert result["status"] == "NORMAL"

    for category in CATEGORIES:
        assert result["current_distribution"][category] == 0.10


def test_monitor_detects_strong_drift(
    db,
    seed_users,
):
    user_id = seed_users["user"].id

    # Deliberately shifted distribution:
    # BANKING 50%, all other categories ~5.56%.
    rows = [
        *[
            make_prediction(user_id, "BANKING")
            for _ in range(50)
        ],
        *[
            make_prediction(user_id, category)
            for category in CATEGORIES
            if category != "BANKING"
            for _ in range(5)
        ],
    ]

    db.add_all(rows)
    db.flush()

    result = monitor_category_model(
        db,
        model_name="MessageShieldCategoryModel",
        model_version="4",
        limit=95,
    )

    assert result["sample_count"] == 95
    assert result["psi"] > 0.25
    assert result["status"] == "DRIFT"
