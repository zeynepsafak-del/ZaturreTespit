from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    assert "Hoş Geldiniz" in response.json()["message"]

def test_health_check_endpoint():
    response = client.get("/health/")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "message": "Backend is running smoothly!"}

def test_predict_endpoint_invalid_file():
    # Hatalı dosya yükleme (resim olmayan dosya)
    files = {"file": ("test.txt", b"dummy content", "text/plain")}
    response = client.post("/predict/", files=files)
    assert response.status_code == 400
    assert response.json()["detail"] == "Lütfen geçerli bir görsel dosyası yükleyin."

def test_predict_endpoint_valid_image():
    # Geçerli dosya yükleme simülasyonu
    files = {"file": ("test.png", b"dummy image data", "image/png")}
    response = client.post("/predict/", files=files)
    assert response.status_code == 200
    assert response.json()["status"] == "processing_ready"
