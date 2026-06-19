import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../theme/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final resultColor = isHighRisk ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Sonucu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppTheme.textDark,
      ),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: kIsWeb
                      ? Image.network(
                          widget.imagePath, 
                          height: 300, 
                          width: double.infinity,
                          fit: BoxFit.cover
                        )
                      : Image.file(
                          File(widget.imagePath), 
                          height: 300, 
                          width: double.infinity,
                          fit: BoxFit.cover
                        ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: resultColor.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: resultColor.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isHighRisk ? Icons.warning_rounded : Icons.check_circle_rounded,
                        color: resultColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Teşhis Sonucu',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : AppTheme.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.prediction,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: resultColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Risk Yüzdesi:',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white70 : AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '%${widget.riskPercentage.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home_rounded, color: Colors.white),
                    label: const Text(
                      'Ana Sayfaya Dön',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
