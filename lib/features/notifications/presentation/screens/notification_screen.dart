import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref, NotificationSettingsState state) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: state.hour, minute: state.minute),
    );
    if (picked != null) {
      await ref.read(notificationSettingsProvider.notifier).updateTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifierState = ref.watch(notificationSettingsProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('NOTIFICATIONS',
            style: AppTypography.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
              color: isDark ? AppColors.darkOnSurface : AppColors.black,
            )),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          // On Linux/Windows, notifications are not supported — show a clear notice
          // instead of a toggle that would silently do nothing.
          if (Platform.isLinux || Platform.isWindows) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.errorDark,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.errorDark, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NOT SUPPORTED',
                            style: AppTypography.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppColors.errorDark)),
                        const SizedBox(height: 4),
                        Text(
                          'Notifications are not supported on this platform.',
                          style: AppTypography.dmSans(
                              fontSize: 10,
                              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Enable toggle container
            Material(
              color: isDark ? AppColors.darkSurface : AppColors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.grey200,
                ),
              ),
              child: SwitchListTile(
                activeThumbColor: AppColors.accentGold,
                activeTrackColor: AppColors.accentGoldDim,
                inactiveThumbColor: isDark ? AppColors.grey500 : AppColors.grey300,
                inactiveTrackColor: isDark ? AppColors.darkBackground : AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                title: Text('DAILY REMINDER',
                    style: AppTypography.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: isDark ? AppColors.darkOnSurface : AppColors.black)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    'Receive a push notification when your daily quote is generated.',
                    style: AppTypography.dmSans(
                        fontSize: 11,
                        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500),
                  ),
                ),
                value: notifierState.isEnabled,
                onChanged: (val) async {
                  await ref.read(notificationSettingsProvider.notifier).setEnabled(val);
                },
              ),
            ),

            if (notifierState.permissionDenied)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C1A1A) : const Color(0xFFFFECEC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.errorDark,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.errorDark, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PERMISSION DENIED',
                                style: AppTypography.dmSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: AppColors.errorDark)),
                            const SizedBox(height: 4),
                            Text(
                              'Please enable notifications in device settings.',
                              style: AppTypography.dmSans(
                                  fontSize: 10,
                                  color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Time picker card — only shown when enabled
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: notifierState.isEnabled ? 1.0 : 0.4,
              child: Material(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.grey200,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  enabled: notifierState.isEnabled,
                  title: Text('NOTIFICATION TIME',
                      style: AppTypography.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: isDark ? AppColors.darkOnSurface : AppColors.black)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      'Choose the time to receive your message.',
                      style: AppTypography.dmSans(
                          fontSize: 11,
                          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.grey300,
                      ),
                    ),
                    child: Text(
                      _formatTime(notifierState.hour, notifierState.minute),
                      style: AppTypography.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.accentGold : AppColors.black,
                      ),
                    ),
                  ),
                  onTap: notifierState.isEnabled
                      ? () => _pickTime(context, ref, notifierState)
                      : null,
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Informational section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DAILY SCHEDULE INFO',
                    style: AppTypography.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: isDark ? AppColors.accentGold : AppColors.grey500,
                    )),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.auto_awesome_rounded,
                  text: 'A unique message is generated for you every 24 hours.',
                  isDark: isDark,
                ),
                _buildInfoRow(
                  icon: Icons.refresh_rounded,
                  text: 'You may regenerate your daily post once per day.',
                  isDark: isDark,
                ),
                _buildInfoRow(
                  icon: Icons.schedule_rounded,
                  text: 'System schedules are preserved across reboots.',
                  isDark: isDark,
                ),
                _buildInfoRow(
                  icon: Icons.language_rounded,
                  text: 'Timezone adjustments are managed automatically.',
                  isDark: isDark,
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
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: isDark ? AppColors.accentGold : AppColors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.dmSans(
                fontSize: 11,
                height: 1.6,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
