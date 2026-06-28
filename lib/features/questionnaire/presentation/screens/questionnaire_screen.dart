import 'package:flutter/material.dart';
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

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();

  String _goal = '';
  String _tone = '';
  String _quoteLength = 'any';
  final Set<String> _topics = {};
  String _language = 'en';
  TimeOfDay _notificationTime = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _availableTopics = [
    'Motivation', 'Love', 'Wisdom', 'Happiness', 'Success', 
    'Friendship', 'Life', 'Leadership', 'Productivity', 'Discipline',
    'Creativity', 'Mental Health', 'Spirituality', 'Focus', 'Confidence',
    'Patience', 'Resilience', 'Growth', 'Mindfulness', 'Stoicism',
    'Minimalism', 'Art', 'Design'
  ];
  
  final List<String> _availableGoals = ['Daily Inspiration', 'Overcome Depression', 'Boost Productivity', 'Learn Philosophy'];
  final List<String> _availableTones = ['Uplifting', 'Philosophical', 'Direct/Tough', 'Humorous'];

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
        _goal = state.preferences!.goal;
        _tone = state.preferences!.tone;
        _quoteLength = state.preferences!.quoteLength;
        _topics.addAll(state.preferences!.topics);
        _language = state.preferences!.language;
      });
    }
  }

  Future<void> _submit() async {
    if (_topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one topic')),
      );
      return;
    }

    final prefs = PreferenceEntity(
      goal: _goal,
      tone: _tone,
      favoriteAuthors: [], // Kept empty to satisfy backend/entity requirements
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
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('PERSONALIZE', style: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2.0)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(32.0),
            children: [
              _buildSectionTitle('WHAT IS YOUR MAIN GOAL?'),
              _buildDropdown(_availableGoals, _goal, (val) => setState(() => _goal = val!)),
              
              _buildSectionTitle('WHAT TONE DO YOU PREFER?'),
              _buildDropdown(_availableTones, _tone, (val) => setState(() => _tone = val!)),
              
              _buildSectionTitle('PREFERRED LENGTH'),
              _buildDropdown(['short', 'medium', 'long', 'any'], _quoteLength, (val) => setState(() => _quoteLength = val!)),

              _buildSectionTitle('SELECT THEMES (MIN 1)'),
              _buildMultiSelect(_availableTopics, _topics, isDark),

              _buildSectionTitle('LANGUAGE'),
              _buildDropdown(['en', 'es', 'fr', 'de'], _language, (val) => setState(() => _language = val!)),

              _buildSectionTitle('DAILY DELIVERY TIME'),
              InkWell(
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: _notificationTime);
                  if (time != null) setState(() => _notificationTime = time);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('SELECT TIME', style: AppTypography.dmSans(fontSize: 14, color: cs.onSurfaceVariant)),
                      Text(_notificationTime.format(context), style: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 64),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
                        )
                      : const Text('SAVE PREFERENCES'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 16),
      child: Text(
        title,
        style: AppTypography.dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0),
      ),
    );
  }

  Widget _buildDropdown(List<String> options, String currentValue, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: options.contains(currentValue) ? currentValue : null,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTypography.dmSans(fontSize: 14)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildMultiSelect(List<String> options, Set<String> selectedSet, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedSet.contains(option);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedSet.remove(option);
              } else {
                selectedSet.add(option);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : Colors.transparent,
              border: Border.all(color: isSelected ? cs.primary : (isDark ? AppColors.borderDark : AppColors.borderLight)),
            ),
            child: Text(
              option.toUpperCase(),
              style: AppTypography.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isSelected ? cs.onPrimary : cs.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
