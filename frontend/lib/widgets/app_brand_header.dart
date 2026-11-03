import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';

class AppBrandHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool compact;

  const AppBrandHeader({
    super.key,
    this.title,
    this.subtitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final logoSize = compact
        ? 64.0
        : screenWidth < 500
            ? 76.0
            : 84.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ==========================================
        // MessageShield Logo
        // ==========================================
        ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 16 : 20),
            child: Image.asset('assets/images/messageshield_logo.png',
                width: logoSize, height: logoSize, excludeFromSemantics: true)),

        SizedBox(
          height: compact ? 14 : 18,
        ),

        // ==========================================
        // Brand Name
        // ==========================================
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 25 : 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
            ),
            children: const [
              TextSpan(
                text: 'Message',
              ),
              TextSpan(
                text: 'Shield',
                style: TextStyle(
                  color: AppColors.teal,
                ),
              ),
              TextSpan(
                text: ' AI',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 7),

        // ==========================================
        // Tagline
        // ==========================================
        Text(
          l10n.smartPrivateProtected,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),

        // ==========================================
        // Optional Screen Title
        // ==========================================
        if (title != null) ...[
          SizedBox(
            height: compact ? 20 : 26,
          ),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ],

        // ==========================================
        // Optional Subtitle
        // ==========================================
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}
