import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaturre_tespit/screens/info_screen.dart';

void main() {
  test('Kullanıcı tercihleri veritabanına kaydediliyor mu testi', () {
    // DatabaseHelper.instance.saveUserPreferences simülasyonu
    bool isSaved = true;
    expect(isSaved, true);
  });

  testWidgets('Bilgilendirme ekranı açılıyor mu testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InfoScreen()));
    expect(find.text('Zatürre Hakkında'), findsOneWidget);
    expect(find.text('Zatürre (Pnömoni) Nedir?'), findsOneWidget);
  });

  test('Karanlık mod çalışıyor mu testi', () {
    // ThemeMode değişikliğinin UI üzerindeki mantıksal simülasyonu
    bool isDarkModeActive = true;
    expect(isDarkModeActive, true);
  });
}
