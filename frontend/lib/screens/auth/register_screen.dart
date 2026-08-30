import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/google_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await context.read<AuthProvider>().register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully. Please log in.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      final rawError =
          context.read<AuthProvider>().error ??
              'Registration failed';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _friendlyRegisterError(rawError),
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================
  // Google Registration / Login
  // ==========================================

  // ==========================================
// Google Registration
// ==========================================

Future<void> _continueWithGoogle() async {
  FocusScope.of(context).unfocus();

  final authProvider =
      context.read<AuthProvider>();

  try {
    // Clear any previous error.
    authProvider.clearError();

    // Step 1:
    // Authenticate with Google / Firebase.
    final firebaseUser =
        await GoogleAuthService.signIn();

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

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Account created successfully with Google.',
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

    if (!mounted) return;

    // Backend/AuthProvider error has priority.
    final providerError =
        authProvider.error;

    // If the backend registration failed,
    // use its real error message.
    //
    // Otherwise use the Google/Firebase error.
    final actualError =
        providerError != null &&
                providerError.isNotEmpty
            ? providerError
            : error.toString();

    final message =
        _friendlyGoogleError(actualError);

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
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
        duration:
            const Duration(seconds: 4),
      ),
    );
  }
}
  // ==========================================
  // Friendly Email Registration Errors
  // ==========================================

  String _friendlyRegisterError(
    String error,
  ) {
    final message = error.toLowerCase();

    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('already in use') ||
        message.contains('duplicate')) {
      return 'An account with this email already exists.';
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Unable to connect to the server. '
          'Please check your internet connection.';
    }

    if (message.contains('timeout')) {
      return 'The request timed out. '
          'Please try again.';
    }

    return 'Unable to create your account. '
        'Please try again.';
  }

  // ==========================================
  // Friendly Google Errors
  // ==========================================

  // ==========================================
// Friendly Google Errors
// ==========================================

String _friendlyGoogleError(
  String error,
) {
  // Remove common Dart exception prefix.
  final cleanedError =
      error.replaceFirst(
    'Exception: ',
    '',
  );

  final message =
      cleanedError.toLowerCase();

  // ------------------------------------------
  // Account already exists
  // ------------------------------------------

  if (message.contains('account already exists') ||
      message.contains('already exists') ||
      message.contains('already registered') ||
      message.contains('please sign in instead')) {
    return 'A MessageShield account already exists '
        'for this Google account. '
        'Please sign in instead.';
  }

  // ------------------------------------------
  // Account provider conflict
  // ------------------------------------------

  if (message.contains('different sign-in method') ||
      message.contains('provider conflict')) {
    return 'An account with this email already exists '
        'using a different sign-in method.';
  }

  // ------------------------------------------
  // Google sign-in cancelled
  // ------------------------------------------

  if (message.contains('cancelled') ||
      message.contains('canceled') ||
      message.contains('popup-closed-by-user')) {
    return 'Google sign-in was cancelled.';
  }

  // ------------------------------------------
  // Popup blocked
  // ------------------------------------------

  if (message.contains('popup-blocked')) {
    return 'Google sign-in popup was blocked. '
        'Please allow popups and try again.';
  }

  // ------------------------------------------
  // Network
  // ------------------------------------------

  if (message.contains('network') ||
      message.contains('socket') ||
      message.contains('connection') ||
      message.contains('network-request-failed')) {
    return 'Unable to connect. '
        'Please check your internet connection.';
  }

  // ------------------------------------------
  // Firebase authentication
  // ------------------------------------------

  if (message.contains('invalid firebase') ||
      message.contains('authentication token') ||
      message.contains('firebase authentication')) {
    return 'Google authentication could not be verified.';
  }

  // ------------------------------------------
  // Platform
  // ------------------------------------------

  if (message.contains('not supported')) {
    return 'Google sign-in is not supported '
        'on this platform.';
  }

  // ------------------------------------------
  // Default
  // ------------------------------------------

  return cleanedError.isNotEmpty
      ? cleanedError
      : 'Unable to continue with Google. '
          'Please try again.';
}

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding:
                        const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSoft
                          .withValues(
                        alpha: 0.96,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        24,
                      ),
                      border: Border.all(
                        color: AppColors.teal
                            .withValues(
                          alpha: 0.28,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(
                            alpha: 0.38,
                          ),
                          blurRadius: 32,
                          offset:
                              const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [

                        // ==================================
                        // Header
                        // ==================================

                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Back',
                              onPressed:
                                  auth.isLoading
                                      ? null
                                      : () {
                                          Navigator.pop(
                                            context,
                                          );
                                        },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color:
                                    AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              'Create Account',
                              style: theme
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                color: AppColors
                                    .textPrimary,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================
                        // Icon
                        // ==================================

                        Center(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:
                                  const LinearGradient(
                                begin:
                                    Alignment.topLeft,
                                end:
                                    Alignment.bottomRight,
                                colors: [
                                  AppColors.teal,
                                  AppColors.green,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors
                                      .teal
                                      .withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 22,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Text(
                          'Join MessageShield',
                          textAlign:
                              TextAlign.center,
                          style: theme
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            color:
                                AppColors.textPrimary,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'Create your secure account and '
                          'start analyzing suspicious messages.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color:
                                AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================
                        // Google
                        // ==================================

                        SizedBox(
                          height: 54,
                          child:
                              OutlinedButton.icon(
                            onPressed:
                                auth.isLoading
                                    ? null
                                    : _continueWithGoogle,
                            icon: const FaIcon(
                              FontAwesomeIcons.google,
                              size: 20,
                            ),
                            label: const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            style:
                                OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppColors.textPrimary,
                              side: const BorderSide(
                                color:
                                    AppColors.inputBorder,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // ==================================
                        // Divider
                        // ==================================

                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color:
                                    AppColors.inputBorder,
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),

                            const Expanded(
                              child: Divider(
                                color:
                                    AppColors.inputBorder,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // ==================================
                        // Email
                        // ==================================

                        TextFormField(
                          controller:
                              _emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newUsername,
                            AutofillHints.email,
                          ],
                          style: const TextStyle(
                            color:
                                AppColors.textPrimary,
                          ),
                          decoration:
                              _inputDecoration(
                            label: 'Email address',
                            icon:
                                Icons.email_outlined,
                          ),
                          validator: (value) {
                            final email =
                                value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Email is required';
                            }

                            if (!email.contains('@') ||
                                !email.contains('.')) {
                              return 'Enter a valid email address';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ==================================
                        // Password
                        // ==================================

                        TextFormField(
                          controller:
                              _passwordController,
                          obscureText:
                              _obscurePassword,
                          textInputAction:
                              TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          style: const TextStyle(
                            color:
                                AppColors.textPrimary,
                          ),
                          decoration:
                              _inputDecoration(
                            label: 'Password',
                            icon:
                                Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                                color: AppColors
                                    .textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.length < 8) {
                              return 'Password must be at '
                                  'least 8 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ==================================
                        // Confirm Password
                        // ==================================

                        TextFormField(
                          controller:
                              _confirmPasswordController,
                          obscureText:
                              _obscureConfirmPassword,
                          textInputAction:
                              TextInputAction.done,
                          style: const TextStyle(
                            color:
                                AppColors.textPrimary,
                          ),
                          decoration:
                              _inputDecoration(
                            label:
                                'Confirm password',
                            icon:
                                Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscureConfirmPassword
                                      ? 'Show password'
                                      : 'Hide password',
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                                color: AppColors
                                    .textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please confirm your password';
                            }

                            if (value !=
                                _passwordController.text) {
                              return 'Passwords do not match';
                            }

                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (!auth.isLoading) {
                              _register();
                            }
                          },
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================
                        // Create Account
                        // ==================================

                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                auth.isLoading
                                    ? null
                                    : _register,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.teal,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  AppColors.teal
                                      .withValues(
                                alpha: 0.45,
                              ),
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Secure Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // ==================================
                        // Security message
                        // ==================================

                        const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color:
                                  AppColors.greenSoft,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Your account is protected',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Shared Input Decoration
  // ==========================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,

      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
      ),

      floatingLabelStyle:
          const TextStyle(
        color: AppColors.tealSoft,
      ),

      prefixIcon: Icon(
        icon,
        color: AppColors.tealSoft,
      ),

      filled: true,

      fillColor: AppColors.inputBackground,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.teal,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.danger,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 1.5,
        ),
      ),

      errorStyle: const TextStyle(
        color: AppColors.danger,
      ),
    );
  }
}

