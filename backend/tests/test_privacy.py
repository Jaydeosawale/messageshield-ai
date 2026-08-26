from app.services.privacy_service import redact
def test_redacts_otp():
    assert "123456" not in redact("Your OTP is 123456")
