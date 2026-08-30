import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/services/google_auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

import '../../widgets/app_background.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

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
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await context.read<AuthProvider>().login(
            email:
                _emailController.text.trim(),
            password:
                _passwordController.text,
          );
    } catch (_) {
      if (!mounted) return;

      final providerError =
          context.read<AuthProvider>().error ??
              'Login failed';

      final message =
          _friendlyError(providerError);

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

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> _continueWithGoogle() async {
    FocusScope.of(context).unfocus();

    try {
      // Step 1:
      // Authenticate with Google through Firebase.
      final firebase_auth.User firebaseUser =
          await GoogleAuthService.signIn();

      if (!mounted) return;

      // Step 2:
      // Send Firebase authentication to
      // MessageShield backend.
      await context
          .read<AuthProvider>()
          .loginWithFirebaseUser(
            firebaseUser,
          );

      if (!mounted) return;
    } catch (error, stackTrace) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        'GOOGLE SIGN-IN ERROR:',
      );
      debugPrint(
        error.toString(),
      );
      debugPrint(
        'GOOGLE SIGN-IN STACK TRACE:',
      );
      debugPrint(
        stackTrace.toString(),
      );
      debugPrint(
        '========================================',
      );

      if (!mounted) return;

      final providerError =
          context.read<AuthProvider>().error;

      final String message;

      if (providerError != null &&
          providerError.isNotEmpty) {
        message =
            _friendlyError(providerError);
      } else {
        message =
            'Google sign-in failed. Please try again.';
      }

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

  // ============================================================
  // USER-FRIENDLY BACKEND ERRORS
  // ============================================================

   String _friendlyError(String error) {
  final value = error.toLowerCase();

  // Google account is valid but not registered
  // in MessageShield yet.
  if (value.contains('account not found') ||
      value.contains('create an account first') ||
      value.contains('not registered')) {
    return 'No MessageShield account found for this Google account. '
        'Please create an account first.';
  }

  if (value.contains('invalid credentials') ||
      value.contains('incorrect email') ||
      value.contains('incorrect password') ||
      value.contains('invalid email or password') ||
      value.contains('unauthorized')) {
    return 'Invalid email or password.';
  }

  if (value.contains('network') ||
      value.contains('connection') ||
      value.contains('socket')) {
    return 'Unable to connect to the server. Please try again.';
  }

  if (value.contains('timeout')) {
    return 'The request timed out. Please try again.';
  }

  if (value.contains('inactive')) {
    return 'Your account is currently inactive.';
  }

  return error.isNotEmpty
      ? error
      : 'Unable to sign in. Please try again.';
}

  @override
  Widget build(BuildContext context) {
    final auth =
        context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,

      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(24),

              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 460,
                ),

                child: Form(
                  key: _formKey,

                  child: Container(
                    padding:
                        const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color:
                          AppColors.backgroundSoft,

                      borderRadius:
                          BorderRadius.circular(28),

                      border: Border.all(
                        color:
                            AppColors.teal
                                .withValues(
                          alpha: 0.22,
                        ),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(
                            alpha: 0.32,
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
                        // ==================================================
                        // LOGO
                        // ==================================================

                        Center(
                          child: Container(
                            width: 86,
                            height: 86,

                            decoration:
                                BoxDecoration(
                              shape: BoxShape.circle,

                              gradient:
                                  const LinearGradient(
                                begin:
                                    Alignment.topLeft,
                                end: Alignment
                                    .bottomRight,
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
                                    alpha: 0.24,
                                  ),
                                  blurRadius: 28,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.shield_outlined,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // BRAND
                        // ==================================================

                        const Text(
                          'MessageShield',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color:
                                AppColors.textPrimary,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'AI-powered message security',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ==================================================
                        // LOGIN TITLE
                        // ==================================================

                        const Text(
                          'Welcome back',

                          style: TextStyle(
                            color:
                                AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Sign in to protect and analyze your messages.',

                          style: TextStyle(
                            color: AppColors
                                .textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        TextFormField(
                          controller:
                              _emailController,

                          keyboardType:
                              TextInputType
                                  .emailAddress,

                          autofillHints: const [
                            AutofillHints.email,
                          ],

                          style: const TextStyle(
                            color:
                                AppColors.textPrimary,
                          ),

                          cursorColor:
                              AppColors.teal,

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
                              return
                                  'Email is required';
                            }

                            if (!email.contains('@') ||
                                !email.contains(
                                  '.',
                                )) {
                              return
                                  'Enter a valid email address';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // PASSWORD
                        // ==================================================

                        TextFormField(
                          controller:
                              _passwordController,

                          obscureText:
                              _obscurePassword,

                          autofillHints: const [
                            AutofillHints.password,
                          ],

                          style: const TextStyle(
                            color:
                                AppColors.textPrimary,
                          ),

                          cursorColor:
                              AppColors.teal,

                          decoration:
                              _inputDecoration(
                            label: 'Password',
                            icon:
                                Icons.lock_outline,
                          ).copyWith(
                            suffixIcon:
                                IconButton(
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
                                value.isEmpty) {
                              return
                                  'Password is required';
                            }

                            return null;
                          },

                          onFieldSubmitted: (_) {
                            if (!auth.isLoading) {
                              _login();
                            }
                          },
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // LOGIN BUTTON
                        // ==================================================

                        SizedBox(
                          height: 54,

                          child: ElevatedButton(
                            onPressed:
                                auth.isLoading
                                    ? null
                                    : _login,

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
                                    width: 23,
                                    height: 23,

                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Secure Login',

                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // DIVIDER
                        // ==================================================

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
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary,
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

                        const SizedBox(height: 20),

                        // ==================================================
                        // GOOGLE
                        // ==================================================

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

                        const SizedBox(height: 22),

                        // ==================================================
                        // REGISTER
                        // ==================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            const Text(
                              "Don't have an account?",

                              style: TextStyle(
                                color: AppColors
                                    .textSecondary,
                                fontSize: 14,
                              ),
                            ),

                            TextButton(
                              onPressed:
                                  auth.isLoading
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const RegisterScreen(),
                                            ),
                                          );
                                        },

                              child: const Text(
                                'Create account',

                                style: TextStyle(
                                  color:
                                      AppColors.teal,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // ==================================================
                        // SECURITY FOOTER
                        // ==================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            const Icon(
                              Icons
                                  .verified_user_outlined,
                              size: 16,
                              color: AppColors.green,
                            ),

                            const SizedBox(width: 7),

                            Text(
                              'Secure AI-powered protection',

                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.8,
                                ),
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

  // ============================================================
  // INPUT DECORATION
  // ============================================================

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
        color: AppColors.teal,
        fontWeight: FontWeight.w600,
      ),

      prefixIcon: Icon(
        icon,
        color: AppColors.teal,
      ),

      filled: true,

      fillColor:
          AppColors.inputBackground,

      errorStyle: const TextStyle(
        color: AppColors.danger,
        fontSize: 12,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.inputBorder,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.teal,
          width: 1.6,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
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
    );
  }
}

