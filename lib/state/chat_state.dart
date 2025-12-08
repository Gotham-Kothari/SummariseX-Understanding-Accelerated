// lib/state/chat_state.dart

import 'dart:io';
import '../models/message.dart';

/// Holds all chat-related app state.
/// This file has NO logic — only variables.
class ChatState {
  /// Full chat history
  final List<ChatMessage> messages;

  /// Current input text (for text or URL)
  final String currentInput;

  /// Selected PDF file (if any)
  final File? selectedPdf;

  /// Summary options
  final String length; // "short" | "medium" | "long"
  final String tone; // "neutral" | "formal" | "casual"

  /// Whether the bot is currently summarizing
  final bool isLoading;

  ChatState({
    required this.messages,
    required this.currentInput,
    required this.selectedPdf,
    required this.length,
    required this.tone,
    required this.isLoading,
  });

  /// Creates the default initial state.
  factory ChatState.initial() {
    return ChatState(
      messages: [],
      currentInput: '',
      selectedPdf: null,
      length: 'short',
      tone: 'neutral',
      isLoading: false,
    );
  }

  /// Creates a copy with changed fields.
  ChatState copyWith({
    List<ChatMessage>? messages,
    String? currentInput,
    File? selectedPdf,
    String? length,
    String? tone,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      currentInput: currentInput ?? this.currentInput,
      selectedPdf: selectedPdf ?? this.selectedPdf,
      length: length ?? this.length,
      tone: tone ?? this.tone,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
