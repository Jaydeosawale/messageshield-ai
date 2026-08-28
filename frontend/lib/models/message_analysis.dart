class MessageAnalysis {
  final int id;
  final String safeMessage;

  // Normalized fields used by dashboard/home/history UI.
  final String category;
  final double confidence;
  final String risk;
  final int riskScore;

  // Structured signals.
  final List<AnalysisSignal> signals;

  final Map<String, double> probabilities;
  final ModelInfo model;

  // Safety-layer metadata.
  final SafetyAnalysis? safety;

  final DateTime createdAt;

  const MessageAnalysis({
    required this.id,
    required this.safeMessage,
    required this.category,
    required this.confidence,
    required this.risk,
    required this.riskScore,
    required this.signals,
    required this.probabilities,
    required this.model,
    required this.createdAt,
    this.safety,
  });

  factory MessageAnalysis.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'];
    final rawRisk = json['risk'];

    final categoryMap = _asMap(rawCategory);
    final riskMap = _asMap(rawRisk);

    // ----------------------------------------------------------
    // CATEGORY
    // ----------------------------------------------------------

    final categoryLabel = categoryMap != null
        ? _asString(
            categoryMap['label'] ??
                categoryMap['category'] ??
                categoryMap['name'],
          )
        : _asString(rawCategory);

    final categoryConfidence = categoryMap != null
        ? _asDouble(categoryMap['confidence'])
        : _asDouble(json['confidence']);

    final categoryProbabilities = categoryMap != null
        ? _asDoubleMap(categoryMap['probabilities'])
        : _asDoubleMap(json['probabilities']);

    final categoryModel = categoryMap != null
        ? ModelInfo.fromJson(
            _asMap(categoryMap['model']) ?? const {},
          )
        : ModelInfo.fromJson(
            _asMap(json['model']) ?? const {},
          );

    // ----------------------------------------------------------
    // RISK
    // ----------------------------------------------------------

    final riskLevel = riskMap != null
        ? _asString(
            riskMap['level'] ??
                riskMap['risk'] ??
                riskMap['label'],
          )
        : _asString(rawRisk);

    final normalizedRiskScore = riskMap != null
        ? _asInt(
            riskMap['score'] ??
                riskMap['risk_score'],
          )
        : _asInt(json['risk_score']);

    // ----------------------------------------------------------
    // SIGNALS
    // ----------------------------------------------------------
    //
    // Analyze API:
    // risk: {
    //   signals: [...]
    // }
    //
    // History API:
    // signals: [...]
    //

    final rawSignals = riskMap != null
        ? riskMap['signals']
        : json['signals'];

    final normalizedSignals = _asSignalList(rawSignals);

    // ----------------------------------------------------------
    // SAFETY
    // ----------------------------------------------------------

    final safetyMap = _asMap(json['safety']);

    return MessageAnalysis(
      id: _asInt(json['id']),
      safeMessage: _asString(json['safe_message']),
      category: categoryLabel,
      confidence: categoryConfidence,
      risk: riskLevel,
      riskScore: normalizedRiskScore,
      signals: normalizedSignals,
      probabilities: categoryProbabilities,
      model: categoryModel,
      safety: safetyMap == null
          ? null
          : SafetyAnalysis.fromJson(safetyMap),
      createdAt: _asDateTime(json['created_at']),
    );
  }

  // ==========================================================
  // RISK HELPERS
  // ==========================================================

  bool get isLowRisk =>
      risk.toUpperCase().trim() == 'LOW';

  bool get isMediumRisk =>
      risk.toUpperCase().trim() == 'MEDIUM';

  bool get isHighRisk =>
      risk.toUpperCase().trim() == 'HIGH';

  String get riskLabel {
    switch (risk.toUpperCase().trim()) {
      case 'LOW':
        return 'Safe';

      case 'MEDIUM':
        return 'Risky';

      case 'HIGH':
        return 'Unsafe';

      default:
        return risk;
    }
  }

  double get confidencePercent => confidence * 100;

  // ==========================================================
  // SENSITIVE CONTENT
  // ==========================================================

  bool get isSensitiveCategory {
    final normalized = category.toUpperCase();

    return normalized.contains('OTP') ||
        normalized.contains('SECURITY') ||
        normalized.contains('PASSWORD') ||
        normalized.contains('PIN') ||
        normalized.contains('BANK') ||
        normalized.contains('PAYMENT') ||
        normalized.contains('CARD');
  }

  bool get hasSignals => signals.isNotEmpty;

  bool get hasRiskSignals {
    return signals.any(
      (signal) => signal.isRiskSignal,
    );
  }
}


// ==========================================================
// ANALYSIS SIGNAL
// ==========================================================

class AnalysisSignal {
  final String type;
  final String message;
  final int score;
  final List<String> keywords;

  const AnalysisSignal({
    required this.type,
    required this.message,
    this.score = 0,
    this.keywords = const [],
  });

  factory AnalysisSignal.fromJson(dynamic json) {
    // ----------------------------------------------------------
    // BACKWARD COMPATIBILITY:
    //
    // API may send:
    //
    // "Suspicious link detected"
    //
    // instead of:
    //
    // {
    //   "type": "...",
    //   "message": "..."
    // }
    // ----------------------------------------------------------

    if (json is String) {
      return AnalysisSignal(
        type: 'Security Check',
        message: json,
      );
    }

    final map = _asMap(json);

    if (map == null) {
      return AnalysisSignal(
        type: 'Security Check',
        message: json?.toString() ?? '',
      );
    }

    return AnalysisSignal(
      type: _asString(
        map['type'] ??
            map['Type'] ??
            map['label'] ??
            map['name'],
      ),

      message: _asString(
        map['message'] ??
            map['Message'] ??
            map['description'] ??
            map['detail'],
      ),

      score: _asInt(
        map['score'] ??
            map['Score'] ??
            map['risk_score'],
      ),

      keywords: _asStringList(
        map['keywords'] ??
            map['Keywords'],
      ),
    );
  }

  // ==========================================================
  // UI HELPERS
  // ==========================================================

  String get displayType {
    if (type.trim().isEmpty) {
      return 'Security Check';
    }

    return _humanizeText(type);
  }

  String get displayMessage {
    if (message.trim().isEmpty) {
      return 'Security analysis completed.';
    }

    return message.trim();
  }

  bool get hasKeywords => keywords.isNotEmpty;

  bool get isRiskSignal => score > 0;

  String get keywordsText => keywords.join(', ');
}


// ==========================================================
// SAFETY ANALYSIS
// ==========================================================

class SafetyAnalysis {
  final String label;
  final double confidence;
  final Map<String, double> probabilities;
  final ModelInfo model;

  const SafetyAnalysis({
    required this.label,
    required this.confidence,
    required this.probabilities,
    required this.model,
  });

  factory SafetyAnalysis.fromJson(Map<String, dynamic> json) {
    return SafetyAnalysis(
      label: _asString(
        json['label'] ??
            json['status'],
      ),

      confidence: _asDouble(
        json['confidence'],
      ),

      probabilities: _asDoubleMap(
        json['probabilities'],
      ),

      model: ModelInfo.fromJson(
        _asMap(json['model']) ?? const {},
      ),
    );
  }

  double get confidencePercent => confidence * 100;

  bool get isSafe =>
      label.toUpperCase().trim() == 'SAFE';

  bool get isUnsafe =>
      label.toUpperCase().trim() == 'UNSAFE';

  String get displayLabel {
    if (label.trim().isEmpty) {
      return 'Unknown';
    }

    return _humanizeText(label);
  }
}


// ==========================================================
// MODEL INFO
// ==========================================================

class ModelInfo {
  final String name;
  final String version;

  const ModelInfo({
    required this.name,
    required this.version,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      name: _asString(
        json['name'],
      ),

      version: _asString(
        json['version'],
      ),
    );
  }
}


// ==========================================================
// JSON HELPERS
// ==========================================================

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return null;
}


String _asString(dynamic value) {
  if (value == null) {
    return '';
  }

  return value.toString();
}


int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? '',
      ) ??
      0;
}


double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
        value?.toString() ?? '',
      ) ??
      0.0;
}


Map<String, double> _asDoubleMap(dynamic value) {
  if (value is! Map) {
    return const {};
  }

  return value.map(
    (key, item) => MapEntry(
      key.toString(),
      _asDouble(item),
    ),
  );
}


List<String> _asStringList(dynamic value) {
  if (value == null) {
    return const [];
  }

  // Supports List.
  if (value is List) {
    return value
        .where((item) => item != null)
        .map(
          (item) => item.toString(),
        )
        .toList();
  }

  // Supports one keyword as a String.
  if (value is String && value.trim().isNotEmpty) {
    return [value];
  }

  return const [];
}


// ==========================================================
// SIGNAL LIST PARSER
// ==========================================================

List<AnalysisSignal> _asSignalList(dynamic value) {
  if (value == null) {
    return const [];
  }

  // Normal API format:
  //
  // [
  //   {...},
  //   {...}
  // ]

  if (value is List) {
    return value
        .where((item) => item != null)
        .map(
          (item) => AnalysisSignal.fromJson(item),
        )
        .toList();
  }

  // If backend unexpectedly sends one object.
  final map = _asMap(value);

  if (map != null) {
    return [
      AnalysisSignal.fromJson(map),
    ];
  }

  // If backend sends one string.
  if (value is String &&
      value.trim().isNotEmpty) {
    return [
      AnalysisSignal.fromJson(value),
    ];
  }

  return const [];
}


// ==========================================================
// DATE PARSER
// ==========================================================

DateTime _asDateTime(dynamic value) {
  if (value is DateTime) {
    return value;
  }

  return DateTime.tryParse(
        value?.toString() ?? '',
      ) ??
      DateTime.now();
}


// ==========================================================
// TEXT FORMATTER
// ==========================================================

String _humanizeText(String value) {
  if (value.trim().isEmpty) {
    return '';
  }

  return value
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .split(RegExp(r'\s+'))
      .where(
        (word) => word.isNotEmpty,
      )
      .map(
        (word) {
          // Preserve common acronyms.
          final upper = word.toUpperCase();

          if (upper == 'OTP' ||
              upper == 'SMS' ||
              upper == 'URL' ||
              upper == 'PIN' ||
              upper == 'UPI' ||
              upper == 'AI') {
            return upper;
          }

          return '${word[0].toUpperCase()}'
              '${word.substring(1).toLowerCase()}';
        },
      )
      .join(' ');
}