import 'dart:convert';
import 'package:http/http.dart' as http;

// Tu clave API (nunca la subas a GitHub público)
const String _DEEPL_API_KEY = '9b9c0cdb-a0bf-4af2-906a-2965883703bd:fx';

Future<String> traducirDeepl(String texto, String targetLang) async {
  final uri = Uri.parse('https://api-free.deepl.com/v2/translate');

  try {
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'DeepL-Auth-Key $_DEEPL_API_KEY',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'text': texto,
        'target_lang': targetLang.toUpperCase(), // "ES" o "EN"
      },
    );

    if (response.statusCode == 200) {
      // ✅ Decodificamos correctamente los bytes como UTF-8
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['translations'][0]['text'];
    } else {
      print('DeepL Error (${response.statusCode}): ${response.body}');
      return texto; // Fallback si hay error
    }
  } catch (e) {
    print('Error en traducción: $e');
    return texto;
  }
}
