// Re-export the fully implemented notification screen under the expected class name
export 'notification_screen.dart' show NotificationScreen;

// Alias class so existing router import (NotificationsScreen) still compiles
import 'package:flutter/material.dart';
import 'notification_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => const NotificationScreen();
}
