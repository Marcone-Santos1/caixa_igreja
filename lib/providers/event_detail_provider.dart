import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

/// Carrega o evento uma vez. `FutureProvider` (sem autoDispose) evita
/// dispose/re-fetch durante transições do GoRouter.
final eventDetailProvider =
    FutureProvider.family<ChurchEvent?, int>((ref, id) async {
  final db = ref.read(appDatabaseProvider);
  return (await (db.select(db.events)..where((e) => e.id.equals(id)))
      .getSingleOrNull());
});
