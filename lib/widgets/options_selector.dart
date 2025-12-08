// lib/widgets/options_selector.dart

import 'package:flutter/material.dart';

class OptionsSelector extends StatelessWidget {
  final String length; // "short" | "medium" | "long"
  final String tone; // "neutral" | "formal" | "casual"
  final ValueChanged<String> onLengthChanged;
  final ValueChanged<String> onToneChanged;

  const OptionsSelector({
    super.key,
    required this.length,
    required this.tone,
    required this.onLengthChanged,
    required this.onToneChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary settings',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildChipRow(
                  context: context,
                  label: 'Length',
                  options: const ['short', 'medium', 'long'],
                  selected: length,
                  onSelected: onLengthChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _buildChipRow(
                  context: context,
                  label: 'Tone',
                  options: const ['neutral', 'formal', 'casual'],
                  selected: tone,
                  onSelected: onToneChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow({
    required BuildContext context,
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$label: ', style: theme.textTheme.bodySmall),
        Expanded(
          child: Wrap(
            spacing: 6,
            children: options.map((opt) {
              final isSelected = opt == selected;
              return ChoiceChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (_) => onSelected(opt),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
