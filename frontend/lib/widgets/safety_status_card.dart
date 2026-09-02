import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../models/message_analysis.dart';

class SafetyStatusCard extends StatelessWidget {
  final SafetyAnalysis? safety;

  const SafetyStatusCard({
    super.key,
    required this.safety,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (safety == null) {
      return const SizedBox.shrink();
    }

    final label = safety!.label;
    final normalizedLabel = label.toUpperCase();

    final isSafe =
        normalizedLabel.contains('SAFE') && !normalizedLabel.contains('UNSAFE');

    final color = isSafe ? AppColors.green : Colors.red;

    final icon =
        isSafe ? Icons.verified_user_rounded : Icons.warning_amber_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiSafetyAnalysis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label.replaceAll('_', ' '),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${safety!.confidencePercent.toStringAsFixed(1)}% ${l10n.confidence}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
