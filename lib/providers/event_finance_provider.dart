import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';
import 'sync_provider.dart';

final eventFinanceSummaryProvider =
    StreamProvider.autoDispose.family<EventFinanceSummary, String>((ref, eventId) {
  final db = ref.watch(appDatabaseProvider);
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    return db.watchSalesForEvent(eventId).map(EventFinanceSummary.fromSales);
  }
  return db.watchEventFinanceSummary(eventId);
});
