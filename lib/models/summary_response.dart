class SummaryMeta {
  final int inputTokens;
  final int outputTokens;
  final int processingTimeMs;

  const SummaryMeta({
    required this.inputTokens,
    required this.outputTokens,
    required this.processingTimeMs,
  });

  factory SummaryMeta.fromJson(Map<String, dynamic> json) {
    return SummaryMeta(
      inputTokens: (json['input_tokens'] ?? 0) as int,
      outputTokens: (json['output_tokens'] ?? 0) as int,
      processingTimeMs: (json['processing_time_ms'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input_tokens': inputTokens,
      'output_tokens': outputTokens,
      'processing_time_ms': processingTimeMs,
    };
  }
}

class ErrorInfo {
  final String code;
  final String message;

  const ErrorInfo({required this.code, required this.message});

  factory ErrorInfo.fromJson(Map<String, dynamic> json) {
    return ErrorInfo(
      code: (json['code'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message};
  }
}

class SummaryResponse {
  final String? summaryShort;
  final String? summaryLong;
  final List<String>? keyPoints;
  final SummaryMeta? meta;
  final ErrorInfo? error;

  const SummaryResponse({
    this.summaryShort,
    this.summaryLong,
    this.keyPoints,
    this.meta,
    this.error,
  });

  bool get hasError => error != null;

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      summaryShort: json['summary_short'] as String?,
      summaryLong: json['summary_long'] as String?,
      keyPoints: (json['key_points'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      meta: json['meta'] != null
          ? SummaryMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? ErrorInfo.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary_short': summaryShort,
      'summary_long': summaryLong,
      'key_points': keyPoints,
      'meta': meta?.toJson(),
      'error': error?.toJson(),
    };
  }
}
