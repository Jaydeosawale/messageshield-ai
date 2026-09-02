import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasPasswordProvider(AuthProvider auth) {
    final firebaseUser = auth.firebaseUser;

    if (firebaseUser == null) {
      return false;
    }

    return firebaseUser.providerData.any(
      (provider) => provider.providerId == 'password',
    );
  }

  Future<void> _openPasswordDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();
    final hasPassword = _hasPasswordProvider(auth);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _PasswordDialog(
          hasPassword: hasPassword,
          onSetPassword: (password) async {
            await auth.setPassword(
              password: password,
            );
          },
          onChangePassword: (
            currentPassword,
            newPassword,
          ) async {
            await auth.changePassword(
              currentPassword: currentPassword,
              newPassword: newPassword,
            );
          },
        );
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasPassword
                ? l10n.passwordChangedSuccessfully
                : l10n.passwordSetSuccessfully,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(
            l10n.logoutQuestion,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            l10n.logoutConfirmation,
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
              child: Text(
                l10n.cancel,
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
              child: Text(
                l10n.logout,
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
    final l10n = AppLocalizations.of(context)!;

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
            Text(
              l10n.profile,
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

            const SizedBox(height: 24),

            Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                final l10n = AppLocalizations.of(context)!;
                final currentLanguage = languageProvider.locale.languageCode;

                String languageName() {
                  switch (currentLanguage) {
                    case 'hi':
                      return l10n.hindi;
                    case 'mr':
                      return l10n.marathi;
                    case 'en':
                    default:
                      return l10n.english;
                  }
                }

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.language_rounded,
                    ),
                    title: Text(l10n.language),
                    subtitle: Text(languageName()),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            backgroundColor: AppColors.backgroundSoft,
                            surfaceTintColor: Colors.transparent,
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                color: AppColors.darkBorder,
                              ),
                            ),
                            title: Text(
                              l10n.changeLanguage,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              12,
                              8,
                              12,
                              8,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<String>(
                                  value: 'en',
                                  groupValue: currentLanguage,
                                  activeColor: AppColors.teal,
                                  tileColor: Colors.transparent,
                                  title: Text(
                                    l10n.english,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await languageProvider.setLanguage(value);

                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    }
                                  },
                                ),
                                RadioListTile<String>(
                                  value: 'hi',
                                  groupValue: currentLanguage,
                                  activeColor: AppColors.teal,
                                  tileColor: Colors.transparent,
                                  title: Text(
                                    l10n.hindi,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await languageProvider.setLanguage(value);

                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    }
                                  },
                                ),
                                RadioListTile<String>(
                                  value: 'mr',
                                  groupValue: currentLanguage,
                                  activeColor: AppColors.teal,
                                  tileColor: Colors.transparent,
                                  title: Text(
                                    l10n.marathi,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onChanged: (value) async {
                                    if (value != null) {
                                      await languageProvider.setLanguage(value);

                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text(
                                  l10n.cancel,
                                  style: const TextStyle(
                                    color: AppColors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
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
                                ? l10n.activeAccount
                                : l10n.inactiveAccount,
                            icon: user.isActive
                                ? Icons.verified_user_outlined
                                : Icons.block_outlined,
                            color: user.isActive
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                          if (user.isAdmin)
                            _StatusBadge(
                              label: l10n.administrator,
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
              title: l10n.accountInformation,
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _ProfileInfoRow(
                    icon: Icons.email_outlined,
                    label: l10n.emailAddress,
                    value: user.email,
                  ),
                  const Divider(
                    height: 28,
                    color: AppColors.darkBorder,
                  ),
                  _ProfileInfoRow(
                    icon: Icons.badge_outlined,
                    label: l10n.userId,
                    value: '#${user.id}',
                  ),
                  const Divider(
                    height: 28,
                    color: AppColors.darkBorder,
                  ),
                  _ProfileInfoRow(
                    icon: Icons.shield_outlined,
                    label: l10n.accountStatus,
                    value: user.isActive ? l10n.active : l10n.inactive,
                    valueColor:
                        user.isActive ? AppColors.success : AppColors.danger,
                  ),
                  if (user.isAdmin) ...[
                    const Divider(
                      height: 28,
                      color: AppColors.darkBorder,
                    ),
                    _ProfileInfoRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: l10n.accountRole,
                      value: l10n.administrator,
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
              title: l10n.security,
              icon: Icons.security_outlined,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      final hasPassword = _hasPasswordProvider(auth);

                      return _ActionRow(
                        icon: Icons.lock_outline,
                        title: l10n.password,
                        subtitle: hasPassword
                            ? l10n.changeAccountPassword
                            : l10n.setPasswordForEmailSignIn,
                        enabled: true,
                        onTap: () => _openPasswordDialog(context),
                      );
                    },
                  ),
                  const Divider(
                    height: 28,
                    color: AppColors.darkBorder,
                  ),
                  _ActionRow(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacy,
                    subtitle: l10n.messageShieldKeepsDataProtected,
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
                title: l10n.administrator,
                icon: Icons.admin_panel_settings_outlined,
                iconColor: AppColors.warning,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.youHaveAdministratorAccess,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.adminToolsAuthorizedOnly,
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
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.adminControlsRestricted,
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
                onPressed: auth.isLoading ? null : () => _logout(context),
                icon: const Icon(
                  Icons.logout,
                ),
                label: Text(
                  l10n.logout,
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

            Center(
              child: Text(
                l10n.smartPrivateProtected,
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
// PASSWORD DIALOG
// ============================================================================

class _PasswordDialog extends StatefulWidget {
  final bool hasPassword;
  final Future<void> Function(String password) onSetPassword;
  final Future<void> Function(
    String currentPassword,
    String newPassword,
  ) onChangePassword;

  const _PasswordDialog({
    required this.hasPassword,
    required this.onSetPassword,
    required this.onChangePassword,
  });

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.hasPassword) {
        await widget.onChangePassword(
          _currentPasswordController.text,
          _passwordController.text,
        );
      } else {
        await widget.onSetPassword(
          _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        onPressed: _isSubmitting ? null : onToggle,
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.hasPassword ? 'Change Password' : 'Set Password';

    return AlertDialog(
      backgroundColor: AppColors.backgroundSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColors.darkBorder,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.hasPassword) ...[
                const Text(
                  'Add a password to your existing account. '
                  'You will still be able to sign in with Google.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              if (widget.hasPassword) ...[
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  enabled: !_isSubmitting,
                  decoration: _decoration(
                    label: 'Current password',
                    icon: Icons.lock_outline,
                    obscure: _obscureCurrent,
                    onToggle: () {
                      setState(() {
                        _obscureCurrent = !_obscureCurrent;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Current password is required.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isSubmitting,
                decoration: _decoration(
                  label: 'New password',
                  icon: Icons.lock_reset_outlined,
                  obscure: _obscurePassword,
                  onToggle: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                enabled: !_isSubmitting,
                decoration: _decoration(
                  label: 'Confirm password',
                  icon: Icons.verified_user_outlined,
                  obscure: _obscureConfirm,
                  onToggle: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },
                ),
                validator: _validateConfirmation,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.hasPassword ? 'Change Password' : 'Set Password',
                ),
        ),
      ],
    );
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
              color: enabled ? AppColors.teal : AppColors.textSecondary,
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
            enabled ? Icons.chevron_right : Icons.lock_outline,
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
