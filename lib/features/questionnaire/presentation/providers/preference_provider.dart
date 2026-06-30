import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/preference_entity.dart';
import '../../data/repositories/preference_repository_impl.dart';

import '../../../../core/providers/shared_preferences_provider.dart';

final preferenceRepositoryProvider = Provider<PreferenceRepositoryImpl>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferenceRepositoryImpl(dio: dio, sharedPreferences: prefs);
});

class PreferenceState {
  final PreferenceEntity? preferences;
  final bool isLoading;
  final String? error;

  PreferenceState({this.preferences, this.isLoading = false, this.error});

  PreferenceState copyWith({PreferenceEntity? preferences, bool? isLoading, String? error}) {
    return PreferenceState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PreferenceNotifier extends StateNotifier<PreferenceState> {
  final PreferenceRepositoryImpl repository;

  PreferenceNotifier({required this.repository}) : super(PreferenceState());

  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await repository.getPreferences();
      state = state.copyWith(preferences: prefs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> savePreferences(PreferenceEntity prefs) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final savedPrefs = await repository.savePreferences(prefs);
      state = state.copyWith(preferences: savedPrefs, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final preferenceProvider = StateNotifierProvider<PreferenceNotifier, PreferenceState>((ref) {
  final repository = ref.watch(preferenceRepositoryProvider);
  return PreferenceNotifier(repository: repository);
});
