import 'dart:convert';
import 'package:http/http.dart' as http;
import 'identification_result.dart';

class ApiService {
  static const String _baseUrl = 'https://crop.kindwise.com/api/v1';
  static const String _apiKey = 'YDiomGAS4BVZ277CnbZZViLZMjmAvtWp14QbhaHZ1b67pi0FN4';

  static Future<IdentificationResult> identifyCrop(List<String> base64Images) async {
    final url = Uri.parse('$_baseUrl/identification');
    final body = jsonEncode({
      'images': base64Images,
      'similar_images': true
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': _apiKey,
      },
      body: body,
    );
    if (response.statusCode == 201) {
      return IdentificationResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al identificar: \${response.statusCode}');
    }
  }
}