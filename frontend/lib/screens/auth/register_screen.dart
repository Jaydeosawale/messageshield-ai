import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/services/google_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_surface.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================
  // Email / Password Registration
  // ==========================================

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    try {
      authProvider.clearError();

      // ==========================================
      // Step 1
      // ==========================================
      //
      // Create Firebase email/password account.
      //
      // Firebase also sends the verification email.
      //

      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // ==========================================
      // Step 2
      // ==========================================
      //
      // Do NOT create MessageShield account yet.
      //
      // User must verify email first.
      //

      await _showEmailVerificationDialog();
    } catch (_) {
      if (!mounted) return;

      final rawError = authProvider.error ?? l10n.registrationFailed;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _friendlyRegisterError(rawError, l10n),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _showEmailVerificationDialog() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogBuildContext,
            setDialogState,
          ) {
            final authProvider = dialogBuildContext.watch<AuthProvider>();

            return AlertDialog(
              backgroundColor: AppColors.backgroundSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.teal,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.verificationEmailTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                l10n.verificationEmailInstructions(
                  _emailController.text.trim(),
                ),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              actions: [
                // ==========================================
                // RESEND
                // ==========================================

                TextButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          try {
                            await dialogBuildContext
                                .read<AuthProvider>()
                                .sendFirebaseVerificationEmail();

                            if (!dialogContext.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).hideCurrentSnackBar();

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.verificationEmailSentAgain,
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (_) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            final error =
                                dialogBuildContext.read<AuthProvider>().error ??
                                    l10n.unableToResendVerificationEmail;

                            ScaffoldMessenger.of(
                              dialogContext,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  child: Text(
                    l10n.resendEmail,
                  ),
                ),

                // ==========================================
                // I'VE VERIFIED
                // ==========================================

                FilledButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          final success = await dialogBuildContext
                              .read<AuthProvider>()
                              .verifyEmailAndCompleteRegistration();

                          if (!dialogContext.mounted) {
                            return;
                          }

                          if (success) {
                            Navigator.of(
                              dialogContext,
                            ).pop();

                            if (!mounted) {
                              return;
                            }

                            if (!mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.emailVerifiedSuccessfully,
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            // Keep the authenticated Firebase/MessageShield
                            // session. AuthGate will show HomeScreen.
                            return;
                          }

                          setDialogState(() {});

                          final error =
                              dialogBuildContext.read<AuthProvider>().error ??
                                  l10n.pleaseVerifyEmailFirst;

                          ScaffoldMessenger.of(
                            dialogContext,
                          ).hideCurrentSnackBar();

                          ScaffoldMessenger.of(
                            dialogContext,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: AppColors.danger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.iveVerifiedMyEmail,
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    // ==========================================
// Registration completed
// ==========================================

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.emailVerifiedSuccessfully,
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Keep the authenticated Firebase/MessageShield
    // session. AuthGate will show HomeScreen.
    return;
  }

  String _friendlyRegisterError(
    Object error,
    AppLocalizations l10n,
  ) {
    final cleanedError =
        error.toString().replaceFirst('Exception: ', '').trim();

    final message = cleanedError.toLowerCase();

    // ==========================================
    // Account already exists
    // ==========================================

    if (message.contains('already exists') ||
        message.contains('already registered') ||
        message.contains('already in use') ||
        message.contains('email already') ||
        message.contains('email exists') ||
        message.contains('duplicate') ||
        message.contains('email and password') ||
        message.contains('google account identity') ||
        message.contains('message shield account') ||
        message.contains('messageshield account')) {
      return l10n.accountWithEmailAlreadyExists;
    }

    // ==========================================
    // Network errors
    // ==========================================

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return l10n.unableToConnectServer;
    }

    // ==========================================
    // Timeout
    // ==========================================

    if (message.contains('timeout')) {
      return l10n.requestTimedOut;
    }

    // ==========================================
    // Default error
    // ==========================================

    return cleanedError.isNotEmpty ? cleanedError : l10n.unableToCreateAccount;
  }

  // ==========================================
  // Google Registration / Login
  // ==========================================

  // ==========================================
// Google Registration
// ==========================================

  Future<void> _continueWithGoogle() async {
    FocusScope.of(context).unfocus();

    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.read<AuthProvider>();

    try {
      // Clear any previous error.
      authProvider.clearError();

      // Step 1:
      // Authenticate with Google / Firebase.
      final firebaseUser = await GoogleAuthService.signIn();

      if (!mounted) return;

      // Step 2:
      // Register a NEW MessageShield account.
      //
      // Backend endpoint:
      // POST /api/v1/auth/firebase/register
      await authProvider.registerWithFirebaseUser(
        firebaseUser,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.accountCreatedWithGoogle,
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // User is authenticated.
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'GOOGLE REGISTRATION ERROR:',
      );
      debugPrint(error.toString());
      debugPrint(
        'GOOGLE REGISTRATION STACK TRACE:',
      );
      debugPrint(stackTrace.toString());
      debugPrint(
        '========================================',
      );

      // Google authentication may have succeeded,
      // but MessageShield registration may have failed.
      //
      // Do not leave the Firebase/Google session
      // active in that case.
      await GoogleAuthService.clearSession();

      if (!mounted) return;

      final providerError = authProvider.error;

      final actualError = providerError != null && providerError.isNotEmpty
          ? providerError
          : error.toString();

      final message = _friendlyGoogleError(
        actualError,
        l10n,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  // ==========================================
  // Friendly Email Registration Errors
  // ==========================================

  String _friendlyGoogleError(
    String error,
    AppLocalizations l10n,
  ) {
    final cleanedError = error.replaceFirst('Exception: ', '').trim();

    final message = cleanedError.toLowerCase();

    if (message.contains('409') || message.contains('conflict')) {
      return l10n.accountWithEmailAlreadyExists;
    }

    // Check this FIRST because the backend message
    // can also contain "already exists".
    if (message.contains('different sign-in method') ||
        message.contains('provider conflict') ||
        message.contains('using email and password') ||
        message.contains('email and password sign-in')) {
      return l10n.emailPasswordAccountExists;
    }

    // ------------------------------------------
    // Google / MessageShield account already exists.
    // ------------------------------------------

    if (message.contains('account already exists') ||
        message.contains('already exists') ||
        message.contains('already registered') ||
        message.contains('already in use') ||
        message.contains('email already') ||
        message.contains('email exists') ||
        message.contains('please sign in instead')) {
      return l10n.accountWithEmailAlreadyExists;
    }

    // ------------------------------------------
    // Google sign-in cancelled.
    // ------------------------------------------

    if (message.contains('cancelled') ||
        message.contains('canceled') ||
        message.contains('popup-closed-by-user')) {
      return l10n.googleSignInCancelled;
    }

    // ------------------------------------------
    // Popup blocked.
    // ------------------------------------------

    if (message.contains('popup-blocked')) {
      return l10n.googlePopupBlocked;
    }

    // ------------------------------------------
    // Network.
    // ------------------------------------------

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection') ||
        message.contains('network-request-failed')) {
      return l10n.unableToConnectServer;
    }

    // ------------------------------------------
    // Firebase authentication.
    // ------------------------------------------

    if (message.contains('invalid firebase') ||
        message.contains('authentication token') ||
        message.contains('firebase authentication')) {
      return l10n.firebaseAuthVerificationFailed;
    }

    // ------------------------------------------
    // Platform.
    // ------------------------------------------

    if (message.contains('not supported')) {
      return l10n.unsupportedPlatform;
    }

    // ------------------------------------------
    // Default.
    // ------------------------------------------

    return cleanedError.isNotEmpty
        ? cleanedError
        : l10n.unableToContinueWithGoogle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    return AuthSurface(
      title: l10n.createAccount,
      description: l10n.createAccountDescription,
      child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            OutlinedButton(
                onPressed: auth.isLoading ? null : _continueWithGoogle,
                child: Row(children: [
                  const FaIcon(FontAwesomeIcons.google, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(l10n.continueWithGoogle,
                          textAlign: TextAlign.center))
                ])),
            const SizedBox(height: 22),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(l10n.or,
                      style: const TextStyle(
                          color: Color(0xFF738096), fontSize: 12))),
              const Expanded(child: Divider())
            ]),
            const SizedBox(height: 22),
            TextFormField(
                controller: _emailController,
                enabled: !auth.isLoading,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: l10n.emailAddress),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return l10n.emailRequired;
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                    return l10n.invalidEmail;
                  }
                  return null;
                }),
            const SizedBox(height: 18),
            TextFormField(
                controller: _passwordController,
                enabled: !auth.isLoading,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    labelText: l10n.password,
                    helperText: l10n.passwordMinimumLength,
                    helperMaxLines: 2,
                    suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? l10n.showPassword
                            : l10n.hidePassword,
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined))),
                validator: (value) => value == null || value.length < 8
                    ? l10n.passwordMinimumLength
                    : null),
            const SizedBox(height: 18),
            TextFormField(
                controller: _confirmPasswordController,
                enabled: !auth.isLoading,
                obscureText: _obscureConfirmPassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    suffixIcon: IconButton(
                        tooltip: _obscureConfirmPassword
                            ? l10n.showPassword
                            : l10n.hidePassword,
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                        icon: Icon(_obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.confirmPasswordRequired;
                  }
                  if (value != _passwordController.text) {
                    return l10n.passwordsDoNotMatch;
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (!auth.isLoading) _register();
                }),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: auth.isLoading ? null : _register,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.createAccount)),
            const SizedBox(height: 20),
            TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (_) => const LoginScreen()));
                        }
                      },
                child: Text(l10n.alreadyHaveAccountLogin,
                    textAlign: TextAlign.center)),
          ])),
    );
  }
}
