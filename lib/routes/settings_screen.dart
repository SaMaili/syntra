import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_repository.dart';
import '../data/settings_repository.dart';
import '../generated/l10n.dart';
import '../logic/notification_manager.dart';
import '../logic/comfort_zone_logic.dart';
import '../providers/challenge_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart' show statisticsRefreshProvider;
import '../services/syntra_notification_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/syntra_progress_bar.dart';
import '../widgets/syntra_button.dart';
import 'about_page.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        children: const [
          _ComfortZoneLevelCard(),
          SizedBox(height: AppSpacing.md),
          _AppSettingsCard(),
          SizedBox(height: AppSpacing.md),
          _NotificationScheduleCard(),
          SizedBox(height: AppSpacing.md),
          _GeneralCard(),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ─── App settings (dark mode, notifications master toggle) ────────────────────

class _AppSettingsCard extends ConsumerWidget {
  const _AppSettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final soundEffectsEnabled = ref.watch(soundEffectsEnabledProvider);

    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(S.of(context).darkMode),
            subtitle: Text(S.of(context).darkModeSubtitle),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: isDark,
            onChanged: (v) => ref.read(themeModeProvider.notifier).setDark(v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
            title: Text(S.of(context).notifications),
            subtitle: Text(S.of(context).notificationsSubtitle),
            secondary: const Icon(Icons.notifications_outlined),
            value: notificationsEnabled,
            onChanged: (v) => _onNotificationsToggle(context, ref, v),
          ),
          const Divider(indent: 16, endIndent: 16),
          SwitchListTile(
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
      trailing: Switch(
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

// ─── Level-down confirmation dialog ──────────────────────────────────────────

class _LevelDownDialog extends ConsumerWidget {
  const _LevelDownDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.levelDownTitle,
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.levelDownBody,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Neon red cancel — visually dominant to discourage downgrade
            SyntraButton(
              onPressed: () => Navigator.of(context).pop(false),
              color: const Color(0xFFFF1744),
              child: Text(l.levelDownCancel),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Subtle confirm — available but not calling for attention
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l.levelDownConfirm,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Comfort Zone Level progress card ────────────────────────────────────────

class _ComfortZoneLevelCard extends ConsumerStatefulWidget {
  const _ComfortZoneLevelCard();

  @override
  ConsumerState<_ComfortZoneLevelCard> createState() =>
      _ComfortZoneLevelCardState();
}

class _ComfortZoneLevelCardState extends ConsumerState<_ComfortZoneLevelCard> {
  int _completions = 0;

  @override
  void initState() {
    super.initState();
    _loadCompletions();
    // Reload completions whenever the level changes (e.g. after a level-up)
    // so the bar shows fresh data for the new level instead of stale old count.
    ref.listenManual(comfortZoneLevelProvider, (prev, next) {
      if (prev != next) _loadCompletions();
    });
    // Refresh after every challenge completion (even without a level-up).
    ref.listenManual(statisticsRefreshProvider, (_, __) => _loadCompletions());
  }

  Future<void> _loadCompletions() async {
    final count = await ref
        .read(comfortZoneLevelProvider.notifier)
        .getCompletionsAtCurrentLevel();
    if (mounted) setState(() => _completions = count);
  }

  Future<void> _onSetLevel(BuildContext context, WidgetRef ref, int targetLevel) async {
    final currentLevel = ref.read(comfortZoneLevelProvider);
    if (targetLevel >= currentLevel) return; // Can only downgrade

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _LevelDownDialog(),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(comfortZoneLevelProvider.notifier).setLevel(targetLevel);
      _loadCompletions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = ref.watch(comfortZoneLevelProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isMaxLevel = level >= ComfortZoneLogic.maxLevel;
    final levelName = ComfortZoneLogic.levelNames[level];
    final progress = isMaxLevel
        ? 1.0
        : (_completions / ComfortZoneLogic.completionsToUnlock)
            .clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    color: cs.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  S.of(context).comfortZoneLevel,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Text(
                    S.of(context).levelN(level),
                    style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              levelName,
              style: tt.bodyMedium?.copyWith(
                  color: cs.primary, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (!isMaxLevel) ...[
              SyntraXpBar(value: progress),
              const SizedBox(height: AppSpacing.xs),
              Text(
                S.of(context).completionsToLevel(
                    _completions, ComfortZoneLogic.completionsToUnlock, level + 1),
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

            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: List.generate(ComfortZoneLogic.maxLevel, (i) {
                final lvl = i + 1;
                final selected = lvl == level;
                return ChoiceChip(
                  label: Text(
                    '$lvl',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? cs.onPrimaryContainer
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  selected: selected,
                  selectedColor: cs.primaryContainer,
                  backgroundColor: cs.surfaceContainerHighest,
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  onSelected: (_) => _onSetLevel(context, ref, lvl),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
