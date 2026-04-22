import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Deve coincidir com `driftDatabase(name: …)` em [AppDatabase].
const kCaixaIgrejaDriftDbName = 'caixa_igreja';

/// Ficheiro SQLite usado pelo Drift em plataformas nativas (`$name.sqlite`).
Future<File> caixaIgrejaDriftDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, '$kCaixaIgrejaDriftDbName.sqlite'));
}
