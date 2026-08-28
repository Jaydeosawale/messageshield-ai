import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class ProbabilityBar extends StatelessWidget {
  final String label;
  final double value;

  const ProbabilityBar({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _formatLabel(label),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(normalizedValue * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalizedValue,
            minHeight: 8,
            backgroundColor: AppColors.teal.withValues(alpha: 0.10),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.teal,
            ),
          ),
        ),
      ],
    );
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) => word[0].toUpperCase() +
              word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}