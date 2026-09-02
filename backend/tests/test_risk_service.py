from app.services.risk_service import assess_risk


def test_urgent_otp_and_cvv_is_high_risk():
    result = assess_risk(
        message="URGENT: share the OTP and CVV immediately",
        category="OTP",
        confidence=0.95,
        safety_label="SCAM",
        safety_confidence=0.95,
    )

    assert result["risk"] == "HIGH"
    assert result["risk_score"] >= 70
    assert "OTP_REQUEST" in {
        signal["type"]
        for signal in result["signals"]
    }


def test_genuine_security_warning_is_low_risk():
    result = assess_risk(
        message=(
            "Never share your OTP, CVV, PIN "
            "or password with anyone."
        ),
        category="OTP",
        confidence=0.95,
        safety_label="SAFE",
        safety_confidence=0.95,
    )

    assert result["risk"] == "LOW"
    assert result["risk_score"] < 40


def test_otp_delivery_is_low_risk():
    result = assess_risk(
        message=(
            "Your OTP is 123456. "
            "Do not share this OTP with anyone."
        ),
        category="OTP",
        confidence=0.95,
        safety_label="SAFE",
        safety_confidence=0.95,
    )

    assert result["risk"] == "LOW"
    assert result["risk_score"] < 40


def test_account_threat_with_otp_request_is_high_risk():
    result = assess_risk(
        message=(
            "URGENT! Your bank account will be blocked. "
            "Share the OTP immediately to verify your account."
        ),
        category="OTP",
        confidence=0.90,
        safety_label="SCAM",
        safety_confidence=0.90,
    )

    assert result["risk"] == "HIGH"
    assert result["risk_score"] >= 70


def test_suspicious_link_is_high_risk():
    result = assess_risk(
        message=(
            "Your account is suspended. "
            "Click here immediately to restore access: "
            "http://fake-bank.com"
        ),
        category="OTP",
        confidence=0.90,
        safety_label="SCAM",
        safety_confidence=0.90,
    )

    assert result["risk"] == "HIGH"
    assert result["risk_score"] >= 70


def test_normal_transaction_notification_is_not_high_risk():
    result = assess_risk(
        message=(
            "Your account was debited by ₹500. "
            "If this was not you, contact your bank immediately."
        ),
        category="BANKING",
        confidence=0.90,
        safety_label="SAFE",
        safety_confidence=0.90,
    )

    assert result["risk"] != "HIGH"


def test_fake_prize_is_suspicious():
    result = assess_risk(
        message=(
            "Congratulations! You have won a cash prize. "
            "Pay the processing fee immediately to claim your reward."
        ),
        category="SCAM",
        confidence=0.90,
        safety_label="SCAM",
        safety_confidence=0.90,
    )

    assert result["risk"] == "HIGH"


def test_bank_warning_alone_is_not_scam():
    result = assess_risk(
        message=(
            "For your security, your bank will never ask "
            "you to share your OTP or PIN."
        ),
        category="OTP",
        confidence=0.90,
        safety_label="SAFE",
        safety_confidence=0.90,
    )

    assert result["risk"] == "LOW"
