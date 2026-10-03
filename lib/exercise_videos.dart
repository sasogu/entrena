// Generado a partir de los metadatos de wger y Wikimedia Commons.
// Créditos completos en assets/videos/CREDITS.md.

class ExerciseVideo {
  const ExerciseVideo({
    required this.asset,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.source,
    required this.sourceUrl,
    this.note,
  });
  final String asset;
  final String author;
  final String license;
  final String licenseUrl;
  final String source;
  final String sourceUrl;

  /// Si el vídeo muestra una variante del ejercicio de la ficha.
  final String? note;
}

/// Vídeos por nombre de ficha (ExerciseGuide.name).
const exerciseVideos = <String, ExerciseVideo>{
  'Press de pecho en máquina': ExerciseVideo(
    asset: 'assets/videos/press_pecho_maquina.mp4',
    author: 'Centers for Disease Control and Prevention (CDC)',
    license: 'Dominio público',
    licenseUrl: 'https://creativecommons.org/publicdomain/mark/1.0/',
    source: 'Wikimedia Commons',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Muscle_Strengthening_at_the_Gym_-_Chest_Press.webm',
  ),
  'Jalón al pecho': ExerciseVideo(
    asset: 'assets/videos/jalon_pecho.mp4',
    author: 'Andrew Kwong',
    license: 'CC BY 3.0',
    licenseUrl: 'https://creativecommons.org/licenses/by/3.0',
    source: 'Wikimedia Commons',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Common_Lat_Pulldown_Mistakes.webm',
  ),
  'Peso muerto rumano con mancuernas': ExerciseVideo(
    asset: 'assets/videos/peso_muerto_rumano.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/507/view/',
  ),
  'Prensa de piernas': ExerciseVideo(
    asset: 'assets/videos/prensa.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/371/view/',
  ),
  'Press inclinado en máquina': ExerciseVideo(
    asset: 'assets/videos/press_inclinado.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/537/view/',
    note: 'Variante con mancuernas en banco inclinado',
  ),
  'Remo sentado en polea': ExerciseVideo(
    asset: 'assets/videos/remo_polea.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/512/view/',
  ),
  'Press de banca': ExerciseVideo(
    asset: 'assets/videos/press_banca.mp4',
    author: 'FitnessScape',
    license: 'CC BY 3.0',
    licenseUrl: 'https://creativecommons.org/licenses/by/3.0',
    source: 'Wikimedia Commons',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Bench_press_-_exercise_demonstration_video.webm',
  ),
  'Sentadilla con barra': ExerciseVideo(
    asset: 'assets/videos/sentadilla_barra.mp4',
    author: 'FitnessScape',
    license: 'CC BY 3.0',
    licenseUrl: 'https://creativecommons.org/licenses/by/3.0',
    source: 'Wikimedia Commons',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Squat_-_exercise_demonstration_video.webm',
  ),
  'Peso muerto': ExerciseVideo(
    asset: 'assets/videos/peso_muerto.mp4',
    author: 'FitnessScape',
    license: 'CC BY 3.0',
    licenseUrl: 'https://creativecommons.org/licenses/by/3.0',
    source: 'Wikimedia Commons',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Deadlift_-_exercise_demonstration_video.webm',
  ),
  'Dominadas': ExerciseVideo(
    asset: 'assets/videos/dominadas.mp4',
    author: 'FitnessScape',
    license: 'CC BY 3.0',
    licenseUrl: 'https://creativecommons.org/licenses/by/3.0',
    source: 'Wikimedia Commons',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Pull-ups_-_exercise_demonstration_video.webm',
  ),
  'Press militar': ExerciseVideo(
    asset: 'assets/videos/press_militar.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/567/view/',
    note: 'Variante con mancuernas, sentado',
  ),
  'Zancadas': ExerciseVideo(
    asset: 'assets/videos/zancadas.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/205/view/',
  ),
  'Hip thrust': ExerciseVideo(
    asset: 'assets/videos/hip_thrust.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/294/view/',
  ),
  'Curl de bíceps': ExerciseVideo(
    asset: 'assets/videos/curl_biceps.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/92/view/',
  ),
  'Extensión de tríceps en polea': ExerciseVideo(
    asset: 'assets/videos/triceps_polea.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/803/view/',
    note: 'Variante a una mano',
  ),
  'Elevaciones laterales': ExerciseVideo(
    asset: 'assets/videos/elevaciones_laterales.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/348/view/',
  ),
  'Curl femoral': ExerciseVideo(
    asset: 'assets/videos/curl_femoral.mp4',
    author: 'Goulart',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    source: 'wger.de',
    sourceUrl: 'https://wger.de/es/exercise/365/view/',
    note: 'Variante tumbado',
  ),
};
