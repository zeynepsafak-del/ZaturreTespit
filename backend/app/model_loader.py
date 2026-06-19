class ModelLoader:
    def __init__(self):
        self.is_loaded = False
        self.model = None

    def load_model(self):
        # Gerçek bir ML modelini yüklemek için gerekli kod buraya gelecek (Örn: PyTorch/TensorFlow)
        # Şimdilik modelin belleğe yüklendiğini simüle ediyoruz
        print("Model belleğe yükleniyor...")
        self.model = "Zaturre_Tespit_Modeli_v1"
        self.is_loaded = True
        print("Model başarıyla yüklendi!")
        return self.is_loaded
