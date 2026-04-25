import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_repository.dart';
import '../data/settings_repository.dart';
import '../generated/l10n.dart';
import '../logic/comfort_zone_logic.dart';
import '../logic/weekly_streak_logic.dart';
import '../logic/notification_manager.dart';
import '../providers/challenge_providers.dart';
import '../providers/scroll_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/shop_providers.dart';
import '../providers/statistics_providers.dart' show czlCompletionsProvider;
import '../services/syntra_notification_service.dart';
import '../theme/app_spacing.dart';
import '../widgets/syntra_blur_app_bar.dart';
import '../widgets/syntra_button.dart';
import '../widgets/syntra_progress_bar.dart';
import 'about_page.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(settingsScrollToTopProvider, (prev, next) {
      if (next > 0 && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(title: Text(S.of(context).settingsTitle)),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          SyntraBlurAppBar.topPadding(context) + AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.bottomNavBarHeight(context) + AppSpacing.md,
        ),
        children: const [
          _ShopCard(),
          SizedBox(height: AppSpacing.md),
          _AppSettingsCard(),
          SizedBox(height: AppSpacing.md),
          _NotificationScheduleCard(),
          SizedBox(height: AppSpacing.md),
          _GeneralCard(),
        ],
      ),
    );
  }
}

// ─── Shop ─────────────────────────────────────────────────────────────────────

class _ShopCard extends ConsumerWidget {
  const _ShopCard();

  Future<void> _buyStreakFreeze(BuildContext context, WidgetRef ref) async {
    final available = ref.read(availableAuraProvider);
    final freezes = ref.read(streakFreezesProvider);
    final l = S.of(context);

    if (freezes >= kMaxStreakFreezes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.shopMaxOwned)),
      );
      return;
    }
    if (available == null || available < kStreakFreezePrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.shopNotEnoughAura)),
      );
      return;
    }

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: const Icon(Icons.ac_unit_rounded,
                      color: Colors.blue, size: 24),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l.shopConfirmTitle,
                    style:
                        tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.shopConfirmBody(kStreakFreezePrice),
                  style: tt.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                SyntraButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l.shopBuyFor(kStreakFreezePrice)),
                ),
                const SizedBox(height: AppSpacing.sm),
                SyntraButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  color: Colors.grey,
                  child: Text(l.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(spentAuraProvider.notifier).spend(kStreakFreezePrice);
    await ref.read(streakFreezesProvider.notifier).add();
    // Lock the freeze to the current week at purchase time — it cannot be
    // applied retroactively to past weeks.
    final currentWeek = WeeklyStreakLogic.isoYearWeek(DateTime.now());
    final frozenWeeks = await SettingsRepository.instance.loadFrozenWeeks();
    await SettingsRepository.instance.saveFrozenWeeks({...frozenWeeks, currentWeek});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.shopPurchased)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    final available = ref.watch(availableAuraProvider);
    final freezes = ref.watch(streakFreezesProvider);

    final canBuy = available != null &&
        available >= kStreakFreezePrice &&
        freezes < kMaxStreakFreezes;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.storefront_outlined, color: cs.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l.shopTitle,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                // Available Aura chip
                if (available != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.chipRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events,
                            size: 14, color: cs.onPrimaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          l.shopAvailableAura(available),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),

            // ── Streak Freeze item ────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Icon(Icons.ac_unit_rounded,
                      color: Colors.blue, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Streak Freeze',
                            style: tt.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Inventory badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: freezes > 0
                                  ? Colors.blue.withValues(alpha: 0.15)
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.chipRadius),
                            ),
                            child: Text(
                              l.shopInInventory(freezes, kMaxStreakFreezes),
                              style: tt.labelSmall?.copyWith(
                                color: freezes > 0
                                    ? Colors.blue
                                    : cs.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.shopStreakFreezeDesc,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Buy button ────────────────────────────────────────────────────
            SyntraButton(
              onPressed: canBuy ? () => _buyStreakFreeze(context, ref) : null,
              child: Text(freezes >= kMaxStreakFreezes
                  ? l.shopMaxOwned
                  : l.shopBuyFor(kStreakFreezePrice)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App settings (dark mode, notifications master toggle) ────────────────────

class _AppSettingsCard extends ConsumerWidget {
  const _AppSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final soundEffectsEnabled = ref.watch(soundEffectsEnabledProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text(S.of(context).darkMode),
            subtitle: Text(S.of(context).darkModeSubtitle),
            trailing: _ThemeModeDropdown(
              value: themeMode,
              onChanged: (m) => ref.read(themeModeProvider.notifier).setMode(m),
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile.adaptive(
            title: Text(S.of(context).notifications),
            subtitle: Text(S.of(context).notificationsSubtitle),
            secondary: const Icon(Icons.notifications_outlined),
            value: notificationsEnabled,
            onChanged: (v) => _onNotificationsToggle(context, ref, v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile.adaptive(
            title: Text(S.of(context).soundEffects),
            subtitle: Text(S.of(context).soundEffectsSubtitle),
            secondary: const Icon(Icons.volume_up_outlined),
            value: soundEffectsEnabled,
            onChanged: (v) =>
                ref.read(soundEffectsEnabledProvider.notifier).set(v),
          ),
        ],
      ),
    );
  }

  Future<void> _onNotificationsToggle(
      BuildContext context, WidgetRef ref, bool value) async {
    await ref.read(notificationsEnabledProvider.notifier).set(value);
    try {
      await SyntraNotificationService.instance
          .setNativeNotificationsEnabled(value);
    } catch (_) {}
    if (value) {
      await NotificationManager.scheduleDailyReminders();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).notificationsEnabled),
        ));
      }
    } else {
      await NotificationManager.cancelAllNotifications();
    }
  }
}

// ─── Notification time slots ──────────────────────────────────────────────────

class _NotificationScheduleCard extends ConsumerWidget {
  const _NotificationScheduleCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider);
    if (!enabled) return const SizedBox.shrink();

    final slots = ref.watch(notificationSlotsProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: AppSpacing.xs, bottom: AppSpacing.md),
              child: Text(
                S.of(context).dailyReminders,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            for (int i = 0; i < 3; i++) ...[
              if (i > 0)
                const Divider(
                    indent: AppSpacing.sm, endIndent: AppSpacing.sm),
              _NotificationSlotTile(slotIndex: i, slot: slots[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationSlotTile extends ConsumerWidget {
  final int slotIndex;
  final NotificationSlotSettings slot;

  const _NotificationSlotTile(
      {required this.slotIndex, required this.slot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final slotColors = [cs.tertiary, cs.primary, cs.secondary];
    final color = slotColors[slotIndex];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(Icons.alarm, color: color, size: 20),
      ),
      title: Text(
        [
          S.of(context).morning,
          S.of(context).afternoon,
          S.of(context).evening,
        ][slotIndex],
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: GestureDetector(
        onTap: slot.enabled ? () => _pickTime(context, ref) : null,
        child: Text(
          slot.formatted,
          style: TextStyle(
            color: slot.enabled
                ? color
                : Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: Switch.adaptive(
        value: slot.enabled,
        onChanged: (v) => _onToggle(ref, v),
      ),
      onTap: slot.enabled ? () => _pickTime(context, ref) : null,
    );
  }

  Future<void> _onToggle(WidgetRef ref, bool value) async {
    final notifier = ref.read(notificationSlotsProvider.notifier);
    await notifier.updateSlot(slotIndex, slot.copyWith(enabled: value));
    await NotificationManager.cancelAllNotifications();
    final notificationsEnabled =
        ref.read(notificationsEnabledProvider);
    if (notificationsEnabled) {
      await NotificationManager.scheduleDailyReminders();
    }
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: slot.time,
    );
    if (picked == null) return;
    final notifier = ref.read(notificationSlotsProvider.notifier);
    await notifier.updateSlot(slotIndex, slot.copyWith(time: picked));
    await NotificationManager.cancelAllNotifications();
    final notificationsEnabled = ref.read(notificationsEnabledProvider);
    if (notificationsEnabled) {
      await NotificationManager.scheduleDailyReminders();
    }
  }
}

// ─── General (language, about) ────────────────────────────────────────────────

class _GeneralCard extends ConsumerWidget {
  const _GeneralCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(activeLocaleProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.translate_outlined),
            title: Text(S.of(context).language),
            subtitle: Text(S.of(context).languageSubtitle),
            trailing: _LanguageDropdown(lang: lang, onChanged: (v) => _onLanguageChange(ref, v)),
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(S.of(context).about),
            subtitle: Text(S.of(context).aboutSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutNotePage()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onLanguageChange(WidgetRef ref, String code) async {
    await ref.read(localeProvider.notifier).setLanguage(code);
    ChallengeRepository.instance.invalidate();
    ref.invalidate(challengeCatalogProvider);
    final notificationsEnabled = ref.read(notificationsEnabledProvider);
    if (notificationsEnabled) {
      await NotificationManager.cancelAllNotifications();
      await NotificationManager.scheduleDailyReminders();
    }
  }
}

// ─── Theme-mode dropdown ──────────────────────────────────────────────────────

class _ThemeModeDropdown extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemeModeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline.withAlpha(80)),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        color: cs.surfaceContainerHighest,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ThemeMode>(
          value: value,
          isDense: true,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: cs.onSurface),
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          items: [
            DropdownMenuItem(value: ThemeMode.light, child: Text(l.themeLight)),
            DropdownMenuItem(value: ThemeMode.dark,  child: Text(l.themeDark)),
            DropdownMenuItem(value: ThemeMode.system, child: Text(l.themeSystem)),
          ],
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

// ─── Language dropdown ────────────────────────────────────────────────────────

class _LanguageDropdown extends StatelessWidget {
  final String lang;
  final ValueChanged<String> onChanged;
  const _LanguageDropdown({required this.lang, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outline.withAlpha(80)),
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        color: cs.surfaceContainerHighest,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: lang,
          isDense: true,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: cs.onSurface),
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          items: [
            DropdownMenuItem(
                value: 'en', child: Text(S.of(context).languageEnglish)),
            DropdownMenuItem(
                value: 'de', child: Text(S.of(context).languageGerman)),
          ],
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

// ─── Comfort Zone Level progress card ────────────────────────────────────────

class ComfortZoneLevelCard extends ConsumerWidget {
  const ComfortZoneLevelCard({super.key});

  String _levelName(S l, int level) => switch (level) {
        1 => l.levelName1,
        2 => l.levelName2,
        3 => l.levelName3,
        4 => l.levelName4,
        5 => l.levelName5,
        6 => l.levelName6,
        7 => l.levelName7,
        8 => l.levelName8,
        9 => l.levelName9,
        _ => l.levelName10,
      };

  String _levelDesc(S l, int level) => switch (level) {
        1 => l.levelDesc1,
        2 => l.levelDesc2,
        3 => l.levelDesc3,
        4 => l.levelDesc4,
        5 => l.levelDesc5,
        6 => l.levelDesc6,
        7 => l.levelDesc7,
        8 => l.levelDesc8,
        9 => l.levelDesc9,
        _ => l.levelDesc10,
      };

  Future<void> _showLevelInfo(
      BuildContext context, WidgetRef ref, int level,
      {int? goDownTo}) async {
    final l = S.of(context);
    final gradient = ComfortZoneLogic.levelGradient(level);
    final icon = ComfortZoneLogic.levelIcons[
        level.clamp(1, ComfortZoneLogic.levelIcons.length - 1)];
    final name = _levelName(l, level);
    final desc = _levelDesc(l, level);
    final canGoDown = goDownTo != null;

    final goDown = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs2 = Theme.of(ctx).colorScheme;
        final tt2 = Theme.of(ctx).textTheme;
        return Container(
          decoration: BoxDecoration(
            color: cs2.surfaceContainerLow,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle ────────────────────────────────────────────────
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs2.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
  
                // ── Icon ──────────────────────────────────────────────────
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradient.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, size: 44, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.md),
  
                // ── Name ──────────────────────────────────────────────────
                Text(
                  name,
                  style: tt2.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
  
                // ── Level chip ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Text(
                    l.levelN(level),
                    style: tt2.labelSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
  
                // ── Description ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    desc,
                    style: tt2.bodyMedium
                        ?.copyWith(color: cs2.onSurfaceVariant, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
  
                // ── Step-down section ─────────────────────────────────────
                if (canGoDown) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Divider(
                      indent: AppSpacing.xl,
                      endIndent: AppSpacing.xl,
                      color: cs2.outlineVariant),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      children: [
                        Text(
                          l.levelDownTitle,
                          style: tt2.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l.levelDownBody,
                          style: tt2.bodySmall?.copyWith(
                              color: cs2.onSurfaceVariant, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
  
                const SizedBox(height: AppSpacing.lg),
  
                // ── Primary action ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SyntraButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(canGoDown ? l.levelDownCancel : l.letsGoButton),
                  ),
                ),
  
                // ── Step-back action ──────────────────────────────────────
                if (canGoDown) ...[
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showModalBottomSheet<bool>(
                        context: ctx,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (confirmCtx) {
                          final cs3 = Theme.of(confirmCtx).colorScheme;
                          final tt3 = Theme.of(confirmCtx).textTheme;
                          return Container(
                            decoration: BoxDecoration(
                              color: cs3.surfaceContainerLow,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28)),
                            ),
                            child: SafeArea(
                              top: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Container(
                                      width: 36,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: cs3.onSurfaceVariant
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: cs3.errorContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.arrow_downward_rounded,
                                      color: cs3.onErrorContainer, size: 28),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  l.levelDownTitle,
                                  style: tt3.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xl),
                                  child: Text(
                                    l.levelDownBody,
                                    style: tt3.bodyMedium?.copyWith(
                                        color: cs3.onSurfaceVariant,
                                        height: 1.5),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xl),
                                  child: SyntraButton(
                                    onPressed: () =>
                                        Navigator.of(confirmCtx).pop(true),
                                    color: cs3.error,
                                    child: Text(l.levelDownConfirm,
                                        style: TextStyle(
                                            color: cs3.onError)),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(confirmCtx).pop(false),
                                  child: Text(l.levelDownCancel,
                                      style: TextStyle(
                                          color: cs3.onSurfaceVariant,
                                          fontSize: 13)),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    if (confirmed == true && ctx.mounted) {
                      Navigator.of(ctx).pop(true);
                    }
                  },
                  child: Text(
                    l.levelDownConfirm,
                    style: TextStyle(color: cs2.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      );
    },
  );

    if (goDown == true && context.mounted) {
      await ref.read(comfortZoneLevelProvider.notifier).setLevel(goDownTo!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(comfortZoneLevelProvider);
    final completions = ref.watch(czlCompletionsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isMaxLevel = level >= ComfortZoneLogic.maxLevel;
    final levelName = ComfortZoneLogic.levelNames[level];
    final needed = ComfortZoneLogic.completionsNeeded(level);
    final progress = isMaxLevel
        ? 1.0
        : (completions / needed).clamp(0.0, 1.0);

    final gradient = ComfortZoneLogic.levelGradient(level);
    final levelIcon = ComfortZoneLogic.levelIcons[level.clamp(1, ComfortZoneLogic.levelIcons.length - 1)];

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header band (tappable → level info popup) ───────────
          InkWell(
            onTap: () => _showLevelInfo(context, ref, level),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: gradient),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(levelIcon, color: Colors.white, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      levelName,
                      style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.chipRadius),
                    ),
                    child: Text(
                      S.of(context).levelN(level),
                      style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.white70, size: 16),
                ],
              ),
            ),
          ),
          // ── Body ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).comfortZoneLevel,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!isMaxLevel) ...[
                  SyntraXpBar(value: progress),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    S.of(context).completionsToLevel(
                        completions,
                        needed,
                        level + 1),
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ] else
                  Text(
                    S.of(context).reachedTheTop,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  S.of(context).setDifficultyManually,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Two rows of 5, each level button taking equal width.
                for (int row = 0; row < 2; row++) ...[
                  if (row > 0) const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: List.generate(5, (col) {
                      final lvl = row * 5 + col + 1;
                      final selected = lvl == level;
                      final locked = lvl > level;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: col == 0 ? 0 : AppSpacing.xs / 2,
                              right: col == 4 ? 0 : AppSpacing.xs / 2),
                          child: Opacity(
                            opacity: locked ? 0.4 : 1.0,
                            child: SyntraButton(
                              onPressed: locked
                                  ? () => _showLevelInfo(context, ref, lvl)
                                  : selected
                                      ? () => _showLevelInfo(context, ref, lvl)
                                      : () => _showLevelInfo(context, ref, lvl,
                                            goDownTo: lvl),
                              color: selected
                                  ? cs.primary
                                  : Theme.of(context).scaffoldBackgroundColor,
                              height: 36,
                              depth: 3,
                              child: Text('$lvl'),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
