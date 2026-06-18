import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Örnek olarak user_id = 1 kullanıyoruz
    var data = await DatabaseHelper.instance.getProfileData(1);
    
    // Eğer kayıt yoksa örnek bir kayıt ekle
    if (data == null) {
      await DatabaseHelper.instance.saveProfileData(1, "Merhaba, ben uygulamanızı kullanan bir doktorum.", "");
      data = await DatabaseHelper.instance.getProfileData(1);
    }

    setState(() {
      _profileData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Kullanıcı Adı: Örnek Kullanıcı',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Biyografi: \${_profileData?['bio'] ?? 'Belirtilmedi'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
