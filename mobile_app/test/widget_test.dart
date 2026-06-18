import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/register_screen.dart';

void main() {
  testWidgets('Splash Screen açılış testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    // Splash Screen'de 'Zatürre Tespit' yazısı görünmeli
    expect(find.text('Zatürre Tespit'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Bekleyen Future.delayed işleminin tamamlanması için zamanı ilerletiyoruz
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('Login ekranı görüntüleme testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2)); // email, password
    expect(find.text('Hesabınız yok mu? Kayıt Olun'), findsOneWidget);
  });

  testWidgets('Register ekranı görüntüleme testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    expect(find.text('Kayıt Ol'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(3)); // name, email, password
    expect(find.text('Zaten hesabınız var mı? Giriş Yapın'), findsOneWidget);
  });

  testWidgets('Login -> Register sayfa geçiş testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Butonu bulup tıklıyoruz
    final registerButton = find.text('Hesabınız yok mu? Kayıt Olun');
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Register sayfasına geçtiğini doğrula
    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Kayıt Ol'), findsWidgets);
  });

  testWidgets('Register -> Login sayfa geçiş testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Move to register screen first
    final registerButton = find.text('Hesabınız yok mu? Kayıt Olun');
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);

    // Now go back to login
    final loginButton = find.text('Zaten hesabınız var mı? Giriş Yapın');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // Should be back at LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
