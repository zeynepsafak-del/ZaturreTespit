import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'database/database_helper.dart';

void main() {
  runApp(const ZaturreTespitApp());
}

class ZaturreTespitApp extends StatefulWidget {
  const ZaturreTespitApp({super.key});

  static _ZaturreTespitAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ZaturreTespitAppState>();

  @override
  State<ZaturreTespitApp> createState() => _ZaturreTespitAppState();
}

class _ZaturreTespitAppState extends State<ZaturreTespitApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // Temsili user_id = 1
    bool isDark = await DatabaseHelper.instance.getUserPreferenceDarkMode(1);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zatürre Tespit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}
