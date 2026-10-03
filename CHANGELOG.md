# Historial de cambios

Este archivo recoge los cambios relevantes de cada versión. Sigue el formato de [Keep a Changelog](https://keepachangelog.com/es/1.1.0/) y versionado semántico.

## [Sin publicar] - 0.2.0

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
