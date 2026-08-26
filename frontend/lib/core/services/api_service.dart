import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ApiService {
  ApiService._();

  static Future<Map<String, String>> _headers({
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await TokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> get(
    String url, {
    bool authenticated = false,
  }) async {
    return http.get(
      Uri.parse(url),
      headers: await _headers(
        authenticated: authenticated,
      ),
    );
  }

  static Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    return http.post(
      Uri.parse(url),
      headers: await _headers(
        authenticated: authenticated,
      ),
      body: jsonEncode(body ?? {}),
    );
  }

  static dynamic decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  static String getErrorMessage(http.Response response) {
    try {
      final data = decodeResponse(response);

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail is String) {
          return detail;
        }

        if (detail != null) {
          return detail.toString();
        }

        final message = data['message'];

        if (message is String) {
          return message;
        }
      }
    } catch (_) {
      // Fall back to generic message below.
    }

    return 'Request failed (${response.statusCode})';
  }
}