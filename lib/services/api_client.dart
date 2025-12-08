// lib/services/api_client.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
// import '../models/summary_request.dart';
import '../models/summary_response.dart';

class SummaryRequest {
  final String inputType;
  final String? content;
  final String length;
  final String tone;

  const SummaryRequest({
    required this.inputType,
    required this.content,
    required this.length,
    required this.tone,
  });

  Map<String, dynamic> toJson() {
    return {
      'input_type': inputType,
      'content': content,
      'length': length,
      'tone': tone,
    };
  }
}

/// Thrown when the HTTP call fails or the response cannot be parsed.
class ApiException implements IOException {
  final String message;
  final int? statusCode;
  final String? body;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message, body: $body)';
}

/// Client that talks to the SummariseX FastAPI backend.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  /// Summarise raw text.
  ///
  /// Maps to JSON request:
  /// {
  ///   "input_type": "text",
  ///   "content": "<text>",
  ///   "length": "short" | "medium" | "long",
  ///   "tone": "neutral" | "formal" | "casual"
  /// }
  Future<SummaryResponse> summariseText(
    String text, {
    String length = 'short',
    String tone = 'neutral',
  }) {
    final request = SummaryRequest(
      inputType: 'text',
      content: text,
      length: length,
      tone: tone,
    );
    return _postJson(request);
  }

  /// Summarise content from a URL.
  ///
  /// JSON body:
  /// {
  ///   "input_type": "url",
  ///   "content": "<url>",
  ///   "length": "...",
  ///   "tone": "..."
  /// }
  Future<SummaryResponse> summariseUrl(
    String url, {
    String length = 'short',
    String tone = 'neutral',
  }) {
    final request = SummaryRequest(
      inputType: 'url',
      content: url,
      length: length,
      tone: tone,
    );
    return _postJson(request);
  }

  /// Summarise a PDF document.
  ///
  /// Uses multipart/form-data with fields:
  /// - input_type = "pdf"
  /// - length
  /// - tone
  /// - file = PDF binary
  Future<SummaryResponse> summarisePdf(
    File pdfFile, {
    String length = 'short',
    String tone = 'neutral',
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.summarisePath}');

    final request = http.MultipartRequest('POST', uri)
      ..fields['input_type'] = 'pdf'
      ..fields['length'] = length
      ..fields['tone'] = tone
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          pdfFile.path,
          // contentType is optional; backend will treat as file upload.
        ),
      );

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request);
    } on SocketException catch (e) {
      throw ApiException('Network error: $e');
    }

    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Internal helper for JSON POST (text + url).
  Future<SummaryResponse> _postJson(SummaryRequest body) async {
    final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.summarisePath}');
    final jsonBody = jsonEncode(body.toJson());

    http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );
    } on SocketException catch (e) {
      throw ApiException('Network error: $e');
    }

    return _handleResponse(response);
  }

  /// Parses HTTP response into SummaryResponse or throws ApiException.
  SummaryResponse _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body;

    // Non-2xx: backend likely returned an error message
    if (status < 200 || status >= 300) {
      // Try to parse backend error into SummaryResponse (if it follows the same schema)
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final parsed = SummaryResponse.fromJson(decoded);
          // If backend filled the `error` field, surface that
          if (parsed.error != null) {
            return parsed;
          }
        }
      } catch (_) {
        // fall through to generic exception
      }
      throw ApiException(
        'Request failed with status $status',
        statusCode: status,
        body: body,
      );
    }

    if (body.isEmpty) {
      throw ApiException('Empty response body from server', statusCode: status);
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return SummaryResponse.fromJson(decoded);
      } else {
        throw ApiException(
          'Unexpected response format (not a JSON object)',
          statusCode: status,
          body: body,
        );
      }
    } catch (e) {
      throw ApiException(
        'Failed to parse response JSON: $e',
        statusCode: status,
        body: body,
      );
    }
  }

  void close() {
    _client.close();
  }
}
