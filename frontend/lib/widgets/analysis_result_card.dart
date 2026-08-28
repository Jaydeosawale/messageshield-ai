import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/message_analysis.dart';

class AnalysisResultCard extends StatelessWidget {
  final MessageAnalysis analysis;
  final bool isPhone;

  const AnalysisResultCard({
    super.key,
    required this.analysis,
    required this.isPhone,
  });

  bool get _isHigh => analysis.isHighRisk;
  bool get _isMedium => analysis.isMediumRisk;

  Color get _riskColor {
    if (_isHigh) return AppColors.danger;
    if (_isMedium) return const Color(0xFFFFA94D);
    return AppColors.green;
  }

  String get _riskTitle => _isHigh
      ? 'HIGH RISK'
      : _isMedium
          ? 'MEDIUM RISK'
          : 'LOW RISK';

  IconData get _riskIcon => _isHigh
      ? Icons.warning_amber_rounded
      : _isMedium
          ? Icons.info_outline_rounded
          : Icons.verified_rounded;

  String get _alert {
    if (_isHigh) {
      return 'This message may be unsafe. Do not click links or share OTPs, passwords, PINs, CVV, or banking details.';
    }
    if (_isMedium) {
      return 'This message contains some indicators that need verification. Confirm the sender through an official channel before acting.';
    }
    return 'No major risk indicators were detected. Still verify unexpected requests before sharing personal information or making payments.';
  }

  List<String> get _actions {
    if (_isHigh) return const [
      'Do not click suspicious links.',
      'Do not share OTPs, passwords, PINs or CVV.',
      'Verify the organisation using an official website or number.',
    ];
    if (_isMedium) return const [
      'Verify the sender independently.',
      'Avoid using links from the message until verified.',
      'Do not share sensitive information.',
    ];
    return const [
      'Stay cautious with unexpected requests.',
      'Verify payment or account requests independently.',
    ];
  }

  String _humanize(String value) {
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word.length == 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final confidence = analysis.confidencePercent.clamp(0, 100);
    final safety = analysis.safety;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPhone ? 16 : 22),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(isPhone ? 18 : 24),
        border: Border.all(color: _riskColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _riskColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_riskIcon, color: _riskColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _riskTitle,
                style: TextStyle(
                  color: _riskColor,
                  fontSize: isPhone ? 18 : 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (analysis.riskScore > 0)
              Text(
                '${analysis.riskScore}/100',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ]),
          const SizedBox(height: 16),
          _section('MESSAGE TYPE'),
          const SizedBox(height: 6),
          Text(
            _humanize(analysis.category),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isPhone ? 17 : 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _section('ALERT'),
          const SizedBox(height: 6),
          Text(_alert, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 14, height: 1.45)),
          if (analysis.signals.isNotEmpty) ...[
            const SizedBox(height: 18),
            _section('WHY WE FLAGGED THIS'),
            const SizedBox(height: 8),
            ...analysis.signals.take(5).map((signal) => _bullet(
              icon: Icons.warning_amber_rounded,
              color: _riskColor,
              text: _humanize(signal.displayMessage),
            )),
          ],
          if (safety != null && safety.label.isNotEmpty) ...[
            const SizedBox(height: 18),
            _section('SAFETY CHECK'),
            const SizedBox(height: 7),
            Row(children: [
              const Icon(Icons.shield_outlined, color: AppColors.tealSoft, size: 19),
              const SizedBox(width: 8),
              Expanded(child: Text(
                _humanize(safety.label),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              )),
            ]),
          ],
          const SizedBox(height: 18),
          _section('WHAT YOU SHOULD DO'),
          const SizedBox(height: 8),
          ..._actions.map((action) => _bullet(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.tealSoft,
            text: action,
          )),
          const SizedBox(height: 18),
          Row(children: [
            const Icon(Icons.analytics_outlined, color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 7),
            Text(
              'Analysis confidence: ${confidence.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(String text) => Text(
    text,
    style: const TextStyle(
      color: AppColors.tealSoft,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    ),
  );

  Widget _bullet({
    required IconData icon,
    required Color color,
    required String text,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 9),
        Expanded(child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.35,
          ),
        )),
      ],
    ),
  );
}
