import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final String prediction;
  final double riskPercentage;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.prediction,
    required this.riskPercentage,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Animasyonla sonucun görünmesini sağlamak için
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHighRisk = widget.riskPercentage > 50.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Analiz Sonucu')),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(File(widget.imagePath), height: 250, fit: BoxFit.cover),
              const SizedBox(height: 30),
              Text(
                'Teşhis: ${widget.prediction}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isHighRisk ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Risk Yüzdesi: %${widget.riskPercentage.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfaya Dön'),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
