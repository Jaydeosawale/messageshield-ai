from app.db.session import SessionLocal
from app.services.analysis_service import analyze_message


def test_otp_analysis():
    db = SessionLocal()

    try:
        result = analyze_message(
            message="Your OTP is 123456. Do not share this code.",
            db=db,
        )

        assert "safe_message" in result
        assert "category" in result
        assert "confidence" in result
        assert "risk" in result
        assert "signals" in result

        assert result["category"] == "OTP_OR_SECURITY"

    finally:
        db.close()


def test_otp_is_redacted():
    db = SessionLocal()

    try:
        result = analyze_message(
            message="Your OTP is 123456.",
            db=db,
        )

        assert "123456" not in result["safe_message"]
        assert "[OTP_REDACTED]" in result["safe_message"]

    finally:
        db.close()