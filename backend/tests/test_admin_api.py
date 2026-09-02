from fastapi.testclient import TestClient

from app.main import app


def test_admin_stats_without_token(client):
    response = client.get(
        "/api/v1/admin/stats",
    )

    assert response.status_code == 401


def test_admin_stats_with_regular_user(authenticated_client):
    response = authenticated_client.get(
        "/api/v1/admin/stats",
    )

    assert response.status_code == 403


def test_admin_stats_with_admin(client, seed_users):
    from app.core.security import create_access_token

    token = create_access_token(
        str(seed_users["admin"].id)
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
