// lib/widgets/summary_cards/keypoints_card.dart

import 'package:flutter/material.dart';
import 'short_summary_card.dart';

class KeypointsCard extends StatelessWidget {
  final List<String> points;

  const KeypointsCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Key Points',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points.map((p) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• '),
              Expanded(
                child: Text(p, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
