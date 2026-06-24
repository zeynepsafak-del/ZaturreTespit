import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.model_loader import ModelLoader

model_loader = ModelLoader()

@asynccontextmanager
async def lifespan(app: FastAPI):
    model_loader.load_model()
    yield

app = FastAPI(title="Zatürre Tespit Backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "message": "Backend ayakta ve çalışıyor",
        "model_loaded": model_loader.is_loaded,
    }

@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):
    try:
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="Hata: Sadece görsel dosyaları yükleyebilirsiniz.")

        file_bytes = await file.read()
        if not file_bytes:
            raise HTTPException(status_code=400, detail="Hata: Yüklenen dosya boş.")

        if not model_loader.is_loaded:
            raise HTTPException(status_code=500, detail="Hata: Yapay zeka modeli henüz yüklenmedi.")

        result = await asyncio.get_event_loop().run_in_executor(
            None, model_loader.predict, file_bytes
        )

        return {
            "filename": file.filename,
            "content_type": file.content_type,
            **result,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Sunucu hatası: {str(e)}")
