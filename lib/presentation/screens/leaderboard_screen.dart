// lib/presentation/screens/leaderboard_screen.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quizapp/core/utils/avatar_helper.dart';
import 'package:quizapp/core/utils/xp_system.dart';

// ── Colour palette (matches profile_screen.dart) ────────────────
const _gradientTop    = Color(0xFF097EA2);
const _gradientBottom = Color(0xFF0BA4D8);
const _bgColor        = Color(0xFF097EA2);
const _cardColor      = Color(0xFF076D8E);
const _cardBorder     = Color(0xFF0B8DB5);

// ── Medal colours ────────────────────────────────────────────────
const _gold   = Color(0xFFFFD700);
const _silver = Color(0xFFC0C8D8);
const _bronze = Color(0xFFCD7F32);

// ── Filter tabs ──────────────────────────────────────────────────
enum _Filter { global, weekly }

// ── Data model for a leaderboard entry ──────────────────────────
class _LeaderEntry {
  final String uid;
  final String name;
  final String avatarSeed;
  final int totalXP;
  final int quizzesPlayed;

  _LeaderEntry({
    required this.uid,
    required this.name,
    required this.avatarSeed,
    required this.totalXP,
    required this.quizzesPlayed,
  });

  factory _LeaderEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return _LeaderEntry(
      uid:           doc.id,
      name:          (d['name'] ?? '').toString().trim(),
      avatarSeed:    (d['avatarSeed'] ?? '').toString(),
      totalXP:       (d['totalXP'] ?? 0) as int,
      quizzesPlayed: (d['quizzesPlayed'] ?? 0) as int,
    );
  }
}

// ════════════════════════════════════════════════════════════════
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  _Filter _filter = _Filter.global;
  late Future<List<_LeaderEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchLeaderboard();
  }

  // ── Fetch top 20 users by totalXP from Firestore ────────────
  Future<List<_LeaderEntry>> _fetchLeaderboard() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('totalXP', descending: true)
        .limit(20)
        .get();
    return snap.docs.map(_LeaderEntry.fromDoc).toList();
  }

  void _setFilter(_Filter f) {
    setState(() {
      _filter = f;
      _future = _fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: FutureBuilder<List<_LeaderEntry>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _gradientBottom),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: Colors.redAccent)),
            );
          }

          final entries   = snap.data ?? [];
          final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final top3      = entries.take(3).toList();
          final rest       = entries.length > 3 ? entries.sublist(3) : <_LeaderEntry>[];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, top3),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTabs(),
                      const SizedBox(height: 12),
                      _sectionLabel('RANKINGS'),
                      const SizedBox(height: 10),
                      ...rest.asMap().entries.map((e) {
                        final rank = e.key + 4; // 4th place onward
                        return _buildRankRow(e.value, rank, currentUid);
                      }),
                      if (rest.isEmpty)
                        _buildEmptyState(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── HEADER with podium ───────────────────────────────────────
  Widget _buildHeader(BuildContext context, List<_LeaderEntry> top3) {
    // Arrange podium: 2nd | 1st | 3rd
    final first  = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third  = top3.length > 2 ? top3[2] : null;

    return ClipPath(
      clipper: _BottomCurveClipper(),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientTop, _gradientBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _DoodleLayer()),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                child: Column(
                  children: [
                    // AppBar row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _headerIconBtn(
                          Icons.arrow_back,
                              () => Navigator.pop(context),
                        ),
                        const Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                        _headerIconBtn(
                          Icons.refresh_rounded,
                              () => setState(() { _future = _fetchLeaderboard(); }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Podium — 2nd | 1st | 3rd
                    if (top3.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 2nd place
                          if (second != null)
                            _buildPodiumItem(second, 2, 52, 40),
                          const SizedBox(width: 12),
                          // 1st place
                          if (first != null)
                            _buildPodiumItem(first, 1, 64, 56),
                          const SizedBox(width: 12),
                          // 3rd place
                          if (third != null)
                            _buildPodiumItem(third, 3, 48, 30),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(
      _LeaderEntry entry, int rank, double avatarSize, double blockHeight) {
    final medalColor = rank == 1 ? _gold : rank == 2 ? _silver : _bronze;
    final medalBg    = medalColor.withOpacity(0.22);
    final medalBorder= medalColor.withOpacity(0.5);
    final medal      = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
    final level      = XpSystem.levelFromXP(entry.totalXP);
    final seed       = entry.avatarSeed.isNotEmpty ? entry.avatarSeed : entry.uid;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown for 1st only
        if (rank == 1)
          const Text('👑', style: TextStyle(fontSize: 20))
        else
          const SizedBox(height: 24),

        const SizedBox(height: 4),

        // Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: SvgPicture.network(
                  AvatarHelper.getUrl(seed),
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) => Container(
                    color: _gradientTop,
                    child: Center(
                      child: Text(
                        entry.name.isNotEmpty
                            ? entry.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: avatarSize * 0.35,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Rank badge
            Positioned(
              bottom: -4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: medalColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: _gradientTop, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: rank == 2 ? const Color(0xFF444444) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Name
        SizedBox(
          width: 80,
          child: Text(
            entry.name.isEmpty ? 'Unknown' : entry.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${entry.totalXP} XP',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white60,
          ),
        ),
        Text(
          'LVL $level',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: medalColor.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 6),

        // Podium block
        Container(
          width: 80,
          height: blockHeight,
          decoration: BoxDecoration(
            color: medalBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border.all(color: medalBorder),
          ),
          child: Center(
            child: Text(medal, style: const TextStyle(fontSize: 20)),
          ),
        ),
      ],
    );
  }

  // ── Filter tabs ──────────────────────────────────────────────
  Widget _buildTabs() {
    return Row(
      children: [
        _tab('🌍  Global', _Filter.global),
        const SizedBox(width: 10),
        _tab('📅  Weekly', _Filter.weekly),
      ],
    );
  }

  Widget _tab(String label, _Filter f) {
    final isActive = _filter == f;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setFilter(f),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _gradientBottom : _cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isActive ? _gradientBottom : _cardBorder,
            ),
            boxShadow: isActive
                ? [BoxShadow(
              color: _gradientBottom.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : Colors.white54,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // ── Rank row (4th place onward) ──────────────────────────────
  Widget _buildRankRow(_LeaderEntry entry, int rank, String currentUid) {
    final isMe   = entry.uid == currentUid;
    final level  = XpSystem.levelFromXP(entry.totalXP);
    final seed   = entry.avatarSeed.isNotEmpty ? entry.avatarSeed : entry.uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? _gradientBottom.withOpacity(0.15) : _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMe ? _gradientBottom : _cardBorder,
          width: isMe ? 1.5 : 1,
        ),
        boxShadow: isMe
            ? [BoxShadow(
          color: _gradientBottom.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )]
            : [BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )],
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isMe ? _gradientBottom : Colors.white38,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe
                    ? _gradientBottom
                    : Colors.white.withOpacity(0.2),
                width: isMe ? 2 : 1.5,
              ),
            ),
            child: ClipOval(
              child: SvgPicture.network(
                AvatarHelper.getUrl(seed),
                fit: BoxFit.cover,
                placeholderBuilder: (_) => Container(
                  color: _gradientTop,
                  child: Center(
                    child: Text(
                      entry.name.isNotEmpty
                          ? entry.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + quizzes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name.isEmpty ? 'Unknown' : entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _gradientBottom,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '📝 ${entry.quizzesPlayed} quizzes',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // XP + Level
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalXP} XP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isMe ? Colors.white : _gradientBottom,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'LVL $level',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: const Center(
        child: Text(
          'No other players yet.\nBe the first to climb the ranks! 🚀',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _headerIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.white54,
        letterSpacing: 1.4,
      ),
    );
  }
}

// ── Custom Clipper (same as profile_screen.dart) ────────────────
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 32);
    path.quadraticBezierTo(
      size.width / 2, size.height + 8,
      size.width, size.height - 32,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BottomCurveClipper old) => false;
}

// ── Doodle Layer (same as profile_screen.dart) ──────────────────
class _DoodleLayer extends StatelessWidget {
  const _DoodleLayer();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DoodlePainter());
}

class _DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final fill = Paint()..style = PaintingStyle.fill;

    stroke.color = Colors.white.withOpacity(0.13);
    canvas.drawCircle(const Offset(28, 42), 22, stroke);
    stroke.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(const Offset(28, 42), 13, stroke);

    stroke.color = Colors.white.withOpacity(0.11);
    canvas.drawCircle(Offset(size.width - 28, 72), 26, stroke);
    stroke.color = Colors.white.withOpacity(0.07);
    canvas.drawCircle(Offset(size.width - 28, 72), 16, stroke);

    stroke.color = Colors.white.withOpacity(0.09);
    canvas.drawCircle(Offset(18, size.height - 55), 22, stroke);

    stroke.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width - 18, size.height - 50), 28, stroke);

    _drawDotGrid(canvas, fill, const Offset(68, 16), 4, 3, 28);
    _drawDotGrid(canvas, fill, Offset(size.width - 112, 16), 4, 2, 28);

    stroke..color = Colors.white.withOpacity(0.16)..strokeWidth = 1.5;
    _drawStar(canvas, Offset(size.width / 2, 22), 10, stroke);
    stroke.color = Colors.white.withOpacity(0.14);
    _drawStar(canvas, Offset(58, size.height - 70), 10, stroke);

    stroke..color = Colors.white.withOpacity(0.15)..strokeWidth = 1.5;
    _drawDiamond(canvas, const Offset(18, 155), 10, stroke);
    stroke.color = Colors.white.withOpacity(0.13);
    _drawDiamond(canvas, Offset(size.width - 18, 155), 10, stroke);

    fill.color = Colors.white.withOpacity(0.15);
    canvas.drawCircle(Offset(size.width / 2, 100), 1.5, fill);
    canvas.drawCircle(Offset(size.width / 2 - 15, 88), 1.5, fill);
    canvas.drawCircle(Offset(size.width / 2 + 15, 100), 1.5, fill);
  }

  void _drawDotGrid(Canvas canvas, Paint fill, Offset origin,
      int cols, int rows, double spacing) {
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        fill.color = Colors.white.withOpacity(0.15 - r * 0.04);
        canvas.drawCircle(
          Offset(origin.dx + c * spacing, origin.dy + r * spacing),
          r == 0 ? 2.2 : (r == 1 ? 2.0 : 1.5),
          fill,
        );
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = Offset(
        center.dx + radius * cos((i * 4 * pi / 5) - pi / 2),
        center.dy + radius * sin((i * 4 * pi / 5) - pi / 2),
      );
      final inner = Offset(
        center.dx + (radius * 0.4) * cos((i * 4 * pi / 5) + 2 * pi / 5 - pi / 2),
        center.dy + (radius * 0.4) * sin((i * 4 * pi / 5) + 2 * pi / 5 - pi / 2),
      );
      if (i == 0) path.moveTo(outer.dx, outer.dy);
      else path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - size)
        ..lineTo(center.dx + size, center.dy)
        ..lineTo(center.dx, center.dy + size)
        ..lineTo(center.dx - size, center.dy)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DoodlePainter old) => false;
}