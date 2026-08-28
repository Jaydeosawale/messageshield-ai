import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/message_analysis.dart';
import 'probability_bar.dart';
import 'risk_badge.dart';
import 'safety_status_card.dart';

class AnalysisResultCard extends StatelessWidget {
  final MessageAnalysis analysis;

  const AnalysisResultCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainResult(),

        const SizedBox(height: 16),

        SafetyStatusCard(
          safety: analysis.safety,
        ),

        if (analysis.safety != null) const SizedBox(height: 16),

        _buildSectionCard(
          icon: Icons.category_outlined,
          title: 'Message Category',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatLabel(analysis.category),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${analysis.confidencePercent.toStringAsFixed(1)}% AI confidence',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildSectionCard(
          icon: Icons.shield_outlined,
          title: 'Risk Assessment',
          trailing: RiskBadge(
            risk: analysis.risk,
          ),
          child: Row(
            children: [
              Expanded(
                child: _RiskMetric(
                  label: 'Risk Score',
                  value: '${analysis.riskScore}',
                ),
              ),
              Expanded(
                child: _RiskMetric(
                  label: 'Level',
                  value: analysis.riskLabel,
                ),
              ),
            ],
          ),
        ),

        if (analysis.signals.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSignalsCard(),
        ],

        if (analysis.probabilities.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildProbabilitiesCard(),
        ],

        if (analysis.safety?.probabilities.isNotEmpty ?? false) ...[
          const SizedBox(height: 16),
          _buildSafetyProbabilitiesCard(),
        ],

        const SizedBox(height: 16),

        _buildModelCard(),
      ],
    );
  }

  // ============================================================
  // MAIN RESULT
  // ============================================================

  Widget _buildMainResult() {
    final Color statusColor;
    final IconData icon;
    final String title;
    final String description;

    if (analysis.isHighRisk) {
      statusColor = AppColors.danger;
      icon = Icons.dangerous_rounded;
      title = 'Potential Threat Detected';
      description =
          'Our AI detected strong indicators of a potential security threat.';
    } else if (analysis.isMediumRisk) {
      statusColor = AppColors.warning;
      icon = Icons.warning_amber_rounded;
      title = 'Use Caution';
      description =
          'Some suspicious patterns were detected. Review this message carefully.';
    } else {
      statusColor = AppColors.green;
      icon = Icons.verified_user_rounded;
      title = 'Message Appears Safe';
      description =
          'No major threat indicators were detected in this message.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: 0.14),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 35,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: statusColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SIGNALS
  // ============================================================

  Widget _buildSignalsCard() {
    return _buildSectionCard(
      icon: Icons.radar_rounded,
      title: 'Detected Signals',
      child: Column(
        children: analysis.signals
            .map(
              (signal) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(
                        top: 6,
                        right: 10,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatLabel(signal),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // CATEGORY PROBABILITIES
  // ============================================================

  Widget _buildProbabilitiesCard() {
    return _buildSectionCard(
      icon: Icons.analytics_outlined,
      title: 'Category Confidence',
      child: Column(
        children: analysis.probabilities.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ProbabilityBar(
                  label: entry.key,
                  value: entry.value,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // SAFETY PROBABILITIES
  // ============================================================

  Widget _buildSafetyProbabilitiesCard() {
    final probabilities = analysis.safety!.probabilities;

    return _buildSectionCard(
      icon: Icons.security_rounded,
      title: 'Safety Confidence',
      child: Column(
        children: probabilities.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: ProbabilityBar(
                  label: entry.key,
                  value: entry.value,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // MODEL INFORMATION
  // ============================================================

  Widget _buildModelCard() {
    return _buildSectionCard(
      icon: Icons.memory_rounded,
      title: 'AI Model Information',
      child: Column(
        children: [
          _ModelRow(
            label: 'Category Model',
            value: analysis.model.name.isEmpty
                ? 'Not available'
                : analysis.model.name,
          ),

          const SizedBox(height: 12),

          _ModelRow(
            label: 'Version',
            value: analysis.model.version.isEmpty
                ? 'Not available'
                : analysis.model.version,
          ),

          if (analysis.safety != null) ...[
            const SizedBox(height: 12),

            Divider(
              color: AppColors.border.withValues(alpha: 0.8),
            ),

            const SizedBox(height: 12),

            _ModelRow(
              label: 'Safety Model',
              value: analysis.safety!.model.name.isEmpty
                  ? 'Not available'
                  : analysis.safety!.model.name,
            ),

            const SizedBox(height: 12),

            _ModelRow(
              label: 'Safety Version',
              value: analysis.safety!.model.version.isEmpty
                  ? 'Not available'
                  : analysis.safety!.model.version,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // REUSABLE DARK SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.teal,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              if (trailing != null) trailing,
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) => word.length == 1
              ? word.toUpperCase()
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

// ============================================================
// RISK METRIC
// ============================================================

class _RiskMetric extends StatelessWidget {
  final String label;
  final String value;

  const _RiskMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 14,
      ),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MODEL ROW
// ============================================================

class _ModelRow extends StatelessWidget {
  final String label;
  final String value;

  const _ModelRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}