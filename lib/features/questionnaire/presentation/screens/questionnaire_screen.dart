import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/preference_provider.dart';
import '../../domain/entities/preference_entity.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // ── Preferences state ─────────────────────────────────────────────────────
  String _goal = '';
  String _tone = '';
  String _quoteLength = 'short';
  final Set<String> _topics = {};
  String _language = 'en';
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Map<String, String>> _goals = [
    {'value': 'MIND COMPOSURE', 'sub': 'Cultivate calm, focus and clarity'},
    {'value': 'PSYCHOLOGICAL RESILIENCE', 'sub': 'Build inner strength for adversity'},
    {'value': 'COGNITIVE PERFORMANCE', 'sub': 'Sharpen thinking and productivity'},
    {'value': 'CLASSICAL WISDOM', 'sub': 'Draw from timeless philosophical traditions'},
  ];

  final List<Map<String, String>> _tones = [
    {'value': 'EMPATHETIC & WARM', 'sub': 'Gentle, supportive and human'},
    {'value': 'SOCRATIC & CONTEMPLATIVE', 'sub': 'Deep, thought-provoking questions'},
    {'value': 'STOIC & DIRECT', 'sub': 'Unflinching truth, no sugarcoating'},
    {'value': 'WRY & WITTY', 'sub': 'Sharp observations with a quiet smile'},
  ];

  final List<String> _availableTopics = [
    'Motivation', 'Love', 'Wisdom', 'Happiness', 'Success',
    'Friendship', 'Life', 'Leadership', 'Productivity', 'Discipline',
    'Creativity', 'Mental Health', 'Spirituality', 'Focus', 'Confidence',
    'Patience', 'Resilience', 'Growth', 'Mindfulness', 'Stoicism',
    'Minimalism', 'Art', 'Design',
  ];

  final List<Map<String, String>> _lengths = [
    {'value': 'short', 'label': 'TERSE', 'sub': 'One sharp line'},
    {'value': 'medium', 'label': 'MEASURED', 'sub': 'Two to three sentences'},
    {'value': 'long', 'label': 'EXPANSIVE', 'sub': 'Full thought explored'},
    {'value': 'any', 'label': 'WHATEVER FITS', 'sub': 'Let the idea decide'},
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'en', 'label': 'ENGLISH'},
    {'value': 'es', 'label': 'ESPAÑOL'},
    {'value': 'fr', 'label': 'FRANÇAIS'},
    {'value': 'de', 'label': 'DEUTSCH'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingPreferences();
    });
  }

  void _loadExistingPreferences() {
    final state = ref.read(preferenceProvider);
    if (state.preferences != null) {
      setState(() {
        _goal = state.preferences!.goal.isNotEmpty ? state.preferences!.goal : '';
        _tone = state.preferences!.tone.isNotEmpty ? state.preferences!.tone : '';
        _quoteLength = state.preferences!.quoteLength.isNotEmpty ? state.preferences!.quoteLength : 'short';
        _topics.addAll(state.preferences!.topics);
        _language = state.preferences!.language.isNotEmpty ? state.preferences!.language : 'en';
      });
    }
  }

  bool get _canAdvance {
    switch (_currentStep) {
      case 0: return _goal.isNotEmpty;
      case 1: return _tone.isNotEmpty;
      case 2: return _topics.isNotEmpty;
      case 3: return true;
      case 4: return true;
      default: return true;
    }
  }

  void _advance() {
    if (!_canAdvance) {
      HapticFeedback.lightImpact();
      return;
    }
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _submit() async {
    final prefs = PreferenceEntity(
      goal: _goal,
      tone: _tone,
      favoriteAuthors: [],
      quoteLength: _quoteLength,
      topics: _topics.toList(),
      language: _language,
      notificationTime: '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}',
    );

    final success = await ref.read(preferenceProvider.notifier).savePreferences(prefs);
    if (success && mounted) {
      context.go(AppRoutes.home);
    } else if (mounted) {
      final error = ref.read(preferenceProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to save preferences')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(preferenceProvider);
    const totalSteps = 5;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Glow background
          _QGlowBackground(isDark: isDark, step: _currentStep),

          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        GestureDetector(
                          onTap: _back,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.grey200,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      Expanded(
                        child: Center(
                          child: Text(
                            'PERSONALIZE',
                            style: AppTypography.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.0,
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                            ),
                          ),
                        ),
                      ),
                      // Step counter
                      Text(
                        '${_currentStep + 1} / $totalSteps',
                        style: AppTypography.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Progress Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _SegmentedProgressBar(
                    totalSteps: totalSteps,
                    currentStep: _currentStep,
                    isDark: isDark,
                  ),
                ),

                // ── Steps ─────────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StepGoal(
                        goals: _goals,
                        selected: _goal,
                        isDark: isDark,
                        onSelect: (val) => setState(() => _goal = val),
                      ),
                      _StepTone(
                        tones: _tones,
                        selected: _tone,
                        isDark: isDark,
                        onSelect: (val) => setState(() => _tone = val),
                      ),
                      _StepTopics(
                        topics: _availableTopics,
                        selected: _topics,
                        isDark: isDark,
                        onToggle: (val) {
                          setState(() {
                            if (_topics.contains(val)) {
                              _topics.remove(val);
                            } else {
                              _topics.add(val);
                            }
                          });
                        },
                      ),
                      _StepLength(
                        lengths: _lengths,
                        selected: _quoteLength,
                        isDark: isDark,
                        onSelect: (val) => setState(() => _quoteLength = val),
                      ),
                      _StepDelivery(
                        languages: _languages,
                        selectedLanguage: _language,
                        notificationTime: _notificationTime,
                        isDark: isDark,
                        onLanguageSelect: (val) => setState(() => _language = val),
                        onTimeTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _notificationTime,
                          );
                          if (time != null) setState(() => _notificationTime = time);
                        },
                      ),
                    ],
                  ),
                ),

                // ── CTA ───────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      if (!_canAdvance)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _currentStep == 2 ? 'Select at least one theme to continue.' : 'Make a selection to continue.',
                            style: AppTypography.dmSans(
                              fontSize: 11,
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _canAdvance ? 1.0 : 0.4,
                          child: TextButton(
                            onPressed: state.isLoading ? null : _advance,
                            style: TextButton.styleFrom(
                              backgroundColor: isDark ? AppColors.accentGold : AppColors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: state.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: isDark ? AppColors.black : AppColors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentStep == 4 ? 'SAVE & BEGIN' : 'CONTINUE',
                                        style: AppTypography.dmSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2.5,
                                          color: isDark ? AppColors.black : AppColors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _currentStep == 4 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: isDark ? AppColors.black : AppColors.white,
                                      ),
                                    ],
                                  ),
                          ),
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
}

// ─── Segmented Progress Bar ──────────────────────────────────────────────────
class _SegmentedProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final bool isDark;

  const _SegmentedProgressBar({
    required this.totalSteps,
    required this.currentStep,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isFilled = index <= currentStep;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              height: 3,
              decoration: BoxDecoration(
                color: isFilled
                    ? (isDark ? AppColors.accentGold : AppColors.black)
                    : (isDark ? AppColors.borderDark : AppColors.grey200),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── STEP 1: Goal ────────────────────────────────────────────────────────────
class _StepGoal extends StatelessWidget {
  final List<Map<String, String>> goals;
  final String selected;
  final bool isDark;
  final void Function(String) onSelect;

  const _StepGoal({
    required this.goals,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      badge: 'STEP 1 — INTENTION',
      title: 'WHAT DO YOU\nSEEK TO BUILD?',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        itemCount: goals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final goal = goals[index];
          final isSelected = selected == goal['value'];
          return _SelectCard(
            label: goal['value']!,
            sub: goal['sub']!,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => onSelect(goal['value']!),
          );
        },
      ),
    );
  }
}

// ─── STEP 2: Tone ────────────────────────────────────────────────────────────
class _StepTone extends StatelessWidget {
  final List<Map<String, String>> tones;
  final String selected;
  final bool isDark;
  final void Function(String) onSelect;

  const _StepTone({
    required this.tones,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      badge: 'STEP 2 — VOICE',
      title: 'HOW SHOULD\nWISDOM SPEAK TO YOU?',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        itemCount: tones.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tone = tones[index];
          final isSelected = selected == tone['value'];
          return _SelectCard(
            label: tone['value']!,
            sub: tone['sub']!,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => onSelect(tone['value']!),
          );
        },
      ),
    );
  }
}

// ─── STEP 3: Topics ──────────────────────────────────────────────────────────
class _StepTopics extends StatelessWidget {
  final List<String> topics;
  final Set<String> selected;
  final bool isDark;
  final void Function(String) onToggle;

  const _StepTopics({
    required this.topics,
    required this.selected,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      badge: 'STEP 3 — TERRITORY',
      title: 'WHICH DOMAINS\nCALL TO YOU?',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics.map((topic) {
            final isSelected = selected.contains(topic);
            return GestureDetector(
              onTap: () => onToggle(topic),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGold.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentGold
                        : (isDark ? AppColors.borderDark : AppColors.grey200),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  topic.toUpperCase(),
                  style: AppTypography.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isSelected
                        ? AppColors.accentGold
                        : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── STEP 4: Quote Length ────────────────────────────────────────────────────
class _StepLength extends StatelessWidget {
  final List<Map<String, String>> lengths;
  final String selected;
  final bool isDark;
  final void Function(String) onSelect;

  const _StepLength({
    required this.lengths,
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      badge: 'STEP 4 — DEPTH',
      title: 'HOW MUCH\nSPACE FOR THOUGHT?',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        itemCount: lengths.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final length = lengths[index];
          final isSelected = selected == length['value'];
          return _SelectCard(
            label: length['label']!,
            sub: length['sub']!,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => onSelect(length['value']!),
          );
        },
      ),
    );
  }
}

// ─── STEP 5: Delivery ────────────────────────────────────────────────────────
class _StepDelivery extends StatelessWidget {
  final List<Map<String, String>> languages;
  final String selectedLanguage;
  final TimeOfDay notificationTime;
  final bool isDark;
  final void Function(String) onLanguageSelect;
  final VoidCallback onTimeTap;

  const _StepDelivery({
    required this.languages,
    required this.selectedLanguage,
    required this.notificationTime,
    required this.isDark,
    required this.onLanguageSelect,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      badge: 'STEP 5 — DELIVERY',
      title: 'WHEN AND IN WHAT\nTONGUE?',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          // Language
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'LANGUAGE',
              style: AppTypography.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: languages.map((lang) {
              final isSelected = selectedLanguage == lang['value'];
              return GestureDetector(
                onTap: () => onLanguageSelect(lang['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentGold.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.accentGold : (isDark ? AppColors.borderDark : AppColors.grey200),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    lang['label']!,
                    style: AppTypography.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isSelected
                          ? AppColors.accentGold
                          : (isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),
          // Daily delivery time
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'DAILY DELIVERY TIME',
              style: AppTypography.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.grey200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TAP TO CHANGE',
                        style: AppTypography.dmSans(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (ctx) => Text(
                          notificationTime.format(ctx),
                          style: AppTypography.playfair(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkOnSurface : AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.grey300,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.alarm_rounded,
                      size: 18,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Step Shell ───────────────────────────────────────────────────────
class _StepShell extends StatelessWidget {
  final String badge;
  final String title;
  final Widget child;

  const _StepShell({
    required this.badge,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge,
                style: AppTypography.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.0,
                  color: isDark ? AppColors.accentGold : AppColors.grey500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: AppTypography.playfair(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkOnSurface : AppColors.black,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

// ─── Premium Select Card ─────────────────────────────────────────────────────
class _SelectCard extends StatelessWidget {
  final String label;
  final String sub;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SelectCard({
    required this.label,
    required this.sub,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGold.withValues(alpha: 0.09)
              : (isDark ? AppColors.darkSurfaceVariant : Colors.transparent),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGold
                : (isDark ? AppColors.borderDark : AppColors.grey200),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isSelected
                          ? AppColors.accentGold
                          : (isDark ? AppColors.darkOnSurface : AppColors.black),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    sub,
                    style: AppTypography.dmSans(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accentGold : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGold
                      : (isDark ? AppColors.borderDark : AppColors.grey300),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 12, color: AppColors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Glow Background ────────────────────────────────────────────────────────
class _QGlowBackground extends StatefulWidget {
  final bool isDark;
  final int step;

  const _QGlowBackground({required this.isDark, required this.step});

  @override
  State<_QGlowBackground> createState() => _QGlowBackgroundState();
}

class _QGlowBackgroundState extends State<_QGlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
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
            Positioned(
              top: 80 + 80 * math.sin(val * 2 * math.pi),
              right: -60 + 40 * math.cos(val * 2 * math.pi),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGold.withValues(alpha: widget.isDark ? 0.06 : 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: 120 + 60 * math.cos(val * 2 * math.pi),
              left: -80 + 30 * math.sin(val * 2 * math.pi),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9F72FF).withValues(alpha: widget.isDark ? 0.04 : 0.015),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}
