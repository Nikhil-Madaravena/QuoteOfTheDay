import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/providers/quote_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final quoteState = ref.watch(quoteProvider);
    final streak = ref.watch(streakProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.displaySmall?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name.isNotEmpty == true ? user!.name : 'My Profile',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // ── Stats Row ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: Colors.deepOrange,
                    value: '$streak',
                    label: 'Day Streak',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.history_rounded,
                    iconColor: cs.primary,
                    value: '${quoteState.history.length}',
                    label: 'Quotes Read',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.favorite_rounded,
                    iconColor: cs.error,
                    value: '${quoteState.favorites.length}',
                    label: 'Favorites',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Settings List ──────────────────────────────────────────────
            _buildProfileItem(context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () => context.push(AppRoutes.notifications)),
            _buildProfileItem(context,
                icon: Icons.tune_rounded,
                title: 'Edit Preferences',
                onTap: () => context.push(AppRoutes.questionnaire)),
            _buildProfileItem(context,
                icon: Icons.history_rounded,
                title: 'Quote History',
                onTap: () => context.push(AppRoutes.history)),
            _buildProfileItem(context,
                icon: Icons.favorite_border_rounded,
                title: 'Favorites',
                onTap: () => context.push(AppRoutes.favorites)),

            const Divider(height: 32),

            _buildProfileItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Logout',
              textColor: cs.error,
              iconColor: cs.error,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
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
    Color? textColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? cs.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? cs.primary),
      ),
      title: Text(title,
          style: theme.textTheme.titleMedium?.copyWith(
              color: textColor ?? cs.onSurface,
              fontWeight: FontWeight.w600)),
      trailing:
          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
