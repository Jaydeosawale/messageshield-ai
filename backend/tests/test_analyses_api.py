def test_get_analyses(authenticated_client):
    response = authenticated_client.get(
        "/api/v1/analyses"
    )

    assert response.status_code == 200

    data = response.json()

    assert "total" in data
    assert "skip" in data
    assert "limit" in data
    assert "returned" in data
    assert "items" in data
    assert isinstance(data["items"], list)


def test_get_analyses_with_pagination(authenticated_client):
    response = authenticated_client.get(
        "/api/v1/analyses?skip=0&limit=10"
    )

    assert response.status_code == 200

    data = response.json()

    assert data["skip"] == 0
    assert data["limit"] == 10
    assert data["returned"] <= 10


def test_analysis_not_found(authenticated_client):
    response = authenticated_client.get(
        "/api/v1/analyses/999999"
    )

    assert response.status_code == 404

    data = response.json()

    assert data["error"]["code"] == "ANALYSIS_NOT_FOUND"
    assert data["error"]["message"] == "Analysis not found"
