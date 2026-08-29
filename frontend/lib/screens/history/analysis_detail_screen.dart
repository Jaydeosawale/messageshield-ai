import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/message_analysis.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final MessageAnalysis analysis;

  // Admin-only technical information.
  final bool isAdmin;

  const AnalysisDetailScreen({
    super.key,
    required this.analysis,
    this.isAdmin = false,
  });

  // ============================================================
  // RISK COLORS
  // ============================================================

  Color _riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return AppColors.danger;

      case 'MEDIUM':
        return AppColors.warning;

      case 'LOW':
        return AppColors.success;

      default:
        return AppColors.textSecondary;
    }
  }

  Color _riskBackgroundColor(String risk) {
    return _riskColor(risk).withValues(
      alpha: 0.10,
    );
  }

  IconData _riskIcon(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return Icons.gpp_bad_rounded;

      case 'MEDIUM':
        return Icons.warning_amber_rounded;

      case 'LOW':
        return Icons.verified_user_rounded;

      default:
        return Icons.help_outline_rounded;
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year} • '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }

  // ============================================================
  // FORMAT TEXT
  // ============================================================

  String _formatText(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                  '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  // ============================================================
  // RISK DESCRIPTION
  // ============================================================

  String _riskDescription(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return 'This message contains strong indicators of potential risk.';

      case 'MEDIUM':
        return 'This message contains some suspicious indicators. Review carefully.';

      case 'LOW':
        return 'No major threat indicators were detected in this message.';

      default:
        return 'Risk information is unavailable.';
    }
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Divider(
        height: 1,
        color: AppColors.darkBorder,
      ),
    );
  }

  // ============================================================
  // SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(
      analysis.risk,
    );

    final riskBackgroundColor = _riskBackgroundColor(
      analysis.risk,
    );

    final confidencePercent =
        analysis.confidence * 100;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,

        elevation: 0,

        centerTitle: false,

        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),

        title: const Text(
          'Analysis Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        top: false,

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  // =================================================
                  // RISK SUMMARY
                  // =================================================

                  Container(
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: riskBackgroundColor,

                      borderRadius:
                          BorderRadius.circular(24),

                      border: Border.all(
                        color: riskColor.withValues(
                          alpha: 0.35,
                        ),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.10,
                          ),
                          blurRadius: 18,
                          offset: const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [

                        // Risk icon

                        Container(
                          width: 76,
                          height: 76,

                          decoration: BoxDecoration(
                            color: riskColor.withValues(
                              alpha: 0.16,
                            ),

                            shape: BoxShape.circle,

                            border: Border.all(
                              color: riskColor.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),

                          child: Icon(
                            _riskIcon(
                              analysis.risk,
                            ),

                            size: 42,
                            color: riskColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Risk title

                        Text(
                          '${analysis.risk.toUpperCase()} RISK',

                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: riskColor,
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                        ),

                        const SizedBox(height: 8),

                        // Risk description

                        Text(
                          _riskDescription(
                            analysis.risk,
                          ),

                          textAlign:
                              TextAlign.center,

                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    AppColors.textSecondary,
                                height: 1.45,
                              ),
                        ),

                        const SizedBox(height: 20),

                        // Risk score

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),

                          decoration: BoxDecoration(
                            color:
                                AppColors.backgroundSoft,

                            borderRadius:
                                BorderRadius.circular(16),

                            border: Border.all(
                              color:
                                  AppColors.darkBorder,
                            ),
                          ),

                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,

                            children: [

                              Icon(
                                Icons.speed_rounded,
                                size: 20,
                                color: riskColor,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                'Risk Score: ${analysis.riskScore}',

                                style:
                                    const TextStyle(
                                  color:
                                      AppColors.textPrimary,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // ANALYZED MESSAGE
                  // =================================================

                  _SectionCard(
                    title: 'Analyzed Message',

                    subtitle:
                        'The message processed by MessageShield AI',

                    icon:
                        Icons.message_outlined,

                    child: Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color:
                            AppColors.inputBackground,

                        borderRadius:
                            BorderRadius.circular(16),

                        border: Border.all(
                          color:
                              AppColors.darkBorder,
                        ),
                      ),

                      child: SelectableText(
                        analysis.safeMessage,

                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color:
                                  AppColors.textPrimary,
                              height: 1.5,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // CLASSIFICATION
                  // =================================================

                  _SectionCard(
                    title: 'Classification',

                    subtitle:
                        'AI category prediction',

                    icon:
                        Icons.category_outlined,

                    child: Column(
                      children: [

                        _InfoTile(
                          icon:
                              Icons.label_outline_rounded,

                          label:
                              'Detected Category',

                          value: _formatText(
                            analysis.category,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _InfoTile(
                          icon:
                              Icons.auto_graph_rounded,

                          label:
                              'Prediction Confidence',

                          value:
                              '${confidencePercent.toStringAsFixed(1)}%',
                        ),

                        const SizedBox(height: 14),

                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(10),

                          child:
                              LinearProgressIndicator(
                            value: analysis.confidence
                                .clamp(
                              0.0,
                              1.0,
                            ),

                            minHeight: 10,

                            backgroundColor:
                                AppColors.inputBackground,

                            color:
                                AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // SECURITY SIGNALS
                  // =================================================

                  _SectionCard(
                    title: 'Security Signals',

                    subtitle:
                        'Signals detected during analysis',

                    icon:
                        Icons.shield_outlined,

                    child: analysis.signals.isEmpty
                        ? const _EmptySignals()
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,

                            children:
                                analysis.signals.map(
                              (signal) {
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: AppColors.teal
                                        .withValues(
                                      alpha: 0.10,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),

                                    border: Border.all(
                                      color: AppColors.teal
                                          .withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),

                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,

                                    children: [

                                      const Icon(
                                        Icons.shield_outlined,

                                        size: 17,

                                        color:
                                            AppColors.tealSoft,
                                      ),

                                      const SizedBox(
                                        width: 7,
                                      ),

                                      Flexible(
                                        child: Text(
                                          _formatText(
                                            signal.displayMessage,
                                          ),

                                          style:
                                              const TextStyle(
                                            color: AppColors
                                                .textPrimary,

                                            fontSize: 13,

                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // MODEL PROBABILITIES
                  // =================================================

                  _SectionCard(
                    title: 'Model Probabilities',

                    subtitle:
                        'Confidence distribution across categories',

                    icon:
                        Icons.analytics_outlined,

                    child: Column(
                      children:
                          analysis.probabilities.entries
                              .map(
                        (entry) {
                          final value =
                              entry.value.clamp(
                            0.0,
                            1.0,
                          );

                          final percent =
                              value * 100;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 18,
                            ),

                            child: Column(
                              children: [

                                Row(
                                  children: [

                                    Expanded(
                                      child: Text(
                                        _formatText(
                                          entry.key,
                                        ),

                                        style:
                                            const TextStyle(
                                          color: AppColors
                                              .textPrimary,

                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      '${percent.toStringAsFixed(1)}%',

                                      style:
                                          const TextStyle(
                                        color:
                                            AppColors.tealSoft,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),

                                  child:
                                      LinearProgressIndicator(
                                    value: value,

                                    minHeight: 9,

                                    backgroundColor:
                                        AppColors
                                            .inputBackground,

                                    color:
                                        AppColors.teal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // ANALYSIS INFORMATION
                  // =================================================

                  _SectionCard(
                    title: isAdmin
                        ? 'Analysis Information'
                        : 'Analysis Details',

                    subtitle: isAdmin
                        ? 'Technical details for this result'
                        : 'Information about this analysis',

                    icon:
                        Icons.info_outline_rounded,

                    child: Column(
                      children: [

                        // =========================================
                        // ADMIN ONLY
                        // =========================================

                        if (isAdmin) ...[

                          _DetailRow(
                            label:
                                'Analysis ID',

                            value:
                                '#${analysis.id}',
                          ),

                          _divider(),

                          _DetailRow(
                            label:
                                'AI Model',

                            value:
                                analysis.model.name,
                          ),

                          _divider(),

                          _DetailRow(
                            label:
                                'Model Version',

                            value:
                                analysis.model.version,
                          ),

                          _divider(),
                        ],

                        // =========================================
                        // ALL USERS
                        // =========================================

                        _DetailRow(
                          label:
                              'Analyzed At',

                          value: _formatDate(
                            analysis.createdAt,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.backgroundSoft,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: AppColors.darkBorder,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),

            blurRadius: 16,

            offset: const Offset(
              0,
              6,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(
                    alpha: 0.12,
                  ),

                  borderRadius:
                      BorderRadius.circular(13),

                  border: Border.all(
                    color: AppColors.teal.withValues(
                      alpha: 0.20,
                    ),
                  ),
                ),

                child: Icon(
                  icon,

                  color:
                      AppColors.tealSoft,

                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,

                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color:
                                AppColors.textPrimary,

                            fontWeight:
                                FontWeight.w800,
                          ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,

                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppColors
                                .textSecondary,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// INFO TILE
// ================================================================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: AppColors.inputBackground,

        borderRadius:
            BorderRadius.circular(14),

        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),

      child: Row(
        children: [

          Icon(
            icon,

            size: 20,

            color:
                AppColors.tealSoft,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,

              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color:
                        AppColors.textSecondary,
                  ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,

              textAlign:
                  TextAlign.end,

              style: const TextStyle(
                color:
                    AppColors.textPrimary,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// EMPTY SIGNALS
// ================================================================

class _EmptySignals extends StatelessWidget {
  const _EmptySignals();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppColors.success.withValues(
          alpha: 0.08,
        ),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: AppColors.success.withValues(
            alpha: 0.20,
          ),
        ),
      ),

      child: const Row(
        children: [

          Icon(
            Icons.check_circle_outline_rounded,

            color:
                AppColors.success,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'No suspicious signals detected.',

              style: TextStyle(
                color:
                    AppColors.textPrimary,

                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// DETAIL ROW
// ================================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Expanded(
          child: Text(
            label,

            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColors.textSecondary,
                ),
          ),
        ),

        const SizedBox(width: 20),

        Flexible(
          child: Text(
            value,

            textAlign:
                TextAlign.end,

            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color:
                      AppColors.textPrimary,

                  fontWeight:
                      FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}