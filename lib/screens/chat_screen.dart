// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/chat_controller.dart';
import '../state/chat_state.dart';
import '../models/message.dart';
import '../widgets/user_message_bubble.dart';
import '../widgets/bot_message_bubble.dart';
import '../widgets/input_bar.dart';
import '../widgets/options_selector.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, controller, _) {
        final ChatState state = controller.state;
        final messages = state.messages;

        // Auto-scroll whenever messages change
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Scaffold(
          appBar: AppBar(title: const Text('SummariseX')),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    if (msg.isUser) {
                      return UserMessageBubble(message: msg);
                    } else {
                      return BotMessageBubble(message: msg);
                    }
                  },
                ),
              ),
              OptionsSelector(
                length: state.length,
                tone: state.tone,
                onLengthChanged: controller.updateLength,
                onToneChanged: controller.updateTone,
              ),
              if (state.isLoading) const TypingIndicator(),
              InputBar(
                currentInput: state.currentInput,
                onInputChanged: controller.updateInput,
                onSendTextOrUrl: controller.sendTextOrUrl,
                onSendPdf: controller.sendPdf,
                onPdfSelected: controller.attachPdf,
                selectedPdf: state.selectedPdf,
              ),
            ],
          ),
        );
      },
    );
  }
}
