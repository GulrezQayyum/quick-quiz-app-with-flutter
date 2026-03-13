// lib/presentation/UI_Widget/quizPages/computer_science_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/presentation/UI_Widget/quizPages/quizpage.dart';
import 'package:quizapp/presentation/UI_Widget/dialogs/quiz_start_dialog.dart';
import 'package:quizapp/presentation/blocs/quiz_bloc.dart';
import 'package:quizapp/presentation/blocs/quiz_event.dart';
import 'package:quizapp/presentation/pages/quiz_homePage.dart';

import '../../pages/quiz_homePage.dart';

class ComputerSciencePage extends StatelessWidget {
  const ComputerSciencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> quizList = [
      "Pointer & Memory",
      "Object-Oriented Programming",
      "Algorithm Analysis",
      "Data Structures",
      "Recursion & Backtracking",
      "The Internet",
      "SQL & Databases",
      "Basic Security",
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF097EA2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF097EA2),
        elevation: 50,
        shadowColor: Colors.cyan,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.computer),
            SizedBox(width: 2),
            Text(
              " Computer Science",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: quizList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quiz Title
                  Text(
                    quizList[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),

                  // Play Button — opens QuizHomePage which auto-shows dialog
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill,
                        color: Colors.white, size: 36),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<QuizBloc>(),
                            child: QuizHomePage(quizTitle: quizList[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}