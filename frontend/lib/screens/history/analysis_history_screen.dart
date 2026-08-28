import 'package:flutter/material.dart';

import '../../core/services/analysis_service.dart';
import '../../models/analysis_history_response.dart';
import '../../models/message_analysis.dart';


class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  State<AnalysisHistoryScreen> createState() =>
      _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState
    extends State<AnalysisHistoryScreen> {
  late Future<AnalysisHistoryResponse> _historyFuture;

  String? _selectedRisk;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = AnalysisService.getHistory(
      risk: _selectedRisk,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadHistory();
    });

    await _historyFuture;
  }

  Color _riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _riskIcon(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return Icons.warning_amber_rounded;
      case 'MEDIUM':
        return Icons.error_outline;
      default:
        return Icons.verified_user_outlined;
    }
  }

  String _formatCategory(String category) {
    return category
        .toLowerCase()
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
      ),
      body: Column(
        children: [
          _buildRiskFilters(),

          Expanded(
            child: FutureBuilder<AnalysisHistoryResponse>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return _buildError();
                }

                final history = snapshot.data;

                if (history == null ||
                    history.items.isEmpty) {
                  return _buildEmpty();
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.items.length,
                    itemBuilder: (context, index) {
                      final analysis =
                          history.items[index];

                      return _AnalysisHistoryCard(
                        analysis: analysis,
                        riskColor:
                            _riskColor(analysis.risk),
                        riskIcon:
                            _riskIcon(analysis.risk),
                        category:
                            _formatCategory(
                          analysis.category,
                        ),
                        date:
                            _formatDate(
                          analysis.createdAt,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: _selectedRisk == null,
            onSelected: (_) {
              setState(() {
                _selectedRisk = null;
                _loadHistory();
              });
            },
          ),
          ChoiceChip(
            label: const Text('High'),
            selected: _selectedRisk == 'HIGH',
            onSelected: (_) {
              setState(() {
                _selectedRisk = 'HIGH';
                _loadHistory();
              });
            },
          ),
          ChoiceChip(
            label: const Text('Medium'),
            selected: _selectedRisk == 'MEDIUM',
            onSelected: (_) {
              setState(() {
                _selectedRisk = 'MEDIUM';
                _loadHistory();
              });
            },
          ),
          ChoiceChip(
            label: const Text('Low'),
            selected: _selectedRisk == 'LOW',
            onSelected: (_) {
              setState(() {
                _selectedRisk = 'LOW';
                _loadHistory();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'No analyses found',
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load analysis history',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadHistory();
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisHistoryCard extends StatelessWidget {
  final MessageAnalysis analysis;
  final Color riskColor;
  final IconData riskIcon;
  final String category;
  final String date;

  const _AnalysisHistoryCard({
    required this.analysis,
    required this.riskColor,
    required this.riskIcon,
    required this.category,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final confidencePercent =
        (analysis.confidence * 100)
            .toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  riskIcon,
                  color: riskColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${analysis.risk} RISK',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: riskColor,
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  date,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              analysis.safeMessage,
              maxLines: 3,
              overflow:
                  TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(category),
                ),
                Chip(
                  label: Text(
                    '$confidencePercent% confidence',
                  ),
                ),
                Chip(
                  label: Text(
                    'Score ${analysis.riskScore}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}