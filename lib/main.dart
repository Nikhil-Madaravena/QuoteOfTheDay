import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/providers/shared_preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Notifications are only supported on Android/iOS/macOS — skip on Linux/Windows
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    // Initialize Notification Service (timezone + plugin setup)
    await NotificationService().init();

    // Re-schedule daily notification on every app start (handles reboots & timezone changes)
    final isEnabled = sharedPreferences.getBool(AppConstants.notificationEnabledKey) ?? true;
    if (isEnabled) {
      final hour = sharedPreferences.getInt(AppConstants.notificationHourKey) ?? 8;
      final minute = sharedPreferences.getInt(AppConstants.notificationMinuteKey) ?? 0;
      await NotificationService().scheduleDailyQuoteNotification(
        hour: hour,
        minute: minute,
      );
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const QODApp(),
    ),
  );
}

class QODApp extends ConsumerWidget {
  const QODApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
