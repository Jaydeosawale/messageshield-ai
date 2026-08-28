import 'package:flutter/material.dart';

import '../../core/services/analysis_service.dart';
import '../../models/message_analysis.dart';
import '../../widgets/app_logo.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<MessageAnalysis>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  // ============================================================
  // Load dashboard data
  // ============================================================

  Future<List<MessageAnalysis>> _loadDashboard() async {
    final response = await AnalysisService.getHistory(
      limit: 100,
    );

    return response.items;
  }

  // ============================================================
  // Refresh dashboard
  // ============================================================

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });

    await _dashboardFuture;
  }

  // ============================================================
  // Count risk level
  // ============================================================

  int _countRisk(
    List<MessageAnalysis> analyses,
    String risk,
  ) {
    return analyses.where(
      (analysis) {
        return analysis.risk.toUpperCase() ==
            risk.toUpperCase();
      },
    ).length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/messageshield_logo.png',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                children: [
                  const TextSpan(
                    text: 'Message',
                  ),
                  TextSpan(
                    text: 'Shield',
                    style: TextStyle(
                      color: colorScheme.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' AI',
                    style: TextStyle(
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: FutureBuilder<List<MessageAnalysis>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          // ======================================================
          // Loading
          // ======================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ======================================================
          // Error
          // ======================================================

          if (snapshot.hasError) {
            return _DashboardError(
              error: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final analyses = snapshot.data ?? [];

          final high = _countRisk(
            analyses,
            'HIGH',
          );

          final medium = _countRisk(
            analyses,
            'MEDIUM',
          );

          final low = _countRisk(
            analyses,
            'LOW',
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            color: colorScheme.primary,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surface,

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                28,
              ),

              children: [
                // =================================================
                // Hero / Security Overview
                // =================================================

                _DashboardHero(
                  totalAnalyses: analyses.length,
                  highRisk: high,
                ),

                const SizedBox(height: 24),

                // =================================================
                // Section Header
                // =================================================

                _SectionHeader(
                  icon: Icons.dashboard_outlined,
                  title: 'Security Overview',
                  subtitle:
                      'Your message security activity',
                ),

                const SizedBox(height: 14),

                // =================================================
                // Total Analyses
                // =================================================

                _TotalAnalysesCard(
                  value: analyses.length.toString(),
                ),

                const SizedBox(height: 14),

                // =================================================
                // Risk Statistics
                //
                // Responsive layout to prevent RenderFlex overflow
                // =================================================

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 520) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _RiskStatCard(
                                  label: 'High',
                                  value: high.toString(),
                                  icon: Icons.shield_outlined,
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RiskStatCard(
                                  label: 'Risky',
                                  value: medium.toString(),
                                  icon: Icons.warning_amber_rounded,
                                  color: const Color(
                                    0xFFFFB84D,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: _RiskStatCard(
                              label: 'Safe Messages',
                              value: low.toString(),
                              icon:
                                  Icons.verified_user_outlined,
                              color:
                                  Theme.of(context)
                                      .colorScheme
                                      .secondary,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _RiskStatCard(
                            label: 'High Risk',
                            value: high.toString(),
                            icon: Icons.shield_outlined,
                            color: const Color(
                              0xFFFF6B6B,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _RiskStatCard(
                            label: 'Risky',
                            value: medium.toString(),
                            icon:
                                Icons.warning_amber_rounded,
                            color: const Color(
                              0xFFFFB84D,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _RiskStatCard(
                            label: 'Safe',
                            value: low.toString(),
                            icon:
                                Icons.verified_user_outlined,
                            color:
                                Theme.of(context)
                                    .colorScheme
                                    .secondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                // =================================================
                // Recent Analyses Header
                // =================================================

                Row(
                  children: [
                    Expanded(
                      child: _SectionHeader(
                        icon: Icons.history_rounded,
                        title: 'Recent Analyses',
                        subtitle:
                            'Latest message security checks',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // Empty State
                // =================================================

                if (analyses.isEmpty)
                  _EmptyDashboardState()

                // =================================================
                // Recent Analysis Cards
                // =================================================

                else
                  ...analyses.take(5).map(
                    (analysis) {
                      return _RecentAnalysisCard(
                        analysis: analysis,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// Dashboard Error
// ================================================================

class _DashboardError extends StatelessWidget {
  final String error;
  final Future<void> Function() onRetry;

  const _DashboardError({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 76,
              height: 76,

              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .error
                    .withValues(alpha: 0.12),

                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: Theme.of(context)
                    .colorScheme
                    .error,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Could not load dashboard',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              error.replaceFirst(
                'Exception: ',
                '',
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 180,

              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Try Again',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Dashboard Hero
// ================================================================

class _DashboardHero extends StatelessWidget {
  final int totalAnalyses;
  final int highRisk;

  const _DashboardHero({
    required this.totalAnalyses,
    required this.highRisk,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final isSecure = highRisk == 0;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF102633),
            colorScheme.primary.withValues(
              alpha: 0.18,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: 0.28,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const AppLogo(
                size: 58,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Message Security',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.w700,
                          ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isSecure
                          ? 'Your recent activity looks secure'
                          : 'Some messages need attention',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(18),
            ),

            child: Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    value: totalAnalyses.toString(),
                    label: 'Messages checked',
                  ),
                ),

                Container(
                  width: 1,
                  height: 38,
                  color: Colors.white.withValues(
                    alpha: 0.12,
                  ),
                ),

                Expanded(
                  child: _HeroMetric(
                    value: highRisk.toString(),
                    label: 'Need attention',
                    valueColor: highRisk > 0
                        ? const Color(0xFFFF6B6B)
                        : colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Hero Metric
// ================================================================

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _HeroMetric({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
        ),
      ],
    );
  }
}

// ================================================================
// Section Header
// ================================================================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.12),

            borderRadius:
                BorderRadius.circular(14),
          ),

          child: Icon(
            icon,
            color:
                Theme.of(context)
                    .colorScheme
                    .primary,
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
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// Total Analyses Card
// ================================================================

class _TotalAnalysesCard extends StatelessWidget {
  final String value;

  const _TotalAnalysesCard({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: 0.18,
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(18),
            ),

            child: Icon(
              Icons.analytics_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Total Analyses',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Messages checked for threats',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ),

          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Risk Statistic Card
// ================================================================

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
    return Container(
      constraints: const BoxConstraints(
        minHeight: 142,
      ),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Empty Dashboard State
// ================================================================

class _EmptyDashboardState extends StatelessWidget {
  const _EmptyDashboardState();

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),

      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: 0.18,
          ),
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: 0.12,
              ),

              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.shield_outlined,
              size: 34,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'No analyses yet',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            'Analyze a message to start building your security activity.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Recent Analysis Card
// ================================================================

class _RecentAnalysisCard extends StatelessWidget {
  final MessageAnalysis analysis;

  const _RecentAnalysisCard({
    required this.analysis,
  });

  Color _riskColor(BuildContext context) {
    switch (analysis.risk.toUpperCase()) {
      case 'HIGH':
      case 'UNSAFE':
        return const Color(0xFFFF6B6B);

      case 'MEDIUM':
      case 'RISKY':
        return const Color(0xFFFFB84D);

      case 'LOW':
      case 'SAFE':
        return Theme.of(context)
            .colorScheme
            .secondary;

      default:
        return Theme.of(context)
            .colorScheme
            .primary;
    }
  }

  IconData _riskIcon() {
    switch (analysis.risk.toUpperCase()) {
      case 'HIGH':
      case 'UNSAFE':
        return Icons.warning_rounded;

      case 'MEDIUM':
      case 'RISKY':
        return Icons.warning_amber_rounded;

      case 'LOW':
      case 'SAFE':
        return Icons.verified_rounded;

      default:
        return Icons.shield_outlined;
    }
  }

  String _formatCategory(
    String category,
  ) {
    return category
        .toLowerCase()
        .replaceAll('-', '_')
        .split('_')
        .map(
      (word) {
        if (word.isEmpty) {
          return word;
        }

        return '${word[0].toUpperCase()}'
            '${word.substring(1)}';
      },
    ).join(' ');
  }

  String _shortMessage(String message) {
    final normalized = message.trim();

    if (normalized.isEmpty) {
      return 'Message analysis';
    }

    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(context);
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: color.withValues(
            alpha: 0.18,
          ),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.12,
                ),

                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: Icon(
                _riskIcon(),
                color: color,
                size: 23,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    _shortMessage(
                      analysis.safeMessage,
                    ),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _formatCategory(
                      analysis.category,
                    ),

                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,

                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,

              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.12,
                    ),

                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Text(
                    analysis.risk.toUpperCase(),

                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Score ${analysis.riskScore}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}