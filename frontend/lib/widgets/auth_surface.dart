import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';

/// Shared product identity for sign-in, registration and account recovery.
class AuthSurface extends StatelessWidget {
  const AuthSurface(
      {super.key,
      required this.title,
      required this.description,
      required this.child});
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const accent = Color(0xFF11665B);
    final theme = AppTheme.lightTheme;
    final brand = Row(mainAxisSize: MainAxisSize.min, children: [
      ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset('assets/images/messageshield_logo.png',
              width: 36, height: 36, excludeFromSemantics: true)),
      const SizedBox(width: 10),
      const Flexible(
          child: Text('MessageShield',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.5))),
    ]);
    return Theme(
        data: theme,
        child: Scaffold(body:
            SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 980;
          final form = Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth < 400 ? 24 : 40,
                    vertical: 32),
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AutofillGroup(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          if (!desktop) ...[brand, const SizedBox(height: 42)],
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 30,
                                  height: 1.15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.8)),
                          const SizedBox(height: 10),
                          Text(description,
                              style: const TextStyle(
                                  color: Color(0xFF65736D),
                                  fontSize: 15,
                                  height: 1.6)),
                          const SizedBox(height: 30),
                          child,
                        ]))),
              ));
          if (!desktop) return form;
          return Row(children: [
            Expanded(
                child: Container(
                    color: const Color(0xFFEDF2E9),
                    padding: const EdgeInsets.all(56),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          brand,
                          Expanded(
                              child: Center(
                                  child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 440),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 7),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: Text(
                                                    l10n?.productBadge ??
                                                        'Message safety, made clearer',
                                                    style: const TextStyle(
                                                        color: accent,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12))),
                                            const SizedBox(height: 24),
                                            Text(
                                                l10n?.productHeadline ??
                                                    'Know what to question.',
                                                style: const TextStyle(
                                                    fontSize: 48,
                                                    height: 1.1,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -1.8)),
                                            const SizedBox(height: 20),
                                            Text(
                                                l10n?.productDescription ??
                                                    'Understand suspicious messages before you click, reply, or pay.',
                                                style: const TextStyle(
                                                    color: Color(0xFF54645F),
                                                    fontSize: 18,
                                                    height: 1.6)),
                                            const SizedBox(height: 36),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(24),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFFDCE3D7)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .chat_bubble_outline_rounded,
                                                          color: accent),
                                                      const SizedBox(
                                                          height: 14),
                                                      Text(
                                                          l10n?.productExample ??
                                                              '“Your account will be blocked. Share your OTP now.”',
                                                          style: const TextStyle(
                                                              fontSize: 16,
                                                              height: 1.6,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500)),
                                                      const SizedBox(
                                                          height: 18),
                                                      const Divider(height: 1),
                                                      const SizedBox(
                                                          height: 18),
                                                      Text(
                                                          l10n?.productExampleReason ??
                                                              'Requests a one-time code • Uses urgency',
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF9A4A14),
                                                              fontSize: 13,
                                                              height: 1.5)),
                                                    ])),
                                          ])))),
                          Text(
                              l10n?.productCaution ??
                                  'A risk assessment is guidance, not a guarantee.',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF65736D))),
                        ]))),
            Expanded(child: ColoredBox(color: Colors.white, child: form)),
          ]);
        }))));
  }
}
