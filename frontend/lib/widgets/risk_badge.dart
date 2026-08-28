import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class RiskBadge extends StatelessWidget {
  final String risk;

  const RiskBadge({
    super.key,
    required this.risk,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedRisk = risk.toUpperCase();

    final Color color;

    switch (normalizedRisk) {
      case 'HIGH':
        color = Colors.red;
        break;

      case 'MEDIUM':
        color = Colors.orange;
        break;

      case 'LOW':
        color = AppColors.green;
        break;

      default:
        color = AppColors.teal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        normalizedRisk,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}