import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NanoBananaService {
  static final NanoBananaService _instance = NanoBananaService._internal();
  factory NanoBananaService() => _instance;
  NanoBananaService._internal();

  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-pro-image-preview:generateContent';

  Future<String?> generateImage(String prompt) async {
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: '.env');
    }
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      print('GEMINI_API_KEY not found in .env');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseModalities': ['IMAGE'],
            'imageConfig': {
              'aspectRatio': '1:1',
              'image_size': '1K'
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final parts = data['candidates'][0]['content']['parts'];
          if (parts != null && parts.isNotEmpty) {
            for (var part in parts) {
              if (part['inlineData'] != null) {
                final mimeType = part['inlineData']['mimeType'];
                final base64Data = part['inlineData']['data'];
                return 'data:$mimeType;base64,$base64Data';
              }
            }
          }
        }
      }
      print('Gemini Image Generation Error: ${response.body}');
      return null;
    } catch (e) {
      print('Error generating image: $e');
      return null;
    }
  }
}
