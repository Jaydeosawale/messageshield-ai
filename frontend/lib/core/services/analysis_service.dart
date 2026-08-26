import '../../models/analysis_history_response.dart';
import '../../models/message_analysis.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AnalysisService {
  AnalysisService._();

  // ==========================================
  // Analyze message
  // ==========================================

  static Future<MessageAnalysis> analyze({
    required String message,
  }) async {
    final response = await ApiService.post(
      ApiConstants.analyze,
      authenticated: true,
      body: {
        'message': message,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        ApiService.getErrorMessage(response),
      );
    }

    final data =
        ApiService.decodeResponse(response)
            as Map<String, dynamic>;

    return MessageAnalysis.fromJson(data);
  }

  // ==========================================
  // Get analysis history
  // ==========================================

  static Future<AnalysisHistoryResponse> getHistory({
    int skip = 0,
    int limit = 20,
    String? category,
    String? risk,
  }) async {
    final queryParameters = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (category != null && category.isNotEmpty) {
      queryParameters['category'] = category;
    }

    if (risk != null && risk.isNotEmpty) {
      queryParameters['risk'] = risk;
    }

    final uri = Uri.parse(
      ApiConstants.analyses,
    ).replace(
      queryParameters: queryParameters,
    );

    final response = await ApiService.get(
      uri.toString(),
      authenticated: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        ApiService.getErrorMessage(response),
      );
    }

    final data =
        ApiService.decodeResponse(response)
            as Map<String, dynamic>;

    return AnalysisHistoryResponse.fromJson(data);
  }

  // ==========================================
  // Get one analysis
  // ==========================================

  static Future<MessageAnalysis> getById(
    int analysisId,
  ) async {
    final response = await ApiService.get(
      '${ApiConstants.analyses}/$analysisId',
      authenticated: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        ApiService.getErrorMessage(response),
      );
    }

    final data =
        ApiService.decodeResponse(response)
            as Map<String, dynamic>;

    return MessageAnalysis.fromJson(data);
  }
}