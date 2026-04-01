import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/syntra_button.dart';

class MindsetScreen extends StatelessWidget {
  const MindsetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, color: cs.primary, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    l.mindsetGrowth,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _MindsetSection(
                color: cs.primary.withValues(alpha: 0.08),
                shadowColor: cs.primary.withValues(alpha: 0.06),
                child: Column(
                  children: [
                    Icon(Icons.psychology_alt, color: cs.primary, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      l.mindsetShapesReality,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              _MindsetSection(
                color: cs.surface,
                shadowColor: cs.primary.withValues(alpha: 0.04),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.rocket_launch, color: cs.primary, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l.growthStartsDecision,
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _MindsetSection(
                color: cs.secondaryContainer.withValues(alpha: 0.5),
                shadowColor: cs.primary.withValues(alpha: 0.03),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: cs.secondary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l.everyDayNewChance,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSecondaryContainer,
                          letterSpacing: 1.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cs.secondary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lightbulb, color: cs.secondary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          l.mindsetTips,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...[
                      l.embraceChallenges,
                      l.focusProgress,
                      l.celebrateSmallWins,
                      l.learnSetbacks,
                      l.stayCurious,
                    ].map((tip) => _TipItem(tip: tip)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _MotivationCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MindsetSection extends StatelessWidget {
  final Color color;
  final Color shadowColor;
  final EdgeInsets padding;
  final Widget child;

  const _MindsetSection({
    required this.color,
    required this.shadowColor,
    this.padding = const EdgeInsets.all(20),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class _TipItem extends StatelessWidget {
  final String tip;
  const _TipItem({required this.tip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: cs.secondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatefulWidget {
  @override
  State<_MotivationCard> createState() => _MotivationCardState();
}

class _MotivationCardState extends State<_MotivationCard> {
  int _index = 0;

  List<String> _quotes(S l) => [
        l.quote1,
        l.quote2,
        l.quote3,
        l.quote4,
        l.quote5,
        l.quote6,
        l.quote7,
        l.quote8,
      ];

  @override
  void initState() {
    super.initState();
    _index = DateTime.now().millisecondsSinceEpoch % 8;
  }

  void _nextQuote() {
    setState(() => _index = (_index + 1) % 8);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final quotes = _quotes(S.of(context));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Icon(Icons.format_quote, color: cs.onPrimaryContainer, size: 32),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                quotes[_index],
                key: ValueKey(_index),
                style: tt.bodyLarge?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            SyntraButton(
              onPressed: _nextQuote,
              child: Text(S.of(context).getNewMotivation),
            ),
          ],
        ),
      ),
    );
  }
}
