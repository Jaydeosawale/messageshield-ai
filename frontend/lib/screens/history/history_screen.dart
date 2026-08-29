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
        return const Color(0xFFFF647C);

      case 'MEDIUM':
        return const Color(0xFFFFB547);

      case 'LOW':
        return const Color(0xFF67E8C8);

      default:
        return const Color(0xFF8FA3BF);
    }
  }

  IconData _riskIcon(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH':
        return Icons.gpp_bad_rounded;

      case 'MEDIUM':
        return Icons.shield_outlined;

      case 'LOW':
        return Icons.verified_user_outlined;

      default:
        return Icons.shield_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(localDate.day)}/'
        '${twoDigits(localDate.month)}/'
        '${localDate.year}'
        ' • '
        '${twoDigits(localDate.hour)}:'
        '${twoDigits(localDate.minute)}';
  }

  String _formatCategory(String category) {
    if (category.trim().isEmpty) {
      return 'Unknown';
    }

    return category
        .replaceAll('-', '_')
        .toLowerCase()
        .split('_')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061721),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: _HistoryBackground(),
            ),
          ),

          SafeArea(
            child: FutureBuilder<List<MessageAnalysis>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
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

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF67E8C8),
                  backgroundColor: const Color(0xFF102632),
                  child: analyses.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: const [
                            SizedBox(height: 100),
                            _EmptyState(),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final horizontalPadding =
                                constraints.maxWidth >= 900
                                    ? 40.0
                                    : 20.0;

                            return ListView.separated(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                38,
                                horizontalPadding,
                                40,
                              ),
                              itemCount: analyses.length + 1,
                              separatorBuilder: (_, index) {
                                if (index == 0) {
                                  return const SizedBox(
                                    height: 30,
                                  );
                                }

                                return const SizedBox(
                                  height: 14,
                                );
                              },
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return const _HistoryHeader();
                                }

                                final analysis =
                                    analyses[index - 1];

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
                                  formattedCategory:
                                      _formatCategory(
                                    analysis.category,
                                  ),
                                );
                              },
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
}


// ==========================================================
// HISTORY HEADER
// ==========================================================

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis History',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: Color(0xFFF1F5F9),
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Your recent message safety checks',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9BAEC2),
          ),
        ),
      ],
    );
  }
}


// ==========================================================
// HISTORY CARD
// ==========================================================

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

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1F5963),
              width: 1,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF102C36),
                Color(0xFF0B202A),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.10,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              22,
              22,
              18,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact =
                    constraints.maxWidth < 650;

                if (isCompact) {
                  return _buildMobileCard(
                    context,
                    confidencePercent,
                  );
                }

                return _buildDesktopCard(
                  context,
                  confidencePercent,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCard(
    BuildContext context,
    String confidencePercent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RiskIconBox(
          riskColor: riskColor,
          riskIcon: riskIcon,
        ),

        const SizedBox(width: 26),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RiskBadge(
                    risk: analysis.risk,
                    riskColor: riskColor,
                  ),

                  const Spacer(),

                  Icon(
                    Icons.chevron_right_rounded,
                    size: 34,
                    color: riskColor.withValues(
                      alpha: 0.90,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                analysis.safeMessage.isEmpty
                    ? 'Message analysis'
                    : analysis.safeMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE6EDF5),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _InfoChip(
                    icon: Icons.account_tree_outlined,
                    label: formattedCategory,
                  ),

                  _InfoChip(
                    icon: Icons.speed_outlined,
                    label:
                        'Score ${analysis.riskScore}',
                  ),

                  _InfoChip(
                    icon: Icons.analytics_outlined,
                    label: '$confidencePercent%',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFF21444D),
              ),

              const SizedBox(height: 13),

              _DateRow(
                formattedDate: formattedDate,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCard(
    BuildContext context,
    String confidencePercent,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _RiskIconBox(
              riskColor: riskColor,
              riskIcon: riskIcon,
              size: 58,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: _RiskBadge(
                risk: analysis.risk,
                riskColor: riskColor,
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 30,
              color: riskColor,
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          analysis.safeMessage.isEmpty
              ? 'Message analysis'
              : analysis.safeMessage,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE6EDF5),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.account_tree_outlined,
              label: formattedCategory,
            ),

            _InfoChip(
              icon: Icons.speed_outlined,
              label:
                  'Score ${analysis.riskScore}',
            ),

            _InfoChip(
              icon: Icons.analytics_outlined,
              label: '$confidencePercent%',
            ),
          ],
        ),

        const SizedBox(height: 18),

        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFF21444D),
        ),

        const SizedBox(height: 12),

        _DateRow(
          formattedDate: formattedDate,
        ),
      ],
    );
  }
}


// ==========================================================
// RISK ICON
// ==========================================================

class _RiskIconBox extends StatelessWidget {
  final Color riskColor;
  final IconData riskIcon;
  final double size;

  const _RiskIconBox({
    required this.riskColor,
    required this.riskIcon,
    this.size = 74,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          size * 0.28,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            riskColor.withValues(alpha: 0.16),
            riskColor.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: riskColor.withValues(
            alpha: 0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(
              alpha: 0.06,
            ),
            blurRadius: 20,
          ),
        ],
      ),
      child: Icon(
        riskIcon,
        color: riskColor,
        size: size * 0.42,
      ),
    );
  }
}


// ==========================================================
// RISK BADGE
// ==========================================================

class _RiskBadge extends StatelessWidget {
  final String risk;
  final Color riskColor;

  const _RiskBadge({
    required this.risk,
    required this.riskColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            riskColor.withValues(alpha: 0.22),
            riskColor.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: riskColor.withValues(
            alpha: 0.14,
          ),
        ),
      ),
      child: Text(
        '${risk.toUpperCase()} RISK',
        style: TextStyle(
          color: riskColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}


// ==========================================================
// INFO CHIP
// ==========================================================

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
      constraints: const BoxConstraints(
        minHeight: 42,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF081827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF244353),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFF5BA9F5),
          ),

          const SizedBox(width: 8),

          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC6D3E2),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================================
// DATE ROW
// ==========================================================

class _DateRow extends StatelessWidget {
  final String formattedDate;

  const _DateRow({
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time_outlined,
          size: 18,
          color: Color(0xFF76C9D4),
        ),

        const SizedBox(width: 10),

        Text(
          formattedDate,
          style: const TextStyle(
            color: Color(0xFF9EB2C5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


// ==========================================================
// LOADING
// ==========================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF67E8C8),
            ),
          ),

          SizedBox(height: 20),

          Text(
            'Loading your analysis history...',
            style: TextStyle(
              color: Color(0xFF9BAEC2),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================================
// EMPTY STATE
// ==========================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF67E8C8)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF67E8C8)
                      .withValues(alpha: 0.20),
                ),
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 42,
                color: Color(0xFF67E8C8),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'No analyses yet',
              style: TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your analyzed messages will appear here so you can review their safety results anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9BAEC2),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==========================================================
// ERROR STATE
// ==========================================================

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
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFFF647C)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFFF647C)
                      .withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 40,
                color: Color(0xFFFF647C),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Unable to load history',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF1F5F9),
              ),
            ),

            const SizedBox(height: 12),

            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9BAEC2),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 26),

            ElevatedButton.icon(
              onPressed: () {
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF123842,
                ),
                foregroundColor: const Color(
                  0xFF67E8C8,
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                  side: const BorderSide(
                    color: Color(0xFF28616A),
                  ),
                ),
              ),
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


// ==========================================================
// BACKGROUND DECORATION
// ==========================================================

class _HistoryBackground extends StatelessWidget {
  const _HistoryBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -180,
          right: -120,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D6670)
                  .withValues(alpha: 0.10),
            ),
          ),
        ),

        Positioned(
          right: 40,
          top: 40,
          child: Opacity(
            opacity: 0.18,
            child: CustomPaint(
              size: const Size(180, 150),
              painter: _BackgroundPatternPainter(),
            ),
          ),
        ),
      ],
    );
  }
}


class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF3CC9C5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF3CC9C5)
      ..style = PaintingStyle.fill;

    for (double x = 10; x < size.width; x += 16) {
      for (double y = 50; y < size.height; y += 16) {
        canvas.drawCircle(
          Offset(x, y),
          1.5,
          dotPaint,
        );
      }
    }

    canvas.drawArc(
      Rect.fromLTWH(
        80,
        0,
        120,
        120,
      ),
      2.8,
      2.8,
      false,
      paint,
    );

    canvas.drawCircle(
      const Offset(135, 58),
      28,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}