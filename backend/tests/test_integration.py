import io
import pytest
from PIL import Image
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def _make_jpeg_bytes(size=(224, 224)) -> bytes:
    img = Image.new("RGB", size, color=(100, 100, 100))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


def test_production_environment_simulation():
    """
    Backend canlı ortamda (Production) çalışıyor mu simülasyon testi
    """
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_mobile_app_connection():
    """
    Mobil uygulama backend'e bağlanabiliyor mu (CORS Testi)
    """
    headers = {"Origin": "http://localhost:flutter"}
    response = client.get("/health", headers=headers)
    assert response.status_code == 200
    assert "access-control-allow-origin" in response.headers


def test_end_to_end_prediction():
    """
    Tahmin sonucu uçtan uca alınabiliyor mu testi
    """
    with TestClient(app) as client:
        files = {"file": ("e2e_test.jpg", _make_jpeg_bytes(), "image/jpeg")}

        response = client.post("/predict", files=files)

        assert response.status_code == 200
        data = response.json()
        assert "prediction" in data
        assert "confidence" in data
        assert data["prediction"] in ["Normal", "Zatürre"]
