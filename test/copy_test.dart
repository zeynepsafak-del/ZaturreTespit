import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Copy image', () {
    var dir = Directory('assets/images');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    var source = File(r'C:\Users\Zeynep\.gemini\antigravity-ide\brain\d7843846-f0a9-48bf-b0d4-7e92807fb403\ai_lung_logo_1781865412396.png');
    var target = File('assets/images/logo.png');
    
    if (source.existsSync()) {
      source.copySync(target.path);
      print('COPIED SUCCESSFULLY');
    } else {
      print('SOURCE FILE NOT FOUND: ${source.path}');
    }
  });
}
