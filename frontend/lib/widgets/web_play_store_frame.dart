import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Web-only download link kept in the layout above the current route.
class WebPlayStoreFrame extends StatelessWidget {
  const WebPlayStoreFrame({super.key, required this.child, this.light = false});
  final bool light;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    return Column(
      children: [
        Material(
          color: light ? const Color(0xFFFAFAF7) : const Color(0xFF101B26),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (MediaQuery.sizeOf(context).width >= 520) ...[
                    Text('MessageShield AI for Android',
                        style: TextStyle(
                            color: light
                                ? const Color(0xFF54645F)
                                : const Color(0xFFF3F6F6),
                            fontSize: 14)),
                    const SizedBox(width: 12),
                  ],
                  Semantics(
                    button: true,
                    label: 'Get MessageShield AI on Google Play',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => launchUrl(
                        Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.jaydeo.messageshield'),
                        mode: LaunchMode.externalApplication,
                        webOnlyWindowName: '_blank',
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                            'assets/images/google_play_badge.png',
                            width: 108,
                            height: 32,
                            excludeFromSemantics: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
