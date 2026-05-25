import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/payment_method.dart';
import '../domain/stock_constants.dart';
import 'drift_database_paths.dart';
import '../domain/sale_line_kind.dart';
import 'package:uuid/uuid.dart';
import 'sale_line_draft.dart';

part 'database.g.dart';

const _uuid = Uuid();

@DataClassName('ChurchEvent')
class Events extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get dateEpochMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// “Fichas” / pontos do evento (valor unitário + estoque).
@DataClassName('EventDotDenom')
class EventDotDenominations extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get label => text()();
  IntColumn get valueCents => integer()();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ChurchProduct')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get priceCents => integer()();
  BoolColumn get trackStock => boolean().withDefault(const Constant(false))();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  BoolColumn get isCombo => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ProductComboItems extends Table {
  TextColumn get comboProductId => text().references(Products, #id)();
  TextColumn get childProductId => text().references(Products, #id)();
  IntColumn get qty => integer()();

  @override
  Set<Column> get primaryKey => {comboProductId, childProductId};
}

@DataClassName('PosSale')
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  IntColumn get soldAtMs => integer()();
  IntColumn get totalCents => integer()();
  IntColumn get amountReceivedCents => integer()();
  TextColumn get paymentMethod =>
      text().withDefault(const Constant(PaymentMethod.dinheiro))();
  TextColumn get notes => text().nullable()();
  BoolColumn get changePending => boolean().withDefault(const Constant(false))();
  TextColumn get customerName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PosSaleLine')
class SaleLines extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  IntColumn get lineKind => integer().withDefault(const Constant(0))();
  TextColumn get productId => text().nullable().references(Products, #id)();
  TextColumn get dotDenominationId =>
      text().nullable().references(EventDotDenominations, #id)();
  TextColumn get freeLabel => text().nullable()();
  IntColumn get qty => integer()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get lineTotalCents => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Fichas entregues como troco (auditoria + baixa de estoque).
@DataClassName('ChangeDotRow')
class SaleChangeDotAllocations extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get dotDenominationId =>
      text().references(EventDotDenominations, #id)();
  IntColumn get qty => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Linha de venda para exibição no registro do evento (sem dados do evento).
class EventSaleLineRow {
  EventSaleLineRow({
    required this.itemLabel,
    required this.qty,
    required this.unitPriceCents,
    required this.lineTotalCents,
  });

  final String itemLabel;
  final int qty;
  final int unitPriceCents;
  final int lineTotalCents;
}

class SaleLineExportRow {
  SaleLineExportRow({
    required this.soldAtMs,
    required this.eventTitle,
    required this.eventDateMs,
    required this.itemDescription,
    required this.qty,
    required this.unitPriceCents,
    required this.lineTotalCents,
    required this.saleTotalCents,
    required this.amountReceivedCents,
    required this.paymentMethod,
  });

  final int soldAtMs;
  final String eventTitle;
  final int eventDateMs;
  final String itemDescription;
  final int qty;
  final int unitPriceCents;
  final int lineTotalCents;
  final int saleTotalCents;
  final int amountReceivedCents;
  final String paymentMethod;

  int get changeCents => amountReceivedCents - saleTotalCents;
}

/// Agregação por método de pagamento (totais de venda).
class PaymentMethodBreakdown {
  const PaymentMethodBreakdown({
    required this.method,
    required this.saleCount,
    required this.totalCents,
  });

  final String method;
  final int saleCount;
  final int totalCents;
}

/// Resumo financeiro de um evento (vendas agregadas).
class EventFinanceSummary {
  const EventFinanceSummary({
    required this.saleCount,
    required this.totalCents,
    required this.cashChangeGivenCents,
    required this.byMethod,
  });

  final int saleCount;
  final int totalCents;

  /// Troco em dinheiro devolvido ao cliente (soma de `recebido - total` quando
  /// método é dinheiro e o valor é positivo).
  final int cashChangeGivenCents;
  final List<PaymentMethodBreakdown> byMethod;

  static EventFinanceSummary fromSales(List<PosSale> sales) {
    if (sales.isEmpty) {
      return const EventFinanceSummary(
        saleCount: 0,
        totalCents: 0,
        cashChangeGivenCents: 0,
        byMethod: [],
      );
    }
    final map = <String, ({int n, int cents})>{};
    var total = 0;
    var cashChange = 0;
    for (final s in sales) {
      final sDyn = s as dynamic;
      final sTotalCents = sDyn.totalCents as int? ?? 0;
      final sAmountReceivedCents = sDyn.amountReceivedCents as int? ?? sTotalCents;
      final sPaymentMethod = sDyn.paymentMethod as String? ?? PaymentMethod.dinheiro;

      total += sTotalCents;
      final cur = map[sPaymentMethod];
      if (cur == null) {
        map[sPaymentMethod] = (n: 1, cents: sTotalCents);
      } else {
        map[sPaymentMethod] = (n: cur.n + 1, cents: cur.cents + sTotalCents);
      }
      if (sPaymentMethod == PaymentMethod.dinheiro) {
        final ch = sAmountReceivedCents - sTotalCents;
        if (ch > 0) cashChange += ch;
      }
    }
    final byMethod = map.entries
        .map(
          (e) => PaymentMethodBreakdown(
            method: e.key,
            saleCount: e.value.n,
            totalCents: e.value.cents,
          ),
        )
        .toList()
      ..sort((a, b) => b.totalCents.compareTo(a.totalCents));
    return EventFinanceSummary(
      saleCount: sales.length,
      totalCents: total,
      cashChangeGivenCents: cashChange,
      byMethod: byMethod,
    );
  }
}

/// Contagens de itens com stock baixo (produtos com rastreio + fichas).
class EventLowStockCounts {
  const EventLowStockCounts({
    required this.lowProductCount,
    required this.lowDotCount,
  });

  final int lowProductCount;
  final int lowDotCount;

  bool get hasAny => lowProductCount > 0 || lowDotCount > 0;
}

@DriftDatabase(
  tables: [
    Events,
    EventDotDenominations,
    Products,
    ProductComboItems,
    Sales,
    SaleLines,
    SaleChangeDotAllocations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(eventDotDenominations);
            await m.createTable(saleChangeDotAllocations);
            await m.addColumn(sales, sales.paymentMethod);
            await customStatement('''
PRAGMA foreign_keys = OFF;
CREATE TABLE sale_lines_new (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  sale_id INTEGER NOT NULL,
  line_kind INTEGER NOT NULL DEFAULT 0,
  product_id INTEGER,
  dot_denomination_id INTEGER,
  free_label TEXT,
  qty INTEGER NOT NULL,
  unit_price_cents INTEGER NOT NULL,
  line_total_cents INTEGER NOT NULL,
  FOREIGN KEY (sale_id) REFERENCES sales (id) ON UPDATE NO ACTION ON DELETE NO ACTION,
  FOREIGN KEY (product_id) REFERENCES products (id) ON UPDATE NO ACTION ON DELETE NO ACTION,
  FOREIGN KEY (dot_denomination_id) REFERENCES event_dot_denominations (id) ON UPDATE NO ACTION ON DELETE NO ACTION
);
INSERT INTO sale_lines_new (id, sale_id, line_kind, product_id, dot_denomination_id, free_label, qty, unit_price_cents, line_total_cents)
SELECT id, sale_id, 0, product_id, NULL, NULL, qty, unit_price_cents, line_total_cents FROM sale_lines;
DROP TABLE sale_lines;
ALTER TABLE sale_lines_new RENAME TO sale_lines;
PRAGMA foreign_keys = ON;
''');
          }
          if (from < 3) {
            // Produtos passam a pertencer a um evento; dados antigos vão para um evento “legado” se necessário.
            await customStatement('''
INSERT INTO events (title, notes, date_epoch_ms)
SELECT 'Catálogo legado', 'Criado na migração: produtos sem evento.', 0
WHERE NOT EXISTS (SELECT 1 FROM events LIMIT 1);
''');
            await customStatement('''
PRAGMA foreign_keys = OFF;
CREATE TABLE products_new (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  event_id INTEGER NOT NULL REFERENCES events (id) ON UPDATE NO ACTION ON DELETE NO ACTION,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  price_cents INTEGER NOT NULL,
  track_stock INTEGER NOT NULL DEFAULT 0,
  stock_qty INTEGER NOT NULL DEFAULT 0,
  active INTEGER NOT NULL DEFAULT 1
);
INSERT INTO products_new (id, event_id, name, description, price_cents, track_stock, stock_qty, active)
SELECT
  p.id,
  COALESCE(
    (SELECT e.id FROM events e ORDER BY e.date_epoch_ms DESC, e.id DESC LIMIT 1),
    (SELECT e2.id FROM events e2 ORDER BY e2.id ASC LIMIT 1)
  ),
  p.name,
  p.description,
  p.price_cents,
  p.track_stock,
  p.stock_qty,
  p.active
FROM products p;
DROP TABLE products;
ALTER TABLE products_new RENAME TO products;
CREATE INDEX IF NOT EXISTS products_event_id_idx ON products (event_id);
PRAGMA foreign_keys = ON;
''');
          }
          if (from < 4) {
            await m.addColumn(sales, sales.notes);
            await m.addColumn(sales, sales.changePending);
            await m.addColumn(sales, sales.customerName);
          }
          if (from < 5) {
            await m.addColumn(products, products.isCombo);
            await m.createTable(productComboItems);
          }
          if (from < 6) {
            // Migração de quebra de esquema estrutural (int para UUID String).
            // Dropamos as tabelas na ordem inversa de dependência e recriamos do zero.
            await customStatement('PRAGMA foreign_keys = OFF;');
            final tablesToDrop = [
              'sale_change_dot_allocations',
              'sale_lines',
              'sales',
              'product_combo_items',
              'products',
              'event_dot_denominations',
              'events'
            ];
            for (final table in tablesToDrop) {
              await customStatement('DROP TABLE IF EXISTS $table;');
            }
            await customStatement('PRAGMA foreign_keys = ON;');
            await m.createAll();
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: kCaixaIgrejaDriftDbName);
  }

  String generateUuid() => _uuid.v7();

  Stream<ChurchEvent?> watchEvent(String id) {
    return (select(events)..where((e) => e.id.equals(id)))
        .watchSingleOrNull();
  }

  Stream<List<EventDotDenom>> watchDotDenominations(String eventId) {
    return (select(eventDotDenominations)
          ..where((t) => t.eventId.equals(eventId))
          ..orderBy([(t) => OrderingTerm.desc(t.valueCents)]))
        .watch();
  }

  Future<List<ChurchProduct>> _mapProductsWithEffectiveStock(List<ChurchProduct> prods) async {
    final List<ChurchProduct> mapped = [];
    for (final p in prods) {
      final pDyn = p as dynamic;
      final pIsCombo = pDyn.isCombo as bool? ?? false;
      final pId = pDyn.id as String? ?? '';

      if (pIsCombo) {
        final items = await (select(productComboItems)..where((t) => t.comboProductId.equals(pId))).get();
        int? effectiveStock;
        bool tracksStock = false;
        for (final item in items) {
          final itemDyn = item as dynamic;
          final childId = itemDyn.childProductId as String? ?? '';
          final itemQty = itemDyn.qty as int? ?? 1;

          final child = await (select(products)..where((t) => t.id.equals(childId))).getSingleOrNull();
          if (child != null) {
            final childDyn = child as dynamic;
            final childTrackStock = childDyn.trackStock as bool? ?? false;
            final childStockQty = childDyn.stockQty as int? ?? 0;

            if (childTrackStock) {
              tracksStock = true;
              final qtyDiv = itemQty > 0 ? itemQty : 1;
              final possible = childStockQty ~/ qtyDiv;
              if (effectiveStock == null || possible < effectiveStock) {
                effectiveStock = possible;
              }
            }
          }
        }
        mapped.add(p.copyWith(
          trackStock: tracksStock,
          stockQty: effectiveStock ?? 0,
        ));
      } else {
        mapped.add(p);
      }
    }
    return mapped;
  }

  Stream<List<ChurchProduct>> watchActiveProductsForEvent(String eventId) {
    return (select(products)
          ..where((p) => p.eventId.equals(eventId))
          ..where((p) => p.active.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch()
        .asyncMap(_mapProductsWithEffectiveStock);
  }

  Stream<List<ChurchProduct>> watchAllProductsForEvent(String eventId) {
    return (select(products)
          ..where((p) => p.eventId.equals(eventId))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch()
        .asyncMap(_mapProductsWithEffectiveStock);
  }

  Stream<List<ChurchEvent>> watchAllEvents() {
    return (select(events)..orderBy([(e) => OrderingTerm.desc(e.dateEpochMs)]))
        .watch();
  }

  /// Vendas do evento, mais recentes primeiro (registro / livro-caixa).
  Stream<List<PosSale>> watchSalesForEvent(String eventId) {
    return (select(sales)
          ..where((s) => s.eventId.equals(eventId))
          ..orderBy([(s) => OrderingTerm.desc(s.soldAtMs)]))
        .watch();
  }

  Stream<List<PosSaleLine>> watchSaleLinesForEvent(String eventId) {
    final q = select(saleLines).join([
      innerJoin(sales, sales.id.equalsExp(saleLines.saleId)),
    ])..where(sales.eventId.equals(eventId));
    return q.watch().map((rows) => rows.map((r) => r.readTable(saleLines)).toList());
  }

  Stream<List<ChangeDotRow>> watchChangeDotAllocationsForEvent(String eventId) {
    final q = select(saleChangeDotAllocations).join([
      innerJoin(sales, sales.id.equalsExp(saleChangeDotAllocations.saleId)),
    ])..where(sales.eventId.equals(eventId));
    return q.watch().map((rows) => rows.map((r) => r.readTable(saleChangeDotAllocations)).toList());
  }

  Stream<EventFinanceSummary> watchEventFinanceSummary(String eventId) {
    return (select(sales)..where((s) => s.eventId.equals(eventId)))
        .watch()
        .map(EventFinanceSummary.fromSales);
  }

  Future<EventFinanceSummary> eventFinanceSummary(String eventId) {
    return (select(sales)..where((s) => s.eventId.equals(eventId)))
        .get()
        .then(EventFinanceSummary.fromSales);
  }

  Stream<EventLowStockCounts> watchEventLowStockCounts(String eventId) {
    final threshold = kLowStockThreshold;
    late StreamSubscription<List<ChurchProduct>> sub1;
    late StreamSubscription<List<EventDotDenom>> sub2;
    var latestP = <ChurchProduct>[];
    var latestD = <EventDotDenom>[];

    late final StreamController<EventLowStockCounts> controller;

    void emit() {
      if (controller.isClosed) return;
      final lowP = latestP
          .where(
            (p) {
              final pDyn = p as dynamic;
              final active = pDyn.active as bool? ?? true;
              final trackStock = pDyn.trackStock as bool? ?? false;
              final stockQty = pDyn.stockQty as int? ?? 0;
              return active && trackStock && stockQty <= threshold;
            },
          )
          .length;
      final lowD = latestD.where((d) {
        final dDyn = d as dynamic;
        final stockQty = dDyn.stockQty as int? ?? 0;
        return stockQty <= threshold;
      }).length;
      controller.add(EventLowStockCounts(lowProductCount: lowP, lowDotCount: lowD));
    }

    controller = StreamController<EventLowStockCounts>(
      onListen: () {
        sub1 = (select(products)..where((p) => p.eventId.equals(eventId)))
            .watch()
            .asyncMap(_mapProductsWithEffectiveStock)
            .listen((list) {
          latestP = list;
          emit();
        });
        sub2 =
            (select(eventDotDenominations)..where((d) => d.eventId.equals(eventId)))
                .watch()
                .listen((list) {
          latestD = list;
          emit();
        });
      },
      onCancel: () {
        sub1.cancel();
        sub2.cancel();
      },
    );

    return controller.stream;
  }

  Future<List<EventSaleLineRow>> saleLinesForSale(String saleId) async {
    final q = select(saleLines).join([
      innerJoin(sales, sales.id.equalsExp(saleLines.saleId)),
      leftOuterJoin(
        products,
        products.id.equalsExp(saleLines.productId) &
            products.eventId.equalsExp(sales.eventId),
      ),
      leftOuterJoin(
        eventDotDenominations,
        eventDotDenominations.id.equalsExp(saleLines.dotDenominationId),
      ),
    ])
      ..where(saleLines.saleId.equals(saleId))
      ..orderBy([OrderingTerm.asc(saleLines.id)]);

    final rows = await q.get();
    final result = <EventSaleLineRow>[];

    for (final row in rows) {
      final sl = row.readTable(saleLines);
      final p = row.readTableOrNull(products);
      final d = row.readTableOrNull(eventDotDenominations);
      
      String itemLabel;
      final slDyn = sl as dynamic;
      final slLineKind = slDyn.lineKind as int? ?? 0;
      final slQty = slDyn.qty as int? ?? 0;
      final slUnitPriceCents = slDyn.unitPriceCents as int? ?? 0;
      final slLineTotalCents = slDyn.lineTotalCents as int? ?? (slQty * slUnitPriceCents);

      if (slLineKind == SaleLineKind.valorLivre) {
        itemLabel = 'Valor: ${slDyn.freeLabel ?? ''}';
      } else if (slLineKind == SaleLineKind.ficha) {
        final dLabel = d != null ? (d as dynamic).label as String? : null;
        final dId = slDyn.dotDenominationId;
        itemLabel = 'Ficha: ${dLabel ?? '#$dId'}';
      } else {
        if (p != null) {
          final pDyn = p as dynamic;
          final pIsCombo = pDyn.isCombo as bool? ?? false;
          final pName = pDyn.name as String? ?? 'Produto';
          final pId = pDyn.id as String? ?? '';
          if (pIsCombo) {
            final comboItems = await getComboItems(pId);
            final parts = <String>[];
            for (final item in comboItems) {
              final itemDyn = item as dynamic;
              final childId = itemDyn.childProductId as String? ?? '';
              final child = await (select(products)..where((t) => t.id.equals(childId))).getSingleOrNull();
              if (child != null) {
                final childName = (child as dynamic).name as String? ?? 'Produto';
                parts.add('${itemDyn.qty}x $childName');
              }
            }
            if (parts.isNotEmpty) {
              itemLabel = '📦 $pName (${parts.join(', ')})';
            } else {
              itemLabel = '📦 $pName';
            }
          } else {
            itemLabel = pName;
          }
        } else {
          itemLabel = 'Produto #${slDyn.productId}';
        }
      }

      result.add(EventSaleLineRow(
        itemLabel: itemLabel,
        qty: slQty,
        unitPriceCents: slUnitPriceCents,
        lineTotalCents: slLineTotalCents,
      ));
    }

    return result;
  }

  Future<List<ChurchEvent>> eventsForDayMs(int dayStartMs) {
    return (select(events)..where((e) => e.dateEpochMs.equals(dayStartMs)))
        .get();
  }

  Future<void> _validateProductStock(String productId, int qtyMultiplier) async {
    final p = await (select(products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (p == null) return;
    if (p.isCombo) {
      final children = await (select(productComboItems)..where((t) => t.comboProductId.equals(productId))).get();
      for (final child in children) {
        await _validateProductStock(child.childProductId, child.qty * qtyMultiplier);
      }
    } else {
      if (p.trackStock && p.stockQty < qtyMultiplier) {
        throw StateError('Estoque insuficiente para ${p.name}');
      }
    }
  }

  Future<void> _abateProductStock(String productId, int qtyMultiplier) async {
    final p = await (select(products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (p == null) return;
    if (p.isCombo) {
      final children = await (select(productComboItems)..where((t) => t.comboProductId.equals(productId))).get();
      for (final child in children) {
        await _abateProductStock(child.childProductId, child.qty * qtyMultiplier);
      }
    } else {
      if (p.trackStock) {
        if (p.stockQty < qtyMultiplier) {
          throw StateError('Estoque insuficiente para ${p.name}');
        }
        await (update(products)..where((t) => t.id.equals(productId))).write(
          ProductsCompanion(stockQty: Value(p.stockQty - qtyMultiplier)),
        );
      }
    }
  }

  Future<void> _revertProductStock(String productId, int qtyMultiplier) async {
    final p = await (select(products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (p == null) return;
    if (p.isCombo) {
      final children = await (select(productComboItems)..where((t) => t.comboProductId.equals(productId))).get();
      for (final child in children) {
        await _revertProductStock(child.childProductId, child.qty * qtyMultiplier);
      }
    } else {
      if (p.trackStock) {
        await (update(products)..where((t) => t.id.equals(productId))).write(
          ProductsCompanion(stockQty: Value(p.stockQty + qtyMultiplier)),
        );
      }
    }
  }

  /// Venda completa: linhas (produto, valor livre ou ficha), pagamento e estoques.
  Future<String> completeSale({
    required String eventId,
    required String paymentMethod,
    required int amountReceivedCents,
    String? notes,
    bool changePending = false,
    String? customerName,
    required List<SaleLineDraft> lines,
  }) {
    if (lines.isEmpty) {
      throw ArgumentError('Carrinho vazio');
    }

    return transaction(() async {
      var totalCents = 0;
      for (final l in lines) {
        if (l.qty <= 0 && l.kind != SaleLineKind.valorLivre) {
          throw ArgumentError('Quantidade inválida');
        }
        totalCents += l.resolveLineTotalCents();
      }
      if (amountReceivedCents < totalCents) {
        throw ArgumentError('Valor recebido menor que o total');
      }

      for (final l in lines) {
        switch (l.kind) {
          case SaleLineKind.product:
            final pid = l.productId;
            if (pid == null) throw ArgumentError('Produto inválido');
            final p = await (select(products)
                  ..where((t) => t.id.equals(pid))
                  ..where((t) => t.eventId.equals(eventId)))
                .getSingleOrNull();
            if (p == null) throw StateError('Produto não encontrado neste evento');
            if (!p.active) throw StateError('Produto inativo: ${p.name}');
            await _validateProductStock(pid, l.qty);
            if (l.unitPriceCents != p.priceCents) {
              throw StateError('Preço do produto alterado; atualize o carrinho');
            }
            break;
          case SaleLineKind.valorLivre:
            if ((l.freeLabel ?? '').trim().isEmpty) {
              throw ArgumentError('Descrição do valor avulso obrigatória');
            }
            if ((l.lineTotalCents ?? 0) <= 0) {
              throw ArgumentError('Valor avulso inválido');
            }
            break;
          case SaleLineKind.ficha:
            final did = l.dotDenominationId;
            if (did == null) throw ArgumentError('Ficha inválida');
            final d =
                await (select(eventDotDenominations)..where((t) => t.id.equals(did)))
                    .getSingleOrNull();
            if (d == null) throw StateError('Denominação não encontrada');
            if (d.eventId != eventId) {
              throw StateError('Ficha não pertence a este evento');
            }
            if (d.stockQty < l.qty) {
              throw StateError('Estoque de fichas insuficiente (${d.label})');
            }
            if (l.unitPriceCents != d.valueCents) {
              throw StateError('Valor da ficha alterado; atualize o carrinho');
            }
            break;
          default:
            throw ArgumentError('Tipo de linha desconhecido');
        }
      }

      final soldAt = DateTime.now().millisecondsSinceEpoch;
      final saleId = _uuid.v7();
      await into(sales).insert(
        SalesCompanion.insert(
          id: saleId,
          eventId: eventId,
          soldAtMs: soldAt,
          totalCents: totalCents,
          amountReceivedCents: amountReceivedCents,
          paymentMethod: Value(paymentMethod),
          notes: Value(notes),
          changePending: Value(changePending),
          customerName: Value(customerName),
        ),
      );

      for (final l in lines) {
        final lineTotal = l.resolveLineTotalCents();
        final unit = l.resolveUnitPriceCents();
        final lineId = _uuid.v7();

        await into(saleLines).insert(
          SaleLinesCompanion.insert(
            id: lineId,
            saleId: saleId,
            lineKind: Value(l.kind),
            productId: Value(l.productId),
            dotDenominationId: Value(l.dotDenominationId),
            freeLabel: Value(l.freeLabel),
            qty: l.kind == SaleLineKind.valorLivre ? 1 : l.qty,
            unitPriceCents: unit,
            lineTotalCents: lineTotal,
          ),
        );

        switch (l.kind) {
          case SaleLineKind.product:
            final pid = l.productId!;
            await _abateProductStock(pid, l.qty);
            break;
          case SaleLineKind.ficha:
            final did = l.dotDenominationId!;
            final d = await (select(eventDotDenominations)
                  ..where((t) => t.id.equals(did)))
                .getSingle();
            await (update(eventDotDenominations)
                  ..where((t) => t.id.equals(did))).write(
              EventDotDenominationsCompanion(
                stockQty: Value(d.stockQty - l.qty),
              ),
            );
            break;
          case SaleLineKind.valorLivre:
            break;
        }
      }

      return saleId;
    });
  }

  /// Atualiza a venda revertendo as linhas antigas e inserindo novas,
  /// atualizando o valor recebido, método, etc, mas mantendo a mesma saleId.
  Future<void> updateSaleWithLines({
    required String saleId,
    required String eventId,
    required String paymentMethod,
    required int amountReceivedCents,
    String? notes,
    bool changePending = false,
    String? customerName,
    required List<SaleLineDraft> lines,
  }) {
    if (lines.isEmpty) {
      throw ArgumentError('Carrinho vazio');
    }

    return transaction(() async {
      // 1. Validar a venda original
      final sale = await (select(sales)..where((s) => s.id.equals(saleId))).getSingleOrNull();
      if (sale == null) throw StateError('Venda não encontrada');
      if (sale.eventId != eventId) throw StateError('Evento da venda inconsistente');

      // 2. Reverter os estoques e deletar linhas antigas e troco
      final oldLines = await (select(saleLines)..where((l) => l.saleId.equals(saleId))).get();
      for (final l in oldLines) {
        if (l.lineKind == SaleLineKind.product && l.productId != null) {
          await _revertProductStock(l.productId!, l.qty);
        } else if (l.lineKind == SaleLineKind.ficha && l.dotDenominationId != null) {
          final d = await (select(eventDotDenominations)..where((t) => t.id.equals(l.dotDenominationId!))).getSingleOrNull();
          if (d != null) {
            await (update(eventDotDenominations)..where((t) => t.id.equals(d.id))).write(
              EventDotDenominationsCompanion(stockQty: Value(d.stockQty + l.qty)),
            );
          }
        }
      }

      final changeAllocations = await (select(saleChangeDotAllocations)..where((t) => t.saleId.equals(saleId))).get();
      for (final a in changeAllocations) {
        final d = await (select(eventDotDenominations)..where((t) => t.id.equals(a.dotDenominationId))).getSingleOrNull();
        if (d != null) {
          await (update(eventDotDenominations)..where((t) => t.id.equals(d.id))).write(
            EventDotDenominationsCompanion(stockQty: Value(d.stockQty + a.qty)),
          );
        }
      }
      await (delete(saleChangeDotAllocations)..where((t) => t.saleId.equals(saleId))).go();
      await (delete(saleLines)..where((t) => t.saleId.equals(saleId))).go();

      // 3. Validar novos itens e calcular novo total
      var totalCents = 0;
      for (final l in lines) {
        if (l.qty <= 0 && l.kind != SaleLineKind.valorLivre) {
          throw ArgumentError('Quantidade inválida');
        }
        totalCents += l.resolveLineTotalCents();
      }
      if (amountReceivedCents < totalCents) {
        throw ArgumentError('Valor recebido menor que o total');
      }

      for (final l in lines) {
        switch (l.kind) {
          case SaleLineKind.product:
            final pid = l.productId;
            if (pid == null) throw ArgumentError('Produto inválido');
            final p = await (select(products)
                  ..where((t) => t.id.equals(pid))
                  ..where((t) => t.eventId.equals(eventId)))
                .getSingleOrNull();
            if (p == null) throw StateError('Produto não encontrado neste evento');
            if (!p.active) throw StateError('Produto inativo: ${p.name}');
            await _validateProductStock(pid, l.qty);
            if (l.unitPriceCents != p.priceCents) {
              throw StateError('Preço do produto alterado; atualize o carrinho');
            }
            break;
          case SaleLineKind.valorLivre:
            if ((l.freeLabel ?? '').trim().isEmpty) {
              throw ArgumentError('Descrição do valor avulso obrigatória');
            }
            if ((l.lineTotalCents ?? 0) <= 0) {
              throw ArgumentError('Valor avulso inválido');
            }
            break;
          case SaleLineKind.ficha:
            final did = l.dotDenominationId;
            if (did == null) throw ArgumentError('Ficha inválida');
            final d = await (select(eventDotDenominations)..where((t) => t.id.equals(did))).getSingleOrNull();
            if (d == null) throw StateError('Denominação não encontrada');
            if (d.eventId != eventId) {
              throw StateError('Ficha não pertence a este evento');
            }
            if (d.stockQty < l.qty) {
              throw StateError('Estoque de fichas insuficiente (${d.label})');
            }
            if (l.unitPriceCents != d.valueCents) {
              throw StateError('Valor da ficha alterado; atualize o carrinho');
            }
            break;
          default:
            throw ArgumentError('Tipo de linha desconhecido');
        }
      }

      // 4. Atualizar os dados da venda original
      await updateSaleDetails(
        saleId: saleId,
        paymentMethod: paymentMethod,
        amountReceivedCents: amountReceivedCents,
        notes: notes,
        changePending: changePending,
        customerName: customerName,
      );
      await (update(sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(totalCents: Value(totalCents)),
      );

      // 5. Inserir novas linhas e abater novos estoques
      for (final l in lines) {
        final lineTotal = l.resolveLineTotalCents();
        final unit = l.resolveUnitPriceCents();
        final lineId = _uuid.v7();

        await into(saleLines).insert(
          SaleLinesCompanion.insert(
            id: lineId,
            saleId: saleId,
            lineKind: Value(l.kind),
            productId: Value(l.productId),
            dotDenominationId: Value(l.dotDenominationId),
            freeLabel: Value(l.freeLabel),
            qty: l.kind == SaleLineKind.valorLivre ? 1 : l.qty,
            unitPriceCents: unit,
            lineTotalCents: lineTotal,
          ),
        );

        switch (l.kind) {
          case SaleLineKind.product:
            final pid = l.productId!;
            await _abateProductStock(pid, l.qty);
            break;
          case SaleLineKind.ficha:
            final did = l.dotDenominationId!;
            final d = await (select(eventDotDenominations)..where((t) => t.id.equals(did))).getSingle();
            await (update(eventDotDenominations)..where((t) => t.id.equals(did))).write(
              EventDotDenominationsCompanion(stockQty: Value(d.stockQty - l.qty)),
            );
            break;
          case SaleLineKind.valorLivre:
            break;
        }
      }
    });
  }

  /// Registra fichas dadas no troco (soma deve ser igual ao troco).
  Future<void> confirmChangeDots({
    required String saleId,
    required String eventId,
    required int changeCents,
    required List<({String dotDenominationId, int qty})> allocation,
  }) {
    return transaction(() async {
      if (changeCents <= 0) return;
      final sale = await (select(sales)..where((s) => s.id.equals(saleId)))
          .getSingleOrNull();
      if (sale == null) throw StateError('Venda não encontrada');
      if (sale.eventId != eventId) throw StateError('Evento inconsistente');
      final actualChange = sale.amountReceivedCents - sale.totalCents;
      if (actualChange != changeCents) {
        throw StateError('Troco não confere com a venda');
      }
      if (sale.paymentMethod != PaymentMethod.dinheiro) {
        throw StateError('Troco em fichas só para pagamento em dinheiro');
      }

      final denoms = await (select(eventDotDenominations)
            ..where((d) => d.eventId.equals(eventId)))
          .get();
      final byId = {for (final d in denoms) d.id: d};

      var sum = 0;
      for (final a in allocation) {
        if (a.qty <= 0) continue;
        final d = byId[a.dotDenominationId];
        if (d == null) throw StateError('Denominação inválida');
        sum += a.qty * d.valueCents;
      }
      if (sum != changeCents) {
        throw ArgumentError(
          'Fichas devem somar exatamente o troco ($changeCents centavos). '
          'Soma atual: $sum',
        );
      }

      final merged = <String, int>{};
      for (final a in allocation) {
        if (a.qty <= 0) continue;
        merged[a.dotDenominationId] =
            (merged[a.dotDenominationId] ?? 0) + a.qty;
      }
      for (final e in merged.entries) {
        final d = byId[e.key];
        if (d == null || d.stockQty < e.value) {
          throw StateError('Estoque insuficiente para fichas');
        }
      }

      for (final a in allocation) {
        if (a.qty <= 0) continue;
        final fresh = await (select(eventDotDenominations)
              ..where((t) => t.id.equals(a.dotDenominationId)))
            .getSingle();
        final allocId = _uuid.v7();
        await into(saleChangeDotAllocations).insert(
          SaleChangeDotAllocationsCompanion.insert(
            id: allocId,
            saleId: saleId,
            dotDenominationId: a.dotDenominationId,
            qty: a.qty,
          ),
        );
        await (update(eventDotDenominations)
              ..where((t) => t.id.equals(a.dotDenominationId)))
            .write(
          EventDotDenominationsCompanion(
            stockQty: Value(fresh.stockQty - a.qty),
          ),
        );
      }
    });
  }

  /// Linhas de venda (itens) de um único evento, ordenadas por data da venda.
  Future<List<SaleLineExportRow>> exportSaleLinesForEvent(String eventId) async {
    final q = select(saleLines).join([
      innerJoin(sales, sales.id.equalsExp(saleLines.saleId)),
      innerJoin(events, events.id.equalsExp(sales.eventId)),
      leftOuterJoin(
        products,
        products.id.equalsExp(saleLines.productId) &
            products.eventId.equalsExp(sales.eventId),
      ),
      leftOuterJoin(
        eventDotDenominations,
        eventDotDenominations.id.equalsExp(saleLines.dotDenominationId),
      ),
    ])
      ..where(sales.eventId.equals(eventId))
      ..orderBy([
        OrderingTerm.asc(sales.soldAtMs),
        OrderingTerm.asc(saleLines.id),
      ]);

    return q.map((row) {
      final sl = row.readTable(saleLines);
      final s = row.readTable(sales);
      final e = row.readTable(events);
      final p = row.readTableOrNull(products);
      final d = row.readTableOrNull(eventDotDenominations);

      final item = switch (sl.lineKind) {
        SaleLineKind.valorLivre => 'Valor: ${sl.freeLabel ?? ''}',
        SaleLineKind.ficha => 'Ficha: ${d?.label ?? '#${sl.dotDenominationId}'}',
        _ => p?.name ?? 'Produto #${sl.productId}',
      };

      return SaleLineExportRow(
        soldAtMs: s.soldAtMs,
        eventTitle: e.title,
        eventDateMs: e.dateEpochMs,
        itemDescription: item,
        qty: sl.qty,
        unitPriceCents: sl.unitPriceCents,
        lineTotalCents: sl.lineTotalCents,
        saleTotalCents: s.totalCents,
        amountReceivedCents: s.amountReceivedCents,
        paymentMethod: s.paymentMethod,
      );
    }).get();
  }

  Future<String> createCombo({
    required String eventId,
    required String name,
    required int priceCents,
    String description = '',
    bool active = true,
    required List<({String childProductId, int qty})> items,
  }) {
    return transaction(() async {
      final comboId = _uuid.v7();
      await into(products).insert(
        ProductsCompanion.insert(
          id: comboId,
          eventId: eventId,
          name: name,
          priceCents: priceCents,
          description: Value(description),
          trackStock: const Value(false),
          isCombo: const Value(true),
          active: Value(active),
        ),
      );
      for (final item in items) {
        if (item.qty <= 0) continue;
        await into(productComboItems).insert(
          ProductComboItemsCompanion.insert(
            comboProductId: comboId,
            childProductId: item.childProductId,
            qty: item.qty,
          ),
        );
      }
      return comboId;
    });
  }

  Future<void> updateCombo({
    required String comboProductId,
    required String name,
    required int priceCents,
    String description = '',
    bool active = true,
    required List<({String childProductId, int qty})> items,
  }) {
    return transaction(() async {
      await (update(products)..where((t) => t.id.equals(comboProductId))).write(
        ProductsCompanion(
          name: Value(name),
          priceCents: Value(priceCents),
          description: Value(description),
          active: Value(active),
        ),
      );
      await (delete(productComboItems)..where((t) => t.comboProductId.equals(comboProductId))).go();
      for (final item in items) {
        if (item.qty <= 0) continue;
        await into(productComboItems).insert(
          ProductComboItemsCompanion.insert(
            comboProductId: comboProductId,
            childProductId: item.childProductId,
            qty: item.qty,
          ),
        );
      }
    });
  }

  Future<List<ProductComboItem>> getComboItems(String comboId) {
    return (select(productComboItems)..where((t) => t.comboProductId.equals(comboId))).get();
  }

  Future<List<ProductComboItem>> getComboItemsForEvent(String eventId) async {
    final query = select(productComboItems).join([
      innerJoin(products, products.id.equalsExp(productComboItems.comboProductId)),
    ])..where(products.eventId.equals(eventId));
    final rows = await query.get();
    return rows.map((row) => row.readTable(productComboItems)).toList();
  }

  /// Sincroniza todos os dados de um evento vindo do Host no banco de dados local do Cliente,
  /// limpando dados antigos e inserindo os novos em uma transação atômica.
  Future<void> syncEventData({
    required String eventId,
    required ChurchEvent event,
    required List<EventDotDenom> denoms,
    required List<ChurchProduct> productsList,
    required List<ProductComboItem> comboItems,
    required List<PosSale> salesList,
    required List<PosSaleLine> saleLinesList,
    required List<ChangeDotRow> changeAllocationsList,
  }) async {
    await transaction(() async {
      // 1. Obter informações de produtos e denominações locais antes de limpar
      final productRows = await (select(products)..where((p) => p.eventId.equals(eventId))).get();
      final productIds = productRows.map((p) => p.id).toList();

      final denomRows = await (select(eventDotDenominations)..where((d) => d.eventId.equals(eventId))).get();
      final denomIds = denomRows.map((d) => d.id).toList();

      // 2. Limpar dados locais antigos associados a esse evento de forma ordenada (chaves estrangeiras)
      final saleRows = await (select(sales)..where((s) => s.eventId.equals(eventId))).get();
      final saleIds = saleRows.map((s) => s.id).toList();
      if (saleIds.isNotEmpty) {
        await (delete(saleChangeDotAllocations)..where((t) => t.saleId.isIn(saleIds))).go();
        await (delete(saleLines)..where((t) => t.saleId.isIn(saleIds))).go();
      }

      // Limpeza de contingência para linhas de venda e troco órfãs vinculadas a produtos/fichas do evento
      if (productIds.isNotEmpty) {
        await (delete(saleLines)..where((t) => t.productId.isIn(productIds))).go();
      }
      if (denomIds.isNotEmpty) {
        await (delete(saleChangeDotAllocations)..where((t) => t.dotDenominationId.isIn(denomIds))).go();
      }

      await (delete(sales)..where((s) => s.eventId.equals(eventId))).go();

      if (productIds.isNotEmpty) {
        await (delete(productComboItems)
              ..where((t) => t.comboProductId.isIn(productIds) | t.childProductId.isIn(productIds)))
            .go();
      }

      await (delete(products)..where((p) => p.eventId.equals(eventId))).go();
      await (delete(eventDotDenominations)..where((d) => d.eventId.equals(eventId))).go();

      // 2. Atualizar ou inserir o evento
      await into(events).insert(event, mode: InsertMode.insertOrReplace);

      // 3. Inserir denominações
      for (final d in denoms) {
        await into(eventDotDenominations).insert(d, mode: InsertMode.insertOrReplace);
      }

      // 4. Inserir produtos
      for (final p in productsList) {
        await into(products).insert(p, mode: InsertMode.insertOrReplace);
      }

      // 5. Inserir itens de combo
      for (final ci in comboItems) {
        await into(productComboItems).insert(ci, mode: InsertMode.insertOrReplace);
      }

      // 6. Inserir vendas
      for (final s in salesList) {
        await into(sales).insert(s, mode: InsertMode.insertOrReplace);
      }

      // 7. Inserir linhas de vendas
      for (final sl in saleLinesList) {
        await into(saleLines).insert(sl, mode: InsertMode.insertOrReplace);
      }

      // 8. Inserir alocações de troco
      for (final ca in changeAllocationsList) {
        await into(saleChangeDotAllocations).insert(ca, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Remove o produto se não existir linha de venda referenciando-o.
  /// Retorna `null` em caso de sucesso, ou mensagem para o utilizador.
  Future<String?> deleteProduct({
    required String eventId,
    required String productId,
  }) async {
    final p = await (select(products)
          ..where((t) => t.id.equals(productId))
          ..where((t) => t.eventId.equals(eventId)))
        .getSingleOrNull();
    if (p == null) return 'Produto não encontrado';
    final used = await (select(saleLines)
          ..where((sl) => sl.productId.equals(productId)))
        .get();
    if (used.isNotEmpty) {
      return 'Este produto já entrou em vendas. Inative-o em vez de excluir.';
    }
    final inCombos = await (select(productComboItems)..where((t) => t.childProductId.equals(productId))).get();
    if (inCombos.isNotEmpty) {
      return 'Este produto faz parte de um combo. Remova-o do combo antes de excluir.';
    }
    
    // Deleta os itens se for um combo (ON DELETE cascade não configurado explicitamente)
    if (p.isCombo) {
      await (delete(productComboItems)..where((t) => t.comboProductId.equals(productId))).go();
    }

    await (delete(products)
          ..where((t) => t.id.equals(productId))
          ..where((t) => t.eventId.equals(eventId)))
        .go();
    return null;
  }

  /// Remove a ficha se não existir venda ou troco referenciando-a.
  Future<String?> deleteDotDenomination({
    required String eventId,
    required String dotDenominationId,
  }) async {
    final d = await (select(eventDotDenominations)
          ..where((t) => t.id.equals(dotDenominationId))
          ..where((t) => t.eventId.equals(eventId)))
        .getSingleOrNull();
    if (d == null) return 'Ficha não encontrada';
    final lines = await (select(saleLines)
          ..where((sl) => sl.dotDenominationId.equals(dotDenominationId)))
        .get();
    if (lines.isNotEmpty) {
      return 'Esta ficha já entrou em vendas e não pode ser excluída.';
    }
    final changeRows = await (select(saleChangeDotAllocations)
          ..where((t) => t.dotDenominationId.equals(dotDenominationId)))
        .get();
    if (changeRows.isNotEmpty) {
      return 'Esta ficha já foi usada no troco de uma venda e não pode ser excluída.';
    }
    await (delete(eventDotDenominations)
          ..where((t) => t.id.equals(dotDenominationId))
          ..where((t) => t.eventId.equals(eventId)))
        .go();
    return null;
  }

  /// Apaga o evento e todos os dados associados (vendas, linhas, produtos, fichas).
  Future<void> deleteEventCascade(String eventId) async {
    await transaction(() async {
      // 1. Obter informações de produtos e denominações locais antes de limpar
      final productRows = await (select(products)..where((p) => p.eventId.equals(eventId))).get();
      final productIds = productRows.map((p) => p.id).toList();

      final denomRows = await (select(eventDotDenominations)..where((d) => d.eventId.equals(eventId))).get();
      final denomIds = denomRows.map((d) => d.id).toList();

      // 2. Limpar dados de vendas associados a esse evento
      final saleRows =
          await (select(sales)..where((s) => s.eventId.equals(eventId))).get();
      final saleIds = saleRows.map((s) => s.id).toList();
      if (saleIds.isNotEmpty) {
        await (delete(saleChangeDotAllocations)
              ..where((t) => t.saleId.isIn(saleIds)))
            .go();
        await (delete(saleLines)..where((t) => t.saleId.isIn(saleIds))).go();
      }

      // Limpeza de contingência para linhas de venda e troco órfãs vinculadas a produtos/fichas do evento
      if (productIds.isNotEmpty) {
        await (delete(saleLines)..where((t) => t.productId.isIn(productIds))).go();
      }
      if (denomIds.isNotEmpty) {
        await (delete(saleChangeDotAllocations)..where((t) => t.dotDenominationId.isIn(denomIds))).go();
      }

      await (delete(sales)..where((s) => s.eventId.equals(eventId))).go();

      // Limpar combo items associados a produtos deste evento
      if (productIds.isNotEmpty) {
        await (delete(productComboItems)
              ..where((t) => t.comboProductId.isIn(productIds) | t.childProductId.isIn(productIds)))
            .go();
      }

      await (delete(products)..where((p) => p.eventId.equals(eventId))).go();
      await (delete(eventDotDenominations)
            ..where((d) => d.eventId.equals(eventId)))
          .go();
      await (delete(events)..where((e) => e.id.equals(eventId))).go();
    });
  }

  /// Atualiza dados básicos de uma venda.
  Future<void> updateSaleDetails({
    required String saleId,
    required String paymentMethod,
    required int amountReceivedCents,
    String? notes,
    bool? changePending,
    String? customerName,
  }) async {
    await (update(sales)..where((s) => s.id.equals(saleId))).write(
      SalesCompanion(
        paymentMethod: Value(paymentMethod),
        amountReceivedCents: Value(amountReceivedCents),
        notes: Value(notes),
        changePending: changePending != null ? Value(changePending) : const Value.absent(),
        customerName: customerName != null ? Value(customerName) : const Value.absent(),
      ),
    );
  }

  /// Exclui a venda e devolve produtos e fichas ao estoque.
  Future<void> deleteSale(String saleId) async {
    await transaction(() async {
      final sale = await (select(sales)..where((s) => s.id.equals(saleId)))
          .getSingleOrNull();
      if (sale == null) return;

      final lines = await (select(saleLines)..where((l) => l.saleId.equals(saleId))).get();

      for (final l in lines) {
        if (l.lineKind == SaleLineKind.product && l.productId != null) {
          await _revertProductStock(l.productId!, l.qty);
        } else if (l.lineKind == SaleLineKind.ficha && l.dotDenominationId != null) {
          final d = await (select(eventDotDenominations)
                ..where((t) => t.id.equals(l.dotDenominationId!)))
              .getSingleOrNull();
          if (d != null) {
            await (update(eventDotDenominations)..where((t) => t.id.equals(d.id))).write(
              EventDotDenominationsCompanion(stockQty: Value(d.stockQty + l.qty)),
            );
          }
        }
      }

      // Deletar as alocações de troco em fichas (caso existam) e reverter estoques dessas fichas de troco
      final changeAllocations = await (select(saleChangeDotAllocations)..where((t) => t.saleId.equals(saleId))).get();
      for (final a in changeAllocations) {
        final d = await (select(eventDotDenominations)..where((t) => t.id.equals(a.dotDenominationId))).getSingleOrNull();
        if (d != null) {
          await (update(eventDotDenominations)..where((t) => t.id.equals(d.id))).write(
            EventDotDenominationsCompanion(stockQty: Value(d.stockQty + a.qty)),
          );
        }
      }
      await (delete(saleChangeDotAllocations)..where((t) => t.saleId.equals(saleId))).go();
      
      await (delete(saleLines)..where((t) => t.saleId.equals(saleId))).go();
      await (delete(sales)..where((t) => t.id.equals(saleId))).go();
    });
  }
}
