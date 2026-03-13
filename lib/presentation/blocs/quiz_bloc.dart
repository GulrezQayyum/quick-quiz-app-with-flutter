import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/domain/usecases/start_quiz.dart';
import 'package:quizapp/presentation/blocs/quiz_event.dart';
import 'package:quizapp/presentation/blocs/quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final StartQuiz startQuiz;

  QuizBloc({required this.startQuiz}) : super(QuizInitial()) {
    on<StartQuizEvent>(_onStartQuiz);
    on<ShowQuizDialogEvent>(_onShowQuizDialog);
  }

  void _onShowQuizDialog(ShowQuizDialogEvent event, Emitter<QuizState> emit) {
    emit(QuizDialogShown());
  }

  void _onStartQuiz(StartQuizEvent event, Emitter<QuizState> emit) {
    startQuiz(event.settings);
    emit(QuizStarted(event.settings));
  }
}