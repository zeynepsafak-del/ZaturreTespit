import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zatürre Hakkında')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Zatürre (Pnömoni) Nedir?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Zatürre, akciğerlerdeki hava keseciklerinin iltihaplanması durumudur. Bakteri, virüs veya mantar kaynaklı olabilir.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Belirtiler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('- Yüksek ateş ve titreme\n- Öksürük (balgamlı olabilir)\n- Nefes darlığı\n- Göğüs ağrısı\n- Halsizlik', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
