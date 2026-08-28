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
        return const Color(0xFFFF5C70);
      case 'MEDIUM':
        return const Color(0xFFFFB020);
      case 'LOW':
        return const Color(0xFF32D583);
      default:
        return const Color(0xFF8FA3BF);
    }
  }

  IconData _riskIcon(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return Icons.dangerous_rounded;
      case 'MEDIUM':
        return Icons.warning_amber_rounded;
      case 'LOW':
        return Icons.verified_user_outlined;
      default:
        return Icons.help_outline_rounded;
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
        .map((word) {
          if (word.isEmpty) {
            return word;
          }

          return '${word[0].toUpperCase()}'
              '${word.substring(1)}';
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 24,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis History',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Your recent message safety checks',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF8FA3BF),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<MessageAnalysis>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error
                  .toString()
                  .replaceFirst('Exception: ', ''),
              onRetry: _refresh,
            );
          }

          final analyses = snapshot.data ?? [];

          if (analyses.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  _EmptyState(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF4F8CFF),
            backgroundColor: const Color(0xFF18263D),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                32,
              ),
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
        (analysis.confidence * 100).toStringAsFixed(0);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnalysisDetailScreen(
                analysis: analysis,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: riskColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  riskIcon,
                  color: riskColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: riskColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${analysis.risk.toUpperCase()} RISK',
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF8FA3BF),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      analysis.safeMessage,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.category_outlined,
                          label: formattedCategory,
                        ),
                        _InfoChip(
                          icon: Icons.speed_outlined,
                          label: 'Score ${analysis.riskScore}',
                        ),
                        _InfoChip(
                          icon:
                              Icons.analytics_outlined,
                          label: '$confidencePercent%',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      height: 1,
                      color: const Color(0xFF20314D),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          size: 15,
                          color: Color(0xFF8FA3BF),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8FA3BF),
                          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0C1728),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF20314D),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF4F8CFF),
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB7C6DA),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),

          SizedBox(height: 18),

          Text(
            'Loading your analysis history...',
            style: TextStyle(
              color: Color(0xFF8FA3BF),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF4F8CFF)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF4F8CFF)
                      .withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 42,
                color: Color(0xFF4F8CFF),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No analyses yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your analyzed messages will appear here so you can review their safety results anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8FA3BF),
                height: 1.5,
              ),
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
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C70)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color: Color(0xFFFF5C70),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Unable to load history',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8FA3BF),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () {
                  onRetry();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}