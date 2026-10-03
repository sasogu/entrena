# Historial de cambios

Este archivo recoge los cambios relevantes de cada versión. Sigue el formato de [Keep a Changelog](https://keepachangelog.com/es/1.1.0/) y versionado semántico.

## 0.4.3 - 2026-10-03 (prueba)

### Añadido

- Cambiar el orden de los ejercicios en Personaliza tu rutina: arrastrando desde el asa (≡) o con «Subir» y «Bajar» en el menú de cada ejercicio. Las series ya apuntadas hoy se mueven con su ejercicio.

## 0.4.2 - 2026-10-03 (prueba)

### Añadido

- Catálogo completo de ejercicios en Rutinas → «Añadir ejercicios del catálogo»: 36 ejercicios agrupados por zona (pierna, empuje, tirón, cadera, tronco y cardio), con buscador por nombre o músculo, aviso de los que tienen vídeo y ficha al tocar el nombre. Se pueden añadir varios seguidos al día que se está editando; las series se ajustan después con «Editar». Sigue disponible escribir un ejercicio que no está.

### Corregido

- En Personaliza tu rutina, los botones de días («Añadir día», «Renombrar», «Quitar día») no cabían en móviles estrechos y se desbordaban.

## 0.4.1 - 2026-10-03 (prueba)

### Añadido

- Deslizar a izquierda o derecha cambia entre Hoy, Rutinas y Progreso. La barra inferior sigue funcionando, ahora con animación.

## 0.4.0 - 2026-10-03 (prueba)

### Añadido

- Rutinas de varios días que se alternan y se complementan (por ejemplo, Día A / Día B o Torso / Pierna). Hoy muestra «Hoy toca: …» con el día siguiente de la secuencia, sin depender del día de la semana; se puede elegir otro día con los botones de arriba.
- Personaliza tu rutina por días: añadir, renombrar y quitar días, y editar los ejercicios de cada uno.
- Rutinas de ejemplo con días: «Cuerpo completo» (A/B), «Fuerza con barra» (A: sentadilla con barra, press de banca, remo; B: peso muerto, press militar, dominadas), «Torso / Pierna», «Cardio y fuerza» (1 día) y «Hockey línea» (A: potencia; B: fuerza y prevención).
- La IA reparte las sesiones según los días por semana (1: cuerpo completo; 2: dos de cuerpo completo; 3: tres distintas o empuje/tirón/pierna; 4 o más: torso/pierna…) para que se complementen.
- El historial indica qué día de la rutina se hizo.

### Cambiado

- «Cuerpo completo A» y «B» pasan a ser los dos días de «Cuerpo completo».

## 0.3.2 - 2026-10-03 (prueba)

### Añadido

- Elegir el objetivo en la pantalla de propuestas con IA (los 17 predefinidos o uno propio). Al usar una propuesta, el objetivo del perfil pasa a ser el elegido y el diálogo de confirmación lo avisa.

## 0.3.1 - 2026-10-03 (prueba)

### Añadido

- Cuatro objetivos de hockey línea: potencia y velocidad de patinaje, aguantar todo el partido, prevenir lesiones de ingle, cadera y espalda, y mantenerse durante la temporada.
- Rutina de ejemplo «Hockey línea» (solo aparece con esos objetivos): bicicleta, saltos de patinador, sentadilla búlgara, zancada lateral, peso muerto rumano, plancha de Copenhague y Pallof press.
- Nueve ejercicios nuevos con ficha: zancada lateral, sentadilla búlgara, aductores y abductores en máquina, plancha lateral, plancha de Copenhague, Pallof press, leñador en polea y saltos de patinador. Vídeo libre para los aductores en máquina (wger, CC BY-SA 4.0).
- La IA recibe qué implica cada objetivo deportivo para orientar las propuestas.

## 0.3.0 - 2026-10-03 (prueba)

### Añadido

- Máquinas de cardio: cinta de correr, bicicleta estática, elíptica, remo ergómetro y escaladora, con su ficha (cómo se usa, errores habituales) y enlace a YouTube.
- Registro de cardio en minutos y distancia opcional, en lugar de repeticiones y kilos. Su progreso se mide en minutos por sesión.
- Rutina de ejemplo «Cardio y fuerza»: calentamiento en cinta, máquinas básicas y elíptica al final.
- Objetivos nuevos: tonificar, cuidar la salud del corazón, preparar una carrera popular, cuidar la espalda y la postura, volver a entrenar tras una pausa, entrenar en poco tiempo y mantenerme en forma a partir de los 50 (13 en total).
- La IA puede proponer máquinas de cardio, en minutos y como calentamiento o bloque propio según el objetivo.

## 0.2.1 - 2026-10-03 (prueba)

### Corregido

- Al elegir una propuesta de la IA, la pestaña Rutinas no la mostraba y parecía que la rutina había desaparecido (sí se aplicaba en Hoy). Ahora Rutinas muestra arriba «Tu rutina actual» con su nombre y ejercicios.

## 0.2.0 - 2026-10-03 (prueba)

### Añadido

- Propuestas de rutina con IA (Rutinas → «Pedir propuestas a la IA»): objetivo, nivel, días, minutos, material, molestias opcionales y, si se quiere, un resumen del historial. La IA devuelve 3 rutinas que explican en qué se diferencian; se puede elegir una o conservar la actual.
- Las propuestas solo usan ejercicios del catálogo de la app, así que todas tienen ficha y, cuando existe, vídeo. Los ejercicios desconocidos se descartan y se avisa.
- Ajustes de IA (menú ⋮): Claude, OpenAI o DeepSeek con la clave de API propia, guardada cifrada en el móvil y fuera de la copia exportada. Incluye «Probar conexión» y borrar la clave.
- Antes del primer envío a cada proveedor se muestra exactamente el texto que se envía y se pide permiso.

### Cambiado

- La app pide permiso de Internet (solo para la IA).

## 0.1.2 - 2026-10-03 (prueba)

### Añadido

- Vídeo de técnica dentro de la ficha de 17 ejercicios: en bucle, sin sonido y sin conexión. Son vídeos con licencia libre de wger (CC BY-SA 4.0) y Wikimedia Commons (CC BY 3.0 y dominio público), recortados y reducidos (7 MB en total). Se indica cuando muestran una variante del ejercicio.
- Se mantiene el botón de YouTube para ver más vídeos; en los ejercicios sin vídeo libre (sentadilla goblet, plancha, puente de glúteos, dead bug y extensión de cuádriceps) es la única opción.
- Pantalla de Créditos (menú ⋮) con autor, licencia y fuente de cada vídeo, y las licencias del software.

## [0.1.1] - 2026-10-03

### Añadido

- Exportar datos desde el menú ⋮: guarda en el móvil (Descargas, Drive…) o envía un fichero `entrena-AAAA-MM-DD.json` con perfiles, rutinas, historial y notas.
- Importar datos: añade los perfiles de la copia a los actuales (renombra los repetidos) o reemplaza todo, con confirmación previa.
- Ficha de cada ejercicio: músculos que trabaja, pasos, errores habituales y un enlace a vídeos de técnica en YouTube. Se abre con ⓘ en Hoy o tocando el ejercicio en Rutinas. Incluye los 10 ejercicios de las rutinas y 12 habituales más (press de banca, sentadilla, peso muerto, dominadas…); para el resto, ofrece la búsqueda en YouTube.

## [0.1.0] - 2026-10-03

Primera versión publicada.

### Añadido

- Aplicación Flutter para Android llamada Entrena.
- Vistas de Hoy, Rutinas y Progreso.
- Perfiles locales separados en el mismo dispositivo.
- Objetivos predefinidos y objetivos personalizados.
- Dos rutinas locales para comparar y elegir según el objetivo.
- Edición de ejercicios y registro local de series, repeticiones y peso.
- Nota opcional por sesión: se escribe desde Hoy y se muestra en el historial.
- Progreso por ejercicio: última marca, récord, gráfica de evolución y detalle de cada sesión con su volumen. Los ejercicios sin peso se siguen por repeticiones.
- Historial de sesiones por perfil; en Progreso se muestran las 5 más recientes y el resto en una pantalla aparte.
- APK firmado para instalar directamente desde GitHub.

### Pendiente

- Cuentas, sincronización entre dispositivos e integración con IA.

[0.1.1]: https://github.com/sasogu/entrena/releases/tag/v0.1.1
[0.1.0]: https://github.com/sasogu/entrena/releases/tag/v0.1.0
