def test_analyze_message(authenticated_client):
    response = authenticated_client.post(
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

    # Current live API response is structured.
    assert "category" in data
    assert isinstance(data["category"], dict)
    assert data["category"]["label"]
    assert 0 <= data["category"]["confidence"] <= 1
    assert isinstance(
        data["category"]["probabilities"],
        dict,
    )
    assert data["category"]["model"]["name"] == (
        "MessageShieldCategoryModel"
    )
    assert data["category"]["model"]["version"] == "4"

    assert "safety" in data
    assert isinstance(data["safety"], dict)
    assert data["safety"]["label"] in [
        "SAFE",
        "SCAM",
    ]
    assert 0 <= data["safety"]["confidence"] <= 1
    assert isinstance(
        data["safety"]["probabilities"],
        dict,
    )
    assert data["safety"]["model"]["name"] == (
        "MessageShieldSafetyModel"
    )
    assert data["safety"]["model"]["version"] == "5"

    assert "risk" in data
    assert isinstance(data["risk"], dict)
    assert data["risk"]["level"] in [
        "LOW",
        "MEDIUM",
        "HIGH",
    ]
    assert isinstance(data["risk"]["score"], int)
    assert isinstance(data["risk"]["signals"], list)

    assert "created_at" in data
