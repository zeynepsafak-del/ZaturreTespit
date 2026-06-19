import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaturre_tespit/screens/loading_screen.dart';
import 'package:zaturre_tespit/screens/result_screen.dart';

void main() {
  testWidgets('Yükleniyor ekranı çalışıyor mu testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoadingScreen(imagePath: 'dummy.jpg')));
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('analiz ediliyor'), findsOneWidget);
  });

  testWidgets('Sonuç ekranı açılıyor mu ve risk yüzdesi görüntüleniyor mu testi', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResultScreen(
          imagePath: 'dummy.jpg',
          prediction: 'Zatürre',
          riskPercentage: 85.5,
        ),
      ),
    );

    // Animasyonun bitmesini bekleyelim
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Analiz Sonucu'), findsOneWidget);
    expect(find.text('Teşhis: Zatürre'), findsOneWidget);
    expect(find.text('Risk Yüzdesi: %85.5'), findsOneWidget);
  });
}
