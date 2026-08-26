import 'message_analysis.dart';

class AnalysisHistoryResponse {
  final int total;
  final int skip;
  final int limit;
  final int returned;
  final List<MessageAnalysis> items;

  const AnalysisHistoryResponse({
    required this.total,
    required this.skip,
    required this.limit,
    required this.returned,
    required this.items,
  });

  factory AnalysisHistoryResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AnalysisHistoryResponse(
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
      returned: json['returned'] as int,
      items: (json['items'] as List)
          .map(
            (item) => MessageAnalysis.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}