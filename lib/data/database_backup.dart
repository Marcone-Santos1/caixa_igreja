import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../providers/database_provider.dart';
import 'drift_database_paths.dart';

/// Copia o ficheiro SQLite da app para um destino escolhido pelo utilizador.
Future<({bool success, bool userCancelled, String? errorMessage})>
    exportDatabaseBackup() async {
  final src = await caixaIgrejaDriftDatabaseFile();
  if (!await src.exists()) {
    return (
      success: false,
      userCancelled: false,
      errorMessage: 'Ficheiro da base não encontrado.',
    );
  }
  final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
  final suggested = 'caixa_igreja_backup_$stamp.sqlite';

  final dir = await FilePicker.platform.getDirectoryPath(
    dialogTitle: 'Escolher pasta para a cópia da base',
  );
  if (dir == null) {
    return (success: false, userCancelled: true, errorMessage: null);
  }

  final targetPath = p.join(dir, suggested);
  try {
    await src.copy(targetPath);
  } on FileSystemException catch (e) {
    return (success: false, userCancelled: false, errorMessage: e.message);
  }
  return (success: true, userCancelled: false, errorMessage: null);
}

/// Substitui a base ativa pela cópia escolhida. Fecha a ligação Drift atual.
///
/// **Limitação:** em alguns dispositivos pode ser necessário reiniciar a app
/// se ocorrer erro ao reabrir a base.
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

  ref.invalidate(appDatabaseProvider);
  await Future<void>.delayed(const Duration(milliseconds: 250));

  final target = await caixaIgrejaDriftDatabaseFile();
  try {
    await source.copy(target.path);
  } on FileSystemException catch (e) {
    return 'Não foi possível copiar: ${e.message}';
  }

  ref.invalidate(appDatabaseProvider);
  return '';
}
