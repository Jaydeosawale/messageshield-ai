from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_login_rate_limit():
    for _ in range(5):
        response = client.post(
            "/api/v1/auth/login",
            json={
                "email": "jaydeo@example.com",
                "password": "wrong_password",
            },
        )

        assert response.status_code in [
            401,
            429,
        ]

    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "jaydeo@example.com",
            "password": "wrong_password",
        },
    )

    assert response.status_code == 429