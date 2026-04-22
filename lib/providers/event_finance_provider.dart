import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

final eventFinanceSummaryProvider =
    StreamProvider.autoDispose.family<EventFinanceSummary, int>((ref, eventId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchEventFinanceSummary(eventId);
});
