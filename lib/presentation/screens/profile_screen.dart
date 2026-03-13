// lib/presentation/screens/profile_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizapp/domain/entities/profile_model.dart';
import 'package:quizapp/presentation/blocs/profile_bloc.dart';
import 'package:quizapp/presentation/blocs/profile_event.dart';
import 'package:quizapp/presentation/blocs/profile_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quizapp/core/utils/avatar_helper.dart';
import 'package:quizapp/core/utils/xp_system.dart';

// ── Colour palette ───────────────────────────────────────────
const _gradientTop    = Color(0xFF097EA2);
const _gradientBottom = Color(0xFF0BA4D8);
const _bgColor        = Color(0xFF097EA2);
const _cardColor      = Color(0xFF076D8E);
const _cardBorder     = Color(0xFF0B8DB5);

// ── All available categories ──────────────────────────────────
const _allCategories = [
  '🖥️ Computer Science',
  '🏛️ History',
  '🤖 AI & ML',
  '🌍 Geography',
  '🔬 Science',
  '🏆 Sports',
  '🎨 Art & Literature',
  '🧮 Mathematics',
  '🎬 Movies & TV',
  '🎵 Music',
  '🍕 Food & Culture',
  '🚀 Space & Astronomy',
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) return _buildLoading();
        if (state is ProfileLoaded)  return _buildView(context, state.profile);
        if (state is ProfileEditing) return _buildEditView(context, state.draft);
        if (state is ProfileSaving)  return _buildLoading();
        if (state is ProfileError)   return _buildError(state.message);
        return const SizedBox.shrink();
      },
    );
  }

  // ── Loading ────────────────────────────────────────────────
  Widget _buildLoading() => const Scaffold(
    backgroundColor: _bgColor,
    body: Center(child: CircularProgressIndicator(color: _gradientBottom)),
  );

  // ── Error ──────────────────────────────────────────────────
  Widget _buildError(String message) => Scaffold(
    backgroundColor: _bgColor,
    body: Center(
      child: Text(message, style: const TextStyle(color: Colors.redAccent)),
    ),
  );

  // ── VIEW MODE ──────────────────────────────────────────────
  Widget _buildView(BuildContext context, UserProfile profile) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, profile),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBioCard(profile),
                  const SizedBox(height: 20),
                  _buildInlineStatsRow(profile),
                  const SizedBox(height: 20),
                  _sectionTitle('FAVORITE CATEGORIES'),
                  const SizedBox(height: 10),
                  _buildCategoryChips(profile),
                  const SizedBox(height: 20),
                  _sectionTitle('PROGRESS'),
                  const SizedBox(height: 10),
                  _buildLevelCard(profile), // ← now passes profile
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, UserProfile profile) {
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 52),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _headerIconBtn(Icons.arrow_back,
                                () => Navigator.pop(context)),
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                        _headerIconBtn(Icons.edit_outlined,
                                () => context.read<ProfileBloc>().add(StartEditing())),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildAvatar(profile),
                    const SizedBox(height: 10),
                    Text(
                      profile.name.isEmpty ? 'No name set' : profile.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile.location.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            profile.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  // ── AVATAR ─────────────────────────────────────────────────
  Widget _buildAvatar(UserProfile profile) {
    final seed = profile.avatarSeed.isNotEmpty ? profile.avatarSeed : profile.id;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: SvgPicture.network(
          AvatarHelper.getUrl(seed),
          width: 92,
          height: 92,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => Container(
            width: 92, height: 92,
            color: _gradientTop,
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── STATS ROW — now uses real profile data ─────────────────
  Widget _buildInlineStatsRow(UserProfile profile) {
    final total    = profile.quizzesPlayed;
    final accuracy = total > 0
        ? '${((profile.totalXP - total * 10) / (total * 20) * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : '—';

    return Row(
      children: [
        _buildStatCard('🎯', accuracy, 'Accuracy'),
        const SizedBox(width: 10),
        _buildStatCard('⚡', '${XpSystem.levelFromXP(profile.totalXP)}', 'Level'),
        const SizedBox(width: 10),
        _buildStatCard('📝', '$total', 'Quizzes'),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _gradientBottom,
                )),
            const SizedBox(height: 3),
            Text(label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54,
                  letterSpacing: 0.6,
                )),
          ],
        ),
      ),
    );
  }

  // ── BIO CARD ───────────────────────────────────────────────
  Widget _buildBioCard(UserProfile profile) {
    final isEmpty = profile.bio.isEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gradientTop, _gradientBottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BIO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white54,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEmpty ? 'No bio yet — tap edit to add one' : profile.bio,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                    color: isEmpty
                        ? Colors.white30
                        : Colors.white.withOpacity(0.9),
                    fontStyle:
                    isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── LEVEL CARD — fully wired to real XP ───────────────────
  Widget _buildLevelCard(UserProfile profile) {
    final xp        = profile.totalXP;
    final level     = XpSystem.levelFromXP(xp);
    final progress  = XpSystem.levelProgress(xp);
    final currentXP = xp - XpSystem.xpForCurrentLevel(xp);
    final neededXP  = XpSystem.xpForNextLevel(xp) - XpSystem.xpForCurrentLevel(xp);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_gradientTop, _gradientBottom],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '⚡ Level $level',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Text(
                'Next: Level ${level + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$currentXP XP',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54)),
              Text('$neededXP XP',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
              const AlwaysStoppedAnimation<Color>(_gradientBottom),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toStringAsFixed(0)}% to Level ${level + 1}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _gradientBottom,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CATEGORY CHIPS (view mode) ─────────────────────────────
  Widget _buildCategoryChips(UserProfile profile) {
    final selected = profile.favoriteCategories;

    if (selected.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white30, size: 18),
            SizedBox(width: 10),
            Text(
              'No categories yet — tap edit to add some',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white30,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selected.map((cat) {
        return Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _cardBorder),
          ),
          child: Text(
            cat,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── CATEGORY SELECTOR (edit mode) ─────────────────────────
  Widget _buildCategorySelector(BuildContext context, UserProfile draft) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allCategories.map((cat) {
        final isSelected = draft.favoriteCategories.contains(cat);
        return GestureDetector(
          onTap: () =>
              context.read<ProfileBloc>().add(ToggleCategory(cat)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _gradientTop : _cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? _gradientBottom : _cardBorder,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: _gradientBottom.withOpacity(0.3),
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
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                    isSelected ? Colors.white : Colors.white60,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── SECTION TITLE ──────────────────────────────────────────
  Widget _sectionTitle(String title) {
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

  // ── EDIT MODE ──────────────────────────────────────────────
  Widget _buildEditView(BuildContext context, UserProfile draft) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _gradientTop,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Edit Profile',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () =>
              context.read<ProfileBloc>().add(CancelEditing()),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () =>
                context.read<ProfileBloc>().add(SaveProfile()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: _buildAvatar(draft)),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () {
                final newSeed = AvatarHelper.randomSeed();
                context
                    .read<ProfileBloc>()
                    .add(UpdateField('avatarSeed', newSeed));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 9),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _cardBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shuffle_rounded,
                        color: _gradientBottom, size: 16),
                    SizedBox(width: 7),
                    Text(
                      'Randomize Avatar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _gradientBottom,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildTextField(
            context: context,
            initialValue: draft.name,
            label: 'Name',
            icon: Icons.person_outline,
            onChanged: (v) =>
                context.read<ProfileBloc>().add(UpdateField('name', v)),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context: context,
            initialValue: draft.bio,
            label: 'Bio',
            icon: Icons.info_outline,
            maxLines: 3,
            onChanged: (v) =>
                context.read<ProfileBloc>().add(UpdateField('bio', v)),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            context: context,
            initialValue: draft.location,
            label: 'Location',
            icon: Icons.location_on_outlined,
            onChanged: (v) => context
                .read<ProfileBloc>()
                .add(UpdateField('location', v)),
          ),
          const SizedBox(height: 24),
          const Text(
            'FAVORITE CATEGORIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white54,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap to select your interests',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white30,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategorySelector(context, draft),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String initialValue,
    required String label,
    required IconData icon,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: _gradientBottom, size: 20),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _gradientBottom),
          ),
        ),
      ),
    );
  }
}

// ── Custom Clipper ─────────────────────────────────────────────
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

// ── Doodle Layer ───────────────────────────────────────────────
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
    stroke.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(const Offset(28, 42), 5, stroke);

    stroke.color = Colors.white.withOpacity(0.11);
    canvas.drawCircle(Offset(size.width - 28, 72), 26, stroke);
    stroke.color = Colors.white.withOpacity(0.07);
    canvas.drawCircle(Offset(size.width - 28, 72), 16, stroke);
    stroke.color = Colors.white.withOpacity(0.04);
    canvas.drawCircle(Offset(size.width - 28, 72), 7, stroke);

    stroke.color = Colors.white.withOpacity(0.09);
    canvas.drawCircle(Offset(18, size.height - 55), 22, stroke);
    stroke.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(18, size.height - 55), 12, stroke);

    stroke.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width - 18, size.height - 50), 28, stroke);
    stroke.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width - 18, size.height - 50), 16, stroke);

    _drawDotGrid(canvas, fill, const Offset(68, 16), 4, 3, 28);
    _drawDotGrid(canvas, fill, Offset(size.width - 112, 16), 4, 2, 28);

    stroke..color = Colors.white.withOpacity(0.18)..strokeWidth = 2.0;
    final trophy = Path()
      ..moveTo(size.width - 72, 100)
      ..quadraticBezierTo(size.width - 72, 86, size.width - 62, 86)
      ..lineTo(size.width - 44, 86)
      ..quadraticBezierTo(size.width - 34, 86, size.width - 34, 100)
      ..quadraticBezierTo(size.width - 34, 116, size.width - 53, 122)
      ..quadraticBezierTo(size.width - 72, 116, size.width - 72, 100);
    canvas.drawPath(trophy, stroke);
    canvas.drawLine(Offset(size.width - 53, 122), Offset(size.width - 53, 132), stroke);
    canvas.drawLine(Offset(size.width - 62, 132), Offset(size.width - 44, 132), stroke);
    stroke..color = Colors.white.withOpacity(0.10)..strokeWidth = 1.5;
    canvas.drawLine(Offset(size.width - 80, 96), Offset(size.width - 72, 102), stroke);
    canvas.drawLine(Offset(size.width - 34, 102), Offset(size.width - 26, 96), stroke);

    stroke..color = Colors.white.withOpacity(0.18)..strokeWidth = 1.8;
    canvas.drawPath(Path()..moveTo(20,140)..lineTo(32,116)..lineTo(27,127)..lineTo(39,104)..lineTo(27,129)..lineTo(32,118), stroke);
    stroke.color = Colors.white.withOpacity(0.13);
    canvas.drawPath(Path()..moveTo(size.width-24,158)..lineTo(size.width-15,140)..lineTo(size.width-19,148)..lineTo(size.width-10,130)..lineTo(size.width-19,150)..lineTo(size.width-15,141), stroke);

    stroke..color = Colors.white.withOpacity(0.16)..strokeWidth = 1.5;
    _drawStar(canvas, Offset(size.width / 2, 22), 10, stroke);
    stroke.color = Colors.white.withOpacity(0.14);
    _drawStar(canvas, Offset(58, size.height - 70), 10, stroke);
    stroke.color = Colors.white.withOpacity(0.12);
    _drawStar(canvas, Offset(size.width - 58, size.height - 55), 9, stroke);

    stroke..color = Colors.white.withOpacity(0.15)..strokeWidth = 1.5;
    _drawDiamond(canvas, const Offset(18, 155), 10, stroke);
    stroke.color = Colors.white.withOpacity(0.13);
    _drawDiamond(canvas, Offset(size.width - 18, 155), 10, stroke);

    stroke..color = Colors.white.withOpacity(0.14)..strokeWidth = 1.5;
    canvas.drawPath(Path()..moveTo(14,size.height-32)..lineTo(26,size.height-52)..lineTo(32,size.height-46)..lineTo(20,size.height-26)..close(), stroke);
    canvas.drawLine(Offset(26, size.height - 52), Offset(29, size.height - 56), stroke);
    stroke.color = Colors.white.withOpacity(0.12);
    canvas.drawPath(Path()..moveTo(size.width-14,size.height-28)..lineTo(size.width-24,size.height-46)..lineTo(size.width-30,size.height-42)..lineTo(size.width-20,size.height-24)..close(), stroke);
    canvas.drawLine(Offset(size.width - 24, size.height - 46), Offset(size.width - 27, size.height - 50), stroke);

    _drawDashedArc(canvas, const Offset(0, 68), 58, stroke..color = Colors.white.withOpacity(0.10));
    _drawDashedArc(canvas, Offset(size.width, 68), 58, stroke..color = Colors.white.withOpacity(0.09));
    _drawDashedCurve(canvas, size, stroke..color = Colors.white.withOpacity(0.07)..strokeWidth = 1.5);

    stroke..color = Colors.white.withOpacity(0.12)..strokeWidth = 1.5;
    _drawCross(canvas, Offset(size.width / 2 - 16, 67), 7, stroke);
    _drawCross(canvas, Offset(size.width / 2 + 16, 55), 5, stroke);
    stroke.color = Colors.white.withOpacity(0.10);
    _drawCross(canvas, const Offset(80, 135), 6, stroke);
    _drawCross(canvas, Offset(size.width - 80, 166), 6, stroke);

    stroke..color = Colors.white.withOpacity(0.11)..strokeWidth = 1.5;
    _drawHexagon(canvas, Offset(size.width / 2 - 45, 165), 9, stroke);
    stroke.color = Colors.white.withOpacity(0.09);
    _drawHexagon(canvas, Offset(size.width / 2 + 50, 178), 7, stroke);

    fill.color = Colors.white.withOpacity(0.15);
    canvas.drawCircle(Offset(size.width / 2, 100), 1.5, fill);
    canvas.drawCircle(Offset(size.width / 2 - 15, 88), 1.5, fill);
    canvas.drawCircle(Offset(size.width / 2 + 15, 100), 1.5, fill);
    fill.color = Colors.white.withOpacity(0.10);
    canvas.drawCircle(const Offset(140, 130), 1.5, fill);
    canvas.drawCircle(Offset(size.width - 140, 130), 1.5, fill);
    canvas.drawCircle(const Offset(100, 160), 1.5, fill);
    canvas.drawCircle(Offset(size.width - 100, 155), 1.5, fill);
    fill.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width / 2 - 35, size.height - 45), 1.5, fill);
    canvas.drawCircle(Offset(size.width / 2 + 20, size.height - 50), 1.5, fill);
  }

  void _drawDotGrid(Canvas canvas, Paint fill, Offset origin, int cols, int rows, double spacing) {
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        fill.color = Colors.white.withOpacity(0.15 - r * 0.04);
        canvas.drawCircle(Offset(origin.dx + c * spacing, origin.dy + r * spacing), r == 0 ? 2.2 : (r == 1 ? 2.0 : 1.5), fill);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = Offset(center.dx + radius * cos((i * 4 * pi / 5) - pi / 2), center.dy + radius * sin((i * 4 * pi / 5) - pi / 2));
      final inner = Offset(center.dx + (radius * 0.4) * cos((i * 4 * pi / 5) + 2 * pi / 5 - pi / 2), center.dy + (radius * 0.4) * sin((i * 4 * pi / 5) + 2 * pi / 5 - pi / 2));
      if (i == 0) path.moveTo(outer.dx, outer.dy); else path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawPath(Path()..moveTo(center.dx, center.dy - size)..lineTo(center.dx + size, center.dy)..lineTo(center.dx, center.dy + size)..lineTo(center.dx - size, center.dy)..close(), paint);
  }

  void _drawCross(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawLine(Offset(center.dx, center.dy - size), Offset(center.dx, center.dy + size), paint);
    canvas.drawLine(Offset(center.dx - size, center.dy), Offset(center.dx + size, center.dy), paint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - pi / 6;
      final pt = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDashedArc(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashAngle = 0.20;
    const gapAngle  = 0.24;
    double angle = pi;
    for (int i = 0; i < 10; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), angle, dashAngle, false, paint);
      angle += dashAngle + gapAngle;
      if (angle > 2 * pi) break;
    }
  }

  void _drawDashedCurve(Canvas canvas, Size size, Paint paint) {
    const dashAngle = 0.16;
    const gapAngle  = 0.20;
    final center = Offset(size.width / 2, size.height + 20);
    final radius = size.width * 0.7;
    double angle = pi + 0.3;
    for (int i = 0; i < 12; i++) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), angle, dashAngle, false, paint);
      angle += dashAngle + gapAngle;
      if (angle > 2 * pi) break;
    }
  }

  @override
  bool shouldRepaint(_DoodlePainter old) => false;
}