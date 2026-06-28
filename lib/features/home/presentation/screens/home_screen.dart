import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/providers/quote_provider.dart';
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

                  const Spacer(flex: 1),

                  // ── Quote section ──────────────────────────────────────
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

                  const Spacer(flex: 2),

                  // ── Action Bar ────────────────────────────────────────
                  if (quoteState.quote != null) ...[
                    _ActionBar(
                      isFavorite: isFav,
                      onShare: _shareQuote,
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
      title: Text('QUOTIDIAN',
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

  Future<void> _shareQuote() async {
    final q = ref.read(quoteProvider).quote;
    if (q == null) return;
    
    final shareText = '"${q.quote}"\n\n— Quotidian';
    
    try {
      await Share.share(shareText);
    } catch (e) {
      // Fallback to clipboard if the native share sheet fails or is unsupported
      _fallbackShare(shareText);
    }
  }

  void _fallbackShare(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard.')),
      );
    }
  }
}

// ── Quote View ───────────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final dynamic quote;
  final bool isDark;

  const _QuoteCard({
    required this.quote,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: '"${quote.quote}"'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied.')),
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text(
              (quote.category as String).toUpperCase(),
              style: AppTypography.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.grey500 : AppColors.grey400,
                letterSpacing: 2.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quote body
            Text(
              quote.quote as String,
              style: AppTypography.playfair(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.white : AppColors.black,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
            
            const SizedBox(height: 48),

            // Explanation / Insight
            if ((quote.explanation as String).isNotEmpty) ...[
              Container(
                width: 32,
                height: 1,
                color: isDark ? AppColors.grey800 : AppColors.grey200,
              ),
              const SizedBox(height: 24),
              Text(
                quote.explanation as String,
                style: AppTypography.dmSans(
                  fontSize: 13,
                  height: 1.8,
                  color: isDark ? AppColors.grey400 : AppColors.grey500,
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
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final VoidCallback onHistory;
  final bool isDark;
  final ColorScheme cs;

  const _ActionBar({
    required this.isFavorite,
    required this.onShare,
    required this.onFavorite,
    required this.onHistory,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MinimalIcon(
            icon: Icons.ios_share_rounded,
            onTap: onShare,
            isDark: isDark,
          ),
          _MinimalIcon(
            icon: isFavorite
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            onTap: onFavorite,
            isDark: isDark,
          ),
          _MinimalIcon(
            icon: Icons.view_carousel_outlined,
            onTap: onHistory,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _MinimalIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _MinimalIcon({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? AppColors.white : AppColors.black,
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
