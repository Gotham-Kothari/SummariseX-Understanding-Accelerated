// lib/widgets/input_bar.dart

import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/file_picker_helper.dart';

class InputBar extends StatefulWidget {
  final String currentInput;
  final ValueChanged<String> onInputChanged;
  final Future<void> Function() onSendTextOrUrl;
  final Future<void> Function() onSendPdf;
  final ValueChanged<File> onPdfSelected;
  final File? selectedPdf;

  const InputBar({
    super.key,
    required this.currentInput,
    required this.onInputChanged,
    required this.onSendTextOrUrl,
    required this.onSendPdf,
    required this.onPdfSelected,
    required this.selectedPdf,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentInput;
  }

  @override
  void didUpdateWidget(covariant InputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentInput != _controller.text) {
      _controller.text = widget.currentInput;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  Future<void> _pickPdf() async {
    final file = await FilePickerHelper.pickPdf();
    if (file != null) {
      widget.onPdfSelected(file);
    }
  }

  Future<void> _handleSend() async {
    if (widget.selectedPdf != null && widget.currentInput.trim().isEmpty) {
      await widget.onSendPdf();
    } else {
      await widget.onSendTextOrUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdf = widget.selectedPdf;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickPdf,
              tooltip: 'Attach PDF',
            ),
            if (pdf != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pdf.path.split(Platform.pathSeparator).last,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  onChanged: widget.onInputChanged,
                  decoration: const InputDecoration(
                    hintText: 'Type text or paste a URL...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _handleSend,
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}
