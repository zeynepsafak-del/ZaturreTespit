import asyncio
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.model_loader import ModelLoader

app = FastAPI(title="Zatürre Tespit Backend")

# Mobil uygulama backend'e bağlanabilsin diye CORS ayarları (Backend son düzenlemesi)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Canlı ortamda sadece mobil uygulamanın origin'i girilmeli
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
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
    try:
        # Hatalı dosya kontrolü: Sadece görselleri kabul ediyoruz
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="Hata: Sadece görsel dosyaları yükleyebilirsiniz.")
        
        # Dosya boş mu kontrolü
        file_bytes = await file.read()
        if not file_bytes:
            raise HTTPException(status_code=400, detail="Hata: Yüklenen dosya boş.")
        
        # Modelin belleğe yüklendiğinden emin olalım
        if not model_loader.is_loaded:
            raise HTTPException(status_code=500, detail="Hata: Yapay zeka modeli henüz yüklenmedi.")

        # Backend Optimizasyonu: CPU yoğun işlemlerin (ML Tahmini) asenkron çalışması simülasyonu
        # Gerçek model entegrasyonunda run_in_executor kullanılmalıdır.
        await asyncio.sleep(0.5)
        
        # Temsili tahmin sonucu (Sprint 4 tamamlandı)
        # Boyuta göre rastgele risk simülasyonu (Sadece örneklem)
        risk = 15.0 if len(file_bytes) % 2 == 0 else 85.5
        prediction = "Normal" if risk < 50.0 else "Zatürre"

        return {
            "filename": file.filename,
            "content_type": file.content_type,
            "prediction": prediction,
            "confidence": risk / 100.0
        }
    except HTTPException:
        raise
    except Exception as e:
        # Beklenmeyen hata yönetimi
        raise HTTPException(status_code=500, detail=f"Sunucu hatası: {str(e)}")
