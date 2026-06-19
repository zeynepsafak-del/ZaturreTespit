import 'dart:io';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Şimdilik temsili user_id = 1 olarak veriyoruz
    final history = await DatabaseHelper.instance.getAnalysisHistory(1);
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analiz Geçmişi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('Henüz analiz kaydınız bulunmuyor.'))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    final date = DateTime.parse(item['timestamp']).toLocal();
                    final isHighRisk = item['risk_percentage'] > 50.0;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: Image.file(
                          File(item['image_path']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 50),
                        ),
                        title: Text(item['prediction']),
                        subtitle: Text('\${date.day}/\${date.month}/\${date.year} \${date.hour}:\${date.minute}'),
                        trailing: Text(
                          '${item['risk_percentage']}%',
                          style: TextStyle(
                            color: isHighRisk ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
