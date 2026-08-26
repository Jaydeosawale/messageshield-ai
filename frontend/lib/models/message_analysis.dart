class ModelInfo {
  final String name;
  final String version;

  const ModelInfo({
    required this.name,
    required this.version,
  });

  factory ModelInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return ModelInfo(
      name: json['name'] as String,
      version: json['version'] as String,
    );
  }
}


class MessageAnalysis {
  final int id;
  final String safeMessage;
  final String category;
  final double confidence;
  final String risk;
  final int riskScore;
  final List<String> signals;
  final Map<String, double> probabilities;
  final ModelInfo model;
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
  });

  factory MessageAnalysis.fromJson(
    Map<String, dynamic> json,
  ) {
    return MessageAnalysis(
      id: json['id'] as int,
      safeMessage: json['safe_message'] as String,
      category: json['category'] as String,
      confidence:
          (json['confidence'] as num).toDouble(),
      risk: json['risk'] as String,
      riskScore: json['risk_score'] as int,
      signals: List<String>.from(
        json['signals'] as List,
      ),
      probabilities: (
        json['probabilities']
            as Map<String, dynamic>
      ).map(
        (key, value) => MapEntry(
          key,
          (value as num).toDouble(),
        ),
      ),
      model: ModelInfo.fromJson(
        json['model'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }
}