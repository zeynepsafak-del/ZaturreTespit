import 'package:flutter/material.dart';
import 'result_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String imagePath;
  const LoadingScreen({super.key, required this.imagePath});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // 3 saniye sonra sonuç ekranına geçiş simülasyonu
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imagePath: widget.imagePath,
              prediction: "Zatürre Tespiti Yapılmadı", // Temsili veri
              riskPercentage: 15.0, // %15 risk
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Görsel analiz ediliyor...\nLütfen bekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
