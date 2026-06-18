import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ZaturreTespitApp());
}

class ZaturreTespitApp extends StatelessWidget {
  const ZaturreTespitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zatürre Tespit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Tema değişikliklerinin uygulanıp uygulanmadığını test etmek için sistem temasını kullanır
      home: const SplashScreen(),
    );
  }
}
