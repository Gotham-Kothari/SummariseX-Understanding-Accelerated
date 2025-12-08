// lib/widgets/summary_cards/short_summary_card.dart

import 'package:flutter/material.dart';

class ShortSummaryCard extends StatelessWidget {
  final String summary;

  const ShortSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Quick Summary',
      child: Text(summary, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

/// Public BaseCard used by all summary card widgets.
/// (Was previously _BaseCard, which made it file-private)
class BaseCard extends StatelessWidget {
  final String title;
  final Widget child;

  const BaseCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }
}
