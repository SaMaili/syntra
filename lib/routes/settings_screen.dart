import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_repository.dart';
import '../data/settings_repository.dart';
import '../generated/l10n.dart';
import '../logic/comfort_zone_logic.dart';
import '../logic/notification_manager.dart';
import '../providers/challenge_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/statistics_providers.dart' show czlCompletionsProvider;
import '../services/syntra_notification_service.dart';
import '../theme/app_spacing.dart';
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
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final soundEffectsEnabled = ref.watch(soundEffectsEnabledProvider);

    return Card(
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

class _ComfortZoneLevelCard extends ConsumerWidget {
  const _ComfortZoneLevelCard();

  Future<void> _onSetLevel(
      BuildContext context, WidgetRef ref, int targetLevel) async {
    final currentLevel = ref.read(comfortZoneLevelProvider);
    if (targetLevel >= currentLevel) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _LevelDownDialog(),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(comfortZoneLevelProvider.notifier).setLevel(targetLevel);
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header band ─────────────────────────────────────────
          Container(
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
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Text(
                    S.of(context).levelN(level),
                    style: tt.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
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
                          child: GestureDetector(
                            onTap: locked ? null : () => _onSetLevel(context, ref, lvl),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? cs.primaryContainer
                                    : locked
                                        ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
                                        : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.chipRadius),
                                border: selected
                                    ? Border.all(
                                        color: cs.primary, width: 1.5)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$lvl',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: selected
                                        ? cs.onPrimaryContainer
                                        : locked
                                            ? cs.onSurfaceVariant.withValues(alpha: 0.35)
                                            : cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
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
