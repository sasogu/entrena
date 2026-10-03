# Entrena

Aplicación Android sencilla para planificar rutinas y registrar el progreso en el gimnasio. Está creada con Flutter y, por ahora, guarda los datos localmente en el dispositivo.

## Descargar

Descarga el fichero `entrena-<versión>.apk` desde la [última versión publicada](https://github.com/sasogu/entrena/releases/latest) y ábrelo en el móvil. Android pedirá permiso para instalar aplicaciones de origen desconocido desde el navegador o el gestor de archivos.

Requiere Android 7.0 o superior. Los datos se guardan solo en el móvil: si desinstalas la app, se pierden.

## Estado actual

- Pantallas de Hoy, Rutinas y Progreso.
- Perfiles separados en un mismo dispositivo; se pueden crear y cambiar desde el avatar.
- Objetivo elegido de una lista o escrito por la persona.
- Dos rutinas de ejemplo entre las que elegir para cada objetivo.
- Edición, alta y eliminación de ejercicios.
- Registro de series, repeticiones y peso, con nota opcional por sesión.
- Progreso por ejercicio con récord, gráfica de evolución e historial completo.
- Persistencia local mediante `shared_preferences`.

Los perfiles actuales no son cuentas y no se sincronizan entre dispositivos. Las rutinas son plantillas locales: la IA todavía no está conectada ni se envían datos a ningún servicio.

## Ejecutar

Con Flutter instalado:

```sh
flutter pub get
flutter test
flutter run
```

Para generar un APK de publicación firmado, crea `android/key.properties` con `storeFile`, `storePassword`, `keyAlias` y `keyPassword` (no se sube al repositorio) y ejecuta `flutter build apk --release`. Sin ese fichero, el APK se firma con la clave de depuración.

Consulta [ROADMAP.md](ROADMAP.md) para las siguientes etapas y [CHANGELOG.md](CHANGELOG.md) para el historial de versiones.

El código se distribuye bajo la licencia MIT; consulta [LICENSE](LICENSE). Los vídeos de `assets/videos/` son de sus autores y conservan su licencia (CC BY-SA 4.0, CC BY 3.0 o dominio público); consulta [assets/videos/CREDITS.md](assets/videos/CREDITS.md). Para sincronizar entre móviles habrá que elegir un servicio de cuentas y backend. Las claves de un proveedor de IA no deben guardarse dentro de la aplicación Android.
