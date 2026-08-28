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
    final rawItems = json['items'];

    return AnalysisHistoryResponse(
      total: _asInt(json['total']),
      skip: _asInt(json['skip']),
      limit: _asInt(json['limit']),
      returned: _asInt(json['returned']),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => MessageAnalysis.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }
}


int _asInt(dynamic value) {
  if (value is int) return value;

  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}