import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/user_model.dart';
import '../../../../core/providers/shared_preferences_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthNotifier(this._dio, this._prefs) : super(const AuthState()) {
    _restoreSession();
  }

  /// On startup, check if a valid token exists and restore session.
  void _restoreSession() {
    final token = _prefs.getString(AppConstants.authTokenKey);
    final name = _prefs.getString('user_name') ?? '';
    final email = _prefs.getString('user_email') ?? '';
    final id = _prefs.getString('user_id') ?? '';
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserModel(id: id, name: name, email: email, token: token),
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Email and password are required');
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      final user = UserModel.fromJson(response.data);
      await _saveSession(user);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Login failed. Check your connection.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: msg);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated, error: 'All fields are required');
      return false;
    }
    if (password.length < 6) {
      state = state.copyWith(
          status: AuthStatus.unauthenticated,
          error: 'Password must be at least 6 characters');
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {'name': name.trim(), 'email': email.trim(), 'password': password},
      );
      final user = UserModel.fromJson(response.data);
      await _saveSession(user);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Registration failed.';
      state = state.copyWith(status: AuthStatus.unauthenticated, error: msg);
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(AppConstants.authTokenKey);
    await _prefs.remove('user_name');
    await _prefs.remove('user_email');
    await _prefs.remove('user_id');
    await _prefs.remove('cached_daily_quote');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _saveSession(UserModel user) async {
    await _prefs.setString(AppConstants.authTokenKey, user.token);
    await _prefs.setString('user_name', user.name);
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_id', user.id);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(dio, prefs);
});
