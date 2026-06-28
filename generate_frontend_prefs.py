import os

files = {
    'lib/features/questionnaire/domain/entities/preference_entity.dart': '''class PreferenceEntity {
  final String goal;
  final String tone;
  final List<String> favoriteAuthors;
  final String quoteLength;
  final List<String> topics;
  final String language;
  final String notificationTime;

  PreferenceEntity({
    required this.goal,
    required this.tone,
    required this.favoriteAuthors,
    required this.quoteLength,
    required this.topics,
    required this.language,
    required this.notificationTime,
  });

  factory PreferenceEntity.fromJson(Map<String, dynamic> json) {
    return PreferenceEntity(
      goal: json['goal'] ?? '',
      tone: json['tone'] ?? '',
      favoriteAuthors: List<String>.from(json['favoriteAuthors'] ?? []),
      quoteLength: json['quoteLength'] ?? 'any',
      topics: List<String>.from(json['topics'] ?? []),
      language: json['language'] ?? 'en',
      notificationTime: json['notificationTime'] ?? '08:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'tone': tone,
      'favoriteAuthors': favoriteAuthors,
      'quoteLength': quoteLength,
      'topics': topics,
      'language': language,
      'notificationTime': notificationTime,
    };
  }
}
''',
    'lib/features/questionnaire/domain/repositories/preference_repository.dart': '''import '../entities/preference_entity.dart';

abstract class PreferenceRepository {
  Future<PreferenceEntity> getPreferences();
  Future<PreferenceEntity> savePreferences(PreferenceEntity preferences);
}
''',
    'lib/features/questionnaire/data/repositories/preference_repository_impl.dart': '''import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/preference_entity.dart';
import '../domain/repositories/preference_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/app_constants.dart';

class PreferenceRepositoryImpl implements PreferenceRepository {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  PreferenceRepositoryImpl({required this.dio, required this.sharedPreferences});

  @override
  Future<PreferenceEntity> getPreferences() async {
    try {
      final token = sharedPreferences.getString(AppConstants.authTokenKey);
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await dio.get('/api/preferences');
      final pref = PreferenceEntity.fromJson(response.data);
      
      // Cache locally
      await sharedPreferences.setString('cached_preferences', json.encode(pref.toJson()));
      
      return pref;
    } catch (e) {
      // Fallback to cache
      final cachedStr = sharedPreferences.getString('cached_preferences');
      if (cachedStr != null) {
        return PreferenceEntity.fromJson(json.decode(cachedStr));
      }
      throw ServerException('Failed to load preferences');
    }
  }

  @override
  Future<PreferenceEntity> savePreferences(PreferenceEntity preferences) async {
    try {
      final token = sharedPreferences.getString(AppConstants.authTokenKey);
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.post('/api/preferences', data: preferences.toJson());
      final pref = PreferenceEntity.fromJson(response.data);

      // Cache locally
      await sharedPreferences.setString('cached_preferences', json.encode(pref.toJson()));

      return pref;
    } catch (e) {
      throw ServerException('Failed to save preferences');
    }
  }
}
''',
    'lib/features/questionnaire/presentation/providers/preference_provider.dart': '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../domain/entities/preference_entity.dart';
import '../data/repositories/preference_repository_impl.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

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
'''
}

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
