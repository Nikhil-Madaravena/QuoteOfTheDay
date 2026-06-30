import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "badge": "DAILY INSIGHTS",
      "title": "WISDOM, REIMAGINED.",
      "text": "Receive one original, masterfully crafted insight every day. No clutter, no noise.",
      "visual": "01"
    },
    {
      "badge": "TAILORED INTENSITY",
      "title": "PERSONAL PHILOSOPHY.",
      "text": "Configure your goal and focus parameters. Quotes are custom-tailored to align with your personal vision.",
      "visual": "02"
    },
    {
      "badge": "YOUR ARCHIVE",
      "title": "CURATE WISDOM.",
      "text": "Organize your favorite thoughts into a premium personal catalog, accessible anytime.",
      "visual": "03"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // ── Premium Glow Background ───────────────────────────────────────
          _GlowBackground(isDark: isDark),

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        'SKIP',
                        style: AppTypography.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPage = value;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = _onboardingData[index];
                      final progress = (index + 1) / _onboardingData.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Beautiful custom progress ring index
                            _OnboardingProgressRing(
                              progress: progress,
                              text: data['visual']!,
                            ),
                            const SizedBox(height: 48),
                            // Badge
                            Text(
                              data['badge']!,
                              style: AppTypography.dmSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3.0,
                                color: isDark ? AppColors.accentGold : AppColors.grey500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Title
                            Text(
                              data['title']!,
                              style: AppTypography.playfair(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkOnSurface : AppColors.black,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Description text
                            Text(
                              data['text']!,
                              style: AppTypography.dmSans(
                                fontSize: 14,
                                height: 1.7,
                                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sleek dots
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => buildDot(index, isDark),
                        ),
                      ),
                      // CTA button
                      TextButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            context.go(AppRoutes.questionnaire);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? AppColors.accentGold : AppColors.black,
                          foregroundColor: isDark ? AppColors.black : AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _onboardingData.length - 1 ? 'GET STARTED' : 'NEXT',
                              style: AppTypography.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: isDark ? AppColors.black : AppColors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: isDark ? AppColors.black : AppColors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, bool isDark) {
    final activeColor = isDark ? AppColors.accentGold : AppColors.black;
    final inactiveColor = isDark ? AppColors.borderDark : AppColors.grey200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 4,
      width: _currentPage == index ? 20 : 4,
      decoration: BoxDecoration(
        color: _currentPage == index ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── Glow Background ─────────────────────────────────────────────────────────
class _GlowBackground extends StatefulWidget {
  final bool isDark;
  const _GlowBackground({required this.isDark});

  @override
  State<_GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<_GlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
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
      builder: (context, child) {
        final val = _ctrl.value;
        return Stack(
          children: [
            // Blob 1
            AnimatedAlign(
              duration: const Duration(milliseconds: 0),
              alignment: Alignment(
                -0.8 + 0.6 * math.sin(val * 2 * math.pi),
                -0.5 + 0.4 * math.cos(val * 2 * math.pi),
              ),
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGold.withValues(alpha: widget.isDark ? 0.08 : 0.04),
                ),
              ),
            ),
            // Blob 2
            AnimatedAlign(
              duration: const Duration(milliseconds: 0),
              alignment: Alignment(
                0.8 + 0.5 * math.cos(val * 2 * math.pi),
                0.6 + 0.3 * math.sin(val * 2 * math.pi),
              ),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9F72FF).withValues(alpha: widget.isDark ? 0.05 : 0.02),
                ),
              ),
            ),
            // Blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Onboarding Progress Ring ────────────────────────────────────────────────
class _OnboardingProgressRing extends StatelessWidget {
  final double progress;
  final String text;

  const _OnboardingProgressRing({
    required this.progress,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _RingPainter(
        progress: progress,
        color: isDark ? AppColors.accentGold : AppColors.black,
        trackColor: isDark ? AppColors.borderDark : AppColors.grey200,
      ),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTypography.playfair(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkOnSurface : AppColors.black,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 2.0;

    final paintTrack = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paintTrack);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paintArc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
