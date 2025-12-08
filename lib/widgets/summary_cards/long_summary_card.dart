// lib/widgets/summary_cards/long_summary_card.dart

import 'package:flutter/material.dart';
import 'short_summary_card.dart';

class LongSummaryCard extends StatelessWidget {
  final String summary;

  const LongSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Detailed Summary',
      child: Text(summary, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
