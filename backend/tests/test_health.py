from fastapi.testclient import TestClient

from app.main import app
from app.core.app_config import (
    APP_NAME,
    APP_VERSION,
)


client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200

    assert response.json() == {
        "status": "ok",
        "service": APP_NAME,
        "version": APP_VERSION,
    }