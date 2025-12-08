// lib/models/message.dart
import 'dart:io';

import 'summary_response.dart';

/// Enumerates the type of content the user sent.
enum MessageContentType { text, url, pdf }

/// Represents a single chat message in the SummariseX UI.
/// For user messages:
///   - [isUser] = true
///   - [content] = text or url (nullable for pdf)
///   - [file] = PDF file for pdf type
///   - [response] = null
///
/// For bot messages:
///   - [isUser] = false
///   - [response] = SummaryResponse from backend
///   - [content] can optionally carry a label like "Summary"
class ChatMessage {
  final String id;
  final bool isUser;
  final MessageContentType type;
  final String? content;
  final File? file;
  final SummaryResponse? response;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.type,
    this.content,
    this.file,
    this.response,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convenience factory for a text or URL user message.
  factory ChatMessage.userText({
    required String id,
    required MessageContentType type,
    required String content,
  }) {
    assert(type == MessageContentType.text || type == MessageContentType.url);
    return ChatMessage(id: id, isUser: true, type: type, content: content);
  }

  /// Convenience factory for a PDF user message.
  factory ChatMessage.userPdf({required String id, required File file}) {
    return ChatMessage(
      id: id,
      isUser: true,
      type: MessageContentType.pdf,
      file: file,
    );
  }

  /// Convenience factory for a bot response message.
  factory ChatMessage.botResponse({
    required String id,
    required SummaryResponse response,
  }) {
    return ChatMessage(
      id: id,
      isUser: false,
      type: MessageContentType.text, // logical type; UI will treat as bot
      response: response,
    );
  }
}
