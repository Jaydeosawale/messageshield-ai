from app.services.analysis_service import analyze_message


def test_otp_analysis(db, seed_users):
    result = analyze_message(
        message="Your OTP is 123456. Do not share this code.",
        user_id=seed_users["user"].id,
        db=db,
    )

    assert "safe_message" in result
    assert "category" in result
    assert "safety" in result
    assert "risk" in result

    assert result["category"]["label"] == "OTP"


def test_otp_is_redacted(db, seed_users):
    result = analyze_message(
        message="Your OTP is 123456.",
        user_id=seed_users["user"].id,
        db=db,
    )

    assert "123456" not in result["safe_message"]
    assert "[OTP_REDACTED]" in result["safe_message"]
