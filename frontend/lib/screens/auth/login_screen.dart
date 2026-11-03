import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:messageshield/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/services/google_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/auth_surface.dart';
import 'register_screen.dart';
import 'forgot_password_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      authProvider.clearError();

      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      debugPrint(
        'LOGIN SUCCESS: isAuthenticated=${authProvider.isAuthenticated}',
      );

      if (!mounted) return;

      // AuthProvider now has the MessageShield JWT
      // and current user.

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.signedInSuccessfully,
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Login may have been opened from Register.
      // Remove the auth screens so AuthGate can show Home.
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      if (!mounted) return;

      final providerError = authProvider.error ?? 'Login failed';

      final message = _friendlyError(providerError, l10n);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // If email isn't verified, give the user
      // an option to resend the verification email.
      if (_isEmailVerificationError(providerError)) {
        await _showVerificationDialog();
        return;
      }

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

  bool _isEmailVerificationError(String error) {
    final message = error.toLowerCase();

    return message.contains('verify your email') ||
        message.contains('email verification') ||
        message.contains('email is not verified') ||
        message.contains('before signing in') ||
        message.contains('before continuing');
  }

  Future<void> _showVerificationDialog() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.teal,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.emailNotVerified,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            l10n.verifyEmailBeforeSignIn,
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await context
                      .read<AuthProvider>()
                      .sendFirebaseVerificationEmail();

                  if (!dialogContext.mounted) return;

                  Navigator.of(dialogContext).pop();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.verificationEmailSent,
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (_) {
                  if (!dialogContext.mounted) return;

                  final error = context.read<AuthProvider>().error ??
                      l10n.unableToResendVerificationEmail;

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
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
          ],
        );
      },
    );
  }
  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _continueWithGoogle() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    try {
      authProvider.clearError();

      // Step 1:
      // Authenticate with Google / Firebase.
      final firebaseUser = await GoogleAuthService.signIn();

      if (!mounted) return;

      // Step 2:
      // Login to an EXISTING MessageShield account.
      //
      // IMPORTANT:
      // Login must NEVER create a MessageShield account.
      await authProvider.loginWithFirebaseUser(firebaseUser);

      if (!mounted) return;

      debugPrint(
        'GOOGLE LOGIN SUCCESS: '
        'isAuthenticated=${authProvider.isAuthenticated}',
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '\${l10n.successfullySignedInWithGoogle}',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Authentication succeeded.
      // Replace the entire authentication stack with Home.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => AppShell(),
        ),
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'GOOGLE LOGIN ERROR:',
      );
      debugPrint(error.toString());
      debugPrint(
        'GOOGLE LOGIN STACK TRACE:',
      );
      debugPrint(stackTrace.toString());
      debugPrint(
        '========================================',
      );

      // Google authentication may have succeeded,
      // but MessageShield login may have failed.
      //
      // Do not leave the Google/Firebase session active.
      await GoogleAuthService.clearSession();

      if (!mounted) return;

      final providerError = authProvider.error;

      final actualError = providerError != null && providerError.isNotEmpty
          ? providerError
          : error.toString();

      final message = _friendlyGoogleError(
        actualError,
        AppLocalizations.of(context)!,
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

  // ============================================================
  // USER-FRIENDLY BACKEND ERRORS
  // ============================================================

  // ============================================================
// USER-FRIENDLY ERRORS
// ============================================================

  String _friendlyError(
    String error,
    AppLocalizations l10n,
  ) {
    // Remove the common Dart Exception prefix.
    final cleanedError = error.replaceFirst(
      'Exception: ',
      '',
    );

    final value = cleanedError.toLowerCase();

    // ----------------------------------------------------------
    // Google account does not have a MessageShield account
    // ----------------------------------------------------------

    if (value.contains('account not found') ||
        value.contains('create an account first')) {
      return l10n.googleAccountNotFound;
    }

    // ----------------------------------------------------------
    // Google sign-in cancelled
    // ----------------------------------------------------------

    if (value.contains('popup-closed-by-user') ||
        value.contains('sign-in was cancelled') ||
        value.contains('sign in was cancelled') ||
        value.contains('cancelled') ||
        value.contains('canceled')) {
      return l10n.googleSignInCancelled;
    }

    // ----------------------------------------------------------
    // Popup blocked
    // ----------------------------------------------------------

    if (value.contains('popup-blocked')) {
      return l10n.googlePopupBlocked;
    }

    // ----------------------------------------------------------
    // Google / Firebase configuration
    // ----------------------------------------------------------

    if (value.contains('operation-not-allowed')) {
      return l10n.googleSignInNotEnabled;
    }

    if (value.contains('configuration') ||
        value.contains('client id') ||
        value.contains('developer_error')) {
      return l10n.googleSignInNotConfigured;
    }

// ----------------------------------------------------------
// Email not verified
// ----------------------------------------------------------

    if (value.contains('verify your email') ||
        value.contains('email not verified') ||
        value.contains('email verification') ||
        value.contains('verify your email address')) {
      return l10n.pleaseVerifyEmail;
    }
    // ----------------------------------------------------------
    // Email/password errors
    // ----------------------------------------------------------

    if (value.contains('invalid credentials') ||
        value.contains('incorrect email') ||
        value.contains('incorrect password') ||
        value.contains(
          'invalid email or password',
        ) ||
        value.contains('unauthorized')) {
      return l10n.invalidEmailOrPassword;
    }

    // ----------------------------------------------------------
    // Network
    // ----------------------------------------------------------

    if (value.contains('network') ||
        value.contains('connection') ||
        value.contains('socket') ||
        value.contains('network-request-failed')) {
      return l10n.unableToConnectServer;
    }

    // ----------------------------------------------------------
    // Timeout
    // ----------------------------------------------------------

    if (value.contains('timeout')) {
      return l10n.requestTimedOut;
    }

    // ----------------------------------------------------------
    // Account inactive
    // ----------------------------------------------------------

    if (value.contains('inactive')) {
      return l10n.accountInactive;
    }

    // ----------------------------------------------------------
    // Default
    // ----------------------------------------------------------

    return cleanedError.isNotEmpty ? cleanedError : l10n.unableToSignIn;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    return AuthSurface(
      title: l10n.welcomeBack,
      description: l10n.signInToProtectMessages,
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
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    labelText: l10n.password,
                    suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? l10n.showPassword
                            : l10n.hidePassword,
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined))),
                validator: (value) => value == null || value.isEmpty
                    ? l10n.passwordRequired
                    : null,
                onFieldSubmitted: (_) {
                  if (!auth.isLoading) _login();
                }),
            const SizedBox(height: 6),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) => ForgotPasswordPage(
                                    initialEmail:
                                        _emailController.text.trim()))),
                    child: Text(l10n.forgotPassword))),
            const SizedBox(height: 14),
            FilledButton(
                onPressed: auth.isLoading ? null : _login,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.login)),
            const SizedBox(height: 22),
            Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.dontHaveAccount),
                  TextButton(
                      onPressed: auth.isLoading
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const RegisterScreen())),
                      child: Text(l10n.createAccount))
                ]),
          ])),
    );
  }

  String _friendlyGoogleError(
    String error,
    AppLocalizations l10n,
  ) {
    final cleanedError = error.replaceFirst('Exception: ', '').trim();

    final message = cleanedError.toLowerCase();

    if (message.contains('not registered') ||
        message.contains('not found') ||
        message.contains('does not exist') ||
        message.contains('no message shield account')) {
      return l10n.googleAccountNotFound;
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return l10n.unableToConnectServer;
    }

    if (message.contains('timeout')) {
      return l10n.requestTimedOut;
    }

    return cleanedError.isNotEmpty
        ? cleanedError
        : l10n.unableToSignInWithGoogle;
  }
}
