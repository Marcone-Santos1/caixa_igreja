import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../providers/database_provider.dart';
import 'database.dart';
import 'drift_database_paths.dart';

/// Resultado da validação do cabeçalho de um arquivo SQLite.
/// `schemaVersion` é o `PRAGMA user_version` gravado no arquivo (offset 60).
({bool isValid, int schemaVersion}) validateSqliteHeader(Uint8List bytes) {
  const magic = 'SQLite format 3';
  if (bytes.length < 100) return (isValid: false, schemaVersion: 0);
  for (var i = 0; i < magic.length; i++) {
    if (bytes[i] != magic.codeUnitAt(i)) {
      return (isValid: false, schemaVersion: 0);
    }
  }
  if (bytes[15] != 0) return (isValid: false, schemaVersion: 0);
  final version = ByteData.sublistView(bytes, 60, 64).getUint32(0);
  return (isValid: true, schemaVersion: version);
}

/// Pasta local de cópias de segurança automáticas (antes de restaurações).
Future<Directory> backupsDirectory() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(docs.path, 'backups'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Copia o banco atual para a pasta de backups com o [prefix] dado.
/// Usa `VACUUM INTO` para gerar um arquivo consistente (inclui o WAL).
Future<File> createLocalSafetyBackup(AppDatabase db, String prefix) async {
  final dir = await backupsDirectory();
  final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final path = p.join(dir.path, '$prefix-$stamp.sqlite');
  await vacuumDatabaseInto(db, path);
  await _pruneOldBackups(dir);
  return File(path);
}

/// `VACUUM INTO` gera uma cópia consistente do banco num único arquivo,
/// sem depender de -wal/-shm.
Future<void> vacuumDatabaseInto(AppDatabase db, String targetPath) async {
  final target = File(targetPath);
  if (await target.exists()) {
    await target.delete();
  }
  final escaped = targetPath.replaceAll("'", "''");
  await db.customStatement("VACUUM INTO '$escaped'");
}

Future<void> _pruneOldBackups(Directory dir, {int keep = 12}) async {
  final files = await dir
      .list()
      .where((e) => e is File && e.path.endsWith('.sqlite'))
      .cast<File>()
      .toList();
  if (files.length <= keep) return;
  files.sort((a, b) => b.path.compareTo(a.path));
  for (final f in files.skip(keep)) {
    try {
      await f.delete();
    } catch (_) {}
  }
}

/// Copia o ficheiro SQLite da app para um destino escolhido pelo utilizador.
/// A cópia é gerada com `VACUUM INTO` para não perder transações no WAL.
Future<({bool success, bool userCancelled, String? errorMessage})>
    exportDatabaseBackup(AppDatabase db) async {
  final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
  final suggested = 'caixa_igreja_backup_$stamp.sqlite';

  final dir = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Escolher pasta para a cópia da base',
  );
  if (dir == null) {
    return (success: false, userCancelled: true, errorMessage: null);
  }

  try {
    await vacuumDatabaseInto(db, p.join(dir, suggested));
  } on FileSystemException catch (e) {
    return (success: false, userCancelled: false, errorMessage: e.message);
  } catch (e) {
    return (success: false, userCancelled: false, errorMessage: e.toString());
  }
  return (success: true, userCancelled: false, errorMessage: null);
}

/// Substitui a base ativa pela cópia escolhida, com validações de segurança:
/// - confere o cabeçalho SQLite e a versão de schema (bloqueia bases de uma
///   versão mais nova do app);
/// - guarda uma cópia da base atual em `backups/` antes de substituir;
/// - remove os ficheiros `-wal`/`-shm` antigos para evitar corrupção.
///
/// Retorno: `null` = utilizador cancelou; `''` = sucesso; texto = erro.
Future<String?> restoreDatabaseBackup(WidgetRef ref) async {
  final pick = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['sqlite', 'db'],
    allowMultiple: false,
    withData: false,
  );
  if (pick == null || pick.files.isEmpty) {
    return null;
  }
  final path = pick.files.single.path;
  if (path == null) return 'Caminho do ficheiro inválido.';

  final source = File(path);
  if (!await source.exists()) return 'Ficheiro não encontrado.';

  // Validar antes de mexer em qualquer coisa.
  final raf = await source.open();
  final header = await raf.read(100);
  await raf.close();
  final check = validateSqliteHeader(Uint8List.fromList(header));
  if (!check.isValid) {
    return 'O ficheiro escolhido não é uma base de dados válida.';
  }
  if (check.schemaVersion > kAppSchemaVersion) {
    return 'Esta cópia foi criada por uma versão mais nova do app '
        '(schema v${check.schemaVersion} > v$kAppSchemaVersion). Atualize o app antes de restaurar.';
  }

  // Cópia de segurança da base atual antes de substituir.
  try {
    final db = ref.read(appDatabaseProvider);
    await createLocalSafetyBackup(db, 'pre-restore');
  } catch (_) {
    // Sem base atual legível; segue com a restauração.
  }

  ref.invalidate(appDatabaseProvider);
  await Future<void>.delayed(const Duration(milliseconds: 250));

  final target = await caixaIgrejaDriftDatabaseFile();
  try {
    // Remover WAL/SHM órfãos: um WAL da base antiga aplicado sobre a base
    // restaurada corromperia o arquivo.
    for (final suffix in const ['-wal', '-shm', '-journal']) {
      final side = File('${target.path}$suffix');
      if (await side.exists()) {
        await side.delete();
      }
    }
    await source.copy(target.path);
  } on FileSystemException catch (e) {
    return 'Não foi possível copiar: ${e.message}';
  }

  ref.invalidate(appDatabaseProvider);
  return '';
}
