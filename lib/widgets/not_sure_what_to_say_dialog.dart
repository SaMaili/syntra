import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import 'syntra_button.dart';

class NotSureWhatToSayDialog extends StatelessWidget {
  final List<String> hints;

  const NotSureWhatToSayDialog({super.key, required this.hints});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(
            l10n.lostForWords,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: hints
            .map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(h, style: const TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
      actions: [
        SyntraButton.small(
          onPressed: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.okayButton),
          ),
        ),
      ],
    );
  }
}
