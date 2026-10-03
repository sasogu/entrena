import 'dart:convert';

import 'models.dart';

/// Formato del fichero de copia. Si cambia de forma incompatible, se sube
/// el número y [decodeBackup] decide qué versiones sabe leer.
const backupFormat = 1;

/// Error al leer una copia, con un mensaje listo para mostrar.
class BackupException implements Exception {
  const BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

String backupFileName(DateTime now) {
  String two(int value) => value.toString().padLeft(2, '0');
  return 'entrena-${now.year}-${two(now.month)}-${two(now.day)}.json';
}

String encodeBackup(List<Profile> profiles, {DateTime? now}) =>
    const JsonEncoder.withIndent('  ').convert({
      'app': 'entrena',
      'format': backupFormat,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'profiles': profiles.map((profile) => profile.toJson()).toList(),
    });

List<Profile> decodeBackup(String text) {
  final Object? data;
  try {
    data = jsonDecode(text);
  } on FormatException {
    throw const BackupException('El fichero no es una copia de Entrena.');
  }
  if (data is! Map<String, dynamic> || data['app'] != 'entrena') {
    throw const BackupException('El fichero no es una copia de Entrena.');
  }
  final format = data['format'];
  if (format is! int || format > backupFormat) {
    throw const BackupException(
      'La copia es de una versión más nueva de Entrena. Actualiza la app.',
    );
  }
  try {
    final profiles = (data['profiles'] as List<dynamic>)
        .map((item) => Profile.fromJson(item as Map<String, dynamic>))
        .toList();
    if (profiles.isEmpty) {
      throw const BackupException('La copia no contiene ningún perfil.');
    }
    return profiles;
  } on BackupException {
    rethrow;
  } catch (_) {
    throw const BackupException('La copia está dañada y no se puede leer.');
  }
}

/// Añade los perfiles importados a los actuales. Si un nombre ya existe,
/// el importado se renombra («Ana (2)») para no mezclar historiales.
List<Profile> mergeProfiles(List<Profile> current, List<Profile> imported) {
  final names = current.map((profile) => profile.name).toSet();
  final result = [...current];
  for (final profile in imported) {
    var name = profile.name;
    for (var i = 2; names.contains(name); i++) {
      name = '${profile.name} ($i)';
    }
    names.add(name);
    result.add(name == profile.name ? profile : renameProfile(profile, name));
  }
  return result;
}

Profile renameProfile(Profile profile, String name) =>
    Profile.fromJson({...profile.toJson(), 'name': name});

int sessionCount(List<Profile> profiles) =>
    profiles.fold(0, (sum, profile) => sum + profile.history.length);
