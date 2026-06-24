import io
import torch.nn as nn
from PIL import Image
from fastapi.testclient import TestClient
from app.main import app
from app.model_loader import ModelLoader


def _make_jpeg_bytes(size=(224, 224)) -> bytes:
    img = Image.new("RGB", size, color=(128, 128, 128))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


client = TestClient(app)


def test_backend_starts_and_health_check_responds():
    """
    Backend ayağa kalkıyor mu ve Health endpoint cevap veriyor mu testi
    """
    response = client.get("/health")
    assert response.status_code == 200
    json_resp = response.json()
    assert json_resp["status"] == "ok"
    assert "Backend ayakta" in json_resp["message"]


def test_model_loads_into_memory():
    """
    Model belleğe yükleniyor mu testi
    """
    loader = ModelLoader()

    assert loader.is_loaded == False
    assert loader.model is None

    loader.load_model()

    assert loader.is_loaded == True
    assert isinstance(loader.model, nn.Module)


def test_api_accepts_image_and_returns_prediction():
    """
    API görsel kabul ediyor mu ve Tahmin endpointi cevap veriyor mu testi
    """
    with TestClient(app) as client:
        files = {"file": ("test_image.jpg", _make_jpeg_bytes(), "image/jpeg")}

        response = client.post("/predict", files=files)

        assert response.status_code == 200
        json_resp = response.json()
        assert json_resp["filename"] == "test_image.jpg"
        assert json_resp["prediction"] in ["Normal", "Zatürre"]
        assert "confidence" in json_resp


def test_file_validation_works():
    """
    Hatalı dosya kontrolü çalışıyor mu testi
    """
    with TestClient(app) as client:
        files = {"file": ("test_doc.txt", b"This is just a text file.", "text/plain")}

        response = client.post("/predict", files=files)

        assert response.status_code == 400
        assert "Sadece görsel" in response.json()["detail"]


def test_error_handling_empty_file():
    """
    Boş dosya yüklendiğinde hata yönetimi çalışıyor mu testi
    """
    with TestClient(app) as client:
        files = {"file": ("empty.jpg", b"", "image/jpeg")}

        response = client.post("/predict", files=files)

        assert response.status_code == 400
        assert "boş" in response.json()["detail"]


def test_api_performance_is_sufficient():
    """
    API performansı yeterli mi testi (Yanıt süresi ölçümü)
    """
    import time
    with TestClient(app) as client:
        files = {"file": ("perf.jpg", _make_jpeg_bytes(), "image/jpeg")}

        start_time = time.time()
        response = client.post("/predict", files=files)
        end_time = time.time()

        assert response.status_code == 200
        assert (end_time - start_time) < 10.0
