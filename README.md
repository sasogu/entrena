# Entrena

Aplicación Android sencilla para planificar rutinas y registrar el progreso en el gimnasio. Está creada con Flutter y, por ahora, guarda los datos localmente en el dispositivo.

## Estado actual

- Pantallas de Hoy, Rutinas y Progreso.
- Perfiles separados en un mismo dispositivo; se pueden crear y cambiar desde el avatar.
- Objetivo elegido de una lista o escrito por la persona.
- Dos rutinas de ejemplo entre las que elegir para cada objetivo.
- Edición, alta y eliminación de ejercicios.
- Registro de series, repeticiones y peso, con historial local por perfil.
- Persistencia mediante `shared_preferences`.
- Versión inicial: `0.1.0`.

Los perfiles actuales no son cuentas y no se sincronizan entre dispositivos. Las rutinas son plantillas locales: la IA todavía no está conectada ni se envían datos a ningún servicio.

## Ejecutar

Con Flutter instalado:

```sh
flutter pub get
flutter run
```

Consulta [ROADMAP.md](ROADMAP.md) para las siguientes etapas y [CHANGELOG.md](CHANGELOG.md) para el historial de versiones.

El proyecto se distribuye bajo la licencia MIT; consulta [LICENSE](LICENSE). Para sincronizar entre móviles habrá que elegir un servicio de cuentas y backend. Las claves de un proveedor de IA no deben guardarse dentro de la aplicación Android.
