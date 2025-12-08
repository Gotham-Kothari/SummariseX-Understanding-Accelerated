// lib/widgets/summary_cards/meta_info_card.dart

import 'package:flutter/material.dart';

import '../../models/summary_response.dart';
import 'short_summary_card.dart';

class MetaInfoCard extends StatelessWidget {
  final SummaryMeta meta;

  const MetaInfoCard({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return BaseCard(
      title: 'Details',
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _MetaChip(label: 'Input tokens: ${meta.inputTokens}'),
          _MetaChip(label: 'Output tokens: ${meta.outputTokens}'),
          _MetaChip(label: 'Time: ${meta.processingTimeMs} ms'),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label, style: theme.textTheme.bodySmall),
      visualDensity: VisualDensity.compact,
    );
  }
}
