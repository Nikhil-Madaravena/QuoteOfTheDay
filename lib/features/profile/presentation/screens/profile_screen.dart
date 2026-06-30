import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/providers/quote_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quoteState = ref.watch(quoteProvider);
    final streak = ref.watch(streakProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('PROFILE',
            style: AppTypography.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
              color: isDark ? AppColors.darkOnSurface : AppColors.black,
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // Monospace Wordmark / Avatar section
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.grey100,
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(
                    color: isDark ? AppColors.accentGold : AppColors.grey300,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: AppTypography.playfair(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.accentGold : AppColors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user?.name.isNotEmpty == true ? user!.name.toUpperCase() : 'MY PROFILE',
              style: AppTypography.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: isDark ? AppColors.darkOnSurface : AppColors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user?.email ?? '',
              style: AppTypography.dmSans(
                fontSize: 11,
                color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
              ),
            ),
            const SizedBox(height: 40),

            // ── Stats Row ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.accentGold,
                    value: '$streak',
                    label: 'STREAK',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.history_rounded,
                    iconColor: isDark ? AppColors.darkOnSurface : AppColors.black,
                    value: '${quoteState.history.length}',
                    label: 'READ',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.errorDark,
                    value: '${quoteState.favorites.length}',
                    label: 'SAVED',
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Divider
            Divider(color: isDark ? AppColors.borderDark : AppColors.grey200, height: 1),
            const SizedBox(height: 16),

            // ── Settings List ──────────────────────────────────────────────
            _buildProfileItem(
              context,
              icon: Icons.notifications_outlined,
              title: 'NOTIFICATIONS',
              onTap: () => context.push(AppRoutes.notifications),
              isDark: isDark,
            ),
            _buildProfileItem(
              context,
              icon: Icons.tune_rounded,
              title: 'EDIT PREFERENCES',
              onTap: () => context.push(AppRoutes.questionnaire),
              isDark: isDark,
            ),
            _buildProfileItem(
              context,
              icon: Icons.history_rounded,
              title: 'QUOTE HISTORY',
              onTap: () => context.push(AppRoutes.history),
              isDark: isDark,
            ),
            _buildProfileItem(
              context,
              icon: Icons.favorite_border_rounded,
              title: 'SAVED QUOTES',
              onTap: () => context.push(AppRoutes.favorites),
              isDark: isDark,
            ),

            const SizedBox(height: 16),
            Divider(color: isDark ? AppColors.borderDark : AppColors.grey200, height: 1),
            const SizedBox(height: 24),

            _buildProfileItem(
              context,
              icon: Icons.logout_rounded,
              title: 'LOGOUT',
              textColor: AppColors.errorDark,
              iconColor: AppColors.errorDark,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Icon(icon, color: iconColor ?? (isDark ? AppColors.darkOnSurface : AppColors.black), size: 20),
      title: Text(
        title,
        style: AppTypography.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: textColor ?? (isDark ? AppColors.darkOnSurface : AppColors.black),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey400,
        size: 18,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.grey200,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.playfair(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkOnSurface : AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.dmSans(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
