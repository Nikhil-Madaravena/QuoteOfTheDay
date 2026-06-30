import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationSettingsState {
  final bool isEnabled;
  final int hour;
  final int minute;
  final bool isLoading;
  final bool permissionDenied;

  const NotificationSettingsState({
    this.isEnabled = true,
    this.hour = 8,
    this.minute = 0,
    this.isLoading = false,
    this.permissionDenied = false,
  });

  NotificationSettingsState copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
    bool? isLoading,
    bool? permissionDenied,
  }) {
    return NotificationSettingsState(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isLoading: isLoading ?? this.isLoading,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  final NotificationService _service;
  final SharedPreferences _prefs;

  NotificationSettingsNotifier(this._service, this._prefs)
      : super(const NotificationSettingsState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final isEnabled = _prefs.getBool(AppConstants.notificationEnabledKey) ?? true;
    final hour = _prefs.getInt(AppConstants.notificationHourKey) ?? 8;
    final minute = _prefs.getInt(AppConstants.notificationMinuteKey) ?? 0;
    state = state.copyWith(isEnabled: isEnabled, hour: hour, minute: minute);
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true);
    if (enabled) {
      final granted = await _service.requestPermissions();
      if (!granted) {
        state = state.copyWith(isLoading: false, permissionDenied: true, isEnabled: false);
        return;
      }
      await _service.scheduleDailyQuoteNotification(
        hour: state.hour,
        minute: state.minute,
      );
    } else {
      await _service.cancelDailyNotification();
    }
    await _prefs.setBool(AppConstants.notificationEnabledKey, enabled);
    state = state.copyWith(isEnabled: enabled, isLoading: false, permissionDenied: false);
  }

  Future<void> updateTime(int hour, int minute) async {
    state = state.copyWith(isLoading: true);
    await _prefs.setInt(AppConstants.notificationHourKey, hour);
    await _prefs.setInt(AppConstants.notificationMinuteKey, minute);

    if (state.isEnabled) {
      await _service.scheduleDailyQuoteNotification(hour: hour, minute: minute);
    }
    state = state.copyWith(hour: hour, minute: minute, isLoading: false);
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return NotificationSettingsNotifier(service, prefs);
});
