from pathlib import Path
import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
import io

MODEL_PATH = Path(__file__).parent.parent / "models" / "EfficientNet-B0.pth"

# Notebook'taki hesaplanan piksel istatistikleri
IMG_MEAN = 0.5099
IMG_STD = 0.2546
IMG_SIZE = 224

LABELS = {0: "Normal", 1: "Zatürre"}

eval_transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[IMG_MEAN], std=[IMG_STD]),
])


def _build_efficientnet_b0() -> nn.Module:
    model = models.efficientnet_b0(weights=None)
    first_conv = model.features[0][0]
    model.features[0][0] = nn.Conv2d(
        1,
        first_conv.out_channels,
        kernel_size=first_conv.kernel_size,
        stride=first_conv.stride,
        padding=first_conv.padding,
        bias=False,
    )
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, 2)
    return model


class ModelLoader:
    def __init__(self):
        self.is_loaded = False
        self.model: nn.Module | None = None
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    def load_model(self):
        print("Model belleğe yükleniyor...")
        net = _build_efficientnet_b0()
        state = torch.load(MODEL_PATH, map_location=self.device, weights_only=True)
        net.load_state_dict(state)
        net.to(self.device)
        net.eval()
        self.model = net
        self.is_loaded = True
        print(f"Model başarıyla yüklendi! ({self.device})")

    def predict(self, image_bytes: bytes) -> dict:
        image = Image.open(io.BytesIO(image_bytes)).convert("L")
        tensor = eval_transform(image).unsqueeze(0).to(self.device)

        with torch.no_grad():
            outputs = self.model(tensor)
            probs = torch.softmax(outputs, dim=1)[0]
            pred_idx = probs.argmax().item()

        return {
            "prediction": LABELS[pred_idx],
            "confidence": round(probs[pred_idx].item(), 4),
            "probabilities": {
                "Normal": round(probs[0].item(), 4),
                "Zatürre": round(probs[1].item(), 4),
            },
        }
