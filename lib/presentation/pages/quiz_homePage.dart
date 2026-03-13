// lib/presentation/screens/quiz_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/domain/entities/quiz_settings.dart';
import 'package:quizapp/presentation/UI_Widget/dialogs/quiz_start_dialog.dart';
import 'package:quizapp/presentation/UI_Widget/quizPages/quizpage.dart';
import 'package:quizapp/presentation/blocs/quiz_bloc.dart';
import 'package:quizapp/presentation/blocs/quiz_event.dart';
import 'package:quizapp/presentation/blocs/quiz_state.dart';

class QuizHomePage extends StatefulWidget {
  final String quizTitle;

  const QuizHomePage({Key? key, required this.quizTitle}) : super(key: key);

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  QuizSettings? _selectedSettings; // ← stores settings chosen in dialog

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartDialog();
    });
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => QuizStartDialog(
        onStartQuiz: (settings) {
          setState(() => _selectedSettings = settings); // ← save it
          context.read<QuizBloc>().add(StartQuizEvent(settings));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizStarted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Quizpage(
                quizTitle: widget.quizTitle,
                settings: _selectedSettings, // ← pass to Quizpage
              ),
            ),
          );
        }
      },
      child: const Scaffold(
        backgroundColor: Color(0xFF097EA2),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0BA4D8)),
        ),
      ),
    );
  }
}