import 'package:flutter/material.dart';
import 'image_picker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Görsel Seç'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ImagePickerScreen()),
            );
          },
        ),
      ),
    );
  }
}
