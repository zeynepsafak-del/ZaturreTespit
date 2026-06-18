from fastapi import FastAPI, UploadFile, File, HTTPException
from app.model_loader import ModelLoader

app = FastAPI(title="Zatürre Tespit Backend")
model_loader = ModelLoader()

@app.on_event("startup")
async def startup_event():
    # Backend ayağa kalkarken model belleğe yüklenir
    model_loader.load_model()

@app.get("/health")
def health_check():
    # Health endpoint: Sistemin ayakta olup olmadığını ve modelin yüklendiğini doğrular
    return {
        "status": "ok", 
        "message": "Backend ayakta ve çalışıyor",
        "model_loaded": model_loader.is_loaded
    }

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    # Hatalı dosya kontrolü: Sadece görselleri kabul ediyoruz
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Hata: Sadece görsel dosyaları yükleyebilirsiniz.")
    
    # Modelin belleğe yüklendiğinden emin olalım
    if not model_loader.is_loaded:
        raise HTTPException(status_code=500, detail="Hata: Yapay zeka modeli henüz yüklenmedi.")

    # Dosya okuma (ileride modelin inputuna verilecek)
    file_bytes = await file.read()
    
    # Temsili tahmin sonucu
    return {
        "filename": file.filename,
        "content_type": file.content_type,
        "prediction": "Normal", # Sprint 4'te gerçek model bağlanacak
        "confidence": 0.95
    }
