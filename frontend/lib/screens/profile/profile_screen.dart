import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: AppColors.darkBorder,
            ),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from MessageShield?',
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) {
      return;
    }

    await context.read<AuthProvider>().logout();

    // DO NOT manually navigate to LoginScreen.
    //
    // AuthGate watches AuthProvider.
    // After logout _user becomes null.
    // AuthGate automatically switches to LoginScreen.
  }

  String _getInitials(String email) {
    if (email.isEmpty) {
      return 'U';
    }

    final username = email.split('@').first.trim();

    if (username.isEmpty) {
      return 'U';
    }

    if (username.length == 1) {
      return username.toUpperCase();
    }

    return username.substring(0, 1).toUpperCase();
  }

  String _getDisplayName(String email) {
    if (email.isEmpty) {
      return 'MessageShield User';
    }

    final username = email.split('@').first.trim();

    if (username.isEmpty) {
      return 'MessageShield User';
    }

    return username;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final width = MediaQuery.sizeOf(context).width;

    final horizontalPadding = width < 600 ? 20.0 : 32.0;

    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            40,
          ),
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage your MessageShield account and security settings.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            // ==========================================================
            // PROFILE HEADER
            // ==========================================================

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.darkBorder,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 500;

                  final avatar = Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.teal,
                          AppColors.green,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(alpha: 0.18),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitials(user.email),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );

                  final details = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(user.email),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusBadge(
                            label: user.isActive
                                ? 'Active Account'
                                : 'Inactive Account',
                            icon: user.isActive
                                ? Icons.verified_user_outlined
                                : Icons.block_outlined,
                            color: user.isActive
                                ? AppColors.success
                                : AppColors.danger,
                          ),

                          if (user.isAdmin)
                            const _StatusBadge(
                              label: 'Administrator',
                              icon: Icons.admin_panel_settings_outlined,
                              color: AppColors.warning,
                            ),
                        ],
                      ),
                    ],
                  );

                  if (isSmall) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: avatar),
                        const SizedBox(height: 20),
                        details,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      avatar,
                      const SizedBox(width: 20),
                      Expanded(child: details),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================================
            // ACCOUNT INFORMATION
            // ==========================================================

            _SectionCard(
              title: 'Account Information',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _ProfileInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    value: user.email,
                  ),

                  const Divider(
                    height: 28,
                    color: AppColors.darkBorder,
                  ),

                  _ProfileInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'User ID',
                    value: '#${user.id}',
                  ),

                  const Divider(
                    height: 28,
                    color: AppColors.darkBorder,
                  ),

                  _ProfileInfoRow(
                    icon: Icons.shield_outlined,
                    label: 'Account Status',
                    value: user.isActive ? 'Active' : 'Inactive',
                    valueColor: user.isActive
                        ? AppColors.success
                        : AppColors.danger,
                  ),

                  if (user.isAdmin) ...[
                    const Divider(
                      height: 28,
                      color: AppColors.darkBorder,
                    ),

                    const _ProfileInfoRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Account Role',
                      value: 'Administrator',
                      valueColor: AppColors.warning,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================================
            // SECURITY
            // ==========================================================

            _SectionCard(
              title: 'Security',
              icon: Icons.security_outlined,
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.lock_outline,
                    title: 'Password',
                    subtitle:
                        'Password changes will be available in a future update.',
                    enabled: false,
                    onTap: null,
                  ),

                  const Divider(
                    height: 28,
                    color: AppColors.darkBorder,
                  ),

                  _ActionRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy',
                    subtitle:
                        'MessageShield keeps your analysis data protected.',
                    enabled: false,
                    onTap: null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================================
            // ADMIN SECTION
            // Only visible for admin
            // ==========================================================

            if (user.isAdmin) ...[
              _SectionCard(
                title: 'Administrator',
                icon: Icons.admin_panel_settings_outlined,
                iconColor: AppColors.warning,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You have administrator access.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Administrative tools and system statistics should only be visible to authorized users.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Admin controls are restricted to administrator accounts.',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],

            // ==========================================================
            // LOGOUT
            // ==========================================================

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: auth.isLoading
                    ? null
                    : () => _logout(context),
                icon: const Icon(
                  Icons.logout,
                ),
                label: const Text(
                  'Logout',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.65),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'MessageShield AI',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 4),

            const Center(
              child: Text(
                'Smart. Private. Protected.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return auth.isLoading
        ? Stack(
            children: [
              content,
              Container(
                color: Colors.black.withValues(alpha: 0.20),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          )
        : content;
  }
}


// ============================================================================
// SECTION CARD
// ============================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppColors.teal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: resolvedIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: resolvedIconColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }
}


// ============================================================================
// PROFILE INFORMATION ROW
// ============================================================================

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


// ============================================================================
// ACTION ROW
// ============================================================================

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(
                alpha: enabled ? 0.12 : 0.06,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: enabled
                  ? AppColors.teal
                  : AppColors.textSecondary,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            enabled
                ? Icons.chevron_right
                : Icons.lock_outline,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}


// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}