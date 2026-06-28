import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const int _dailyQuoteNotificationId = 0;
  static const String _channelId = 'qod_daily_quote';
  static const String _channelName = 'Daily Quote';
  static const String _channelDescription =
      'Notifies you when your personalized daily quote is ready';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Linux desktop does not support flutter_local_notifications — skip.
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Detect the local timezone from the device
    final String timezoneName = await _getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Called when user taps a notification
  void _onNotificationTap(NotificationResponse response) {
    // Navigation is handled by the app router reading the payload
    // The payload 'home' signals GoRouter to navigate to the home/quote screen
  }

  /// Request platform-specific notification permissions.
  /// Returns true if permission granted.
  Future<bool> requestPermissions() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) return false;

    // Android 13+ explicit permission request
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? granted =
          await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      return granted ?? false;
    }

    // iOS permission request
    final IOSFlutterLocalNotificationsPlugin? iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final bool? granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Schedule a daily notification at the given [hour] and [minute] (local time).
  Future<void> scheduleDailyQuoteNotification({
    required int hour,
    required int minute,
  }) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) return;

    // Cancel any existing notification first
    await cancelDailyNotification();

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'Daily Quote',
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        badgeNumber: 1,
      ),
    );

    await _plugin.zonedSchedule(
      _dailyQuoteNotificationId,
      '✨ Quote of the Day',
      'Your personalized quote is ready. Tap to read it!',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'home',
    );
  }

  /// Cancel the scheduled daily notification.
  Future<void> cancelDailyNotification() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) return;
    await _plugin.cancel(_dailyQuoteNotificationId);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) return;
    await _plugin.cancelAll();
  }

  /// Returns the next [tz.TZDateTime] instance for the specified [hour]:[minute].
  /// If the time has already passed today, returns tomorrow's instance.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Attempts to get the device's IANA timezone name.
  /// Falls back to 'UTC' if detection fails.
  Future<String> _getLocalTimezone() async {
    try {
      final offset = DateTime.now().timeZoneOffset;
      final offsetHours = offset.inHours;

      const Map<int, String> offsetToTimezone = {
        -12: 'Etc/GMT+12',
        -11: 'Pacific/Midway',
        -10: 'Pacific/Honolulu',
        -8: 'America/Los_Angeles',
        -7: 'America/Denver',
        -6: 'America/Chicago',
        -5: 'America/New_York',
        -4: 'America/Halifax',
        -3: 'America/Sao_Paulo',
        0: 'Europe/London',
        1: 'Europe/Paris',
        2: 'Europe/Helsinki',
        3: 'Europe/Moscow',
        4: 'Asia/Dubai',
        5: 'Asia/Karachi',
        6: 'Asia/Dhaka',
        7: 'Asia/Bangkok',
        8: 'Asia/Shanghai',
        9: 'Asia/Tokyo',
        10: 'Australia/Sydney',
        12: 'Pacific/Auckland',
      };

      // Handle IST (UTC+5:30)
      if (offset.inMinutes == 330) return 'Asia/Kolkata';

      return offsetToTimezone[offsetHours] ?? 'UTC';
    } catch (_) {
      return 'UTC';
    }
  }

  /// Check if notification permissions are granted.
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) return false;

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }
    return true;
  }
}
