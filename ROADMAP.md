# Hoja de ruta

El diseño debe seguir siendo sencillo de usar durante una sesión: registrar una serie en pocos toques, comparar rutinas y mantener el control sobre cualquier cambio.

## 0.1 · Rutinas y registro local — completada

- [x] App Android en Flutter con vistas Hoy, Rutinas y Progreso.
- [x] Perfiles separados en un mismo dispositivo.
- [x] Elegir un objetivo de una lista o escribir uno propio.
- [x] Ver varias rutinas de ejemplo para el objetivo y elegir una.
- [x] Editar la rutina y añadir o quitar ejercicios.
- [x] Registrar series, repeticiones y peso por sesión.
- [x] Guardar el historial de sesiones por perfil en el dispositivo.
- [x] Añadir notas opcionales por sesión.
- [x] Revisar progresos por ejercicio y mejorar el historial.

Las alternativas actuales son plantillas locales sencillas, no recomendaciones generadas por IA. Los objetivos de fuerza, hipertrofia y resistencia ajustan las repeticiones sugeridas; otros objetivos usan una pauta general.

## 0.1.1 · Copia de datos y fichas de ejercicios — publicada

- [x] Exportar e importar todos los datos en un fichero.
- [x] Explicación de cada ejercicio con enlace a vídeos de técnica.
- [x] Probar en el móvil y publicar.

## 0.1.2 · Vídeos de técnica con licencia libre — en pruebas

- [x] Vídeo corto dentro de la ficha (17 ejercicios), con créditos.
- [ ] Grabar vídeos propios para los ejercicios sin vídeo libre.
- [ ] Probar en el móvil y publicar.

## 0.2 · Propuestas de IA — en pruebas

- [x] Clave de API propia (Claude, OpenAI o DeepSeek), cifrada en el móvil; sin servidor intermedio.
- [x] Mostrar lo que se envía y pedir consentimiento antes del primer envío.
- [x] Generar varias rutinas comparables para el objetivo y nivel de cada persona.
- [x] Explicar las diferencias entre propuestas y permitir elegir o conservar la rutina actual.
- [x] Pedir aprobación antes de aplicar una propuesta.
- [ ] Revisar el historial y sugerir ajustes concretos (subir peso, cambiar un ejercicio estancado).

## 0.4 · Rutinas de varios días — en pruebas

- [x] Días que se alternan en orden; Hoy propone el siguiente.
- [x] Personalizar por días (añadir, renombrar, quitar).
- [x] La IA reparte sesiones complementarias según los días por semana.

## Más adelante · Cuentas y sincronización — aplazada

- [ ] Definir si habrá cuentas individuales o un grupo compartido.
- [ ] Elegir autenticación y backend.
- [ ] Sincronizar perfiles, rutinas e historial entre móviles.
- [ ] Resolver uso sin conexión y conflictos de sincronización.
- [ ] Borrado de datos en el servidor.

## Criterios del producto

- Interfaz breve y legible durante el entrenamiento.
- Las personas usuarias eligen su objetivo y conservan control sobre sus rutinas.
- La app sigue registrando entrenamientos sin conexión.
- La IA propone; la persona decide si aplica los cambios.
