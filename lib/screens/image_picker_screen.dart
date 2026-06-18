import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_preview_screen.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({super.key});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imagePath: image.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görsel Seçimi')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.photo_library),
          label: const Text('Galeriden Seç'),
          onPressed: _pickImage,
        ),
      ),
    );
  }
}
