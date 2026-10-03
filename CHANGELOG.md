# Historial de cambios

Este archivo recoge los cambios relevantes de cada versión. Sigue el formato de [Keep a Changelog](https://keepachangelog.com/es/1.1.0/) y versionado semántico.

## [Sin publicar]

### Añadido

- Nota opcional por sesión: se escribe desde Hoy y se muestra en el historial de Progreso.
- Progreso por ejercicio: lista en Progreso con la última marca y el cambio desde la primera sesión; al tocar un ejercicio se ve su récord, una gráfica y cada sesión con su volumen. Los ejercicios sin peso se siguen por repeticiones.
- Historial completo en una pantalla aparte; en Progreso se muestran las 5 sesiones más recientes.
- Pruebas unitarias y de pantalla del guardado de sesiones y del progreso.

### Cambiado

- Los pesos se muestran sin decimales innecesarios («60 kg», «62,5 kg»).
- El código se reparte en `models.dart`, `progress.dart` y `progress_screens.dart`.

## [0.1.0] - 2026-09-25

### Añadido

- Aplicación Flutter para Android llamada Entrena.
- Vistas de Hoy, Rutinas y Progreso.
- Perfiles locales separados en el mismo dispositivo.
- Objetivos predefinidos y objetivos personalizados.
- Dos rutinas locales para comparar y elegir según el objetivo.
- Edición de ejercicios y registro local de series, repeticiones y peso.
- Historial de sesiones por perfil.

### Pendiente

- Cuentas, sincronización entre dispositivos e integración con IA.
