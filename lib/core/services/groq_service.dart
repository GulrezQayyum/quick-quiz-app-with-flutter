// lib/core/services/groq_service.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class GroqService {
  static const _apiKey = 'api-key';
  static const _model  = 'llama-3.1-8b-instant';
  static const _url    = 'https://api.groq.com/openai/v1/chat/completions';

  // ── Single completion call ───────────────────────────────────
  static Future<String> _complete(List<Map<String, String>> messages) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model':       _model,
          'messages':    messages,
          'max_tokens':  256,
          'temperature': 0.7,
        }),
      );

      // Print full response for debugging
      debugPrint('Groq status: ${response.statusCode}');
      debugPrint('Groq body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final error = jsonDecode(response.body);
        final msg   = error['error']?['message'] ?? response.body;
        throw Exception('Groq ${response.statusCode}: $msg');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint('Groq unexpected error: $e');
      throw Exception('Network error: $e');
    }
  }

  // ── HINT: given a question + options, return a hint ─────────
  static Future<String> getHint({
    required String question,
    required List<String> options,
  }) async {
    final optionsText = options
        .asMap()
        .entries
        .map((e) => '${String.fromCharCode(65 + e.key)}) ${e.value}')
        .join('\n');

    return _complete([
      {
        'role': 'system',
        'content':
        'You are a helpful quiz assistant. When given a question and its options, '
            'provide a SHORT hint (1-2 sentences max) that guides the student toward '
            'the correct answer WITHOUT directly revealing it. Be encouraging.',
      },
      {
        'role': 'user',
        'content': 'Question: $question\n\nOptions:\n$optionsText\n\nGive me a hint.',
      },
    ]);
  }

  // ── CHATBOT: category-aware AI tutor ────────────────────────
  static Future<String> chat({
    required String userMessage,
    required String category,
    required List<Map<String, String>> history,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content':
        'You are an expert tutor in $category. Answer questions clearly and '
            'concisely. Keep responses under 150 words. Use simple language. '
            'If asked something unrelated to $category, politely redirect.',
      },
      ...history,
      {'role': 'user', 'content': userMessage},
    ];

    return _complete(messages);
  }
}