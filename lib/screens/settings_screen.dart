import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    bool isDark = await DatabaseHelper.instance.getUserPreferenceDarkMode(1);
    setState(() {
      _darkModeEnabled = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Bildirimler'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Karanlık Tema'),
            value: _darkModeEnabled,
            onChanged: (bool value) async {
              setState(() {
                _darkModeEnabled = value;
              });
              await DatabaseHelper.instance.saveUserPreferences(1, value);
              ZaturreTespitApp.of(context)?.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Hakkında'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Zatürre Tespit App',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
