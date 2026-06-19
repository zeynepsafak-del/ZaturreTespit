import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zaturre_tespit/main.dart';
import 'package:zaturre_tespit/screens/splash_screen.dart';
import 'package:zaturre_tespit/screens/login_screen.dart';

void main() {
  testWidgets('Splash Screen açılıyor mu testi', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(const ZaturreTespitApp());

    // Splash ekranının render edildiğini doğrula
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Zatürre Tespit'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Login ekranı açılıyor mu testi (Splash sonrası)', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(const ZaturreTespitApp());

    // Splash ekranı 2 saniye bekler, biz de tester ile zamanı ilerletelim
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Login ekranına geçildiğini doğrula
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2)); // E-posta ve Şifre
    expect(find.byType(ElevatedButton), findsOneWidget); // Giriş butonu
  });

  testWidgets('Tema değişiklikleri uygulanıyor mu testi', (WidgetTester tester) async {
    // Koyu temayı test etmek için bir sarmalayıcı oluşturalım
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark, // Açıkça koyu temayı seçiyoruz
        home: const Scaffold(
          body: Text('Tema Testi'),
        ),
      ),
    );

    // Koyu temada arka planın koyu renkte (veya ona yakın bir şey) olduğunu doğrulamak için
    // Temanın koyu moda geçip geçmediğini kontrol ederiz
    final BuildContext context = tester.element(find.byType(Scaffold));
    final Brightness brightness = Theme.of(context).brightness;

    expect(brightness, Brightness.dark);
  });
}
