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
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _riskIcon(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return Icons.dangerous_rounded;
      case 'MEDIUM':
        return Icons.warning_amber_rounded;
      case 'LOW':
        return Icons.verified_user_rounded;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    String twoDigits(int value) =>
        value.toString().padLeft(2, '0');

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year} at '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }

  String _formatSignal(String signal) {
    return signal
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(analysis.risk);
    final confidencePercent =
        (analysis.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        _riskIcon(analysis.risk),
                        size: 64,
                        color: riskColor,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '${analysis.risk} RISK',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: riskColor,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Risk Score: ${analysis.riskScore}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Analyzed Message',
                icon: Icons.message_outlined,
                child: SelectableText(
                  analysis.safeMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Classification',
                icon: Icons.category_outlined,
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Category',
                      value: analysis.category
                          .replaceAll('_', ' '),
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Confidence',
                      value: '$confidencePercent%',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Security Signals',
                icon: Icons.security_outlined,
                child: analysis.signals.isEmpty
                    ? const Text(
                        'No suspicious signals detected.',
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: analysis.signals
                            .map(
                              (signal) => Chip(
                                avatar: const Icon(
                                  Icons.shield_outlined,
                                  size: 16,
                                ),
                                label: Text(
                                  _formatSignal(signal),
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Model Probabilities',
                icon: Icons.analytics_outlined,
                child: Column(
                  children: analysis.probabilities.entries
                      .map(
                        (entry) {
                          final percent =
                              entry.value * 100;

                          return Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 14,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key.replaceAll(
                                          '_',
                                          ' ',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${percent.toStringAsFixed(1)}%',
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                LinearProgressIndicator(
                                  value: entry.value,
                                  minHeight: 8,
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
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

              _SectionCard(
                title: 'Analysis Information',
                icon: Icons.info_outline,
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Analysis ID',
                      value: '#${analysis.id}',
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Model',
                      value: analysis.model.name,
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Version',
                      value: analysis.model.version,
                    ),
                    const Divider(),
                    _DetailRow(
                      label: 'Analyzed',
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
}


class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
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
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
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
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}