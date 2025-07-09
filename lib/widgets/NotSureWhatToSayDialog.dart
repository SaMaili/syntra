import 'package:flutter/material.dart';

class NotSureWhatToSayDialog extends StatelessWidget {
  final String text;

  const NotSureWhatToSayDialog({super.key, required this.text});

  String _formatText(String text) {
    return text.replaceAll('|', '\n');
  }

  @override
  Widget build(BuildContext context) {
    final formattedText = _formatText(text);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: _buildTitle(),
      content: _buildContent(formattedText),
      actions: [_buildAction(context)],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: const [
        Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
        SizedBox(width: 8),
        Text(
          'Lost for words?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildAction(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Okay', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
