import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuizLoader {
  static Future<Map<String, dynamic>> loadQuizData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/jsonFiles/comp_sci_quizzes.json');
      final data = jsonDecode(response);

      // Go inside "computer_science"
      return data['computer_science'] as Map<String, dynamic>;
    } catch (e) {
      print("Error loading quiz data: $e");
      return {};
    }
  }
}

