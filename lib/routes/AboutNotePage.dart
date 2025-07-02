import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutNotePage extends StatelessWidget {
  const AboutNotePage({Key? key}) : super(key: key);

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Über die App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: _getVersion(),
          builder: (context, snapshot) {
            final version = snapshot.data ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Syntra',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Syntra ist eine innovative App, die Benutzern hilft, ihre Herausforderungen zu meistern und ihre Ziele zu erreichen.'
                  '\n'
                  '\nVersion: $version'
                  '\nEntwickler: SaMaili'
                  '\n'
                  '\n GitHub: ',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Text(
                  '© 2025 Syntra. Alle Rechte vorbehalten.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
