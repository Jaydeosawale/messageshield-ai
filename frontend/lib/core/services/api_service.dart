import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ApiService {
  ApiService._();

  static Future<Map<String, String>> _headers({
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await TokenStorage.getToken();

      // IMPORTANT:
      // Never silently send a protected request without a token.
      if (token == null || token.trim().isEmpty) {
        throw Exception(
          'You are not logged in. Please sign in again.',
        );
      }

      headers['Authorization'] =
          'Bearer ${token.trim()}';

      // Debug only - does NOT print the real token.
      debugPrint(
        'Authenticated request: token found',
      );
    }

    return headers;
  }

  static Future<http.Response> get(
    String url, {
    bool authenticated = false,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(
        authenticated: authenticated,
      ),
    );

    debugPrint(
      'GET $url -> ${response.statusCode}',
    );

    return response;
  }

  static Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(
        authenticated: authenticated,
      ),
      body: jsonEncode(body ?? {}),
    );

    debugPrint(
      'POST $url -> ${response.statusCode}',
    );

    return response;
  }

  static dynamic decodeResponse(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  static String getErrorMessage(
    http.Response response,
  ) {
    try {
      final data = decodeResponse(response);

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail is String &&
            detail.isNotEmpty) {
          return detail;
        }

        if (detail != null) {
          return detail.toString();
        }

        final message = data['message'];

        if (message is String &&
            message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Fall back below.
    }

    return 'Request failed (${response.statusCode})';
  }
}