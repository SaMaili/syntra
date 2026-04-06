import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../theme/app_spacing.dart';

class SurveyWidget extends StatefulWidget {
  final bool isAborted;
  const SurveyWidget({super.key, required this.isAborted});

  @override
  State<SurveyWidget> createState() => SurveyWidgetState();
}

class SurveyWidgetState extends State<SurveyWidget> {
  int _feeling = 2;
  int _perceived = 2;
  bool _submitted = false;
  final TextEditingController _notesController = TextEditingController();

  // Semantic sentiment scale — intentionally not theme colors.
  static const _smileys = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];
  static const _smileyColors = [
    Colors.red, Colors.orange, Colors.amber, Colors.lightGreen, Colors.green,
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    if (_submitted) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Text(
          l.thankYouFeedback,
          style: tt.bodyLarge?.copyWith(color: cs.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.howDidYouFeel,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => IconButton(
            icon: Icon(
              _smileys[i],
              color: _feeling == i ? _smileyColors[i] : cs.outlineVariant,
              size: 36,
            ),
            onPressed: () => setState(() => _feeling = i),
          )),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l.howPerceivedQuestion,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => IconButton(
            icon: Icon(
              _smileys[i],
              color: _perceived == i ? _smileyColors[i] : cs.outlineVariant,
              size: 36,
            ),
            onPressed: () => setState(() => _perceived = i),
          )),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l.notes,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: widget.isAborted
                ? l.failureNotesHint
                : l.notesPlaceholder,
          ),
        ),
      ],
    );
  }

  bool get submitted => _submitted;
  int get feeling => _feeling;
  int get perceived => _perceived;
  String get notes => _notesController.text;
  void submit() => setState(() => _submitted = true);
}
