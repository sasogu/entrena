import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'exercise_guide.dart';
import 'exercise_videos.dart';

Future<void> showExerciseGuide(BuildContext context, String name) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, controller) =>
            ExerciseGuideView(name: name, controller: controller),
      ),
    );

class ExerciseGuideView extends StatelessWidget {
  const ExerciseGuideView({super.key, required this.name, this.controller});
  final String name;
  final ScrollController? controller;

  Future<void> _openVideo(BuildContext context) async {
    final opened = await launchUrl(
      exerciseVideoUri(name),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido abrir YouTube.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guide = findExerciseGuide(name);
    final grey = TextStyle(color: Colors.grey.shade700);
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          guide?.name ?? name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        if (guide == null)
          Text(
            'Todavía no hay explicación para este ejercicio. Puedes ver cómo '
            'se hace en YouTube.',
            style: grey,
          )
        else ...[
          Text('Trabaja: ${guide.muscles}', style: grey),
          if (exerciseVideos[guide.name] case final video?) ...[
            const SizedBox(height: 14),
            ExerciseVideoPlayer(video: video),
          ],
          _heading('Cómo se hace'),
          ...guide.steps.asMap().entries.map(
            (entry) => _item(
              CircleAvatar(
                radius: 12,
                child: Text(
                  '${entry.key + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              entry.value,
            ),
          ),
          _heading('Errores habituales'),
          ...guide.mistakes.map(
            (mistake) => _item(
              Icon(Icons.close, size: 20, color: Colors.red.shade400),
              mistake,
            ),
          ),
          if (guide.tip != null) ...[
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(guide.tip!),
              ),
            ),
          ],
        ],
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => _openVideo(context),
          icon: const Icon(Icons.play_circle_outline),
          label: Text(
            exerciseVideos.containsKey(guide?.name)
                ? 'Ver más vídeos en YouTube'
                : 'Ver vídeos en YouTube',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Empieza con poco peso hasta dominar la técnica. Si notas dolor '
          '(no cansancio), para y consulta con un profesional.',
          style: grey.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
    ),
  );

  Widget _item(Widget leading, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 28, child: leading),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
      ],
    ),
  );
}

/// Vídeo corto de técnica: arranca solo, en bucle y sin sonido. Se pausa al
/// tocarlo. Debajo muestra el autor y la licencia, como exige la licencia.
class ExerciseVideoPlayer extends StatefulWidget {
  const ExerciseVideoPlayer({super.key, required this.video});
  final ExerciseVideo video;

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.video.asset);
    _controller
        .initialize()
        .then((_) async {
          await _controller.setVolume(0);
          await _controller.setLooping(true);
          await _controller.play();
          if (mounted) setState(() {});
        })
        .catchError((Object _) {
          if (mounted) setState(() => _failed = true);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() => setState(
    () =>
        _controller.value.isPlaying ? _controller.pause() : _controller.play(),
  );

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final ready = _controller.value.isInitialized;
    final aspect = ready ? _controller.value.aspectRatio : 16 / 9;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: AspectRatio(
              aspectRatio: aspect,
              child: ColoredBox(
                color: const Color(0xFF1B1F1C),
                child: _failed
                    ? const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white70),
                      )
                    : !ready
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: _togglePlay,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller),
                            if (!_controller.value.isPlaying)
                              const CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (video.note != null)
          Text(
            video.note!,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        InkWell(
          onTap: () => launchUrl(
            Uri.parse(video.sourceUrl),
            mode: LaunchMode.externalApplication,
          ),
          child: Text(
            'Vídeo: ${video.author} · ${video.license} · ${video.source}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}
