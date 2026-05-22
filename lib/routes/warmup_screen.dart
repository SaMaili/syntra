// warmup_screen.dart — 1:1 with the Warmup.jsx design.
//
// Flow:
//   Step 1 — pick a vibe (where you're going). Crossfade reveals Step 2.
//   Step 2 — pick a length (5/10/15 min). Auto-builds a 2–4 challenge ladder.
//   VibeWarmupCard — pink-glow card with the ladder, shuffle/swap, start.
//   MyWarmupCard  — saved (bookmarked) challenges in user order; drag to
//                   reorder; remove from list; start.
//   Just-one     — single random challenge as a quick escape hatch.
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../challenge.dart';
import '../generated/l10n.dart';
import '../logic/warmup_logic.dart';
import '../providers/challenge_providers.dart'
    show challengeCatalogProvider, bookmarkedChallengeIdsProvider;
import '../providers/scroll_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart';
import '../providers/warmup_providers.dart';
import '../router.dart';
import '../services/sound_service.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_chip.dart';

class WarmupScreen extends ConsumerStatefulWidget {
  const WarmupScreen({super.key});

  @override
  ConsumerState<WarmupScreen> createState() => _WarmupScreenState();
}

class _WarmupScreenState extends ConsumerState<WarmupScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startChallenge(Challenge c, {WarmupSession? warmup}) async {
    SoundService.playDing(enabled: ref.read(soundEffectsEnabledProvider));
    final result = await context.pushActiveChallenge(c,
        isGuided: true, warmup: warmup);
    if (result != null && mounted) refreshStatistics(ref);
  }

  void _startWarmup(List<Challenge> ladder) {
    if (ladder.isEmpty) return;
    HapticFeedback.mediumImpact();
    // Launch the first rung carrying the whole ladder; the done screen chains
    // automatically into each subsequent challenge.
    _startChallenge(
      ladder.first,
      warmup: WarmupSession(ladder: ladder),
    );
  }

  void _startJustOne() {
    final catalog = ref.read(challengeCatalogProvider).valueOrNull;
    if (catalog == null || catalog.isEmpty) return;
    final pick = catalog[Random().nextInt(catalog.length)];
    _startChallenge(pick);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(dailyScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    // When the vibe/length/seed changes, drop per-slot overrides so the
    // user's "Shuffle set" feels fresh, not pinned to old swaps.
    ref.listen(warmupVibeProvider, (_, _) =>
        ref.read(warmupSlotOverridesProvider.notifier).state = const {});
    ref.listen(warmupLengthProvider, (_, _) =>
        ref.read(warmupSlotOverridesProvider.notifier).state = const {});
    ref.listen(warmupSeedProvider, (_, _) =>
        ref.read(warmupSlotOverridesProvider.notifier).state = const {});

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(
            0,
            AppSpacing.sm,
            0,
            MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScreenTitle(),
              _Step1Question(),
              _VibePicker(),
              _Step2AndCard(),
              SizedBox(height: AppSpacing.sm),
              _MyWarmupCard(),
              SizedBox(height: AppSpacing.sm),
              _JustOneButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Screen title ────────────────────────────────────────────────────────────

class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
      child: Text(
        S.of(context).warmupTitle,
        style: TextStyle(
          fontFamily: 'Octarine',
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.4,
          color: isDark ? Colors.white : cs.onSurface,
        ),
      ),
    );
  }
}

// ─── Step 1 lead-in (eyebrow + question + subtitle) ─────────────────────────

class _Step1Question extends StatelessWidget {
  const _Step1Question();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final titleColor = isDark ? Colors.white : cs.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(
            text: l.warmupStep1Eyebrow,
            color: cs.primary,
          ),
          const SizedBox(height: 6),
          Text(
            l.warmupStep1Question,
            style: TextStyle(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              height: 1.2,
              letterSpacing: -0.3,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.warmupStep1Subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.45,
              color: s.mutedSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vibe chip row (horizontal scroll) + "pick a vibe" hint ─────────────────

class _VibePicker extends ConsumerWidget {
  const _VibePicker();

  static const _vibes = WarmupVibe.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(warmupVibeProvider);
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Don't hard-clip: the active chip's soft glow extends past the
            // 36 px row and would otherwise be sliced into a rectangle.
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: _vibes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final v = _vibes[i];
              return SyntraChip(
                active: selected == v,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(warmupVibeProvider.notifier).state =
                      selected == v ? null : v;
                },
                label: _vibeLabel(l, v),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (selected == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            child: Text(
              l.warmupPickVibeHint,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: s.mutedSubtle,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Step 2 + auto-built warm-up card (only shown when a vibe is picked) ────

class _Step2AndCard extends ConsumerWidget {
  const _Step2AndCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibe = ref.watch(warmupVibeProvider);
    if (vibe == null) return const SizedBox.shrink();
    return const Column(
      children: [
        _Step2LengthRow(),
        _VibeWarmupCard(),
      ],
    );
  }
}

class _Step2LengthRow extends ConsumerWidget {
  const _Step2LengthRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = ref.watch(warmupLengthProvider);
    final l = S.of(context);
    final s = SyntraSurface.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(
            text: l.warmupStep2Eyebrow,
            color: s.mutedSubtle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final opt in WarmupLength.values) ...[
                SyntraChip(
                  active: length == opt,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(warmupLengthProvider.notifier).state = opt;
                  },
                  label: _lengthLabel(l, opt),
                  size: SyntraChipSize.sm,
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _VibeWarmupCard extends ConsumerWidget {
  const _VibeWarmupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vibe = ref.watch(warmupVibeProvider);
    if (vibe == null) return const SizedBox.shrink();
    final setAsync = ref.watch(warmupSetProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final length = ref.watch(warmupLengthProvider);

    return setAsync.when(
      loading: () => const _CardSkeleton(),
      error: (e, _) => _CardError(message: '$e'),
      data: (items) {
        if (items.isEmpty) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: s.bg1,
              border: Border.all(color: s.bg3),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              S.of(context).noChallengesFound,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: s.mutedSubtle,
              ),
            ),
          );
        }

        final totalSec = items.fold<int>(0, (a, b) => a + b.time);
        final totalAura = items.fold<int>(0, (a, b) => a + b.aura);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 360),
          switchInCurve: const Cubic(.16, 1, .3, 1),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey('$vibe·$length'),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.3, -1),
                end: const Alignment(0.4, 1),
                colors: [
                  cs.primary.withValues(alpha: 0.10),
                  isDark ? s.bg0 : s.bg2,
                ],
                stops: const [0.0, 0.6],
              ),
              border: Border.all(color: cs.primary.withValues(alpha: 0.32)),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              children: [
                // Pink glow blob top-right.
                Positioned(
                  top: -50,
                  right: -50,
                  child: IgnorePointer(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            cs.primary.withValues(alpha: 0.28),
                            cs.primary.withValues(alpha: 0),
                          ],
                          stops: const [0.0, 0.7],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _VibeCardHeader(
                        vibeLabel: _vibeLabel(l, vibe),
                        title: l.warmupVibeCardTitle(_vibeLabel(l, vibe)),
                        summary: l.warmupCardSummary(
                          items.length,
                          formatWarmupDuration(totalSec),
                          totalAura,
                        ),
                        onShuffle: () {
                          HapticFeedback.selectionClick();
                          ref.read(warmupSeedProvider.notifier).update(
                              (v) => v + 1);
                        },
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < items.length; i++)
                        _LadderRow(
                          index: i,
                          isLast: i == items.length - 1,
                          challenge: items[i],
                          onSwap: () {
                            HapticFeedback.selectionClick();
                            _swapSlot(ref, i);
                          },
                        ),
                      const SizedBox(height: 14),
                      SyntraButton(
                        onPressed: () => context
                            .findAncestorStateOfType<_WarmupScreenState>()
                            ?._startWarmup(items),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l.warmupStart),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _swapSlot(WidgetRef ref, int index) {
    final vibe = ref.read(warmupVibeProvider);
    if (vibe == null) return;
    final current = ref.read(warmupSetProvider).valueOrNull ?? const [];
    final catalog = ref.read(challengeCatalogProvider).valueOrNull ?? const [];
    final swapped = swapWarmupItem(
      current,
      index,
      vibe,
      catalog,
      seed: DateTime.now().microsecondsSinceEpoch,
    );
    if (identical(swapped, current)) return;
    final overrides =
        Map<int, String>.from(ref.read(warmupSlotOverridesProvider));
    overrides[index] = swapped[index].id;
    ref.read(warmupSlotOverridesProvider.notifier).state = overrides;
  }
}

// ─── Vibe-card sub-pieces ────────────────────────────────────────────────────

class _VibeCardHeader extends StatelessWidget {
  final String vibeLabel;
  final String title;
  final String summary;
  final VoidCallback onShuffle;

  const _VibeCardHeader({
    required this.vibeLabel,
    required this.title,
    required this.summary,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Eyebrow(
                text: l.warmupForVibe(vibeLabel.toLowerCase()),
                color: cs.primary,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Octarine',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  height: 1.15,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  height: 1.4,
                  color: s.mutedSubtle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _CircleIconButton(
          onTap: onShuffle,
          icon: Icons.shuffle_rounded,
          iconColor: BrandColors.pinkSoft,
        ),
      ],
    );
  }
}

class _LadderRow extends StatelessWidget {
  final int index;
  final bool isLast;
  final Challenge challenge;
  final VoidCallback onSwap;

  const _LadderRow({
    required this.index,
    required this.isLast,
    required this.challenge,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final s = SyntraSurface.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : s.bg3,
                ),
              ),
      ),
      child: Row(
        children: [
          _NumberBadge(n: index + 1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.3,
                    color: isDark ? Colors.white : cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'L${challenge.level} · ${formatWarmupDuration(challenge.time)} · +${challenge.aura}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: s.mutedSubtle,
                  ),
                ),
              ],
            ),
          ),
          _IconOnlyTap(
            onTap: onSwap,
            child: Icon(Icons.refresh_rounded, size: 15, color: s.mutedSubtle),
          ),
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int n;
  const _NumberBadge({required this.n});

  @override
  Widget build(BuildContext context) {
    final s = SyntraSurface.of(context);
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: s.bg2,
        shape: BoxShape.circle,
        border: Border.all(color: s.bg4, width: 1),
      ),
      child: Text(
        '$n',
        style: const TextStyle(
          fontFamily: 'Octarine',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: BrandColors.pinkSoft,
        ),
      ),
    );
  }
}

// ─── My warm-up: saved challenges, drag-to-reorder ──────────────────────────

class _MyWarmupCard extends ConsumerStatefulWidget {
  const _MyWarmupCard();

  @override
  ConsumerState<_MyWarmupCard> createState() => _MyWarmupCardState();
}

class _MyWarmupCardState extends ConsumerState<_MyWarmupCard> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final l = S.of(context);
    final itemsAsync = ref.watch(savedWarmupChallengesProvider);
    final items = itemsAsync.valueOrNull ?? const <Challenge>[];

    final totalSec = items.fold<int>(0, (a, b) => a + b.time);
    final totalAura = items.fold<int>(0, (a, b) => a + b.aura);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Eyebrow(text: l.warmupMySectionEyebrow, color: s.mutedSubtle),
          const SizedBox(height: 4),
          Text(
            l.warmupMyTitle,
            style: TextStyle(
              fontFamily: 'Octarine',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.3,
              height: 1.2,
              color: isDark ? Colors.white : cs.onSurface,
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l.warmupMySummary(
                items.length,
                formatWarmupDuration(totalSec),
                totalAura,
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.4,
                color: s.mutedSubtle,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (items.isEmpty)
            _SavedEmpty(text: l.warmupMyEmpty)
          else
            _SavedReorderableList(items: items),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SyntraButton(
                  onPressed: items.isEmpty
                      ? () => _focusChallengesTab(ref)
                      : () => context
                          .findAncestorStateOfType<_WarmupScreenState>()
                          ?._startWarmup(items),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.warmupStart),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                onTap: () => _focusChallengesTab(ref),
                icon: Icons.add_rounded,
                iconColor: s.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _focusChallengesTab(WidgetRef ref) {
    HapticFeedback.selectionClick();
    ref.read(homeTabIndexProvider.notifier).state = 0;
  }
}

class _SavedEmpty extends StatelessWidget {
  final String text;
  const _SavedEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    final s = SyntraSurface.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg4, style: BorderStyle.solid, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.bookmark_outline_rounded, size: 22, color: s.muted),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.4,
              color: s.mutedSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedReorderableList extends ConsumerWidget {
  final List<Challenge> items;
  const _SavedReorderableList({required this.items});

  static const double _rowHeight = 64;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      physics: const NeverScrollableScrollPhysics(),
      proxyDecorator: (child, _, _) => Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.02, child: child),
      ),
      itemCount: items.length,
      onReorder: (from, to) {
        final adjusted = to > from ? to - 1 : to;
        ref
            .read(savedWarmupOrderProvider.notifier)
            .reorder(from, adjusted);
      },
      itemBuilder: (context, i) => _SavedRow(
        key: ValueKey(items[i].id),
        index: i,
        challenge: items[i],
        height: _rowHeight,
        onRemove: () {
          // Removing from the saved warm-up un-bookmarks too.
          ref
              .read(bookmarkedChallengeIdsProvider.notifier)
              .toggle(items[i].id);
        },
      ),
    );
  }
}

class _SavedRow extends StatelessWidget {
  final int index;
  final Challenge challenge;
  final double height;
  final VoidCallback onRemove;

  const _SavedRow({
    super.key,
    required this.index,
    required this.challenge,
    required this.height,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        height: height,
        child: Container(
          padding: const EdgeInsets.only(left: 8, right: 12),
          decoration: BoxDecoration(
            color: s.bg1,
            border: Border.all(color: s.bg3, width: 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: index,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(Icons.drag_indicator_rounded,
                      size: 18, color: s.mutedSubtle),
                ),
              ),
              const SizedBox(width: 4),
              _NumberBadge(n: index + 1),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      challenge.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Octarine',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.3,
                        color: isDark ? Colors.white : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'L${challenge.level} · ${formatWarmupDuration(challenge.time)} · +${challenge.aura}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: s.mutedSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              _IconOnlyTap(
                onTap: onRemove,
                child: Icon(Icons.close_rounded, size: 15, color: s.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Just-one ghost button ──────────────────────────────────────────────────

class _JustOneButton extends ConsumerWidget {
  const _JustOneButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = SyntraSurface.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          onTap: () => context
              .findAncestorStateOfType<_WarmupScreenState>()
              ?._startJustOne(),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: s.bg1,
              border: Border.all(color: s.bg3, width: 1),
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: s.muted),
                const SizedBox(width: 6),
                Text(
                  l.warmupJustOne,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared atoms ────────────────────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const _Eyebrow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 10,
        letterSpacing: 1.6,
        color: color,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  const _CircleIconButton({
    required this.onTap,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = SyntraSurface.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: s.bg2,
            shape: BoxShape.circle,
            border: Border.all(color: s.bg4, width: 1),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

class _IconOnlyTap extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _IconOnlyTap({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
            width: 28, height: 28, child: Center(child: child)),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    final s = SyntraSurface.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      height: 220,
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CardError extends StatelessWidget {
  final String message;
  const _CardError({required this.message});

  @override
  Widget build(BuildContext context) {
    final s = SyntraSurface.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.bg1,
        border: Border.all(color: s.bg3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(message,
          style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: s.muted)),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────────

String _vibeLabel(S l, WarmupVibe v) => switch (v) {
      WarmupVibe.coffee => l.warmupVibeCoffee,
      WarmupVibe.errands => l.warmupVibeErrands,
      WarmupVibe.any => l.warmupVibeAny,
    };

String _lengthLabel(S l, WarmupLength v) => switch (v) {
      WarmupLength.m5 => l.warmupLength5,
      WarmupLength.m10 => l.warmupLength10,
      WarmupLength.m15 => l.warmupLength15,
    };
