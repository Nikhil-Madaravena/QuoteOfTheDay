import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../features/questionnaire/presentation/providers/preference_provider.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../models/quote_model.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class QuoteState {
  final QuoteModel? quote;
  final List<QuoteModel> history;
  final List<QuoteModel> favorites;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool isOffline;

  const QuoteState({
    this.quote,
    this.history = const [],
    this.favorites = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.isOffline = false,
  });

  QuoteState copyWith({
    QuoteModel? quote,
    List<QuoteModel>? history,
    List<QuoteModel>? favorites,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    bool? isOffline,
  }) {
    return QuoteState(
      quote: quote ?? this.quote,
      history: history ?? this.history,
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class QuoteNotifier extends StateNotifier<QuoteState> {
  final Dio _dio;
  final SharedPreferences _prefs;

  static const _cachedQuoteKey = 'cached_daily_quote';
  static const _cachedHistoryKey = 'cached_history';
  static const _cachedFavoritesKey = 'cached_favorites';
  static const _streakKey = 'streak_count';
  static const _streakDateKey = 'streak_date';

  QuoteNotifier(this._dio, this._prefs) : super(const QuoteState()) {
    _loadFromCache();
  }

  void _attachToken() {
    final token = _prefs.getString(AppConstants.authTokenKey);
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Load cached data immediately for offline support
  void _loadFromCache() {
    final cachedQuote = _prefs.getString(_cachedQuoteKey);
    final cachedHistory = _prefs.getStringList(_cachedHistoryKey) ?? [];
    final cachedFavs = _prefs.getStringList(_cachedFavoritesKey) ?? [];

    state = state.copyWith(
      quote: cachedQuote != null ? QuoteModel.fromJsonString(cachedQuote) : null,
      history: cachedHistory.map(QuoteModel.fromJsonString).toList(),
      favorites: cachedFavs.map(QuoteModel.fromJsonString).toList(),
    );
  }

  Future<void> loadDailyQuote() async {
    state = state.copyWith(isLoading: state.quote == null, isRefreshing: state.quote != null, clearError: true);
    try {
      _attachToken();
      final response = await _dio.get('/api/quotes/daily');
      final quote = QuoteModel.fromJson(response.data);
      await _prefs.setString(_cachedQuoteKey, quote.toJsonString());
      _updateStreak();
      state = state.copyWith(quote: quote, isLoading: false, isRefreshing: false, isOffline: false);
    } on DioException catch (e) {
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: isNetwork ? null : e.message,
        isOffline: isNetwork,
      );
    }
  }

  Future<void> regenerateQuote() async {
    if (state.quote?.hasRegenerated == true) return;
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      _attachToken();
      final response = await _dio.post('/api/quotes/regenerate');
      final quote = QuoteModel.fromJson(response.data);
      await _prefs.setString(_cachedQuoteKey, quote.toJsonString());
      state = state.copyWith(quote: quote, isRefreshing: false);
    } on DioException catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.message);
    }
  }

  Future<void> loadHistory() async {
    try {
      _attachToken();
      final response = await _dio.get('/api/quotes/history');
      final history = (response.data as List)
          .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      await _prefs.setStringList(
          _cachedHistoryKey, history.map((q) => q.toJsonString()).toList());
      state = state.copyWith(history: history, isOffline: false);
    } on DioException {
      // Silently fall back to cached data already loaded
    }
  }

  Future<void> loadFavorites() async {
    try {
      _attachToken();
      final response = await _dio.get('/api/quotes/favorites');
      final favs = (response.data as List)
          .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      await _prefs.setStringList(
          _cachedFavoritesKey, favs.map((q) => q.toJsonString()).toList());
      state = state.copyWith(favorites: favs, isOffline: false);
    } on DioException {
      // Silently fall back to cached data
    }
  }

  Future<void> toggleFavorite(QuoteModel quote) async {
    final isFav = state.favorites.any((f) => f.id == quote.id || f.quote == quote.quote);
    if (isFav) {
      await _removeFavorite(quote);
    } else {
      await _addFavorite(quote);
    }
  }

  Future<void> _addFavorite(QuoteModel quote) async {
    try {
      _attachToken();
      await _dio.post('/api/quotes/favorites', data: {
        'quoteText': quote.quote,
        'author': quote.author,
        'topic': quote.category,
      });
    } catch (_) {}
    // Optimistic update
    final newFavs = [quote, ...state.favorites];
    await _prefs.setStringList(
        _cachedFavoritesKey, newFavs.map((q) => q.toJsonString()).toList());
    state = state.copyWith(favorites: newFavs);
  }

  Future<void> _removeFavorite(QuoteModel quote) async {
    try {
      _attachToken();
      // Need to find the actual favorite ID, as the passed quote might be a DailyQuote ID
      final favToRemove = state.favorites.firstWhere(
        (f) => f.id == quote.id || f.quote == quote.quote,
        orElse: () => quote,
      );
      await _dio.delete('/api/quotes/favorites/${favToRemove.id}');
    } catch (_) {}
    // Optimistic update
    final newFavs = state.favorites.where((f) => f.id != quote.id && f.quote != quote.quote).toList();
    await _prefs.setStringList(
        _cachedFavoritesKey, newFavs.map((q) => q.toJsonString()).toList());
    state = state.copyWith(favorites: newFavs);
  }

  bool isFavorite(QuoteModel quote) {
    return state.favorites.any((f) => f.id == quote.id || f.quote == quote.quote);
  }

  // ── Streak tracking ──────────────────────────────────────────────────────
  void _updateStreak() {
    final lastDateStr = _prefs.getString(_streakDateKey);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (lastDateStr == null) {
      _prefs.setInt(_streakKey, 1);
      _prefs.setString(_streakDateKey, todayDate.toIso8601String());
      return;
    }

    final lastDate = DateTime.parse(lastDateStr);
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final diff = todayDate.difference(lastDay).inDays;

    if (diff == 0) return; // Already counted today
    if (diff == 1) {
      // Consecutive day
      final current = _prefs.getInt(_streakKey) ?? 0;
      _prefs.setInt(_streakKey, current + 1);
    } else {
      // Streak broken
      _prefs.setInt(_streakKey, 1);
    }
    _prefs.setString(_streakDateKey, todayDate.toIso8601String());
  }

  int get currentStreak => _prefs.getInt(_streakKey) ?? 0;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final quoteProvider = StateNotifierProvider<QuoteNotifier, QuoteState>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return QuoteNotifier(dio, prefs);
});

final streakProvider = Provider<int>((ref) {
  final notifier = ref.watch(quoteProvider.notifier);
  return notifier.currentStreak;
});
