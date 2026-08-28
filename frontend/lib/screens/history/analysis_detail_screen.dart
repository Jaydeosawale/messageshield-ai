import 'package:flutter/material.dart';

import '../../models/message_analysis.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final MessageAnalysis analysis;

  const AnalysisDetailScreen({
    super.key,
    required this.analysis,
  });

  Color _riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFF5C70);
      case 'MEDIUM':
        return const Color(0xFFFFB74D);
      case 'LOW':
        return const Color(0xFF39D98A);
      default:
        return Colors.grey;
    }
  }

  Color _riskBackgroundColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFF5C70).withValues(alpha: 0.12);
      case 'MEDIUM':
        return const Color(0xFFFFB74D).withValues(alpha: 0.12);
      case 'LOW':
        return const Color(0xFF39D98A).withValues(alpha: 0.12);
      default:
        return Colors.grey.withValues(alpha: 0.12);
    }
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

  String _formatText(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(analysis.risk);
    final riskBackgroundColor = _riskBackgroundColor(analysis.risk);

    final confidencePercent = analysis.confidence * 100;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // =========================
              // RISK SUMMARY
              // =========================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: riskBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: riskColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _riskIcon(analysis.risk),
                        size: 42,
                        color: riskColor,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      '${analysis.risk.toUpperCase()} RISK',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: riskColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _riskDescription(analysis.risk),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Colors.white70,
                          ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08111F)
                            .withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 20,
                            color: riskColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Risk Score: ${analysis.riskScore}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =========================
              // MESSAGE
              // =========================

              _SectionCard(
                title: 'Analyzed Message',
                subtitle: 'The message processed by MessageShield AI',
                icon: Icons.message_outlined,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C1728),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SelectableText(
                    analysis.safeMessage,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // CLASSIFICATION
              // =========================

              _SectionCard(
                title: 'Classification',
                subtitle: 'AI category prediction',
                icon: Icons.category_outlined,
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.label_outline_rounded,
                      label: 'Detected Category',
                      value: _formatText(
                        analysis.category,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _InfoTile(
                      icon: Icons.auto_graph_rounded,
                      label: 'Prediction Confidence',
                      value:
                          '${confidencePercent.toStringAsFixed(1)}%',
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: analysis.confidence.clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 10,
                        backgroundColor:
                            const Color(0xFF20314D),
                        color:
                            const Color(0xFF4F8CFF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // SECURITY SIGNALS
              // =========================

              _SectionCard(
                title: 'Security Signals',
                subtitle: 'Signals detected during analysis',
                icon: Icons.shield_outlined,
                child: analysis.signals.isEmpty
                    ? _EmptySignals()
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: analysis.signals
                            .map(
                              (signal) => Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4F8CFF,
                                  ).withValues(alpha: 0.10),
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF4F8CFF,
                                    ).withValues(
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
                                      color: Color(
                                        0xFF4F8CFF,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      _formatText(signal.displayMessage),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),

              const SizedBox(height: 16),

              // =========================
              // PROBABILITIES
              // =========================

              _SectionCard(
                title: 'Model Probabilities',
                subtitle: 'Confidence distribution across categories',
                icon: Icons.analytics_outlined,
                child: Column(
                  children: analysis.probabilities.entries
                      .map(
                        (entry) {
                          final value = entry.value.clamp(
                            0.0,
                            1.0,
                          );

                          final percent = value * 100;

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
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${percent.toStringAsFixed(1)}%',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Color(0xFF4F8CFF),
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
                                        const Color(
                                      0xFF20314D,
                                    ),
                                    color:
                                        const Color(
                                      0xFF00B8D9,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // ANALYSIS INFORMATION
              // =========================

              _SectionCard(
                title: 'Analysis Information',
                subtitle: 'Technical details for this result',
                icon: Icons.info_outline_rounded,
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Analysis ID',
                      value: '#${analysis.id}',
                    ),

                    _divider(),

                    _DetailRow(
                      label: 'AI Model',
                      value: analysis.model.name,
                    ),

                    _divider(),

                    _DetailRow(
                      label: 'Model Version',
                      value: analysis.model.version,
                    ),

                    _divider(),

                    _DetailRow(
                      label: 'Analyzed At',
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
    );
  }

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

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Divider(
        height: 1,
      ),
    );
  }
}

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                    color: const Color(
                      0xFF4F8CFF,
                    ).withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4F8CFF),
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
                              fontWeight:
                                  FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Colors.white54,
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
      ),
    );
  }
}

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
        color: const Color(0xFF0C1728),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF00B8D9),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySignals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF39D98A)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF39D98A),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'No suspicious signals detected.',
            ),
          ),
        ],
      ),
    );
  }
}

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
                  color: Colors.white60,
                ),
          ),
        ),

        const SizedBox(width: 20),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}