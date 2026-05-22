import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/challenge_repository.dart';
import '../generated/l10n.dart';
import '../logic/notification_manager.dart';
import '../providers/challenge_providers.dart';
import '../providers/scroll_providers.dart';
import '../providers/settings_providers.dart';
import '../services/syntra_notification_service.dart';
import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';
import '../widgets/syntra_blur_app_bar.dart';
import '../widgets/syntra_settings_widgets.dart';
import '../widgets/syntra_sheet.dart';
import '../widgets/syntra_switch.dart';
import 'about_page.dart';
import 'settings/aura_wallet_card.dart';
import 'settings/inventory_card.dart';

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

    final l = S.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(title: Text(l.settingsTitle)),
      body: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          0,
          SyntraBlurAppBar.topPadding(context) + AppSpacing.sm,
          0,
          AppSpacing.bottomNavBarHeight(context) + AppSpacing.md,
        ),
        children: [
          const AuraWalletCard(),

          SettingsSectionLabel(label: l.sectionInventory),
          const InventoryCard(),

          SettingsSectionLabel(label: l.sectionNotifications),
          const _NotificationsGroup(),

          SettingsSectionLabel(label: l.sectionFeel),
          const _FeelGroup(),

          SettingsSectionLabel(label: l.sectionAppearance),
          const _AppearanceGroup(),

          SettingsSectionLabel(label: l.sectionAbout),
          const _AboutGroup(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Notifications group ─────────────────────────────────────────────────────

class _NotificationsGroup extends ConsumerStatefulWidget {
  const _NotificationsGroup();

  @override
  ConsumerState<_NotificationsGroup> createState() =>
      _NotificationsGroupState();
}

class _NotificationsGroupState extends ConsumerState<_NotificationsGroup> {
  Future<void> _onMasterToggle(bool value) async {
    await ref.read(notificationsEnabledProvider.notifier).set(value);
    try {
      await SyntraNotificationService.instance.setNativeNotificationsEnabled(
        value,
      );
    } catch (e) {
      debugPrint('Failed to set native notifications: $e');
    }
    if (value) {
      await NotificationManager.scheduleDailyReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).notificationsEnabled)),
        );
      }
    } else {
      await NotificationManager.cancelAllNotifications();
    }
  }

  Future<void> _reschedule() async {
    await NotificationManager.cancelAllNotifications();
    if (ref.read(notificationsEnabledProvider)) {
      await NotificationManager.scheduleDailyReminders();
    }
  }

  Future<void> _onReminderToggle(bool value) async {
    HapticFeedback.selectionClick();
    await ref.read(reminderEnabledProvider.notifier).set(value);
    await _reschedule();
  }

  Future<void> _pickTime(TimeOfDay current) async {
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    await ref.read(reminderTimeProvider.notifier).setTime(picked);
    await _reschedule();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final enabled = ref.watch(notificationsEnabledProvider);
    final reminderEnabled = ref.watch(reminderEnabledProvider);
    final time = ref.watch(reminderTimeProvider);

    final pillFg = isDark ? Colors.white : cs.onSurface;
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    return SettingsGroup(
      children: [
        SettingsRow(
          icon: Icons.notifications_active_outlined,
          label: l.notificationsMasterLabel,
          sublabel: l.notificationsMasterSublabel,
          trailing: SyntraSwitch(value: enabled, onChanged: _onMasterToggle),
          last: !enabled,
        ),
        SynReveal(
          open: enabled,
          child: Column(
            children: [
              // The daily nudge is optional, independent of the master switch.
              SettingsRow(
                icon: Icons.schedule_outlined,
                label: l.dailyReminderLabel,
                sublabel: l.dailyReminderSublabel,
                last: !reminderEnabled,
                trailing: SyntraSwitch(
                  value: reminderEnabled,
                  onChanged: _onReminderToggle,
                ),
              ),
              SynReveal(
                open: reminderEnabled,
                child: SettingsRow(
                  icon: Icons.access_time_rounded,
                  label: l.reminderTimeLabel,
                  last: true,
                  trailing: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _pickTime(time);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: s.bg2,
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.55),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formatted,
                        style: TextStyle(
                          fontFamily: 'Octarine',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: pillFg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Feel group ──────────────────────────────────────────────────────────────

class _FeelGroup extends ConsumerWidget {
  const _FeelGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final sfx = ref.watch(soundEffectsEnabledProvider);
    return SettingsGroup(
      children: [
        SettingsRow(
          icon: Icons.volume_up_outlined,
          label: l.soundEffects,
          sublabel: l.soundEffectsSubtitle,
          trailing: SyntraSwitch(
            value: sfx,
            onChanged: (v) =>
                ref.read(soundEffectsEnabledProvider.notifier).set(v),
          ),
          last: true,
        ),
      ],
    );
  }
}

// ─── Appearance group ────────────────────────────────────────────────────────

class _AppearanceGroup extends ConsumerWidget {
  const _AppearanceGroup();

  Future<void> _onLanguageChange(WidgetRef ref, String code) async {
    await ref.read(localeProvider.notifier).setLanguage(code);
    ChallengeRepository.instance.invalidate();
    ref.invalidate(challengeCatalogProvider);
    if (ref.read(notificationsEnabledProvider)) {
      await NotificationManager.cancelAllNotifications();
      await NotificationManager.scheduleDailyReminders();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final dividerColor = s.bg3;
    final labelColor = isDark ? Colors.white : cs.onSurface;
    final themeMode = ref.watch(themeModeProvider);
    final lang = ref.watch(activeLocaleProvider);

    return SettingsGroup(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dark_mode_outlined,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    l.darkMode,
                    style: tt.titleSmall?.copyWith(
                      fontFamily: 'Octarine',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ThemePicker(
                value: themeMode,
                onChanged: (m) =>
                    ref.read(themeModeProvider.notifier).setMode(m),
              ),
            ],
          ),
        ),
        Container(height: 1, color: dividerColor),
        SettingsRow(
          icon: Icons.translate_outlined,
          label: l.language,
          trailing: _LanguageButton(
            lang: lang,
            onChanged: (v) => _onLanguageChange(ref, v),
          ),
          last: true,
        ),
      ],
    );
  }
}

// ─── About group ─────────────────────────────────────────────────────────────

class _AboutGroup extends ConsumerWidget {
  const _AboutGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);
    return SettingsGroup(
      children: [
        SettingsRow(
          icon: Icons.info_outline_rounded,
          label: l.about,
          sublabel: l.aboutSubtitle,
          trailing: Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: SyntraSurface.of(context).muted,
          ),
          last: true,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AboutNotePage())),
        ),
      ],
    );
  }
}

// ─── Theme picker (3-up swatches matching the design) ───────────────────────

class _ThemePicker extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _ThemeSwatch(
            label: l.themeLight,
            selected: value == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
            paint: _SwatchPaint.light,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeSwatch(
            label: l.themeDark,
            selected: value == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
            paint: _SwatchPaint.dark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeSwatch(
            label: l.themeSystem,
            selected: value == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
            paint: _SwatchPaint.system,
          ),
        ),
      ],
    );
  }
}

enum _SwatchPaint { light, dark, system }

class _ThemeSwatch extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _SwatchPaint paint;

  const _ThemeSwatch({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.paint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = SyntraSurface.of(context);
    final outerBg = s.bg0;
    final outerBorder = selected ? cs.primary : (isDark ? s.bg4 : s.bg3);
    final labelColor = selected
        ? (isDark ? Colors.white : cs.onSurface)
        : cs.onSurfaceVariant;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: outerBg,
          border: Border.all(color: outerBorder, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        // Clip the inner content (not the decorated box) at the radius just
        // inside the 1px border, so the hard-edged swatch tucks cleanly into
        // the rounded stroke instead of chipping its top corners.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Column(
            children: [
              SizedBox(height: 38, child: _SwatchSurface(paint: paint)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Octarine',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwatchSurface extends StatelessWidget {
  final _SwatchPaint paint;
  const _SwatchSurface({required this.paint});

  @override
  Widget build(BuildContext context) {
    switch (paint) {
      case _SwatchPaint.light:
        return Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: _Bar(color: Colors.black.withValues(alpha: 0.55)),
        );
      case _SwatchPaint.dark:
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: _Bar(color: Colors.white.withValues(alpha: 0.55)),
        );
      case _SwatchPaint.system:
        return Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: _Bar(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: _Bar(color: Colors.white.withValues(alpha: 0.45)),
              ),
            ),
          ],
        );
    }
  }
}

class _Bar extends StatelessWidget {
  final Color color;
  const _Bar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

// ─── Language button ─────────────────────────────────────────────────────────

class _LanguageButton extends StatelessWidget {
  final String lang;
  final ValueChanged<String> onChanged;
  const _LanguageButton({required this.lang, required this.onChanged});

  Future<void> _open(BuildContext context) async {
    final l = S.of(context);
    final picked = await showSyntraSheet<String>(
      context,
      useRootNavigator: true,
      builder: (ctx) {
        final tt = Theme.of(ctx).textTheme;
        final cs = Theme.of(ctx).colorScheme;
        final entries = [('en', l.languageEnglish), ('de', l.languageGerman)];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l.language,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              for (final (code, name) in entries)
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(ctx).pop(code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: lang == code
                          ? cs.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: tt.bodyMedium?.copyWith(
                              color: lang == code ? cs.primary : cs.onSurface,
                              fontWeight: lang == code
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (lang == code)
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: cs.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final name = lang == 'de' ? l.languageGerman : l.languageEnglish;
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: SettingsRowValue(value: name),
      ),
    );
  }
}
