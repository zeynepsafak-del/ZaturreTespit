import 'dart:io';

void main() {
  var dir = Directory('assets/images');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  var source = File(r'C:\Users\Zeynep\.gemini\antigravity-ide\brain\d7843846-f0a9-48bf-b0d4-7e92807fb403\media__1781857761304.png');
  var target = File('assets/images/logo.png');
  source.copySync(target.path);
  print('Copied successfully');
}
