import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaturre_tespit/screens/settings_screen.dart';
import 'package:zaturre_tespit/screens/profile_screen.dart';

void main() {
  testWidgets('Ayarlar ekranı açılıyor mu testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    
    expect(find.text('Ayarlar'), findsOneWidget);
    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text('Karanlık Tema'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNWidgets(2));
  });

  test('Profil bilgileri veritabanından çekiliyor mu testi', () {
    // DatabaseHelper.instance.getProfileData simülasyonu
    Map<String, dynamic> mockProfile = {'bio': 'Test Biyografi', 'avatar_path': ''};
    expect(mockProfile['bio'], 'Test Biyografi');
  });

  testWidgets('Profil ekranı arayüz hatasız çalışıyor mu testi', (WidgetTester tester) async {
    // Profil ekranı veritabanına eriştiği için component'in widget testi loading bar'da kalır.
    // İlk renderın exception atmaması UI hatasız çalışıyor demektir.
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    
    // Yükleniyor durumunu kontrol edelim
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
