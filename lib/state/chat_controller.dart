// lib/state/chat_controller.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/api_client.dart';
import '../models/message.dart';
import '../models/summary_response.dart';
import 'chat_state.dart';

/// The controller manages:
/// - Adding messages
/// - Calling backend (ApiClient)
/// - Updating state
///
/// It uses ChangeNotifier so the UI updates automatically.
class ChatController extends ChangeNotifier {
  ChatState _state = ChatState.initial();
  final ApiClient _apiClient = ApiClient();
  final _uuid = const Uuid();

  ChatState get state => _state;

  // -------------------------
  // Basic State Mutations
  // -------------------------

  void updateInput(String text) {
    _state = _state.copyWith(currentInput: text);
    notifyListeners();
  }

  void updateLength(String length) {
    _state = _state.copyWith(length: length);
    notifyListeners();
  }

  void updateTone(String tone) {
    _state = _state.copyWith(tone: tone);
    notifyListeners();
  }

  void attachPdf(File pdf) {
    _state = _state.copyWith(selectedPdf: pdf);
    notifyListeners();
  }

  void clearPdf() {
    _state = _state.copyWith(selectedPdf: null);
    notifyListeners();
  }

  // -------------------------
  // MAIN SEND HANDLERS
  // -------------------------

  Future<void> sendTextOrUrl() async {
    final input = _state.currentInput.trim();
    if (input.isEmpty) return;

    // Detect URL
    final bool isUrl =
        input.startsWith('http://') || input.startsWith('https://');

    final MessageContentType type = isUrl
        ? MessageContentType.url
        : MessageContentType.text;

    // Add user message
    final msg = ChatMessage.userText(
      id: _uuid.v4(),
      type: type,
      content: input,
    );

    _addMessage(msg);

    // Clear input
    _state = _state.copyWith(currentInput: '');
    notifyListeners();

    // Call backend
    await _summariseByType(type, content: input);
  }

  Future<void> sendPdf() async {
    final pdf = _state.selectedPdf;
    if (pdf == null) return;

    final msg = ChatMessage.userPdf(id: _uuid.v4(), file: pdf);

    _addMessage(msg);

    // Clear the selected PDF
    _state = _state.copyWith(selectedPdf: null);
    notifyListeners();

    // Call backend
    await _summariseByType(MessageContentType.pdf, file: pdf);
  }

  // -------------------------
  // INTERNAL: Summarisation logic
  // -------------------------

  Future<void> _summariseByType(
    MessageContentType type, {
    String? content,
    File? file,
  }) async {
    _setLoading(true);

    SummaryResponse response;

    try {
      switch (type) {
        case MessageContentType.text:
          response = await _apiClient.summariseText(
            content!,
            length: _state.length,
            tone: _state.tone,
          );
          break;

        case MessageContentType.url:
          response = await _apiClient.summariseUrl(
            content!,
            length: _state.length,
            tone: _state.tone,
          );
          break;

        case MessageContentType.pdf:
          response = await _apiClient.summarisePdf(
            file!,
            length: _state.length,
            tone: _state.tone,
          );
          break;
      }
    } catch (e) {
      // Hard errors like network / parsing issues
      response = SummaryResponse(
        error: ErrorInfo(code: 'CLIENT_ERROR', message: e.toString()),
      );
    }

    // Add bot response
    final botMsg = ChatMessage.botResponse(id: _uuid.v4(), response: response);
    _addMessage(botMsg);

    _setLoading(false);
  }

  // -------------------------
  // Helpers
  // -------------------------

  void _addMessage(ChatMessage message) {
    final updated = List<ChatMessage>.from(_state.messages)..add(message);
    _state = _state.copyWith(messages: updated);
    notifyListeners();
  }

  void _setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }
}
