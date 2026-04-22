import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

final eventLowStockCountsProvider =
    StreamProvider.autoDispose.family<EventLowStockCounts, int>((ref, eventId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchEventLowStockCounts(eventId);
});
