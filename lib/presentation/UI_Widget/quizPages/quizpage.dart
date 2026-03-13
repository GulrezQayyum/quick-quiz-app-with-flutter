// lib/presentation/UI_Widget/quizPages/quizpage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/core/services/groq_service.dart';
import 'package:quizapp/core/utils/xp_system.dart';
import 'package:quizapp/domain/entities/quiz_settings.dart';
import 'package:quizapp/presentation/blocs/profile_bloc.dart';
import 'package:quizapp/presentation/blocs/profile_event.dart';
import 'package:quizapp/services/quiz_loader.dart';

const _tealDark   = Color(0xFF097EA2);
const _tealMid    = Color(0xFF0BA4D8);
const _cardColor  = Color(0xFF076D8E);
const _cardBorder = Color(0xFF0B8DB5);

class Quizpage extends StatefulWidget {
  final String quizTitle;
  final QuizSettings? settings;

  const Quizpage({super.key, required this.quizTitle, this.settings});

  @override
  State<Quizpage> createState() => _QuizpageState();
}

class _QuizpageState extends State<Quizpage> {
  List<Map<String, dynamic>> _questions = [];
  int  _currentIndex = 0;
  int  _score        = 0;
  int? _selectedIndex;

  // ── Timer ────────────────────────────────────────────────────
  Timer? _timer;
  int  _timeRemaining = 0;
  bool _timeUp        = false;

  // ── Hint ─────────────────────────────────────────────────────
  bool   _hintLoading = false;
  bool   _hintUsed    = false; // one hint per question
  String? _hintText;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final data = await QuizLoader.loadQuizData();
    setState(() {
      _questions = List<Map<String, dynamic>>.from(
        data[widget.quizTitle] ?? [],
      );
    });
    _startTimer();
  }

  // ── Timer ────────────────────────────────────────────────────
  void _startTimer() {
    final duration = widget.settings?.durationInSeconds ?? 60;
    setState(() { _timeRemaining = duration; _timeUp = false; });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeRemaining <= 1) {
        t.cancel();
        setState(() { _timeRemaining = 0; _timeUp = true; });
        _showResult();
      } else {
        setState(() => _timeRemaining--);
      }
    });
  }

  String get _formattedTime {
    final m = _timeRemaining ~/ 60;
    final s = _timeRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    final total = widget.settings?.durationInSeconds ?? 60;
    final ratio = _timeRemaining / total;
    if (ratio > 0.5)  return Colors.greenAccent;
    if (ratio > 0.25) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  // ── Answer ───────────────────────────────────────────────────
  void _checkAnswer(int index) {
    if (_timeUp) return;
    final correctIndex = _questions[_currentIndex]['correctAnswerIndex'];
    setState(() {
      _selectedIndex = index;
      if (index == correctIndex) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _hintUsed      = false;
        _hintText      = null;
      });
    } else {
      _timer?.cancel();
      _showResult();
    }
  }

  // ── Hint ─────────────────────────────────────────────────────
  Future<void> _fetchHint() async {
    if (_hintUsed || _hintLoading || _selectedIndex != null) return;

    setState(() { _hintLoading = true; });

    try {
      final q       = _questions[_currentIndex];
      final options = List<String>.from(q['options'] ?? []);
      final hint    = await GroqService.getHint(
        question: q['question'] ?? '',
        options:  options,
      );
      setState(() {
        _hintText    = hint;
        _hintUsed    = true;
        _hintLoading = false;
      });
      _showHintSheet(hint);
    } catch (e) {
      setState(() { _hintLoading = false; });
      _showHintSheet('Could not load hint. Check your connection.');
    }
  }

  void _showHintSheet(String hint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_tealDark, _tealMid],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('💡', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AI Hint',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white54, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: _cardBorder),
            const SizedBox(height: 12),

            // Hint text
            Text(
              hint,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Groq badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome,
                    color: _tealMid, size: 13),
                const SizedBox(width: 5),
                Text(
                  'Powered by Groq AI',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Result ───────────────────────────────────────────────────
  void _showResult() {
    _timer?.cancel();
    final xpEarned   = XpSystem.calculateXP(_score, _questions.length);
    final pageContext = context;
    context.read<ProfileBloc>().add(AwardXP(xpEarned));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text(
          _timeUp ? '⏰ Time\'s Up!' : '🎉 Quiz Finished!',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / ${_questions.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: _tealMid,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${((_score / _questions.length) * 100).toStringAsFixed(0)}% accuracy',
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _tealMid),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    '+$xpEarned XP earned',
                    style: const TextStyle(
                      color: _tealMid,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                final nav = Navigator.of(pageContext);
                nav.pop();
                nav.pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: _tealMid,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        backgroundColor: _tealDark,
        body: Center(
            child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final question = _questions[_currentIndex];
    final options  = List<String>.from(question['options'] ?? []);

    return Scaffold(
      backgroundColor: _tealDark,
      appBar: AppBar(
        backgroundColor:
        Theme.of(context).appBarTheme.backgroundColor ??
            _tealDark,
        elevation: 50,
        shadowColor: Colors.cyan,
        title: Text(widget.quizTitle),
        centerTitle: true,
        actions: [
          // ── Hint button in appbar ──────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: _selectedIndex == null && !_hintUsed && !_timeUp
                  ? _fetchHint
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _hintUsed
                      ? Colors.white.withOpacity(0.08)
                      : _tealMid.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hintUsed
                        ? Colors.white24
                        : _tealMid.withOpacity(0.7),
                  ),
                ),
                child: _hintLoading
                    ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '💡',
                      style: TextStyle(
                        fontSize: 13,
                        color: _hintUsed
                            ? Colors.white30
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _hintUsed ? 'Used' : 'Hint',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _hintUsed
                            ? Colors.white30
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Counter + Timer row ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _timerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _timerColor.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined,
                          color: _timerColor, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        _formattedTime,
                        style: TextStyle(
                          color: _timerColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question text
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    question['question'] ?? 'No question',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _tealDark,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options
            Expanded(
              flex: 2,
              child: ListView(
                children: List.generate(options.length, (index) {
                  final isSelected = _selectedIndex == index;
                  final isCorrect  =
                      _questions[_currentIndex]['correctAnswerIndex'] ==
                          index;

                  Color color = const Color(0xFF0A4563);
                  if (_selectedIndex != null) {
                    if (isSelected && isCorrect)        color = Colors.green;
                    else if (isSelected && !isCorrect)  color = Colors.red;
                    else if (isCorrect)                 color = Colors.green;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (_selectedIndex == null && !_timeUp)
                            ? () => _checkAnswer(index)
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30, height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            if (_selectedIndex != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _tealDark,
                    padding:
                    const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1
                        ? 'Next Question'
                        : 'Finish Quiz',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}