import 'dart:io';

class AppConstants {
  static const String appName = 'Quote of the Day';
  
  // Dynamically resolve localhost depending on the platform (10.0.2.2 for Android emulator)
  static String get baseUrl {
    if (const bool.hasEnvironment('API_URL')) {
      return const String.fromEnvironment('API_URL');
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }
  
  // SharedPreferences Keys
  static const String isFirstTimeUserKey = 'isFirstTimeUser';
  static const String authTokenKey = 'authToken';
  static const String notificationEnabledKey = 'notification_enabled';
  static const String notificationHourKey = 'notification_hour';
  static const String notificationMinuteKey = 'notification_minute';
}
