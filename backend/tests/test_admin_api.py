from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def get_token(
    email: str,
    password: str,
):
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": email,
            "password": password,
        },
    )

    assert response.status_code == 200

    return response.json()["access_token"]


def test_admin_stats_without_token():
    response = client.get(
        "/api/v1/admin/stats",
    )

    assert response.status_code == 401


def test_admin_stats_with_regular_user():
    token = get_token(
        email="user@example.com",
        password="TestUserPassword123!",
    )

    response = client.get(
        "/api/v1/admin/stats",
        headers={
            "Authorization": f"Bearer {token}",
        },
    )

    assert response.status_code == 403


def test_admin_stats_with_admin():
    token = get_token(
        email="jaydeo@example.com",
        password="StrongPassword123!",
    )

    response = client.get(
        "/api/v1/admin/stats",
        headers={
            "Authorization": f"Bearer {token}",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert "total_analyses" in data
    assert "risk_distribution" in data
    assert "category_distribution" in data