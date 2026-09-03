from app.models.message_analysis import MessageAnalysis
from mlops.drift.category_distribution import get_category_distribution


def test_returns_empty_distribution_when_model_version_has_no_predictions(db, seed_users):
    db.add(
        MessageAnalysis(
            user_id=seed_users["user"].id,
            safe_message="old prediction",
            category="OTP_OR_SECURITY",
            confidence=0.40,
            probabilities={},
            safety_label="SAFE",
            safety_confidence=0.90,
            safety_probabilities={},
            risk="LOW",
            risk_score=10,
            signals=[],
            model_name="MessageShieldModel",
            model_version="1",
            safety_model_name="MessageShieldSafetyModel",
            safety_model_version="1",
        )
    )
    db.flush()

    distribution, sample_count = get_category_distribution(
        db,
        model_name="MessageShieldCategoryModel",
        model_version="4",
        limit=100,
    )

    assert distribution == {}
    assert sample_count == 0


def test_filters_predictions_by_model_name_and_version(db, seed_users):
    rows = [
        MessageAnalysis(
            user_id=seed_users["user"].id,
            safe_message="v1 prediction",
            category="OTP_OR_SECURITY",
            confidence=0.40,
            probabilities={},
            safety_label="SAFE",
            safety_confidence=0.90,
            safety_probabilities={},
            risk="LOW",
            risk_score=10,
            signals=[],
            model_name="MessageShieldModel",
            model_version="1",
            safety_model_name="MessageShieldSafetyModel",
            safety_model_version="1",
        ),
        MessageAnalysis(
            user_id=seed_users["user"].id,
            safe_message="v4 banking",
            category="BANKING",
            confidence=0.90,
            probabilities={},
            safety_label="SCAM",
            safety_confidence=0.90,
            safety_probabilities={},
            risk="HIGH",
            risk_score=80,
            signals=[],
            model_name="MessageShieldCategoryModel",
            model_version="4",
            safety_model_name="MessageShieldSafetyModel",
            safety_model_version="5",
        ),
        MessageAnalysis(
            user_id=seed_users["user"].id,
            safe_message="v4 otp",
            category="OTP",
            confidence=0.90,
            probabilities={},
            safety_label="SAFE",
            safety_confidence=0.90,
            safety_probabilities={},
            risk="LOW",
            risk_score=10,
            signals=[],
            model_name="MessageShieldCategoryModel",
            model_version="4",
            safety_model_name="MessageShieldSafetyModel",
            safety_model_version="5",
        ),
        MessageAnalysis(
            user_id=seed_users["user"].id,
            safe_message="v4 otp again",
            category="OTP",
            confidence=0.80,
            probabilities={},
            safety_label="SAFE",
            safety_confidence=0.90,
            safety_probabilities={},
            risk="LOW",
            risk_score=10,
            signals=[],
            model_name="MessageShieldCategoryModel",
            model_version="4",
            safety_model_name="MessageShieldSafetyModel",
            safety_model_version="5",
        ),
    ]

    db.add_all(rows)
    db.flush()

    distribution, sample_count = get_category_distribution(
        db,
        model_name="MessageShieldCategoryModel",
        model_version="4",
        limit=100,
    )

    assert sample_count == 3
    assert distribution == {
        "BANKING": 1 / 3,
        "OTP": 2 / 3,
    }


def test_limit_controls_number_of_recent_predictions(db, seed_users):
    rows = [
        MessageAnalysis(
            user_id=seed_users["user"].id,
            safe_message=f"prediction {index}",
            category="BANKING",
            confidence=0.90,
            probabilities={},
            safety_label="SAFE",
            safety_confidence=0.90,
            safety_probabilities={},
            risk="LOW",
            risk_score=10,
            signals=[],
            model_name="MessageShieldCategoryModel",
            model_version="4",
            safety_model_name="MessageShieldSafetyModel",
            safety_model_version="5",
        )
        for index in range(5)
    ]

    db.add_all(rows)
    db.flush()

    distribution, sample_count = get_category_distribution(
        db,
        model_name="MessageShieldCategoryModel",
        model_version="4",
        limit=3,
    )

    assert sample_count == 3
    assert distribution == {
        "BANKING": 1.0,
    }


def test_invalid_limit_is_rejected(db, seed_users):
    try:
        get_category_distribution(
            db,
            model_name="MessageShieldCategoryModel",
            model_version="4",
            limit=0,
        )
        assert False, "Expected ValueError"
    except ValueError as exc:
        assert str(exc) == "limit must be greater than zero."
