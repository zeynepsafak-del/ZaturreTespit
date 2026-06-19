# Base image olarak hafif bir Python sürümü seçiyoruz
FROM python:3.9-slim

# Çalışma dizinini ayarlıyoruz
WORKDIR /app

# Gereksinimleri kopyalayıp kuruyoruz
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kaynak kodları kopyalıyoruz
COPY . .

# Konteynerın dışarıya açacağı port
EXPOSE 8000

# Backend'i canlı ortamda (production) çalıştırmak için komut
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
