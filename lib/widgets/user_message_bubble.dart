// lib/widgets/user_message_bubble.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/message.dart';

class UserMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const UserMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onPrimary;

    Widget content;

    switch (message.type) {
      case MessageContentType.text:
      case MessageContentType.url:
        content = Text(
          message.content ?? '',
          style: TextStyle(color: textColor),
        );
        break;
      case MessageContentType.pdf:
        final file = message.file;
        final fileName = file != null
            ? file.path.split(Platform.pathSeparator).last
            : 'PDF file';
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                fileName,
                style: TextStyle(color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
        break;
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: content,
      ),
    );
  }
}
