import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  late NotificationSettingsNotifier _notifier;
  late NotificationSettingsState _state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final service = ref.read(notificationServiceProvider);
      _notifier = NotificationSettingsNotifier(service, prefs);
      setState(() {
        _state = _notifier.state;
      });
    });
  }

  String _formatTime(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _notifier.state.hour, minute: _notifier.state.minute),
    );
    if (picked != null) {
      await _notifier.updateTime(picked.hour, picked.minute);
      if (mounted) setState(() => _state = _notifier.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Enable toggle card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              title: Text('Daily Quote Reminder',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Get reminded when your quote is ready',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6)),
              ),
              secondary: CircleAvatar(
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.notifications_outlined, color: cs.primary),
              ),
              value: _notifier.state.isEnabled,
              onChanged: (val) async {
                await _notifier.setEnabled(val);
                if (mounted) setState(() => _state = _notifier.state);
              },
            ),
          ),

          if (_notifier.state.permissionDenied)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Card(
                color: cs.errorContainer,
                child: ListTile(
                  leading: Icon(Icons.warning_amber_rounded, color: cs.error),
                  title: Text('Permission Denied',
                      style: TextStyle(color: cs.onErrorContainer, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Please enable notifications in your device settings.',
                    style: TextStyle(color: cs.onErrorContainer.withOpacity(0.8)),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Time picker card — only shown when enabled
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _notifier.state.isEnabled ? 1.0 : 0.4,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                enabled: _notifier.state.isEnabled,
                title: Text('Notification Time',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Tap to change when you receive your daily quote',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6)),
                ),
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(Icons.access_time_rounded, color: cs.secondary),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatTime(_notifier.state.hour, _notifier.state.minute),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: _notifier.state.isEnabled ? _pickTime : null,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Informational section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About Daily Quotes',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.5), fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.auto_awesome_rounded,
                  text: 'A personalized quote is generated for you each day.',
                  cs: cs,
                  theme: theme,
                ),
                _buildInfoRow(
                  icon: Icons.refresh_rounded,
                  text: 'You can regenerate your quote once per day.',
                  cs: cs,
                  theme: theme,
                ),
                _buildInfoRow(
                  icon: Icons.schedule_rounded,
                  text: 'Notification time is saved across device restarts.',
                  cs: cs,
                  theme: theme,
                ),
                _buildInfoRow(
                  icon: Icons.language_rounded,
                  text: 'Timezone changes are handled automatically.',
                  cs: cs,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required ColorScheme cs,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
