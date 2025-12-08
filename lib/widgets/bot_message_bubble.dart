// lib/widgets/bot_message_bubble.dart

import 'package:flutter/material.dart';

import '../models/message.dart';
import '../models/summary_response.dart';
import 'summary_cards/short_summary_card.dart';
import 'summary_cards/long_summary_card.dart';
import 'summary_cards/keypoints_card.dart';
import 'summary_cards/meta_info_card.dart';

class BotMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const BotMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final SummaryResponse? response = message.response;

    if (response == null) {
      return const SizedBox.shrink();
    }

    final error = response.error;

    Widget child;

    if (error != null) {
      child = Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${error.code}: ${error.message}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
            ),
          ],
        ),
      );
    } else {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (response.summaryShort != null &&
              response.summaryShort!.trim().isNotEmpty)
            ShortSummaryCard(summary: response.summaryShort!),
          if (response.summaryLong != null &&
              response.summaryLong!.trim().isNotEmpty)
            LongSummaryCard(summary: response.summaryLong!),
          if (response.keyPoints != null && response.keyPoints!.isNotEmpty)
            KeypointsCard(points: response.keyPoints!),
          if (response.meta != null) MetaInfoCard(meta: response.meta!),
        ],
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
