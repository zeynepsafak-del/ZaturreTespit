import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_production_environment_simulation():
    """
    Backend canlı ortamda (Production) çalışıyor mu simülasyon testi
    """
    # Uygulamanın ayakta olduğunu health endpoint üzerinden teyit ediyoruz
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_mobile_app_connection():
    """
    Mobil uygulama backend'e bağlanabiliyor mu (CORS Testi)
    """
    # Origin başlığı ile mobil uygulamadan geliyormuş gibi istek atıyoruz
    headers = {"Origin": "http://localhost:flutter"}
    response = client.get("/health", headers=headers)
    assert response.status_code == 200
    # CORS ayarları doğru yapıldıysa headers kısmında access-control-allow-origin döner
    assert "access-control-allow-origin" in response.headers

def test_end_to_end_prediction():
    """
    Tahmin sonucu uçtan uca alınabiliyor mu testi
    """
    # Test ortamında uygulamanın başladığını varsaymak adına modeli yüklüyoruz
    app.router.startup()
    
    dummy_image = b"integration_test_image_bytes"
    files = {"file": ("e2e_test.jpg", dummy_image, "image/jpeg")}
    
    response = client.post("/predict", files=files)
    
    assert response.status_code == 200
    data = response.json()
    assert "prediction" in data
    assert "confidence" in data
    assert data["prediction"] in ["Normal", "Zatürre"]
