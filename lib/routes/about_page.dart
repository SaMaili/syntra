import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
import '../widgets/syntra_blur_app_bar.dart';

class AboutNotePage extends StatelessWidget {
  const AboutNotePage({super.key});

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = S.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: SyntraBlurAppBar(title: Text(l.aboutTheApp)),
      body: FutureBuilder<String>(
        future: _getVersion(),
        builder: (context, snapshot) {
          final version = snapshot.data ?? '';
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                24, SyntraBlurAppBar.topPadding(context) + 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syntra',
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '${l.aboutDescription}'
                  '\n'
                  '\nVersion: $version'
                  '\n${l.developerLabel}',
                  style: tt.bodyLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${l.privacyPolicy}: ', style: tt.bodyLarge),
                    Flexible(
                      child: InkWell(
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${l.couldNotOpenLink}: $e'),
                                  backgroundColor: cs.error,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'https://samaili.github.io/syntra/',
                          style: tt.bodyLarge?.copyWith(
                            color: cs.primary,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l.allRightsReserved,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
