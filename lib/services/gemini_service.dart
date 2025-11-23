import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  final ConfigService _configService = ConfigService();

  Future<String> generatePostContent(
    String prompt,
    String audience, {
    String? pdfBase64,
    String? systemInstruction,
  }) async {
    // Busca a chave do Supabase
    final apiKey = await _configService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      return 'Erro: GEMINI_API_KEY não configurada. Por favor, configure a chave nas configurações.';
    }

    List<Map<String, dynamic>> parts = [
      {"text": prompt},
    ];

    if (pdfBase64 != null) {
      parts.add({
        "inlineData": {"mimeType": "application/pdf", "data": pdfBase64},
      });
    }

    final Map<String, dynamic> requestBody = {
      "contents": [
        {"role": "user", "parts": parts},
      ],
      "tools": [
        {"googleSearch": {}},
      ],
    };

    if (systemInstruction != null) {
      requestBody["systemInstruction"] = {
        "parts": [
          {"text": systemInstruction},
        ],
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final parts = data['candidates'][0]['content']['parts'];
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] ?? 'Sem texto gerado.';
          }
        }
        return 'Resposta vazia da API.';
      } else {
        return 'Erro na API: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Erro ao chamar Gemini: $e';
    }
  }
}
