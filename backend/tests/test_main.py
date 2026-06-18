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
