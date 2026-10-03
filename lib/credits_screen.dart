import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'exercise_videos.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  void _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final grey = TextStyle(color: Colors.grey.shade700);
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Entrena es software libre (licencia MIT). Los vídeos de técnica '
            'son obra de sus autores y conservan su licencia. Se han recortado, '
            'quitado el audio y reducido de tamaño.',
            style: grey,
          ),
          const SizedBox(height: 12),
          ...exerciseVideos.entries.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.movie_outlined),
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${entry.value.author} · ${entry.value.license}\n'
                '${entry.value.source}',
              ),
              isThreeLine: true,
              onTap: () => _open(entry.value.sourceUrl),
              trailing: IconButton(
                tooltip: 'Ver licencia',
                icon: const Icon(Icons.gavel_outlined),
                onPressed: () => _open(entry.value.licenseUrl),
              ),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.code),
            title: const Text('Licencias del software'),
            subtitle: const Text('Flutter y librerías que usa la app'),
            onTap: () =>
                showLicensePage(context: context, applicationName: 'Entrena'),
          ),
        ],
      ),
    );
  }
}
