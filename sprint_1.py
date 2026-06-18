# 1. IMPORTS
# %matplotlib inline

from pathlib import Path
from PIL import Image, UnidentifiedImageError
from collections import Counter

import gc
import copy
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import torch
import torch.nn as nn
import torch.optim as optim

from torch.utils.data import Dataset, DataLoader, random_split
from torchvision import transforms, models

from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

# 2. SABİTLER
DATASET_ROOT = Path(r"C:\Users\WinOn\Desktop\data\raw\Chest-X-Ray Epic Hospital Chittagong, Bangladesh pneumonia")

IMG_SIZE = 224
BATCH_SIZE = 16
VAL_RATIO = 0.2
SEED = 42

NUM_EPOCHS = 5
PATIENCE = 3

torch.manual_seed(SEED)
np.random.seed(SEED)

# 3. YARDIMCI FONKSİYONLAR
def find_dir_case_insensitive(parent, folder_name):
    parent = Path(parent)

    if not parent.exists():
        raise FileNotFoundError(f"Klasör bulunamadı: {parent}")

    for p in parent.iterdir():
        if p.is_dir() and p.name.lower() == folder_name.lower():
            return p

    raise FileNotFoundError(f"{parent} içinde '{folder_name}' klasörü bulunamadı.")


def list_images(folder):
    valid_exts = {".jpg", ".jpeg", ".png", ".bmp"}
    return sorted([
        p for p in Path(folder).rglob("*")
        if p.suffix.lower() in valid_exts
    ])


def check_image_file(img_path):
    try:
        with Image.open(img_path) as img:
            img.verify()
        return True, None
    except (UnidentifiedImageError, OSError, IOError) as e:
        return False, str(e)


def show_images(image_paths, title, n=6):
    n = min(n, len(image_paths))

    plt.figure(figsize=(12, 6))

    for i in range(n):
        img = Image.open(image_paths[i]).convert("L")

        plt.subplot(2, 3, i + 1)
        plt.imshow(img, cmap="gray")
        plt.title(image_paths[i].name)
        plt.axis("off")

    plt.suptitle(title)
    plt.tight_layout()
    plt.show()

# 4. KLASÖRLER
train_dir = find_dir_case_insensitive(DATASET_ROOT, "Training")
test_dir = find_dir_case_insensitive(DATASET_ROOT, "Testing")

train_normal_dir = find_dir_case_insensitive(train_dir, "normal")
train_pneumonia_dir = find_dir_case_insensitive(train_dir, "pneumonia")

test_normal_dir = find_dir_case_insensitive(test_dir, "normal")
test_pneumonia_dir = find_dir_case_insensitive(test_dir, "pneumonia")

# 5. GÖRÜNTÜLER
train_normal_imgs = list_images(train_normal_dir)
train_pneumonia_imgs = list_images(train_pneumonia_dir)

test_normal_imgs = list_images(test_normal_dir)
test_pneumonia_imgs = list_images(test_pneumonia_dir)

all_images = (
    train_normal_imgs +
    train_pneumonia_imgs +
    test_normal_imgs +
    test_pneumonia_imgs
)

print("Toplam görüntü:", len(all_images))

# 6. SINIF DAĞILIMI
print("\n===== SINIF DAĞILIMI =====")
print("Train normal    :", len(train_normal_imgs))
print("Train pneumonia :", len(train_pneumonia_imgs))
print("Test normal     :", len(test_normal_imgs))
print("Test pneumonia  :", len(test_pneumonia_imgs))

train_counts = [len(train_normal_imgs), len(train_pneumonia_imgs)]
test_counts = [len(test_normal_imgs), len(test_pneumonia_imgs)]

x = np.arange(2)

plt.figure(figsize=(6, 4))
plt.bar(x, train_counts, width=0.4, label="Train", align="center")
plt.bar(x + 0.4, test_counts, width=0.4, label="Test")
plt.xticks(x + 0.2, ["Normal", "Pneumonia"])
plt.ylabel("Görüntü Sayısı")
plt.title("Train vs Test Sınıf Dağılımı")
plt.legend()
plt.tight_layout()
plt.show()

# 7. BOZUK DOSYA KONTROLÜ
bad_files = []

for img_path in all_images:
    ok, err = check_image_file(img_path)
    if not ok:
        bad_files.append((img_path, err))

print("\n===== BOZUK DOSYA KONTROLÜ =====")
print("Toplam görüntü:", len(all_images))
print("Bozuk dosya sayısı:", len(bad_files))

if len(bad_files) > 0:
    print("İlk birkaç bozuk dosya:")
    for p, e in bad_files[:5]:
        print("-", p, "| Hata:", e)

# 8. BOYUT ANALİZİ
records = []

for split_name, label_name, paths in [
    ("train", "normal", train_normal_imgs),
    ("train", "pneumonia", train_pneumonia_imgs),
    ("test", "normal", test_normal_imgs),
    ("test", "pneumonia", test_pneumonia_imgs),
]:
    for p in paths:
        try:
            with Image.open(p) as img:
                w, h = img.size
                mode = img.mode

            records.append({
                "split": split_name,
                "label": label_name,
                "path": str(p),
                "width": w,
                "height": h,
                "mode": mode,
                "ratio": round(w / h, 4) if h != 0 else None
            })
        except:
            pass

df = pd.DataFrame(records)

print("\n===== BOYUT ANALİZİ =====")
print(df[["width", "height"]].describe())

print("\nSınıfa göre boyut özeti:")
print(df.groupby(["split", "label"])[["width", "height"]].agg(["mean", "min", "max"]))

top_sizes = (
    df.groupby(["width", "height"])
    .size()
    .reset_index(name="count")
    .sort_values("count", ascending=False)
    .head(10)
)

print("\nEn sık görülen ilk 10 boyut:")
print(top_sizes)

plt.figure(figsize=(6, 4))
plt.hist(df["width"], bins=30)
plt.xlabel("Width")
plt.ylabel("Count")
plt.title("Görüntü Genişlik Dağılımı")
plt.tight_layout()
plt.show()

plt.figure(figsize=(6, 4))
plt.hist(df["height"], bins=30)
plt.xlabel("Height")
plt.ylabel("Count")
plt.title("Görüntü Yükseklik Dağılımı")
plt.tight_layout()
plt.show()

print("Normal görüntü sayısı:", len(train_normal_imgs))
print("Pneumonia görüntü sayısı:", len(train_pneumonia_imgs))

# 9. ÖRNEK GÖRÜNTÜLER
print("\n===== ÖRNEK GÖRÜNTÜLER =====")
show_images(train_normal_imgs, "Train - Normal Örnekleri", n=6)
show_images(train_pneumonia_imgs, "Train - Pneumonia Örnekleri", n=6)

# 10. PİKSEL İSTATİSTİĞİ
def compute_mean_std(image_paths, img_size=224, max_images=300):
    vals = []

    tfm = transforms.Compose([
        transforms.Resize((img_size, img_size)),
        transforms.ToTensor()
    ])

    paths = image_paths if max_images is None else image_paths[:max_images]

    for p in paths:
        try:
            img = Image.open(p).convert("L")
            x = tfm(img)
            vals.append(x)
        except:
            pass

    stacked = torch.stack(vals, dim=0)

    mean = stacked.mean().item()
    std = stacked.std().item()

    return mean, std


mean_value, std_value = compute_mean_std(
    all_images,
    img_size=IMG_SIZE,
    max_images=300
)

print("\n===== PİKSEL İSTATİSTİĞİ =====")
print(f"Hesaplanan mean: {mean_value:.4f}")
print(f"Hesaplanan std : {std_value:.4f}")

# 11. TRANSFORMS
train_transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(10),
    transforms.ToTensor(),
    transforms.Normalize(mean=[mean_value], std=[std_value if std_value > 0 else 0.5])
])

eval_transform = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[mean_value], std=[std_value if std_value > 0 else 0.5])
])

# 12. DATASET
class ChestXrayDataset(Dataset):
    def __init__(self, split_dir, transform=None):
        self.split_dir = Path(split_dir)
        self.transform = transform

        self.normal_dir = find_dir_case_insensitive(self.split_dir, "normal")
        self.pneumonia_dir = find_dir_case_insensitive(self.split_dir, "pneumonia")

        self.samples = []

        for img_path in list_images(self.normal_dir):
            self.samples.append((img_path, 0))

        for img_path in list_images(self.pneumonia_dir):
            self.samples.append((img_path, 1))

        self.class_to_idx = {"normal": 0, "pneumonia": 1}
        self.idx_to_class = {0: "normal", 1: "pneumonia"}

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        img_path, label = self.samples[idx]

        image = Image.open(img_path).convert("L")

        if self.transform is not None:
            image = self.transform(image)

        return image, label


full_train_dataset = ChestXrayDataset(train_dir, transform=train_transform)
test_dataset = ChestXrayDataset(test_dir, transform=eval_transform)

# 13. TRAIN / VAL SPLIT
val_size = int(len(full_train_dataset) * VAL_RATIO)
train_size = len(full_train_dataset) - val_size

generator = torch.Generator().manual_seed(SEED)

train_dataset, val_dataset = random_split(
    full_train_dataset,
    [train_size, val_size],
    generator=generator
)

# Validation için augmentationsız dataset
full_train_eval_dataset = ChestXrayDataset(train_dir, transform=eval_transform)

train_indices = train_dataset.indices
val_indices = val_dataset.indices


class SubsetWithTransform(Dataset):
    def __init__(self, base_dataset, indices):
        self.base_dataset = base_dataset
        self.indices = indices

    def __len__(self):
        return len(self.indices)

    def __getitem__(self, idx):
        return self.base_dataset[self.indices[idx]]


train_dataset = SubsetWithTransform(full_train_dataset, train_indices)
val_dataset = SubsetWithTransform(full_train_eval_dataset, val_indices)

train_loader = DataLoader(
    train_dataset,
    batch_size=BATCH_SIZE,
    shuffle=True,
    num_workers=0
)

val_loader = DataLoader(
    val_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
    num_workers=0
)

test_loader = DataLoader(
    test_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
    num_workers=0
)

print("\n===== FINAL VERİ SAYILARI =====")
print("Train:", len(train_dataset))
print("Val  :", len(val_dataset))
print("Test :", len(test_dataset))

# 14. BATCH KONTROLÜ VE GÖRSELLEŞTİRME
images, labels = next(iter(train_loader))

print("\nBatch image shape:", images.shape)
print("Batch label shape:", labels.shape)
print("İlk 10 etiket:", labels[:10].tolist())

images_vis = images.clone()
images_vis = images_vis * std_value + mean_value
images_vis = images_vis.clamp(0, 1)

plt.figure(figsize=(10, 6))

for i in range(min(6, len(images_vis))):
    plt.subplot(2, 3, i + 1)
    plt.imshow(images_vis[i].squeeze().cpu().numpy(), cmap="gray")
    plt.title("normal" if labels[i].item() == 0 else "pneumonia")
    plt.axis("off")

plt.tight_layout()
plt.show()

# 15. DEVICE
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("\nKullanılan cihaz:", DEVICE)

# 16. CLASS WEIGHTS
def compute_class_weights(dataset):
    labels = [dataset[i][1] for i in range(len(dataset))]

    counts = Counter(labels)

    n_total = len(labels)
    n_classes = len(counts)

    weights = [
        n_total / (n_classes * counts[c])
        for c in sorted(counts)
    ]

    return torch.tensor(weights, dtype=torch.float)


class_weights = compute_class_weights(train_dataset).to(DEVICE)

print("\nClass weights:", class_weights)

# 17. CUSTOM CNN
class CustomCNN(nn.Module):
    def __init__(self):
        super().__init__()

        self.features = nn.Sequential(
            nn.Conv2d(1, 32, 3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),

            nn.Conv2d(32, 64, 3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),

            nn.Conv2d(64, 128, 3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),

            nn.AdaptiveAvgPool2d((4, 4))
        )

        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(128 * 4 * 4, 256),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(256, 2)
        )

    def forward(self, x):
        x = self.features(x)
        x = self.classifier(x)
        return x

# 18. RESNET18
def build_resnet18():
    model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)

    old_conv = model.conv1

    model.conv1 = nn.Conv2d(
        1,
        old_conv.out_channels,
        kernel_size=old_conv.kernel_size,
        stride=old_conv.stride,
        padding=old_conv.padding,
        bias=False
    )

    model.fc = nn.Linear(model.fc.in_features, 2)

    return model

# 19. EFFICIENTNET-B0
def build_efficientnet_b0():
    model = models.efficientnet_b0(
        weights=models.EfficientNet_B0_Weights.DEFAULT
    )

    first_conv = model.features[0][0]

    model.features[0][0] = nn.Conv2d(
        1,
        first_conv.out_channels,
        kernel_size=first_conv.kernel_size,
        stride=first_conv.stride,
        padding=first_conv.padding,
        bias=False
    )

    model.classifier[1] = nn.Linear(
        model.classifier[1].in_features,
        2
    )

    return model

# 20. TRAIN FUNCTION
def train_model(model, model_name, train_loader, val_loader):
    model = model.to(DEVICE)

    criterion = nn.CrossEntropyLoss(weight=class_weights)

    optimizer = optim.Adam(
        model.parameters(),
        lr=1e-4
    )

    best_acc = 0
    best_weights = copy.deepcopy(model.state_dict())
    patience_counter = 0

    history = {
        "train_acc": [],
        "val_acc": [],
        "train_loss": [],
        "val_loss": []
    }

    for epoch in range(NUM_EPOCHS):

        # ---------------- TRAIN ----------------
        model.train()

        train_correct = 0
        train_total = 0
        train_loss_total = 0

        for images, labels in train_loader:
            images = images.to(DEVICE)
            labels = labels.to(DEVICE)

            optimizer.zero_grad()

            outputs = model(images)
            loss = criterion(outputs, labels)

            loss.backward()
            optimizer.step()

            preds = outputs.argmax(1)

            train_correct += (preds == labels).sum().item()
            train_total += labels.size(0)
            train_loss_total += loss.item() * labels.size(0)

        train_acc = train_correct / train_total
        train_loss = train_loss_total / train_total

        # ---------------- VALIDATION ----------------
        model.eval()

        val_correct = 0
        val_total = 0
        val_loss_total = 0

        with torch.no_grad():
            for images, labels in val_loader:
                images = images.to(DEVICE)
                labels = labels.to(DEVICE)

                outputs = model(images)
                loss = criterion(outputs, labels)

                preds = outputs.argmax(1)

                val_correct += (preds == labels).sum().item()
                val_total += labels.size(0)
                val_loss_total += loss.item() * labels.size(0)

        val_acc = val_correct / val_total
        val_loss = val_loss_total / val_total

        history["train_acc"].append(train_acc)
        history["val_acc"].append(val_acc)
        history["train_loss"].append(train_loss)
        history["val_loss"].append(val_loss)

        print(
            f"{model_name} | "
            f"Epoch {epoch + 1}/{NUM_EPOCHS} | "
            f"Train Loss: {train_loss:.4f} | "
            f"Val Loss: {val_loss:.4f} | "
            f"Train Acc: {train_acc:.4f} | "
            f"Val Acc: {val_acc:.4f}"
        )

        # ---------------- EARLY STOPPING ----------------
        if val_acc > best_acc:
            best_acc = val_acc
            best_weights = copy.deepcopy(model.state_dict())
            patience_counter = 0
        else:
            patience_counter += 1

        if patience_counter >= PATIENCE:
            print("Early stopping çalıştı")
            break

    model.load_state_dict(best_weights)

    return model, history

# 21. TEST FUNCTION
def evaluate_model(model, loader):
    model.eval()

    correct = 0
    total = 0

    all_preds = []
    all_labels = []
    all_probs = []

    with torch.no_grad():
        for images, labels in loader:
            images = images.to(DEVICE)
            labels = labels.to(DEVICE)

            outputs = model(images)
            probs = torch.softmax(outputs, dim=1)
            preds = outputs.argmax(1)

            correct += (preds == labels).sum().item()
            total += labels.size(0)

            all_preds.extend(preds.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
            all_probs.extend(probs.cpu().numpy())

    accuracy = correct / total

    return accuracy, all_preds, all_labels, all_probs

# 22. METRICS
def compute_metrics(preds, labels):
    preds = np.array(preds)
    labels = np.array(labels)

    tp = ((preds == 1) & (labels == 1)).sum()
    tn = ((preds == 0) & (labels == 0)).sum()

    fp = ((preds == 1) & (labels == 0)).sum()
    fn = ((preds == 0) & (labels == 1)).sum()

    accuracy = (tp + tn) / len(labels)

    precision = tp / (tp + fp + 1e-8)
    recall = tp / (tp + fn + 1e-8)

    f1 = (
        2 * precision * recall /
        (precision + recall + 1e-8)
    )

    specificity = tn / (tn + fp + 1e-8)

    return {
        "accuracy": accuracy,
        "precision": precision,
        "recall": recall,
        "f1_score": f1,
        "specificity": specificity
    }

# 23. CONFUSION MATRIX
def plot_confusion_matrix(labels, preds, model_name):
    cm = confusion_matrix(labels, preds)

    disp = ConfusionMatrixDisplay(
        confusion_matrix=cm,
        display_labels=["Normal", "Pneumonia"]
    )

    fig, ax = plt.subplots(figsize=(5, 5))
    disp.plot(ax=ax, cmap="Blues")
    plt.title(f"{model_name} - Confusion Matrix")
    plt.tight_layout()
    plt.show()

    gc.collect()

# 24. ACCURACY + LOSS GRAFİKLERİ
def plot_history(history, model_name):
    epochs = range(1, len(history["train_acc"]) + 1)

    plt.figure(figsize=(7, 5))
    plt.plot(epochs, history["train_acc"], marker="o", label="Train Accuracy")
    plt.plot(epochs, history["val_acc"], marker="o", label="Validation Accuracy")
    plt.title(f"{model_name} - Accuracy Grafiği")
    plt.xlabel("Epoch")
    plt.ylabel("Accuracy")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()

    plt.figure(figsize=(7, 5))
    plt.plot(epochs, history["train_loss"], marker="o", label="Train Loss")
    plt.plot(epochs, history["val_loss"], marker="o", label="Validation Loss")
    plt.title(f"{model_name} - Loss Grafiği")
    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()

    gc.collect()

# 25. DOĞRU / YANLIŞ TAHMİN GÖRSELLEŞTİRME
def plot_predictions(model, loader, model_name, n=6):
    model.eval()

    images_list = []
    labels_list = []
    preds_list = []
    probs_list = []

    with torch.no_grad():
        for images, labels in loader:
            images_device = images.to(DEVICE)

            outputs = model(images_device)
            probs = torch.softmax(outputs, dim=1)
            preds = outputs.argmax(1).cpu()

            images_list.extend(images.cpu())
            labels_list.extend(labels.cpu())
            preds_list.extend(preds)
            probs_list.extend(probs.cpu())

            if len(images_list) >= n:
                break

    plt.figure(figsize=(15, 8))

    for i in range(min(n, len(images_list))):
        img = images_list[i].clone()
        img = img * std_value + mean_value
        img = img.clamp(0, 1)

        true_label = labels_list[i].item()
        pred_label = preds_list[i].item()

        normal_prob = probs_list[i][0].item()
        pneumonia_prob = probs_list[i][1].item()

        durum = "Doğru" if true_label == pred_label else "Yanlış"

        true_name = "Normal" if true_label == 0 else "Pneumonia"
        pred_name = "Normal" if pred_label == 0 else "Pneumonia"

        plt.subplot(2, 3, i + 1)
        plt.imshow(img.squeeze().numpy(), cmap="gray")
        plt.axis("off")
        plt.title(
            f"{durum}\n"
            f"Gerçek: {true_name} | Tahmin: {pred_name}\n"
            f"Normal: {normal_prob:.2f} | Pneumonia: {pneumonia_prob:.2f}",
            fontsize=10
        )

    plt.suptitle(f"{model_name} - Örnek Tahminler", fontsize=14)
    plt.tight_layout()
    plt.show()

# 26. MODEL LİSTESİ
models_dict = {
    "Custom CNN": CustomCNN(),
    "ResNet18": build_resnet18(),
    "EfficientNet-B0": build_efficientnet_b0()
}

# 27. ANA EĞİTİM
results = []
trained_models = {}
histories = {}
test_outputs = {}

for name, model in models_dict.items():

    print("\n", "=" * 60)
    print(name)
    print("=" * 60)

    trained_model, history = train_model(
        model,
        name,
        train_loader,
        val_loader
    )

    accuracy, preds, labels, probs = evaluate_model(
        trained_model,
        test_loader
    )

    metrics = compute_metrics(preds, labels)
    metrics["model"] = name

    results.append(metrics)
    trained_models[name] = trained_model
    histories[name] = history

    test_outputs[name] = {
        "preds": preds,
        "labels": labels,
        "probs": probs
    }

    print("\nTEST SONUÇLARI")
    for k, v in metrics.items():
        if k != "model":
            print(f"{k}: {v:.4f}")

    torch.save(
        trained_model.state_dict(),
        f"{name}.pth"
    )

    print(f"\n{name} modeli kaydedildi")

    if torch.cuda.is_available():
        torch.cuda.empty_cache()

    gc.collect()

# 28. SONUÇ TABLOSU
results_df = pd.DataFrame(results)

print("\n===== TÜM SONUÇLAR =====")
print(results_df)

results_df.to_csv(
    "test_results.csv",
    index=False
)

print("\nCSV dosyası kaydedildi: test_results.csv")

# 29. ACCURACY / LOSS GRAFİKLERİ
for name in histories:
    print("\n" + "=" * 60)
    print(f"{name} ACCURACY / LOSS GRAFİKLERİ")
    print("=" * 60)

    plot_history(histories[name], name)

# 30. CONFUSION MATRIX GRAFİKLERİ
for name in test_outputs:
    print("\n" + "=" * 60)
    print(f"{name} CONFUSION MATRIX")
    print("=" * 60)

    plot_confusion_matrix(
        test_outputs[name]["labels"],
        test_outputs[name]["preds"],
        name
    )

# 31. ÖRNEK TAHMİNLER
for name in trained_models:
    print("\n" + "=" * 60)
    print(f"{name} ÖRNEK TAHMİNLER")
    print("=" * 60)

    plot_predictions(
        trained_models[name],
        test_loader,
        name,
        n=6
    )

# 32. MODEL KARŞILAŞTIRMA GRAFİKLERİ
plt.figure(figsize=(8, 5))
plt.bar(results_df["model"], results_df["accuracy"])
plt.ylabel("Accuracy")
plt.title("Model Accuracy Karşılaştırması")
plt.ylim(0, 1)
plt.xticks(rotation=15)
plt.tight_layout()
plt.show()

plt.figure(figsize=(8, 5))
plt.bar(results_df["model"], results_df["f1_score"])
plt.ylabel("F1 Score")
plt.title("Model F1-Score Karşılaştırması")
plt.ylim(0, 1)
plt.xticks(rotation=15)
plt.tight_layout()
plt.show()

# 33. EN İYİ MODEL
best_model_row = results_df.loc[
    results_df["f1_score"].idxmax()
]

best_model_name = best_model_row["model"]
best_model = trained_models[best_model_name]

print("\n===== EN İYİ MODEL =====")
print(best_model_row)

torch.save(
    best_model.state_dict(),
    "best_model.pth"
)

print("\nbest_model.pth kaydedildi")

