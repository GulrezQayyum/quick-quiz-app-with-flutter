// lib/presentation/UI_Widget/quiz_start_dialog.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quizapp/domain/entities/quiz_settings.dart';

// ── Colour palette (matches app theme) ──────────────────────────
const _gradientTop    = Color(0xFF097EA2);
const _gradientBottom = Color(0xFF0BA4D8);
const _cardColor      = Color(0xFF076D8E);
const _cardBorder     = Color(0xFF0B8DB5);

class QuizStartDialog extends StatelessWidget {
  final Function(QuizSettings) onStartQuiz;
  final List<int> timeOptions;

  const QuizStartDialog({
    super.key,
    required this.onStartQuiz,
    this.timeOptions = const [30, 60, 120, 300],
  });

  String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds seconds';
    final mins = seconds ~/ 60;
    return '$mins minute${mins > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    int selectedTime = timeOptions.first;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── Gradient header with Lottie ──────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_gradientTop, _gradientBottom],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 120,
                          child: Lottie.asset(
                            'assets/animations/startquiz.json',
                            repeat: true,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ready to Begin?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Select a time limit and test your knowledge',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Body ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      children: [

                        // ── Time selector chips ───────────────
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'TIME LIMIT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white54,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: timeOptions.map((time) {
                            final isSelected = selectedTime == time;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedTime = time),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _gradientTop
                                      : Colors.white.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? _gradientBottom
                                        : _cardBorder,
                                    width: isSelected ? 2 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: _gradientBottom
                                          .withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 13),
                                      const SizedBox(width: 5),
                                    ],
                                    Text(
                                      _formatTime(time),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // ── Info row ──────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _infoChip('📝', '10', 'Questions'),
                              _divider(),
                              _infoChip('⏱️', _formatTime(selectedTime), 'Duration'),
                              _divider(),
                              _infoChip('⚡', '~${10 + 20}', 'Max XP'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Buttons row ───────────────────────
                        Row(
                          children: [
                            // Cancel
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                    Border.all(color: _cardBorder),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Start
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () {
                                  onStartQuiz(
                                    QuizSettings(
                                      questionCount: 10,
                                      durationInSeconds: selectedTime,
                                      difficulty: 'easy',
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        _gradientTop,
                                        _gradientBottom
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gradientBottom
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_arrow_rounded,
                                          color: Colors.white, size: 20),
                                      SizedBox(width: 6),
                                      Text(
                                        'Start Quiz',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _gradientBottom,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: _cardBorder,
    );
  }
}