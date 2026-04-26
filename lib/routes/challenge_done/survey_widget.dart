import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../theme/app_spacing.dart';

class SurveyWidget extends StatefulWidget {
  final bool isAborted;
  final String challengeId;

  const SurveyWidget({
    super.key,
    required this.isAborted,
    required this.challengeId,
  });

  @override
  State<SurveyWidget> createState() => SurveyWidgetState();
}

class SurveyWidgetState extends State<SurveyWidget> {
  int _feeling = 2;
  int _perceived = 2;
  bool _submitted = false;
  late final int _promptIndex;
  final TextEditingController _notesController = TextEditingController();

  static const _kPromptCount = 10;

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
  void initState() {
    super.initState();
    // Deterministic per challenge so the same challenge always shows the same
    // prompt — but different challenges get different prompts.
    _promptIndex = widget.challengeId.hashCode.abs() % _kPromptCount;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _noteHint(S l) {
    if (widget.isAborted) return l.failureNotesHint;
    return [
      l.notePrompt1, l.notePrompt2, l.notePrompt3, l.notePrompt4,
      l.notePrompt5, l.notePrompt6, l.notePrompt7, l.notePrompt8,
      l.notePrompt9, l.notePrompt10,
    ][_promptIndex];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);
    final scaleLabel = tt.labelSmall?.copyWith(color: cs.outline);

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.feelingScaleLow, style: scaleLabel),
              Text(l.feelingScaleHigh, style: scaleLabel),
            ],
          ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.perceivedScaleLow, style: scaleLabel),
              Text(l.perceivedScaleHigh, style: scaleLabel),
            ],
          ),
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
            hintText: _noteHint(l),
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
