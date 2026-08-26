import 'package:flutter/material.dart';

import '../../core/services/analysis_service.dart';
import '../../models/message_analysis.dart';
import 'analysis_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<MessageAnalysis>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadAnalyses();
  }

  Future<List<MessageAnalysis>> _loadAnalyses() async {
    return (await AnalysisService.getHistory()).items;
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _loadAnalyses();
    });

    await _historyFuture;
  }

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
        return Icons.dangerous_outlined;

      case 'MEDIUM':
        return Icons.warning_amber_rounded;

      case 'LOW':
        return Icons.verified_user_outlined;

      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(localDate.day)}/'
        '${twoDigits(localDate.month)}/'
        '${localDate.year} • '
        '${twoDigits(localDate.hour)}:'
        '${twoDigits(localDate.minute)}';
  }

  String _formatCategory(String category) {
    return category
        .toLowerCase()
        .split('_')
        .map(
          (word) {
            if (word.isEmpty) {
              return word;
            }

            return '${word[0].toUpperCase()}'
                '${word.substring(1)}';
          },
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MessageAnalysis>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error
                  .toString()
                  .replaceFirst('Exception: ', ''),
              onRetry: _refresh,
            );
          }

          final analyses = snapshot.data ?? [];

          // Empty
          if (analyses.isEmpty) {
            return const _EmptyState();
          }

          // History list
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: analyses.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final analysis = analyses[index];

                return _HistoryCard(
                  analysis: analysis,
                  riskColor: _riskColor(
                    analysis.risk,
                  ),
                  riskIcon: _riskIcon(
                    analysis.risk,
                  ),
                  formattedDate: _formatDate(
                    analysis.createdAt,
                  ),
                  formattedCategory: _formatCategory(
                    analysis.category,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MessageAnalysis analysis;
  final Color riskColor;
  final IconData riskIcon;
  final String formattedDate;
  final String formattedCategory;

  const _HistoryCard({
    required this.analysis,
    required this.riskColor,
    required this.riskIcon,
    required this.formattedDate,
    required this.formattedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePercent =
        (analysis.confidence * 100)
            .toStringAsFixed(0);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AnalysisDetailScreen(
                analysis: analysis,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // Risk icon
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    riskColor.withOpacity(0.12),
                child: Icon(
                  riskIcon,
                  color: riskColor,
                ),
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Risk + arrow
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${analysis.risk} RISK',
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight:
                                          FontWeight.bold,
                                      color: riskColor,
                                    ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Message
                    Text(
                      analysis.safeMessage,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge,
                    ),

                    const SizedBox(height: 14),

                    // Metadata
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon:
                              Icons.category_outlined,
                          label:
                              formattedCategory,
                        ),
                        _InfoChip(
                          icon:
                              Icons.speed_outlined,
                          label:
                              'Score ${analysis.riskScore}',
                        ),
                        _InfoChip(
                          icon:
                              Icons.analytics_outlined,
                          label:
                              '$confidencePercent%',
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 15,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
      visualDensity:
          VisualDensity.compact,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 20),

            Text(
              'No analyses yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            Text(
              'Messages you analyze will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),

            const SizedBox(height: 16),

            Text(
              'Could not load history',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                onRetry();
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}