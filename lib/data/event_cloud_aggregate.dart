import 'package:drift/drift.dart';

import 'database.dart';

/// Versão do formato do agregado de evento enviado à nuvem.
/// Independente do schema Drift: muda quando a ESTRUTURA do JSON muda.
// v2: + fiadoPayments (venda fiada).
const kEventAggregateFormatVersion = 2;

/// Linhas brutas de um evento (INCLUINDO tombstones — diferente do snapshot
/// Wi-Fi, a nuvem precisa propagar exclusões lógicas).
class EventAggregateRows {
  EventAggregateRows({
    required this.event,
    required this.denoms,
    required this.products,
    required this.comboItems,
    required this.cashSessions,
    required this.sales,
    required this.saleLines,
    required this.changeAllocations,
    required this.fiadoPayments,
    required this.stockMovements,
  });

  final ChurchEvent event;
  final List<EventDotDenom> denoms;
  final List<ChurchProduct> products;
  final List<ProductComboItem> comboItems;
  final List<CashSession> cashSessions;
  final List<PosSale> sales;
  final List<PosSaleLine> saleLines;
  final List<ChangeDotRow> changeAllocations;
  final List<FiadoPayment> fiadoPayments;
  final List<StockMovement> stockMovements;

  int get rowCount =>
      1 +
      denoms.length +
      products.length +
      comboItems.length +
      cashSessions.length +
      sales.length +
      saleLines.length +
      changeAllocations.length +
      fiadoPayments.length +
      stockMovements.length;
}

/// Sincronização por evento: o evento é o agregado que viaja para a nuvem
/// como uma unidade (RFC v2, `docs/rfc_sincronizacao_nuvem_v2_por_evento.md`).
extension EventCloudAggregate on AppDatabase {
  /// Carrega todas as linhas do evento, sem filtrar tombstones.
  Future<EventAggregateRows?> loadEventAggregateRows(String eventId) async {
    final event = await (select(events)..where((e) => e.id.equals(eventId)))
        .getSingleOrNull();
    if (event == null) return null;

    final denoms = await (select(eventDotDenominations)
          ..where((d) => d.eventId.equals(eventId)))
        .get();
    final prods =
        await (select(products)..where((p) => p.eventId.equals(eventId))).get();
    final productIds = prods.map((p) => p.id).toList();
    final denomIds = denoms.map((d) => d.id).toList();

    final combos = productIds.isEmpty
        ? <ProductComboItem>[]
        : await (select(productComboItems)
              ..where((c) => c.comboProductId.isIn(productIds)))
            .get();
    final sessions = await (select(cashSessions)
          ..where((s) => s.eventId.equals(eventId)))
        .get();
    final salesRows =
        await (select(sales)..where((s) => s.eventId.equals(eventId))).get();
    final saleIds = salesRows.map((s) => s.id).toList();
    final lines = saleIds.isEmpty
        ? <PosSaleLine>[]
        : await (select(saleLines)..where((l) => l.saleId.isIn(saleIds))).get();
    final allocations = saleIds.isEmpty
        ? <ChangeDotRow>[]
        : await (select(saleChangeDotAllocations)
              ..where((a) => a.saleId.isIn(saleIds)))
            .get();
    final fiado = saleIds.isEmpty
        ? <FiadoPayment>[]
        : await (select(fiadoPayments)..where((f) => f.saleId.isIn(saleIds)))
            .get();
    final movements = await (select(stockMovements)
          ..where((m) =>
              (m.itemType.equals(AppDatabase.kStockItemProduct) &
                  m.itemId.isIn(productIds)) |
              (m.itemType.equals(AppDatabase.kStockItemDot) &
                  m.itemId.isIn(denomIds))))
        .get();

    return EventAggregateRows(
      event: event,
      denoms: denoms,
      products: prods,
      comboItems: combos,
      cashSessions: sessions,
      sales: salesRows,
      saleLines: lines,
      changeAllocations: allocations,
      fiadoPayments: fiado,
      stockMovements: movements,
    );
  }

  /// Exporta o agregado do evento como JSON (para gzip + envio).
  Future<Map<String, dynamic>?> exportEventAggregate(String eventId) async {
    final rows = await loadEventAggregateRows(eventId);
    if (rows == null) return null;
    return {
      'formatVersion': kEventAggregateFormatVersion,
      'schemaVersion': kAppSchemaVersion,
      'eventId': eventId,
      'event': rows.event.toJson(),
      'denoms': rows.denoms.map((e) => e.toJson()).toList(),
      'products': rows.products.map((e) => e.toJson()).toList(),
      'comboItems': rows.comboItems.map((e) => e.toJson()).toList(),
      'cashSessions': rows.cashSessions.map((e) => e.toJson()).toList(),
      'sales': rows.sales.map((e) => e.toJson()).toList(),
      'saleLines': rows.saleLines.map((e) => e.toJson()).toList(),
      'changeAllocations':
          rows.changeAllocations.map((e) => e.toJson()).toList(),
      'fiadoPayments': rows.fiadoPayments.map((e) => e.toJson()).toList(),
      'stockMovements': rows.stockMovements.map((e) => e.toJson()).toList(),
    };
  }

  /// Impressão digital do estado do evento, derivada dos próprios dados:
  /// muda sempre que algo é escrito (o `rowVersion` do v9 só cresce; exclusões
  /// são tombstones). `dirty` = fingerprint atual ≠ fingerprint do último
  /// envio — nenhuma flag mantida à mão.
  Future<String?> eventCloudFingerprint(String eventId) async {
    final rows = await loadEventAggregateRows(eventId);
    if (rows == null) return null;
    var versionSum = 0;
    var maxUpdated = 0;
    void fold(int rowVersion, int updatedAtMs) {
      versionSum += rowVersion;
      if (updatedAtMs > maxUpdated) maxUpdated = updatedAtMs;
    }

    fold(rows.event.rowVersion, rows.event.updatedAtMs);
    for (final r in rows.denoms) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.products) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.comboItems) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.cashSessions) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.sales) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.saleLines) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.changeAllocations) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.fiadoPayments) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    for (final r in rows.stockMovements) {
      fold(r.rowVersion, r.updatedAtMs);
    }
    return 'n${rows.rowCount}.v$versionSum.t$maxUpdated';
  }

  /// Aplica um agregado vindo da nuvem, substituindo o evento inteiro
  /// localmente (fast-forward). Roda sob bypass: os valores de
  /// `rowVersion`/`updatedAtMs` vêm prontos do outro aparelho.
  Future<void> applyEventAggregate(Map<String, dynamic> json) async {
    final formatVersion = (json['formatVersion'] as num?)?.toInt() ?? 0;
    if (formatVersion > kEventAggregateFormatVersion) {
      throw StateError(
          'Formato do snapshot mais novo que este app. Atualize o app.');
    }
    final schemaVersion = (json['schemaVersion'] as num?)?.toInt() ?? 0;
    if (schemaVersion > kAppSchemaVersion) {
      throw StateError(
          'Snapshot criado por uma versão mais nova do app. Atualize o app.');
    }

    final event =
        ChurchEvent.fromJson(json['event'] as Map<String, dynamic>);
    final eventId = event.id;
    List<T> parse<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      return (json[key] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    }

    final denoms = parse('denoms', EventDotDenom.fromJson);
    final prods = parse('products', ChurchProduct.fromJson);
    final combos = parse('comboItems', ProductComboItem.fromJson);
    final sessions = parse('cashSessions', CashSession.fromJson);
    final salesRows = parse('sales', PosSale.fromJson);
    final lines = parse('saleLines', PosSaleLine.fromJson);
    final allocations = parse('changeAllocations', ChangeDotRow.fromJson);
    final fiado = parse('fiadoPayments', FiadoPayment.fromJson);
    final movements = parse('stockMovements', StockMovement.fromJson);

    await runWithSyncBypass(() async {
      // 1. Limpar o estado local do evento (ordem respeita as referências).
      final localProducts = await (select(products)
            ..where((p) => p.eventId.equals(eventId)))
          .get();
      final localDenoms = await (select(eventDotDenominations)
            ..where((d) => d.eventId.equals(eventId)))
          .get();
      final localProductIds = localProducts.map((p) => p.id).toList();
      final localDenomIds = localDenoms.map((d) => d.id).toList();
      final localSales = await (select(sales)
            ..where((s) => s.eventId.equals(eventId)))
          .get();
      final localSaleIds = localSales.map((s) => s.id).toList();

      await (delete(stockMovements)
            ..where((m) =>
                (m.itemType.equals(AppDatabase.kStockItemProduct) &
                    m.itemId.isIn(localProductIds)) |
                (m.itemType.equals(AppDatabase.kStockItemDot) &
                    m.itemId.isIn(localDenomIds))))
          .go();
      if (localSaleIds.isNotEmpty) {
        await (delete(saleChangeDotAllocations)
              ..where((a) => a.saleId.isIn(localSaleIds)))
            .go();
        await (delete(fiadoPayments)
              ..where((f) => f.saleId.isIn(localSaleIds)))
            .go();
        await (delete(saleLines)..where((l) => l.saleId.isIn(localSaleIds)))
            .go();
      }
      await (delete(sales)..where((s) => s.eventId.equals(eventId))).go();
      await (delete(cashSessions)..where((s) => s.eventId.equals(eventId)))
          .go();
      if (localProductIds.isNotEmpty) {
        await (delete(productComboItems)
              ..where((c) =>
                  c.comboProductId.isIn(localProductIds) |
                  c.childProductId.isIn(localProductIds)))
            .go();
      }
      await (delete(products)..where((p) => p.eventId.equals(eventId))).go();
      await (delete(eventDotDenominations)
            ..where((d) => d.eventId.equals(eventId)))
          .go();

      // 2. Inserir o agregado remoto como veio.
      await into(events).insert(event, mode: InsertMode.insertOrReplace);
      for (final r in denoms) {
        await into(eventDotDenominations)
            .insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in prods) {
        await into(products).insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in combos) {
        await into(productComboItems)
            .insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in sessions) {
        await into(cashSessions).insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in salesRows) {
        await into(sales).insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in lines) {
        await into(saleLines).insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in allocations) {
        await into(saleChangeDotAllocations)
            .insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in fiado) {
        await into(fiadoPayments).insert(r, mode: InsertMode.insertOrReplace);
      }
      for (final r in movements) {
        await into(stockMovements).insert(r, mode: InsertMode.insertOrReplace);
      }
    });
  }
}
