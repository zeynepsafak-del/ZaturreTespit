from fastapi import FastAPI
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
