import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/auth_surface.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage(
      {super.key, this.sendResetEmail, this.initialEmail = ''});
  final String initialEmail;
  final Future<void> Function(String email)? sendResetEmail;
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _busy = false;
  String? _message;
  @override
  void initState() {
    super.initState();
    _email.text = widget.initialEmail.trim();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    if (_busy) return;
    final email = _email.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() => _message =
          (l10n?.resetInvalidEmail ?? 'Enter a valid email address.'));
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final sender = widget.sendResetEmail;
      if (sender != null) {
        await sender(email);
      } else {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      }
      if (mounted) {
        setState(
          () => _message = (l10n?.resetSent ??
              'If this account exists, a reset link has been sent. Check your inbox and spam folder.'),
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => _message = error.code == 'user-not-found'
              ? (l10n?.resetSent ??
                  'If this account exists, a reset link has been sent. Check your inbox and spam folder.')
              : error.code == 'too-many-requests'
                  ? (l10n?.resetTooMany ??
                      'Too many reset requests. Please wait before trying again.')
                  : (l10n?.resetFailed ??
                      'Unable to send the reset email. Check your connection and try again.'),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = (l10n?.resetFailed ??
              'Unable to send the reset email. Check your connection and try again.'),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AuthSurface(
      title: l10n?.passwordResetTitle ?? 'Reset password',
      description: l10n?.passwordResetIntro ??
          'Enter your MessageShield email to receive a password-reset link.',
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _email,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                    labelText: l10n?.emailAddress ?? 'Email address'),
                onSubmitted: (_) {
                  if (!_busy) _send();
                }),
            const SizedBox(height: 20),
            if (_message != null) ...[
              Semantics(
                  liveRegion: true,
                  child: Text(_message!, style: const TextStyle(height: 1.6))),
              const SizedBox(height: 20)
            ],
            FilledButton(
                onPressed: _busy ? null : _send,
                child: Text(_busy
                    ? (l10n?.resetSending ?? 'Sending…')
                    : (l10n?.resetSendLink ?? 'Send reset link'))),
            const SizedBox(height: 16),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n?.resetBackToLogin ?? 'Back to sign in')),
          ]),
    );
  }
}
