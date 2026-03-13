import 'package:flutter/material.dart';
import 'package:quizapp/domain/entities/quiz_settings.dart';

@immutable
abstract class QuizState {
  const QuizState();
}

class QuizInitial extends QuizState {}

class QuizDialogShown extends QuizState {}

class QuizStarted extends QuizState {
  final QuizSettings settings;

  const QuizStarted(this.settings);
}

class QuizInProgress extends QuizState {
  final int timeRemaining;

  const QuizInProgress(this.timeRemaining);
}

class QuizCompleted extends QuizState {
  final int score;

  const QuizCompleted(this.score);
}