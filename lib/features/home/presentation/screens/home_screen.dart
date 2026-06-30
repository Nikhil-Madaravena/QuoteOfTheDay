import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/providers/quote_provider.dart';
import '../../../../core/models/quote_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/skeleton_loader.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim =
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quoteProvider.notifier).loadDailyQuote();
      // Check for a pending streak milestone to celebrate
      final milestone = ref.read(streakMilestoneProvider);
      if (milestone != null && mounted) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) _showMilestoneCelebration(milestone);
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _animateIn() {
    _entranceCtrl.forward(from: 0);
  }

  void _showMilestoneCelebration(int days) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MilestoneSheet(days: days),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    final quoteState = ref.watch(quoteProvider);
    final streak = ref.watch(streakProvider);

    ref.listen(quoteProvider.select((s) => s.quote), (prev, next) {
      if (next != null) _animateIn();
    });

    final isFav = quoteState.quote != null &&
        quoteState.favorites.any((f) => f.quote == quoteState.quote!.quote);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(cs, streak, isDark),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isDesktop ? 640 : double.infinity),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (quoteState.isOffline) ...[
                    _OfflineBanner(isDark: isDark),
                    const SizedBox(height: 12),
                  ],

                  // ── Quote section (Scrollable) ──────────────────────────
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (quoteState.isLoading)
                              const QuoteCardSkeleton()
                            else if (quoteState.quote != null)
                              FadeTransition(
                                opacity: _fadeAnim,
                                child: SlideTransition(
                                  position: _slideAnim,
                                  child: _QuoteCard(
                                    quote: quoteState.quote!,
                                    isDark: isDark,
                                  ),
                                ),
                              )
                            else if (quoteState.error != null)
                              _ErrorState(error: quoteState.error!, isDark: isDark)
                            else
                              _EmptyState(isDark: isDark),
                          ],
                        ),
                      ),
                    ),
                  ),



                  // ── Action Bar ────────────────────────────────────────
                  if (quoteState.quote != null) ...[
                    _ActionBar(
                      isFavorite: isFav,
                      onCopy: _copyQuote,
                      onFavorite: () => ref
                          .read(quoteProvider.notifier)
                          .toggleFavorite(quoteState.quote!),
                      onHistory: () => context.push(AppRoutes.history),
                      isDark: isDark,
                      cs: cs,
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme cs, int streak, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('QELIO',
          style: AppTypography.dmSans(
              fontSize: 11, 
              fontWeight: FontWeight.w700, 
              letterSpacing: 2.0,
              color: isDark ? AppColors.white : AppColors.black)),
      actions: [
        if (streak > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text('STREAK: $streak',
                  style: AppTypography.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: isDark ? AppColors.grey400 : AppColors.grey500)),
            ),
          ),
        IconButton(
          onPressed: () => context.push(AppRoutes.profile),
          icon: Icon(Icons.person_outline_rounded,
              size: 20,
              color: isDark ? AppColors.white : AppColors.black),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _copyQuote() {
    final q = ref.read(quoteProvider).quote;
    if (q == null) return;
    final text = '"${q.quote}"';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('COPIED TO CLIPBOARD'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// ── Quote View ───────────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final bool isDark;

  const _QuoteCard({
    required this.quote,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        Clipboard.setData(ClipboardData(text: '"${quote.quote}"'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('COPIED TO CLIPBOARD')),
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category label
            Text(
              quote.category.toUpperCase(),
              style: AppTypography.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.accentGold : AppColors.grey500,
                letterSpacing: 3.0,
              ),
            ),

            const SizedBox(height: 28),

            // Quote body
            Text(
              '\u201C${quote.quote}\u201D',
              style: AppTypography.playfair(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkOnSurface : AppColors.black,
                height: 1.65,
              ),
              textAlign: TextAlign.left,
            ),

            // Explanation / Insight
            if (quote.explanation.isNotEmpty) ...[
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 1,
                color: isDark ? AppColors.borderDark : AppColors.grey200,
              ),
              const SizedBox(height: 28),
              Text(
                quote.explanation,
                style: AppTypography.dmSans(
                  fontSize: 12,
                  height: 1.9,
                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Action Bar ────────────────────────────────────────────────────────────────
class _ActionBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onCopy;
  final VoidCallback onFavorite;
  final VoidCallback onHistory;
  final bool isDark;
  final ColorScheme cs;

  const _ActionBar({
    required this.isFavorite,
    required this.onCopy,
    required this.onFavorite,
    required this.onHistory,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.copy_rounded,
            label: 'COPY',
            onTap: onCopy,
            isDark: isDark,
          ),
          _ActionButton(
            icon: isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            label: isFavorite ? 'SAVED' : 'SAVE',
            onTap: onFavorite,
            isDark: isDark,
            isActive: isFavorite,
          ),
          _ActionButton(
            icon: Icons.access_time_rounded,
            label: 'HISTORY',
            onTap: onHistory,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.accentGold : AppColors.black;
    final inactiveColor = isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500;
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isActive ? activeColor : (isDark ? AppColors.darkOnSurface : AppColors.black)),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.dmSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Offline Banner ────────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  final bool isDark;
  const _OfflineBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? AppColors.grey900 : AppColors.grey100,
      child: Text(
        'OFFLINE. SHOWING CACHED.',
        style: AppTypography.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: isDark ? AppColors.grey400 : AppColors.grey500),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  final bool isDark;
  const _ErrorState({required this.error, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 32, color: isDark ? AppColors.white : AppColors.black),
          const SizedBox(height: 24),
          Text('UNABLE TO LOAD',
              style: AppTypography.dmSans(
                  fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.0)),
          const SizedBox(height: 12),
          Text(error,
              textAlign: TextAlign.center,
              style: AppTypography.dmSans(
                  fontSize: 13, color: isDark ? AppColors.grey500 : AppColors.grey400)),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('NO QUOTE AVAILABLE.',
          style: AppTypography.dmSans(
              fontSize: 11,
              letterSpacing: 2.0,
              color: isDark ? AppColors.grey500 : AppColors.grey400)),
    );
  }
}



// ── Streak Milestone Celebration Sheet ───────────────────────────────────────
class _MilestoneSheet extends StatelessWidget {
  final int days;
  const _MilestoneSheet({required this.days});

  String get _emoji {
    if (days >= 100) return '🏆';
    if (days >= 30) return '🔥';
    if (days >= 14) return '⚡';
    if (days >= 7) return '🌟';
    return '✨';
  }

  String get _title {
    if (days >= 100) return 'LEGENDARY';
    if (days >= 30) return 'ON FIRE';
    if (days >= 14) return 'TWO WEEKS STRONG';
    if (days >= 7) return 'ONE WEEK IN';
    return 'GETTING STARTED';
  }

  String get _message {
    if (days >= 100) return 'A hundred days of daily wisdom. That\'s not a habit — that\'s a lifestyle. You\'re absolutely unstoppable.';
    if (days >= 30) return 'A full month of showing up every single day. Most people quit in week one. You didn\'t.';
    if (days >= 14) return 'Two solid weeks of daily growth. You\'re building something real here. Keep going.';
    if (days >= 7) return 'A whole week of daily reflection. The hardest part is starting — and you\'ve already done that.';
    return 'Three days in and already building momentum. Every great habit starts exactly like this.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gold gradient header bar
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentGold, Color(0xFFFFF0A0), AppColors.accentGold],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              children: [
                // Emoji
                Text(_emoji, style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 16),

                // Day count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '$days DAY STREAK',
                    style: AppTypography.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  _title,
                  style: AppTypography.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: isDark ? AppColors.darkOnSurface : AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: AppTypography.dmSans(
                    fontSize: 13,
                    height: 1.7,
                    color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 32),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'KEEP IT UP',
                      style: AppTypography.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
