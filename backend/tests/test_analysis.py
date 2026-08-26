def test_analyze_message(client):
    response = client.post(
        "/api/v1/analyze",
        json={
            "message": (
                "URGENT! Your account is blocked. "
                "Send OTP immediately."
            )
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert "id" in data
    assert data["safe_message"]

    assert data["category"] in [
        "NORMAL",
        "OTP_OR_SECURITY",
        "PAYMENT",
        "PROMOTION",
    ]

    assert 0 <= data["confidence"] <= 1

    assert data["risk"] in [
        "LOW",
        "MEDIUM",
        "HIGH",
    ]

    assert "risk_score" in data
    assert isinstance(data["signals"], list)
    assert isinstance(data["probabilities"], dict)

    assert data["model"]["name"] == "MessageShieldModel"
    assert data["model"]["version"] == "1"

    assert "created_at" in data