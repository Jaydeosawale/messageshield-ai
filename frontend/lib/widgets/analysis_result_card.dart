import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../core/theme/app_theme.dart';
import '../models/message_analysis.dart';

class AnalysisResultCard extends StatelessWidget {
  final MessageAnalysis analysis;
  final bool isPhone;

  /// Controls technical/admin-only information.
  final bool isAdmin;

  const AnalysisResultCard({
    super.key,
    required this.analysis,
    required this.isPhone,
    this.isAdmin = false,
  });

  bool get _isHigh => analysis.isHighRisk;

  bool get _isMedium => analysis.isMediumRisk;

  Color get _riskColor {
    if (_isHigh) return AppColors.danger;

    if (_isMedium) {
      return const Color(0xFFFFA94D);
    }

    return AppColors.green;
  }

  String _riskTitle(AppLocalizations l10n) {
    if (_isHigh) return l10n.riskHigh;

    if (_isMedium) return l10n.riskMedium;

    return l10n.riskLow;
  }

  IconData get _riskIcon {
    if (_isHigh) {
      return Icons.warning_amber_rounded;
    }

    if (_isMedium) {
      return Icons.info_outline_rounded;
    }

    return Icons.verified_rounded;
  }

  String _alert(AppLocalizations l10n) {
    if (_isHigh) {
      return l10n.highRiskAlert;
    }

    if (_isMedium) {
      return l10n.mediumRiskAlert;
    }

    return l10n.lowRiskAlert;
  }

  List<String> _actions(AppLocalizations l10n) {
    if (_isHigh) {
      return [
        l10n.doNotClickSuspiciousLinks,
        l10n.doNotShareSensitiveCodes,
        l10n.verifyOrganisationOfficial,
      ];
    }

    if (_isMedium) {
      return [
        l10n.verifySenderIndependently,
        l10n.avoidMessageLinks,
        l10n.doNotShareSensitiveInformation,
      ];
    }

    return [
      l10n.stayCautiousUnexpectedRequests,
      l10n.verifyPaymentAccountRequests,
    ];
  }

  String _humanize(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) => word.length == 1
              ? word.toUpperCase()
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Keeps normal backend messages readable.
  ///
  /// Example:
  /// "Suspicious link detected"
  ///
  /// stays:
  /// "Suspicious link detected"
  String _displaySignalMessage(AnalysisSignal signal, AppLocalizations l10n) {
    final message = signal.displayMessage.trim();

    if (message.isEmpty) {
      return l10n.securityAnalysisCompleted;
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final confidence = analysis.confidencePercent.clamp(0, 100).toDouble();

    final safety = analysis.safety;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isPhone ? 16 : 22,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSoft.withValues(
          alpha: 0.92,
        ),
        borderRadius: BorderRadius.circular(
          isPhone ? 18 : 24,
        ),
        border: Border.all(
          color: _riskColor.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // RISK HEADER
          // ==========================================

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _riskColor.withValues(
                    alpha: 0.16,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _riskIcon,
                  color: _riskColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  _riskTitle(l10n),
                  style: TextStyle(
                    color: _riskColor,
                    fontSize: isPhone ? 18 : 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // Admin-only technical score.
              if (isAdmin && analysis.riskScore > 0)
                Text(
                  '${analysis.riskScore}/100',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ==========================================
          // MESSAGE TYPE
          // ==========================================

          _section(l10n.messageType),

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

          // ==========================================
          // ALERT
          // ==========================================

          _section(l10n.alert),

          const SizedBox(height: 6),

          Text(
            _alert(l10n),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),

          // ==========================================
          // RISK SIGNALS
          // ==========================================

          if (analysis.signals.isNotEmpty) ...[
            const SizedBox(height: 18),
            _section(l10n.whyWeFlaggedThis),
            const SizedBox(height: 8),
            ...analysis.signals.take(5).map(
                  (signal) => _bullet(
                    icon: Icons.warning_amber_rounded,
                    color: _riskColor,
                    text: _displaySignalMessage(signal, l10n),
                  ),
                ),
          ],

          // ==========================================
          // SAFETY CHECK
          // ==========================================

          if (safety != null && safety.label.isNotEmpty) ...[
            const SizedBox(height: 18),
            _section(l10n.safetyCheck),
            const SizedBox(height: 7),
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.tealSoft,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _humanize(safety.label),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ==========================================
          // WHAT USER SHOULD DO
          // ==========================================

          const SizedBox(height: 18),

          _section(l10n.whatYouShouldDo),

          const SizedBox(height: 8),

          ..._actions(l10n).map(
            (action) => _bullet(
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.tealSoft,
              text: action,
            ),
          ),

          // ==========================================
          // NORMAL USER CONFIDENCE
          // ==========================================

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 7),
              Text(
                '${l10n.analysisConfidence}: ${confidence.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // ==========================================
          // ADMIN TECHNICAL DETAILS
          // ==========================================

          if (isAdmin) ...[
            const SizedBox(height: 22),

            Divider(
              color: AppColors.darkBorder.withValues(
                alpha: 0.8,
              ),
            ),

            const SizedBox(height: 16),

            _section(l10n.adminAnalysisDetails),

            const SizedBox(height: 12),

            _adminRow(
              l10n.riskScore,
              '${analysis.riskScore}/100',
            ),

            _adminRow(
              l10n.categoryConfidence,
              '${confidence.toStringAsFixed(2)}%',
            ),

            _adminRow(
              l10n.categoryModel,
              analysis.model.name.isEmpty
                  ? l10n.notAvailable
                  : analysis.model.name,
            ),

            _adminRow(
              l10n.modelVersion,
              analysis.model.version.isEmpty
                  ? l10n.notAvailable
                  : analysis.model.version,
            ),

            if (safety != null) ...[
              const SizedBox(height: 10),
              _adminRow(
                l10n.safetyLabel,
                safety.label.isEmpty ? l10n.notAvailable : safety.label,
              ),
              _adminRow(
                l10n.safetyConfidence,
                '${safety.confidencePercent.clamp(0, 100).toStringAsFixed(2)}%',
              ),
              _adminRow(
                l10n.safetyModel,
                safety.model.name.isEmpty
                    ? l10n.notAvailable
                    : safety.model.name,
              ),
            ],

            // Category probabilities.
            if (analysis.probabilities.isNotEmpty) ...[
              const SizedBox(height: 14),
              _section(l10n.categoryProbabilities),
              const SizedBox(height: 8),
              ...analysis.probabilities.entries.map(
                (entry) {
                  final probability = (entry.value * 100).clamp(0, 100);

                  return _adminRow(
                    _humanize(entry.key),
                    '${probability.toStringAsFixed(2)}%',
                  );
                },
              ),
            ],

            // Safety probabilities.
            if (safety != null && safety.probabilities.isNotEmpty) ...[
              const SizedBox(height: 14),
              _section(l10n.safetyProbabilities),
              const SizedBox(height: 8),
              ...safety.probabilities.entries.map(
                (entry) {
                  final probability = (entry.value * 100).clamp(0, 100);

                  return _adminRow(
                    _humanize(entry.key),
                    '${probability.toStringAsFixed(2)}%',
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SECTION LABEL
  // ==========================================

  Widget _section(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.tealSoft,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }

  // ==========================================
  // BULLET
  // ==========================================

  Widget _bullet({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ADMIN DATA ROW
  // ==========================================

  Widget _adminRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isPhone ? 130 : 170,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
