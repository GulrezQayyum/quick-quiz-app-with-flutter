import 'package:flutter/material.dart';
import 'package:quizapp/domain/entities/quiz_settings.dart';

@immutable
abstract class QuizEvent {
  const QuizEvent();
}

class ShowQuizDialogEvent extends QuizEvent {}

class StartQuizEvent extends QuizEvent {
  final QuizSettings settings;

  const StartQuizEvent(this.settings);
}

class TimerTickedEvent extends QuizEvent {}

class QuizCompletedEvent extends QuizEvent {
  final int score;

  const QuizCompletedEvent(this.score);
}