from fastapi import FastAPI
from app.api.endpoints import health, predict

app = FastAPI(title="Zatürre Tespit Backend API", version="1.0.0")

app.include_router(health.router, prefix="/health", tags=["Health"])
app.include_router(predict.router, prefix="/predict", tags=["Prediction"])

@app.get("/")
def root():
    return {"message": "Zatürre Tespit API'sine Hoş Geldiniz!"}
