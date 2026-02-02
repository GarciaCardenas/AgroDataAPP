import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static const String apiUrl = 'https://api.groq.com/openai/v1/chat/completions';

  static String get apiKey => dotenv.env['GROQ_API_KEY']?.trim() ?? '';
  
  static Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      if (apiKey.isEmpty) {
        return 'Error: Falta GROQ_API_KEY en el archivo .env';
      }
      List<Map<String, String>> messages = [
        {
          'role': 'system',
          'content': 'Eres un asistente agrícola experto especializado en cultivos, plagas, enfermedades y gestión agrícola. Ayudas a los agricultores con consejos prácticos en español.'
        }
      ];
      
      messages.addAll(conversationHistory);
      messages.add({
        'role': 'user',
        'content': userMessage,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] ?? 'Sin respuesta';
        }
        
        return 'No se pudo obtener una respuesta válida.';
      } else {
        if (response.statusCode == 401) {
          return 'Error: API key inválida. Obtén tu API key gratis en https://console.groq.com/keys';
        }
        
        print('Error API: ${response.statusCode}');
        print('Response: ${response.body}');
        
        try {
          final error = jsonDecode(response.body);
          return 'Error ${response.statusCode}: ${error['error']?['message'] ?? 'Error desconocido'}';
        } catch (e) {
          return 'Error ${response.statusCode}: No se pudo obtener respuesta.';
        }
      }
    } catch (e) {
      print('Exception: $e');
      return 'Error: No se pudo conectar con el asistente.';
    }
  }

  static bool isApiKeyConfigured() {
    return apiKey.isNotEmpty;
  }
}
