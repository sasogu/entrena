/// Explicaciones breves de los ejercicios: qué trabajan, cómo se hacen y los
/// errores habituales. Se buscan por nombre, sin tener en cuenta mayúsculas
/// ni tildes, para que también funcionen con ejercicios añadidos a mano.
class ExerciseGuide {
  const ExerciseGuide({
    required this.name,
    this.aliases = const [],
    required this.muscles,
    required this.steps,
    required this.mistakes,
    this.tip,
    required this.videoQuery,
  });
  final String name;
  final List<String> aliases;
  final String muscles;
  final List<String> steps;
  final List<String> mistakes;
  final String? tip;
  final String videoQuery;
}

String normalizeExerciseName(String text) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñç';
  const to = 'aaaaeeeeiiiioooouuuunc';
  final lower = text.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final char in lower.split('')) {
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
}

ExerciseGuide? findExerciseGuide(String name) {
  final key = normalizeExerciseName(name);
  for (final guide in exerciseGuides) {
    if (normalizeExerciseName(guide.name) == key ||
        guide.aliases.any((alias) => normalizeExerciseName(alias) == key)) {
      return guide;
    }
  }
  return null;
}

/// Búsqueda de YouTube con la técnica del ejercicio. Se usa una búsqueda en
/// lugar de un vídeo fijo para que el enlace no caduque.
Uri exerciseVideoUri(String name) {
  final query = findExerciseGuide(name)?.videoQuery ?? '$name técnica correcta';
  return Uri.https('www.youtube.com', '/results', {'search_query': query});
}

const exerciseGuides = [
  // Rutina «Cuerpo completo A».
  ExerciseGuide(
    name: 'Sentadilla goblet',
    aliases: ['Sentadilla copa', 'Goblet squat'],
    muscles: 'Cuádriceps y glúteos; también aductores y abdomen.',
    steps: [
      'Sujeta una mancuerna o kettlebell en vertical contra el pecho, con los codos apuntando abajo.',
      'Pies algo más separados que la cadera y puntas ligeramente hacia fuera.',
      'Baja llevando la cadera atrás y abajo, con el pecho alto y la espalda recta.',
      'Las rodillas siguen la dirección de los pies. Baja hasta que los muslos queden paralelos al suelo, o hasta donde puedas sin redondear la espalda.',
      'Sube empujando el suelo con todo el pie.',
    ],
    mistakes: [
      'Rodillas que se van hacia dentro.',
      'Talones que se despegan del suelo.',
      'Redondear la espalda al bajar.',
    ],
    tip: 'Coge aire al bajar y suéltalo al subir.',
    videoQuery: 'sentadilla goblet técnica correcta',
  ),
  ExerciseGuide(
    name: 'Press de pecho en máquina',
    aliases: ['Press pecho máquina', 'Chest press'],
    muscles: 'Pectoral; también tríceps y parte delantera del hombro.',
    steps: [
      'Ajusta el asiento para que las asas queden a la altura de la mitad del pecho.',
      'Espalda apoyada en el respaldo, pies en el suelo y hombros atrás y abajo.',
      'Empuja las asas hasta estirar los brazos casi del todo, sin bloquear los codos.',
      'Vuelve despacio hasta notar el pecho estirado, sin que los hombros se adelanten.',
    ],
    mistakes: [
      'Despegar la espalda del respaldo.',
      'Subir los hombros hacia las orejas.',
      'Dejar caer el peso de golpe al volver.',
    ],
    videoQuery: 'press de pecho en máquina técnica correcta',
  ),
  ExerciseGuide(
    name: 'Jalón al pecho',
    aliases: ['Jalón', 'Polea al pecho', 'Lat pulldown'],
    muscles:
        'Dorsal ancho (espalda); también bíceps y parte media de la espalda.',
    steps: [
      'Ajusta el rodillo para que sujete los muslos.',
      'Coge la barra con las palmas hacia delante, un poco más abierto que los hombros.',
      'Inclina el tronco ligeramente hacia atrás, con el pecho alto.',
      'Tira llevando los codos hacia abajo y atrás hasta que la barra llegue a la parte alta del pecho.',
      'Sube despacio hasta estirar los brazos.',
    ],
    mistakes: [
      'Bajar la barra por detrás de la nuca.',
      'Balancear el cuerpo para mover el peso.',
      'Tirar solo con los brazos y encoger los hombros.',
    ],
    videoQuery: 'jalón al pecho técnica correcta',
  ),
  ExerciseGuide(
    name: 'Peso muerto rumano con mancuernas',
    aliases: ['Peso muerto rumano', 'Romanian deadlift'],
    muscles:
        'Isquiotibiales (parte trasera del muslo) y glúteos; también zona lumbar.',
    steps: [
      'De pie, pies a la anchura de la cadera y una mancuerna en cada mano delante de los muslos.',
      'Flexiona un poco las rodillas y mantenlas así todo el ejercicio.',
      'Lleva la cadera hacia atrás e inclina el tronco con la espalda recta. Las mancuernas bajan pegadas a las piernas.',
      'Baja hasta notar estiramiento detrás de los muslos, normalmente a media espinilla.',
      'Sube empujando la cadera hacia delante y apretando los glúteos.',
    ],
    mistakes: [
      'Redondear la espalda.',
      'Doblar mucho las rodillas: se convierte en una sentadilla.',
      'Separar las mancuernas del cuerpo.',
      'Echar el tronco atrás al terminar de subir.',
    ],
    videoQuery: 'peso muerto rumano con mancuernas técnica correcta',
  ),
  ExerciseGuide(
    name: 'Plancha',
    aliases: ['Plancha abdominal', 'Plank'],
    muscles: 'Abdomen y zona media completa.',
    steps: [
      'Apoya los antebrazos en el suelo con los codos justo debajo de los hombros.',
      'Estira las piernas y apóyate en las puntas de los pies.',
      'Mantén el cuerpo en línea recta de la cabeza a los talones, mirando al suelo.',
      'Aprieta abdomen y glúteos y respira con normalidad durante todo el tiempo.',
    ],
    mistakes: [
      'Dejar caer la cadera.',
      'Subir mucho la cadera.',
      'Aguantar la respiración.',
    ],
    tip: 'Si cuesta demasiado, apoya las rodillas en lugar de los pies.',
    videoQuery: 'plancha abdominal técnica correcta',
  ),

  // Rutina «Cuerpo completo B».
  ExerciseGuide(
    name: 'Prensa de piernas',
    aliases: ['Prensa', 'Leg press'],
    muscles: 'Cuádriceps y glúteos; también aductores.',
    steps: [
      'Siéntate con la espalda y la cadera bien apoyadas en el respaldo.',
      'Pies en el centro de la plataforma, a la anchura de la cadera.',
      'Quita los seguros y baja despacio hasta que las rodillas formen más o menos un ángulo recto.',
      'Empuja con todo el pie hasta estirar las piernas, sin bloquear las rodillas.',
    ],
    mistakes: [
      'Bloquear las rodillas arriba.',
      'Bajar tanto que la cadera se despega del respaldo.',
      'Rodillas que se van hacia dentro.',
      'Empujar solo con las puntas de los pies.',
    ],
    videoQuery: 'prensa de piernas técnica correcta',
  ),
  ExerciseGuide(
    name: 'Press inclinado en máquina',
    aliases: ['Press inclinado'],
    muscles: 'Parte alta del pectoral; también hombro delantero y tríceps.',
    steps: [
      'Ajusta el asiento para que las asas queden a la altura de la parte alta del pecho.',
      'Espalda apoyada, pies en el suelo y hombros atrás y abajo.',
      'Empuja hacia arriba y adelante hasta estirar los brazos casi del todo, sin bloquear los codos.',
      'Vuelve despacio hasta notar el pecho estirado.',
    ],
    mistakes: [
      'Despegar la espalda del respaldo.',
      'Subir los hombros hacia las orejas.',
      'Hacer el recorrido a medias.',
    ],
    videoQuery: 'press inclinado en máquina técnica correcta',
  ),
  ExerciseGuide(
    name: 'Remo sentado en polea',
    aliases: ['Remo en polea', 'Remo sentado', 'Remo gironda'],
    muscles: 'Espalda (dorsal y parte media); también bíceps.',
    steps: [
      'Siéntate con los pies en los apoyos y las rodillas un poco flexionadas.',
      'Coge el agarre con los brazos estirados y el tronco recto.',
      'Tira llevando los codos hacia atrás, pegados al cuerpo, hasta que el agarre llegue al abdomen. Junta los omóplatos.',
      'Vuelve despacio estirando los brazos, sin redondear la espalda.',
    ],
    mistakes: [
      'Balancear el tronco hacia delante y atrás para mover el peso.',
      'Encoger los hombros.',
      'Redondear la espalda al volver.',
    ],
    videoQuery: 'remo sentado en polea técnica correcta',
  ),
  ExerciseGuide(
    name: 'Puente de glúteos',
    aliases: ['Puente de glúteo', 'Glute bridge'],
    muscles: 'Glúteos; también parte trasera del muslo.',
    steps: [
      'Túmbate boca arriba con las rodillas dobladas y los pies apoyados, a la anchura de la cadera y cerca del cuerpo.',
      'Brazos estirados a los lados.',
      'Empuja con los talones y sube la cadera hasta que hombros, cadera y rodillas queden en línea recta.',
      'Aprieta los glúteos uno o dos segundos arriba y baja despacio.',
    ],
    mistakes: [
      'Arquear la zona lumbar en lugar de subir con los glúteos.',
      'Empujar con las puntas de los pies.',
      'Bajar de golpe.',
    ],
    videoQuery: 'puente de glúteos técnica correcta',
  ),
  ExerciseGuide(
    name: 'Dead bug',
    aliases: ['Bicho muerto'],
    muscles: 'Abdomen profundo y control de la zona lumbar.',
    steps: [
      'Túmbate boca arriba con los brazos estirados hacia el techo.',
      'Sube las piernas con cadera y rodillas dobladas en ángulo recto.',
      'Pega la zona lumbar al suelo y mantenla así todo el ejercicio.',
      'Estira a la vez un brazo hacia atrás y la pierna contraria hacia delante, cerca del suelo pero sin tocarlo.',
      'Vuelve al centro y repite con el otro lado.',
    ],
    mistakes: ['Despegar la zona lumbar del suelo.', 'Hacerlo deprisa.'],
    tip: 'Suelta el aire mientras estiras brazo y pierna.',
    videoQuery: 'dead bug ejercicio técnica correcta',
  ),

  // Otros ejercicios habituales que se pueden añadir a la rutina.
  ExerciseGuide(
    name: 'Press de banca',
    aliases: ['Press banca', 'Press de banca con barra', 'Bench press'],
    muscles: 'Pectoral; también tríceps y hombro delantero.',
    steps: [
      'Túmbate en el banco con los ojos bajo la barra y los pies firmes en el suelo.',
      'Coge la barra un poco más abierto que los hombros y junta los omóplatos.',
      'Baja la barra controlada hasta la parte media o baja del pecho, con los codos algo pegados al cuerpo, no en cruz.',
      'Empuja hasta estirar los brazos.',
    ],
    mistakes: [
      'Rebotar la barra en el pecho.',
      'Abrir los codos en ángulo recto con el cuerpo.',
      'Levantar los glúteos del banco.',
    ],
    tip:
        'Con peso alto, entrena con alguien que te asista o usa los topes de seguridad.',
    videoQuery: 'press de banca técnica correcta',
  ),
  ExerciseGuide(
    name: 'Sentadilla con barra',
    aliases: ['Sentadilla', 'Back squat'],
    muscles: 'Cuádriceps y glúteos; también aductores, zona lumbar y abdomen.',
    steps: [
      'Coloca la barra sobre la parte alta de la espalda, no sobre el cuello, y sácala del soporte.',
      'Pies algo más separados que la cadera, puntas ligeramente hacia fuera.',
      'Coge aire, aprieta el abdomen y baja llevando la cadera atrás y abajo.',
      'Rodillas en la dirección de los pies. Baja al menos hasta que los muslos queden paralelos al suelo, si puedes sin redondear la espalda.',
      'Sube empujando el suelo con todo el pie.',
    ],
    mistakes: [
      'Rodillas hacia dentro.',
      'Talones que se levantan.',
      'Redondear la espalda abajo.',
    ],
    tip: 'Usa los topes de seguridad del rack.',
    videoQuery: 'sentadilla con barra técnica correcta',
  ),
  ExerciseGuide(
    name: 'Peso muerto',
    aliases: ['Peso muerto convencional', 'Deadlift'],
    muscles:
        'Glúteos, parte trasera del muslo y espalda; trabaja casi todo el cuerpo.',
    steps: [
      'Pies a la anchura de la cadera, con la barra sobre la mitad del pie.',
      'Baja la cadera y coge la barra justo por fuera de las piernas.',
      'Espalda recta, pecho alto y barra pegada a las espinillas.',
      'Sube empujando el suelo con las piernas y estirando la cadera a la vez. La barra sube rozando las piernas.',
      'Baja con el mismo recorrido: primero la cadera atrás y después dobla las rodillas.',
    ],
    mistakes: [
      'Redondear la espalda.',
      'Separar la barra del cuerpo.',
      'Subir la cadera antes que la barra.',
    ],
    videoQuery: 'peso muerto técnica correcta',
  ),
  ExerciseGuide(
    name: 'Dominadas',
    aliases: ['Dominada', 'Pull up'],
    muscles: 'Dorsal ancho; también bíceps y parte media de la espalda.',
    steps: [
      'Cuélgate de la barra con las palmas hacia delante, un poco más abierto que los hombros.',
      'Baja los hombros, alejándolos de las orejas, antes de empezar.',
      'Tira llevando los codos hacia abajo hasta que la barbilla pase la barra.',
      'Baja despacio hasta estirar los brazos.',
    ],
    mistakes: [
      'Balancearse o dar patadas para subir.',
      'Hacer medio recorrido.',
    ],
    tip: 'Si aún no te salen, usa la máquina asistida o una goma elástica.',
    videoQuery: 'dominadas técnica correcta principiantes',
  ),
  ExerciseGuide(
    name: 'Press militar',
    aliases: [
      'Press de hombros',
      'Press de hombro',
      'Press militar con mancuernas',
      'Press de hombros con mancuernas',
    ],
    muscles: 'Hombros; también tríceps.',
    steps: [
      'De pie o sentado, con la barra o las mancuernas a la altura de los hombros.',
      'Aprieta abdomen y glúteos para no arquear la espalda.',
      'Empuja hacia arriba hasta estirar los brazos por encima de la cabeza.',
      'Baja despacio hasta la altura de los hombros.',
    ],
    mistakes: [
      'Arquear la zona lumbar.',
      'Ayudarse con un impulso de piernas.',
    ],
    videoQuery: 'press militar técnica correcta',
  ),
  ExerciseGuide(
    name: 'Zancadas',
    aliases: ['Zancada', 'Lunges', 'Estocadas'],
    muscles: 'Cuádriceps y glúteos; también equilibrio.',
    steps: [
      'De pie, da un paso largo hacia delante.',
      'Baja hasta que las dos rodillas formen más o menos un ángulo recto, con la rodilla trasera cerca del suelo.',
      'Tronco recto y rodilla delantera en la dirección del pie.',
      'Empuja con el pie de delante para volver y cambia de pierna.',
    ],
    mistakes: [
      'Paso demasiado corto: la rodilla delantera se adelanta mucho.',
      'Rodilla delantera hacia dentro.',
      'Inclinar mucho el tronco.',
    ],
    videoQuery: 'zancadas técnica correcta',
  ),
  ExerciseGuide(
    name: 'Hip thrust',
    aliases: ['Empuje de cadera', 'Hip thrust con barra'],
    muscles: 'Glúteos.',
    steps: [
      'Siéntate en el suelo con la parte alta de la espalda apoyada en un banco y la barra sobre la cadera, mejor con almohadilla.',
      'Pies apoyados a la anchura de la cadera, rodillas dobladas.',
      'Empuja con los talones y sube la cadera hasta que el tronco quede paralelo al suelo y las rodillas en ángulo recto.',
      'Aprieta los glúteos arriba con la barbilla hacia el pecho y baja controlado.',
    ],
    mistakes: [
      'Arquear la zona lumbar arriba.',
      'Pies demasiado lejos o demasiado cerca.',
    ],
    videoQuery: 'hip thrust técnica correcta',
  ),
  ExerciseGuide(
    name: 'Curl de bíceps',
    aliases: [
      'Curl bíceps',
      'Curl con mancuernas',
      'Curl de bíceps con mancuernas',
      'Curl con barra',
    ],
    muscles: 'Bíceps.',
    steps: [
      'De pie, con una mancuerna en cada mano o la barra, brazos estirados y palmas hacia delante.',
      'Codos pegados al cuerpo y quietos.',
      'Dobla los codos y sube el peso hacia los hombros.',
      'Baja despacio hasta estirar los brazos.',
    ],
    mistakes: [
      'Balancear el cuerpo para subir el peso.',
      'Adelantar los codos.',
      'Bajar de golpe.',
    ],
    videoQuery: 'curl de bíceps técnica correcta',
  ),
  ExerciseGuide(
    name: 'Extensión de tríceps en polea',
    aliases: ['Extensión de tríceps', 'Tríceps en polea', 'Jalón de tríceps'],
    muscles: 'Tríceps.',
    steps: [
      'De pie frente a la polea alta, con la cuerda o la barra cogida.',
      'Codos pegados al cuerpo y doblados.',
      'Estira los brazos hacia abajo hasta extender los codos.',
      'Vuelve despacio hasta que los antebrazos queden más o menos horizontales.',
    ],
    mistakes: [
      'Separar los codos del cuerpo.',
      'Inclinarse encima del peso para empujar.',
    ],
    videoQuery: 'extensión de tríceps en polea técnica correcta',
  ),
  ExerciseGuide(
    name: 'Elevaciones laterales',
    aliases: ['Elevación lateral', 'Elevaciones laterales con mancuernas'],
    muscles: 'Parte lateral del hombro.',
    steps: [
      'De pie, con una mancuerna en cada mano a los lados del cuerpo.',
      'Codos ligeramente doblados.',
      'Sube los brazos hacia los lados hasta la altura de los hombros, no más.',
      'Baja despacio.',
    ],
    mistakes: [
      'Usar demasiado peso y balancearse.',
      'Subir los hombros hacia las orejas.',
      'Subir los brazos por encima de los hombros.',
    ],
    videoQuery: 'elevaciones laterales técnica correcta',
  ),
  ExerciseGuide(
    name: 'Extensión de cuádriceps',
    aliases: ['Extensión de piernas', 'Leg extension'],
    muscles: 'Cuádriceps.',
    steps: [
      'Ajusta la máquina para que la rodilla quede alineada con el eje y el rodillo sobre los tobillos.',
      'Espalda apoyada y manos en las asas.',
      'Estira las piernas hasta extender las rodillas.',
      'Baja despacio sin dejar caer el peso.',
    ],
    mistakes: ['Dar impulso con un golpe.', 'Despegar la cadera del asiento.'],
    videoQuery: 'extensión de cuádriceps máquina técnica correcta',
  ),
  ExerciseGuide(
    name: 'Curl femoral',
    aliases: [
      'Curl de isquios',
      'Curl femoral tumbado',
      'Curl femoral sentado',
    ],
    muscles: 'Isquiotibiales (parte trasera del muslo).',
    steps: [
      'Ajusta la máquina para que la rodilla quede alineada con el eje y el rodillo sobre los tobillos.',
      'Dobla las rodillas llevando los talones hacia los glúteos.',
      'Vuelve despacio hasta casi estirar las piernas.',
    ],
    mistakes: [
      'Levantar la cadera del banco para ayudarse.',
      'Bajar de golpe.',
    ],
    videoQuery: 'curl femoral máquina técnica correcta',
  ),
];
