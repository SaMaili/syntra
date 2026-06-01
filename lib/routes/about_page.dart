import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../theme/brand_colors.dart';
import '../tools/fake_data_seeder.dart';
import '../widgets/syntra_blur_app_bar.dart';

class AboutNotePage extends StatelessWidget {
  const AboutNotePage({super.key});

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  Future<void> _onVersionLongPress(BuildContext context) async {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Seeding fake data…')));
    await seedFakeData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Done! Restart the app to see screenshot data.')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = S.of(context);
    final s = SyntraSurface.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(title: Text(l.aboutTheApp)),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _getVersion(),
          builder: (context, snapshot) {
            final version = snapshot.data ?? '';
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, kToolbarHeight + 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App name + icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/SyntraBird.svg',
                        width: 44,
                        height: 44,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Syntra',
                        style: TextStyle(
                          fontFamily: 'Octarine',
                          fontWeight: FontWeight.w700,
                          fontSize: 36,
                          letterSpacing: -0.8,
                          height: 1,
                          color: isDark ? Colors.white : cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Version badge
                  if (version.isNotEmpty)
                    GestureDetector(
                      onLongPress: kDebugMode
                          ? () => _onVersionLongPress(context)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: s.bg2,
                          border: Border.all(color: s.bg3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'v$version',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    l.aboutDescription,
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.developerLabel,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 28),
                  Divider(color: s.bg3),
                  const SizedBox(height: 20),

                  // Privacy policy
                  Text(
                    l.privacyPolicy,
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final url =
                          Uri.parse('https://samaili.github.io/syntra/');
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          await launchUrl(url,
                              mode: LaunchMode.platformDefault);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(SnackBar(
                              content: Text('${l.couldNotOpenLink}: $e'),
                              backgroundColor: cs.error,
                            ));
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'samaili.github.io/syntra',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: cs.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Copyright
                  Text(
                    l.allRightsReserved,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
