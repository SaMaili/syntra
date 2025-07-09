import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutNotePage extends StatelessWidget {
  const AboutNotePage({super.key});

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.grey[400] : Colors.grey;
    final linkColor = isDark ? Colors.lightBlueAccent : Colors.blue;
    final bgColor = isDark ? Colors.grey[900] : Colors.white;
    return Scaffold(
      appBar: AppBar(title: const Text('About the App')),
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: _getVersion(),
          builder: (context, snapshot) {
            final version = snapshot.data ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syntra',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Syntra is an innovative app that helps users overcome social challenges and achieve their goals.'
                  '\n'
                  '\nVersion: $version'
                  '\nDeveloper: SaMaili',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'GitHub: ',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    InkWell(
                      child: Text(
                        'https://github.com/SaMaili/syntra',
                        style: TextStyle(
                          color: linkColor,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () async {
                        final url = Uri.parse(
                          'https://github.com/SaMaili/syntra',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  // copyright notice
                  '\u00a9 2025 Syntra. All rights reserved.',
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
