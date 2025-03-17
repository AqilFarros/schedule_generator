import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Service {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=';

  static Future<String> generateSchedule(
    String scheduleName,
    String duration,
    String priority,
    String fromData,
    String untilDate,
  ) async {
    if (_apiKey.isEmpty) {
      return 'API key not found';
    }

    final String url = _baseUrl + _apiKey;

    // Request body
    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Buatlah jadwal $scheduleName, berdasarkan prioritas $priority dengan durasi $duration jam, dimulai dari $fromData sampai $untilDate",
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        return "Terjadi Kesalahan ${response.statusCode} + ${response.body}";
      }
    } catch (e) {
      return "Terjadi Kesalahan $e";
    }
  }
}
