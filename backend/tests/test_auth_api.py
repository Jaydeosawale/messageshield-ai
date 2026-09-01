def test_login_success(client, seed_users):
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "jaydeo@example.com",
            "password": "StrongPassword123!",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert "access_token" in data
    assert data["token_type"] == "bearer"



def test_check_email_exists(client, seed_users):
    response = client.post(
        "/api/v1/auth/check-email",
        json={
            "email": "jaydeo@example.com",
        },
    )

    assert response.status_code == 200
    assert response.json()["exists"] is True


def test_check_email_does_not_exist(client, seed_users):
    response = client.post(
        "/api/v1/auth/check-email",
        json={
            "email": "new-user@example.com",
        },
    )

    assert response.status_code == 200
    assert response.json()["exists"] is False
    
def test_login_invalid_password(client, seed_users):
    response = client.post(
        "/api/v1/auth/login",
        json={
            "email": "jaydeo@example.com",
            "password": "wrong_password_123",
        },
    )

    assert response.status_code == 401