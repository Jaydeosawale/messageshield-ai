import 'package:flutter/material.dart';

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
    final logoSize = compact ? 72.0 : 92.0;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
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
                color: AppColors.teal.withValues(alpha: 0.22),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            color: Colors.white,
            size: 46,
          ),
        ),

        SizedBox(height: compact ? 16 : 20),

        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
            ),
            children: [
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
                  color: AppColors.teal,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Smart. Private. Protected.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),

        if (title != null) ...[
          SizedBox(height: compact ? 22 : 28),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],

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