// lib/presentation/screens/categories.dart
import 'package:flutter/material.dart';
import 'package:quizapp/presentation/UI_Widget/pages/architecturePage.dart';
import 'package:quizapp/presentation/UI_Widget/pages/artLiteraturePage.dart';
import 'package:quizapp/presentation/UI_Widget/pages/compSciencePage.dart';
import 'package:quizapp/presentation/UI_Widget/pages/historyGeoPage.dart';
import 'package:quizapp/presentation/UI_Widget/pages/natureSciPage.dart';
import 'package:quizapp/presentation/UI_Widget/pages/sportsPage.dart';
import '../UI_Widget/pages/aiPage.dart';
import '../UI_Widget/pages/ai_chat_sheet.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Floating AI tutor button ─────────────────────────────
      floatingActionButton: _AiFloatingButton(),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0BA4D8), Color(0xFF097EA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Choose a Category",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  // ↑ bottom padding so last card isn't hidden behind FAB
                  children: [
                    _buildCategoryItem(
                      context,
                      "assets/cards/cs_card.png",
                      "Computer Science",
                      "Test your knowledge on the tech powering the future.",
                          () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const ComputerSciencePage(),
                      )),
                    ),
                    _buildCategoryItem(
                      context,
                      "assets/cards/ai_card.png",
                      "Artificial Intelligence & Machine Learning",
                      "Challenge your understanding of how machines learn and think",
                          () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const AIandMLPage(),
                      )),
                    ),
                    _buildCategoryItem(
                      context,
                      "assets/cards/art_card.png",
                      "Art & Literature",
                      "Explore creativity, classic works, and modern art.",
                          () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ArtLiteraturePage(),
                      )),
                    ),
                    _buildCategoryItem(
                      context,
                      "assets/cards/history_card.png",
                      "History & Geography",
                      "Discover past civilizations and the world around us.",
                          () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const HistoryGeographyPage(),
                      )),
                    ),
                    _buildCategoryItem(
                      context,
                      "assets/cards/architecture_card.png",
                      "World Architecture",
                      "Learn about iconic structures and design styles.",
                          () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const ArchitecturePage(),
                      )),
                    ),
                    _buildCategoryItem(
                      context,
                      "assets/cards/nature_card.png",
                      "Science & Nature",
                      "Uncover the mysteries of nature and science.",
                          () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const ScienceNaturePage(),
                      )),
                    ),
                    _buildCategoryItem(
                      context,
                      "assets/cards/sports_card.png",
                      "Sports & Games",
                      "Test your knowledge of games, players, and events.",
                          () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const SportsPage(),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context,
      String imagePath,
      String title,
      String description,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.tealAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated floating AI button ──────────────────────────────────
class _AiFloatingButton extends StatefulWidget {
  @override
  State<_AiFloatingButton> createState() => _AiFloatingButtonState();
}

class _AiFloatingButtonState extends State<_AiFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 6.0, end: 18.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: GestureDetector(
          onTap: () => AiChatSheet.show(context, 'Quiz Tutor'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF097EA2), Color(0xFF0BA4D8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0BA4D8).withOpacity(0.55),
                  blurRadius: _glow.value,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🤖', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Ask AI Tutor',
                  style: TextStyle(
                    fontSize: 14,
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
    );
  }
}