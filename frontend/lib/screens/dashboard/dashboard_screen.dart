import 'package:flutter/material.dart';

import '../../core/services/analysis_service.dart';
import '../../models/message_analysis.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<MessageAnalysis>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  // ==========================================
  // Load dashboard data
  // ==========================================

  Future<List<MessageAnalysis>> _loadDashboard() async {
    final response =
        await AnalysisService.getHistory(
      limit: 100,
    );

    return response.items;
  }

  // ==========================================
  // Refresh dashboard
  // ==========================================

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });

    await _dashboardFuture;
  }

  // ==========================================
  // Count risk level
  // ==========================================

  int _countRisk(
    List<MessageAnalysis> analyses,
    String risk,
  ) {
    return analyses
        .where(
          (analysis) =>
              analysis.risk.toUpperCase() ==
              risk.toUpperCase(),
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MessageAnalysis>>(
        future: _dashboardFuture,
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
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Could not load dashboard',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      snapshot.error
                          .toString()
                          .replaceFirst(
                            'Exception: ',
                            '',
                          ),
                      textAlign:
                          TextAlign.center,
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label:
                          const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final analyses =
              snapshot.data ?? [];

          final high =
              _countRisk(analyses, 'HIGH');

          final medium =
              _countRisk(analyses, 'MEDIUM');

          final low =
              _countRisk(analyses, 'LOW');

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(16),
              children: [
                // ==========================================
                // Header
                // ==========================================

                Text(
                  'Security Overview',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Your message security activity',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 20),

                // ==========================================
                // Total analyses
                // ==========================================

                _StatCard(
                  icon:
                      Icons.analytics_outlined,
                  label: 'Total Analyses',
                  value:
                      analyses.length.toString(),
                ),

                const SizedBox(height: 12),

                // ==========================================
                // Risk statistics
                // ==========================================

                Row(
                  children: [
                    Expanded(
                      child: _RiskStatCard(
                        label: 'High Risk',
                        value: high.toString(),
                        icon:
                            Icons.dangerous_outlined,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _RiskStatCard(
                        label: 'Medium',
                        value:
                            medium.toString(),
                        icon: Icons
                            .warning_amber_rounded,
                        color:
                            Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _RiskStatCard(
                        label: 'Low Risk',
                        value: low.toString(),
                        icon: Icons
                            .verified_user_outlined,
                        color:
                            Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==========================================
                // Recent activity
                // ==========================================

                Text(
                  'Recent Activity',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),

                if (analyses.isEmpty)
                  const Card(
                    child: Padding(
                      padding:
                          EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No messages analyzed yet.',
                        ),
                      ),
                    ),
                  )
                else
                  ...analyses.take(5).map(
                        (analysis) =>
                            _RecentAnalysisCard(
                          analysis: analysis,
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// Total analyses card
// ==========================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
            ),

            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Risk statistic card
// ==========================================

class _RiskStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _RiskStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                    color: color,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              textAlign:
                  TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Recent analysis card
// ==========================================

class _RecentAnalysisCard extends StatelessWidget {
  final MessageAnalysis analysis;

  const _RecentAnalysisCard({
    required this.analysis,
  });

  Color _riskColor() {
    switch (analysis.risk.toUpperCase()) {
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

  String _formatCategory(
    String category,
  ) {
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
    final color = _riskColor();

    return Card(
      margin:
          const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              color.withValues(alpha: 0.12),
          child: Icon(
            Icons.security_outlined,
            color: color,
          ),
        ),

        title: Text(
          analysis.safeMessage,
          maxLines: 2,
          overflow:
              TextOverflow.ellipsis,
        ),

        subtitle: Padding(
          padding:
              const EdgeInsets.only(top: 4),
          child: Text(
            _formatCategory(
              analysis.category,
            ),
          ),
        ),

        trailing: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              analysis.risk,
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Score ${analysis.riskScore}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}