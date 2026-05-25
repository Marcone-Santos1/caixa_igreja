import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/stock_constants.dart';
import 'database_provider.dart';
import 'sync_provider.dart';
import 'event_dashboard_provider.dart';

final eventLowStockCountsProvider =
    StreamProvider.autoDispose.family<EventLowStockCounts, String>((ref, eventId) {
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    final productsStream = ref.watch(eventProductsStreamProvider(eventId).stream);
    final denomsStream = ref.watch(eventDenomsStreamProvider(eventId).stream);

    final controller = StreamController<EventLowStockCounts>();
    List<ChurchProduct>? lastProds;
    List<EventDotDenom>? lastDenoms;

    void emit() {
      if (lastProds != null && lastDenoms != null && !controller.isClosed) {
        final lowP = lastProds!
            .where((p) => p.active && p.trackStock && p.stockQty <= kLowStockThreshold)
            .length;
        final lowD = lastDenoms!.where((d) => d.stockQty <= kLowStockThreshold).length;
        controller.add(EventLowStockCounts(lowProductCount: lowP, lowDotCount: lowD));
      }
    }

    final sub1 = productsStream.listen((prods) {
      lastProds = prods;
      emit();
    });
    final sub2 = denomsStream.listen((denoms) {
      lastDenoms = denoms;
      emit();
    });

    ref.onDispose(() {
      sub1.cancel();
      sub2.cancel();
      controller.close();
    });

    return controller.stream;
  }

  final db = ref.watch(appDatabaseProvider);
  return db.watchEventLowStockCounts(eventId);
});
