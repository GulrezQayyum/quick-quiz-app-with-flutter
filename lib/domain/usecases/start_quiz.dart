import 'package:quizapp/domain/entities/quiz_settings.dart';

abstract class StartQuiz {
  Future<void> call(QuizSettings Settings);
}
