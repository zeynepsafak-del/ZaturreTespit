from fastapi import APIRouter, File, UploadFile, HTTPException

router = APIRouter()

@router.post("/")
async def predict_pneumonia(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Lütfen geçerli bir görsel dosyası yükleyin.")
    
    # İleride yapay zeka modeline (PyTorch/TensorFlow) gönderilecek yer
    return {
        "filename": file.filename,
        "content_type": file.content_type,
        "status": "processing_ready",
        "message": "Görsel alındı, model analizi için hazır."
    }
