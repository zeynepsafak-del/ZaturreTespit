from fastapi.testclient import TestClient
from app.main import app
from app.model_loader import ModelLoader

client = TestClient(app)

def test_backend_starts_and_health_check_responds():
    """
    Backend ayağa kalkıyor mu ve Health endpoint cevap veriyor mu testi
    """
    # FastAPI test client kullanıldığında startup event otomatik tetiklenmeyebilir (FastAPI versiyonuna bağlı),
    # bu yüzden açıkça yüklemeyi sağlıyoruz veya app'in lifecycle'ı içinde olduğunu farz ediyoruz.
    # Health endpointine istek atalım:
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
    
    # Başlangıçta yüklenmemiş olmalı
    assert loader.is_loaded == False
    assert loader.model is None
    
    # Yükleme metodunu çağırıyoruz
    loader.load_model()
    
    # Yükleme başarılı mı?
    assert loader.is_loaded == True
    assert loader.model == "Zaturre_Tespit_Modeli_v1"

def test_api_accepts_image_and_returns_prediction():
    """
    API görsel kabul ediyor mu ve Tahmin endpointi cevap veriyor mu testi
    """
    with TestClient(app) as client:
        # Uygulama başlarken modelin bellekte olduğundan emin olalım
        app.router.startup()

        dummy_image_data = b"fake_image_content"
        files = {"file": ("test_image.jpg", dummy_image_data, "image/jpeg")}
        
        response = client.post("/predict", files=files)
        
        assert response.status_code == 200
        json_resp = response.json()
        assert json_resp["filename"] == "test_image.jpg"
        assert json_resp["prediction"] == "Normal"
        assert "confidence" in json_resp

def test_file_validation_works():
    """
    Hatalı dosya kontrolü çalışıyor mu testi
    """
    with TestClient(app) as client:
        dummy_text_data = b"This is just a text file."
        files = {"file": ("test_doc.txt", dummy_text_data, "text/plain")}
        
        response = client.post("/predict", files=files)
        
        assert response.status_code == 400
        assert response.json()["detail"] == "Hata: Sadece görsel dosyaları yükleyebilirsiniz."
