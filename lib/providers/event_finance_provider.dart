import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';
import 'sync_provider.dart';
import 'event_dashboard_provider.dart';

final eventFinanceSummaryProvider =
    StreamProvider.autoDispose.family<EventFinanceSummary, String>((ref, eventId) {
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    return ref.watch(eventSalesStreamProvider(eventId).stream).map(EventFinanceSummary.fromSales);
  }
  final db = ref.watch(appDatabaseProvider);
  return db.watchEventFinanceSummary(eventId);
});
