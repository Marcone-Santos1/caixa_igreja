import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../domain/sale_line_kind.dart';
import 'database_provider.dart';
import 'sync_provider.dart';

class ProductSaleStat {
  final int productId;
  final String name;
  final int qtySold;
  final int totalCents;
  final bool trackStock;
  final int remainingStock;
  final bool active;
  final bool isCombo;

  ProductSaleStat({
    required this.productId,
    required this.name,
    required this.qtySold,
    required this.totalCents,
    required this.trackStock,
    required this.remainingStock,
    required this.active,
    required this.isCombo,
  });
}

class FichaSaleStat {
  final int denomId;
  final String label;
  final int qtySold;
  final int totalCents;
  final int remainingStock;

  FichaSaleStat({
    required this.denomId,
    required this.label,
    required this.qtySold,
    required this.totalCents,
    required this.remainingStock,
  });
}

class FreeValueSaleStat {
  final String label;
  final int qtySold;
  final int totalCents;

  FreeValueSaleStat({
    required this.label,
    required this.qtySold,
    required this.totalCents,
  });
}

class HourlySaleStat {
  final String hourLabel; // e.g. "18h"
  final int totalCents;
  final int salesCount;

  HourlySaleStat({
    required this.hourLabel,
    required this.totalCents,
    required this.salesCount,
  });
}

class PendingChangeSaleInfo {
  final int saleId;
  final String customerName;
  final int changeCents;

  PendingChangeSaleInfo({
    required this.saleId,
    required this.customerName,
    required this.changeCents,
  });
}

class ChangeDotStat {
  final int denomId;
  final String label;
  final int valueCents;
  final int qtyGiven;
  final int totalCents;

  ChangeDotStat({
    required this.denomId,
    required this.label,
    required this.valueCents,
    required this.qtyGiven,
    required this.totalCents,
  });
}

class EventDashboardData {
  final int totalSalesCount;
  final int totalRevenueCents;
  final int averageTicketCents;
  final Map<String, int> revenueByPaymentMethod; // method -> cents
  final Map<String, int> salesCountByPaymentMethod; // method -> count
  final Map<String, int> averageTicketByPaymentMethod; // method -> average cents
  final int totalPendingChangeCents;
  final List<PendingChangeSaleInfo> pendingChangeSales;
  final List<ChangeDotStat> changeDotStats;
  final List<ProductSaleStat> productStats;
  final List<ProductSaleStat> comboStats;
  final List<FichaSaleStat> fichaStats;
  final List<FreeValueSaleStat> freeValueStats;
  final List<HourlySaleStat> hourlyStats;

  EventDashboardData({
    required this.totalSalesCount,
    required this.totalRevenueCents,
    required this.averageTicketCents,
    required this.revenueByPaymentMethod,
    required this.salesCountByPaymentMethod,
    required this.averageTicketByPaymentMethod,
    required this.totalPendingChangeCents,
    required this.pendingChangeSales,
    required this.changeDotStats,
    required this.productStats,
    required this.comboStats,
    required this.fichaStats,
    required this.freeValueStats,
    required this.hourlyStats,
  });

  factory EventDashboardData.compute({
    required List<PosSale> sales,
    required List<PosSaleLine> lines,
    required List<ChurchProduct> products,
    required List<EventDotDenom> denoms,
    required List<ChangeDotRow> changeDotAllocations,
  }) {
    // Diagnosticar e tratar possíveis valores nulos vindos do banco de dados (bypass de null safety)
    final cleanedSales = sales.map((sale) {
      final sDyn = sale as dynamic;
      final id = sDyn.id as int? ?? 0;
      final eventId = sDyn.eventId as int? ?? 0;
      final soldAtMs = sDyn.soldAtMs as int? ?? 0;
      final totalCents = sDyn.totalCents as int? ?? 0;
      final amountReceivedCents = sDyn.amountReceivedCents as int? ?? totalCents;
      final paymentMethod = sDyn.paymentMethod as String? ?? 'dinheiro';
      final changePending = sDyn.changePending as bool? ?? false;
      final customerName = sDyn.customerName as String?;
      final notes = sDyn.notes as String?;

      if (sDyn.id == null ||
          sDyn.eventId == null ||
          sDyn.soldAtMs == null ||
          sDyn.totalCents == null ||
          sDyn.amountReceivedCents == null ||
          sDyn.paymentMethod == null ||
          sDyn.changePending == null) {
        developer.log('Venda #$id possui campos nulos no banco de dados. Tratando com fallbacks.', name: 'CaixaIgreja_Warning');
      }

      return PosSale(
        id: id,
        eventId: eventId,
        soldAtMs: soldAtMs,
        totalCents: totalCents,
        amountReceivedCents: amountReceivedCents,
        paymentMethod: paymentMethod,
        changePending: changePending,
        customerName: customerName,
        notes: notes,
      );
    }).toList();

    final cleanedLines = lines.map((line) {
      final lDyn = line as dynamic;
      final id = lDyn.id as int? ?? 0;
      final saleId = lDyn.saleId as int? ?? 0;
      final lineKind = lDyn.lineKind as int? ?? 0;
      final productId = lDyn.productId as int?;
      final dotDenominationId = lDyn.dotDenominationId as int?;
      final freeLabel = lDyn.freeLabel as String?;
      final qty = lDyn.qty as int? ?? 0;
      final unitPriceCents = lDyn.unitPriceCents as int? ?? 0;
      final lineTotalCents = lDyn.lineTotalCents as int? ?? (qty * unitPriceCents);

      if (lDyn.id == null ||
          lDyn.saleId == null ||
          lDyn.lineKind == null ||
          lDyn.qty == null ||
          lDyn.unitPriceCents == null ||
          lDyn.lineTotalCents == null) {
        developer.log('Linha de venda #$id possui campos nulos no banco de dados. Tratando com fallbacks.', name: 'CaixaIgreja_Warning');
      }

      return PosSaleLine(
        id: id,
        saleId: saleId,
        lineKind: lineKind,
        productId: productId,
        dotDenominationId: dotDenominationId,
        freeLabel: freeLabel,
        qty: qty,
        unitPriceCents: unitPriceCents,
        lineTotalCents: lineTotalCents,
      );
    }).toList();

    final cleanedProducts = products.map((p) {
      final pDyn = p as dynamic;
      final id = pDyn.id as int? ?? 0;
      final eventId = pDyn.eventId as int? ?? 0;
      final name = pDyn.name as String? ?? '';
      final description = pDyn.description as String? ?? '';
      final priceCents = pDyn.priceCents as int? ?? 0;
      final trackStock = pDyn.trackStock as bool? ?? false;
      final stockQty = pDyn.stockQty as int? ?? 0;
      final active = pDyn.active as bool? ?? true;
      final isCombo = pDyn.isCombo as bool? ?? false;

      return ChurchProduct(
        id: id,
        eventId: eventId,
        name: name,
        description: description,
        priceCents: priceCents,
        trackStock: trackStock,
        stockQty: stockQty,
        active: active,
        isCombo: isCombo,
      );
    }).toList();

    final cleanedDenoms = denoms.map((d) {
      final dDyn = d as dynamic;
      final id = dDyn.id as int? ?? 0;
      final eventId = dDyn.eventId as int? ?? 0;
      final label = dDyn.label as String? ?? '';
      final valueCents = dDyn.valueCents as int? ?? 0;
      final stockQty = dDyn.stockQty as int? ?? 0;

      return EventDotDenom(
        id: id,
        eventId: eventId,
        label: label,
        valueCents: valueCents,
        stockQty: stockQty,
      );
    }).toList();

    final cleanedChangeDotAllocations = changeDotAllocations.map((c) {
      final cDyn = c as dynamic;
      final id = cDyn.id as int? ?? 0;
      final saleId = cDyn.saleId as int? ?? 0;
      final dotDenominationId = cDyn.dotDenominationId as int? ?? 0;
      final qty = cDyn.qty as int? ?? 0;

      return ChangeDotRow(
        id: id,
        saleId: saleId,
        dotDenominationId: dotDenominationId,
        qty: qty,
      );
    }).toList();

    final totalSalesCount = cleanedSales.length;
    var totalRevenueCents = 0;
    final Map<String, int> revenueByPaymentMethod = {};
    final Map<String, int> salesCountByPaymentMethod = {};

    for (final sale in cleanedSales) {
      totalRevenueCents += sale.totalCents;
      revenueByPaymentMethod[sale.paymentMethod] =
          (revenueByPaymentMethod[sale.paymentMethod] ?? 0) + sale.totalCents;
      salesCountByPaymentMethod[sale.paymentMethod] =
          (salesCountByPaymentMethod[sale.paymentMethod] ?? 0) + 1;
    }

    final Map<String, int> averageTicketByPaymentMethod = {};
    revenueByPaymentMethod.forEach((method, revenue) {
      final count = salesCountByPaymentMethod[method] ?? 0;
      averageTicketByPaymentMethod[method] = count > 0 ? revenue ~/ count : 0;
    });

    final averageTicketCents =
        totalSalesCount > 0 ? totalRevenueCents ~/ totalSalesCount : 0;

    // Calculate pending change
    var totalPendingChangeCents = 0;
    final List<PendingChangeSaleInfo> pendingChangeSales = [];
    for (final sale in cleanedSales) {
      if (sale.changePending) {
        final change = sale.amountReceivedCents - sale.totalCents;
        if (change > 0) {
          totalPendingChangeCents += change;
          pendingChangeSales.add(PendingChangeSaleInfo(
            saleId: sale.id,
            customerName: sale.customerName ?? 'Não informado',
            changeCents: change,
          ));
        }
      }
    }

    // Aggregate change dots stats
    final Map<int, int> changeDotQtyAgg = {};
    for (final alloc in cleanedChangeDotAllocations) {
      changeDotQtyAgg[alloc.dotDenominationId] =
          (changeDotQtyAgg[alloc.dotDenominationId] ?? 0) + alloc.qty;
    }

    final List<ChangeDotStat> changeDotStats = [];
    for (final d in cleanedDenoms) {
      final qty = changeDotQtyAgg[d.id] ?? 0;
      if (qty > 0) {
        changeDotStats.add(ChangeDotStat(
          denomId: d.id,
          label: d.label,
          valueCents: d.valueCents,
          qtyGiven: qty,
          totalCents: qty * d.valueCents,
        ));
      }
    }
    // Sort change dot stats by total cents descending
    changeDotStats.sort((a, b) => b.totalCents.compareTo(a.totalCents));

    // Aggregate product stats
    final Map<int, (int qty, int cents)> productAgg = {};
    // Aggregate denom stats
    final Map<int, (int qty, int cents)> denomAgg = {};
    // Aggregate free value stats
    final Map<String, (int qty, int cents)> freeValueAgg = {};

    for (final line in cleanedLines) {
      if (line.lineKind == SaleLineKind.product && line.productId != null) {
        final current = productAgg[line.productId!] ?? (0, 0);
        productAgg[line.productId!] =
            (current.$1 + line.qty, current.$2 + line.lineTotalCents);
      } else if (line.lineKind == SaleLineKind.ficha &&
          line.dotDenominationId != null) {
        final current = denomAgg[line.dotDenominationId!] ?? (0, 0);
        denomAgg[line.dotDenominationId!] =
            (current.$1 + line.qty, current.$2 + line.lineTotalCents);
      } else if (line.lineKind == SaleLineKind.valorLivre) {
        final label = line.freeLabel ?? 'Valor avulso';
        final current = freeValueAgg[label] ?? (0, 0);
        freeValueAgg[label] =
            (current.$1 + line.qty, current.$2 + line.lineTotalCents);
      }
    }

    final List<ProductSaleStat> productStats = [];
    final List<ProductSaleStat> comboStats = [];

    for (final p in cleanedProducts) {
      final agg = productAgg[p.id] ?? (0, 0);
      final stat = ProductSaleStat(
        productId: p.id,
        name: p.name,
        qtySold: agg.$1,
        totalCents: agg.$2,
        trackStock: p.trackStock,
        remainingStock: p.stockQty,
        active: p.active,
        isCombo: p.isCombo,
      );
      productStats.add(stat);
      if (p.isCombo) {
        comboStats.add(stat);
      }
    }
    productStats.sort((a, b) {
      final cmp = b.qtySold.compareTo(a.qtySold);
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });
    comboStats.sort((a, b) {
      final cmp = b.qtySold.compareTo(a.qtySold);
      if (cmp != 0) return cmp;
      return a.name.compareTo(b.name);
    });

    final List<FichaSaleStat> fichaStats = [];
    for (final d in cleanedDenoms) {
      final agg = denomAgg[d.id] ?? (0, 0);
      fichaStats.add(FichaSaleStat(
        denomId: d.id,
        label: d.label,
        qtySold: agg.$1,
        totalCents: agg.$2,
        remainingStock: d.stockQty,
      ));
    }
    fichaStats.sort((a, b) => b.qtySold.compareTo(a.qtySold));

    final List<FreeValueSaleStat> freeValueStats = [];
    freeValueAgg.forEach((label, agg) {
      freeValueStats.add(FreeValueSaleStat(
        label: label,
        qtySold: agg.$1,
        totalCents: agg.$2,
      ));
    });
    freeValueStats.sort((a, b) => b.totalCents.compareTo(a.totalCents));

    // Aggregate hourly stats
    final Map<int, (int cents, int count)> hourlyAgg = {};
    for (final sale in cleanedSales) {
      final dt = DateTime.fromMillisecondsSinceEpoch(sale.soldAtMs);
      final hour = dt.hour;
      final current = hourlyAgg[hour] ?? (0, 0);
      hourlyAgg[hour] = (current.$1 + sale.totalCents, current.$2 + 1);
    }

    final List<HourlySaleStat> hourlyStats = [];
    final sortedHours = hourlyAgg.keys.toList()..sort();
    for (final hour in sortedHours) {
      final agg = hourlyAgg[hour]!;
      hourlyStats.add(HourlySaleStat(
        hourLabel: '${hour.toString().padLeft(2, '0')}h',
        totalCents: agg.$1,
        salesCount: agg.$2,
      ));
    }

    return EventDashboardData(
      totalSalesCount: totalSalesCount,
      totalRevenueCents: totalRevenueCents,
      averageTicketCents: averageTicketCents,
      revenueByPaymentMethod: revenueByPaymentMethod,
      salesCountByPaymentMethod: salesCountByPaymentMethod,
      averageTicketByPaymentMethod: averageTicketByPaymentMethod,
      totalPendingChangeCents: totalPendingChangeCents,
      pendingChangeSales: pendingChangeSales,
      changeDotStats: changeDotStats,
      productStats: productStats,
      comboStats: comboStats,
      fichaStats: fichaStats,
      freeValueStats: freeValueStats,
      hourlyStats: hourlyStats,
    );
  }
}

final eventSalesStreamProvider = StreamProvider.autoDispose.family<List<PosSale>, int>((ref, eventId) {
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    return ref.watch(syncClientStreamProvider((eventId, 'sales'))).map((list) => list.cast<PosSale>());
  }
  final db = ref.watch(appDatabaseProvider);
  return db.watchSalesForEvent(eventId);
});

final eventSaleLinesStreamProvider = StreamProvider.autoDispose.family<List<PosSaleLine>, int>((ref, eventId) {
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    return ref.watch(syncClientStreamProvider((eventId, 'lines'))).map((list) => list.cast<PosSaleLine>());
  }
  final db = ref.watch(appDatabaseProvider);
  return db.watchSaleLinesForEvent(eventId);
});

final eventProductsStreamProvider = StreamProvider.autoDispose.family<List<ChurchProduct>, int>((ref, eventId) {
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    return ref.watch(syncClientStreamProvider((eventId, 'products'))).map((list) => list.cast<ChurchProduct>());
  }
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllProductsForEvent(eventId);
});

final eventDenomsStreamProvider = StreamProvider.autoDispose.family<List<EventDotDenom>, int>((ref, eventId) {
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    return ref.watch(syncClientStreamProvider((eventId, 'denoms'))).map((list) => list.cast<EventDotDenom>());
  }
  final db = ref.watch(appDatabaseProvider);
  return db.watchDotDenominations(eventId);
});

final eventChangeDotAllocationsStreamProvider = StreamProvider.autoDispose.family<List<ChangeDotRow>, int>((ref, eventId) {
  final syncState = ref.watch(syncProvider);
  if (syncState.mode == SyncMode.client && syncState.isConnected) {
    return ref.watch(syncClientStreamProvider((eventId, 'changeDotAllocations'))).map((list) => list.cast<ChangeDotRow>());
  }
  final db = ref.watch(appDatabaseProvider);
  return db.watchChangeDotAllocationsForEvent(eventId);
});

final eventDashboardProvider = Provider.family<AsyncValue<EventDashboardData>, int>((ref, eventId) {
  final salesAsync = ref.watch(eventSalesStreamProvider(eventId));
  final linesAsync = ref.watch(eventSaleLinesStreamProvider(eventId));
  final productsAsync = ref.watch(eventProductsStreamProvider(eventId));
  final denomsAsync = ref.watch(eventDenomsStreamProvider(eventId));
  final changeDotAllocAsync = ref.watch(eventChangeDotAllocationsStreamProvider(eventId));

  if (salesAsync.isLoading ||
      linesAsync.isLoading ||
      productsAsync.isLoading ||
      denomsAsync.isLoading ||
      changeDotAllocAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (salesAsync.hasError) return AsyncValue.error(salesAsync.error!, salesAsync.stackTrace!);
  if (linesAsync.hasError) return AsyncValue.error(linesAsync.error!, linesAsync.stackTrace!);
  if (productsAsync.hasError) return AsyncValue.error(productsAsync.error!, productsAsync.stackTrace!);
  if (denomsAsync.hasError) return AsyncValue.error(denomsAsync.error!, denomsAsync.stackTrace!);
  if (changeDotAllocAsync.hasError) return AsyncValue.error(changeDotAllocAsync.error!, changeDotAllocAsync.stackTrace!);

  final sales = salesAsync.value!;
  final lines = linesAsync.value!;
  final products = productsAsync.value!;
  final denoms = denomsAsync.value!;
  final changeDotAllocations = changeDotAllocAsync.value!;

  final data = EventDashboardData.compute(
    sales: sales,
    lines: lines,
    products: products,
    denoms: denoms,
    changeDotAllocations: changeDotAllocations,
  );
  return AsyncValue.data(data);
});
