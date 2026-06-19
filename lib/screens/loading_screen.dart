import 'package:flutter/material.dart';
import 'dart:math';
import 'result_screen.dart';
import '../api/api_service.dart';
import '../database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    final apiService = ApiService();
    final result = await apiService.predictImage(widget.imagePath);

    String prediction = "Bilinmiyor";
    double risk = 0.0;

    if (result != null) {
      prediction = result['prediction'] ?? "Normal";
      // Backend % olarak göndermiyorsa çarparız veya backend ne verirse
      risk = (result['confidence'] ?? 0.0) * 100;
    } else {
      // Backend çalışmıyorsa simüle et
      await Future.delayed(const Duration(seconds: 2));
      final random = Random();
      final isZaturre = random.nextBool();
      prediction = isZaturre ? "Zatürre (Simüle)" : "Normal (Simüle)";
      risk = isZaturre ? (60.0 + random.nextDouble() * 35.0) : (5.0 + random.nextDouble() * 25.0);
    }

    // Veritabanına kaydet (Aktif kullanıcı)
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('userId') ?? 1;
    await DatabaseHelper.instance.saveImageRecord(currentUserId, widget.imagePath, prediction, risk);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imagePath: widget.imagePath,
            prediction: prediction,
            riskPercentage: risk,
          ),
        ),
      );
    }
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
