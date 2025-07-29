import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class NotSureWhatToSayDialog extends StatelessWidget {
  final String text;

  const NotSureWhatToSayDialog({super.key, required this.text});

  String _formatText(String text) {
    return text.replaceAll('|', '\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final formattedText = _formatText(text);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: _buildTitle(l10n),
      content: _buildContent(formattedText),
      actions: [_buildAction(context, l10n)],
    );
  }

  Widget _buildTitle(S l10n) {
    return Row(
      children: [
        const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
        const SizedBox(width: 8),
        Text(
          l10n.lostForWords,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildContent(String formattedText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(formattedText, style: const TextStyle(fontSize: 18))],
    );
  }

  Widget _buildAction(BuildContext context, S l10n) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(
        l10n.okayButton,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
