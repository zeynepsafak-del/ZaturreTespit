import os

def test_backend_structure():
    # Klasör yapısı testi
    assert os.path.exists("app/main.py")
    assert os.path.exists("app/api/endpoints/health.py")
    assert os.path.exists("app/api/endpoints/predict.py")
