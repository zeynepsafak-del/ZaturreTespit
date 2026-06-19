import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Emülatör üzerinden localhost'a erişmek için 10.0.2.2 kullanılır
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>?> predictImage(String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('\$baseUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return json.decode(responseData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
