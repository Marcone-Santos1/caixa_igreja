import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/payment_method.dart';
import '../domain/sale_line_kind.dart';
import 'sale_line_draft.dart';

part 'database.g.dart';

@DataClassName('ChurchEvent')
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get dateEpochMs => integer()();
}

/// “Fichas” / pontos do evento (valor unitário + estoque).
@DataClassName('EventDotDenom')
class EventDotDenominations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get eventId => integer().references(Events, #id)();
  TextColumn get label => text()();
  IntColumn get valueCents => integer()();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
}

@DataClassName('ChurchProduct')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get priceCents => integer()();
  BoolColumn get trackStock => boolean().withDefault(const Constant(false))();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('PosSale')
class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get eventId => integer().references(Events, #id)();
  IntColumn get soldAtMs => integer()();
  IntColumn get totalCents => integer()();
  IntColumn get amountReceivedCents => integer()();
  TextColumn get paymentMethod =>
      text().withDefault(const Constant(PaymentMethod.dinheiro))();
}

@DataClassName('PosSaleLine')
class SaleLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get lineKind => integer().withDefault(const Constant(0))();
  IntColumn get productId => integer().nullable().references(Products, #id)();
  IntColumn get dotDenominationId =>
      integer().nullable().references(EventDotDenominations, #id)();
  TextColumn get freeLabel => text().nullable()();
  IntColumn get qty => integer()();
  IntColumn get unitPriceCents => integer()();
  IntColumn get lineTotalCents => integer()();
}

/// Fichas entregues como troco (auditoria + baixa de estoque).
@DataClassName('ChangeDotRow')
class SaleChangeDotAllocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().references(Sales, #id)();
  IntColumn get dotDenominationId =>
      integer().references(EventDotDenominations, #id)();
  IntColumn get qty => integer()();
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

@DriftDatabase(
  tables: [
    Events,
    EventDotDenominations,
    Products,
    Sales,
    SaleLines,
    SaleChangeDotAllocations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

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
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'caixa_igreja');
  }

  Stream<ChurchEvent?> watchEvent(int id) {
    return (select(events)..where((e) => e.id.equals(id)))
        .watchSingleOrNull();
  }

  Stream<List<EventDotDenom>> watchDotDenominations(int eventId) {
    return (select(eventDotDenominations)
          ..where((t) => t.eventId.equals(eventId))
          ..orderBy([(t) => OrderingTerm.desc(t.valueCents)]))
        .watch();
  }

  Stream<List<ChurchProduct>> watchActiveProducts() {
    return (select(products)
          ..where((p) => p.active.equals(true))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  Stream<List<ChurchProduct>> watchAllProducts() {
    return (select(products)..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  Stream<List<ChurchEvent>> watchAllEvents() {
    return (select(events)..orderBy([(e) => OrderingTerm.desc(e.dateEpochMs)]))
        .watch();
  }

  /// Vendas do evento, mais recentes primeiro (registro / livro-caixa).
  Stream<List<PosSale>> watchSalesForEvent(int eventId) {
    return (select(sales)
          ..where((s) => s.eventId.equals(eventId))
          ..orderBy([(s) => OrderingTerm.desc(s.soldAtMs)]))
        .watch();
  }

  Future<List<EventSaleLineRow>> saleLinesForSale(int saleId) {
    final q = select(saleLines).join([
      leftOuterJoin(products, products.id.equalsExp(saleLines.productId)),
      leftOuterJoin(
        eventDotDenominations,
        eventDotDenominations.id.equalsExp(saleLines.dotDenominationId),
      ),
    ])
      ..where(saleLines.saleId.equals(saleId))
      ..orderBy([OrderingTerm.asc(saleLines.id)]);

    return q.map((row) {
      final sl = row.readTable(saleLines);
      final p = row.readTableOrNull(products);
      final d = row.readTableOrNull(eventDotDenominations);
      final item = switch (sl.lineKind) {
        SaleLineKind.valorLivre => 'Valor: ${sl.freeLabel ?? ''}',
        SaleLineKind.ficha => 'Ficha: ${d?.label ?? '#${sl.dotDenominationId}'}',
        _ => p?.name ?? 'Produto #${sl.productId}',
      };
      return EventSaleLineRow(
        itemLabel: item,
        qty: sl.qty,
        unitPriceCents: sl.unitPriceCents,
        lineTotalCents: sl.lineTotalCents,
      );
    }).get();
  }

  Future<List<ChurchEvent>> eventsForDayMs(int dayStartMs) {
    return (select(events)..where((e) => e.dateEpochMs.equals(dayStartMs)))
        .get();
  }

  /// Venda completa: linhas (produto, valor livre ou ficha), pagamento e estoques.
  Future<int> completeSale({
    required int eventId,
    required String paymentMethod,
    required int amountReceivedCents,
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
            final p = await (select(products)..where((t) => t.id.equals(pid)))
                .getSingleOrNull();
            if (p == null) throw StateError('Produto não encontrado');
            if (!p.active) throw StateError('Produto inativo: ${p.name}');
            if (p.trackStock && p.stockQty < l.qty) {
              throw StateError('Estoque insuficiente para ${p.name}');
            }
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
      final saleId = await into(sales).insert(
        SalesCompanion.insert(
          eventId: eventId,
          soldAtMs: soldAt,
          totalCents: totalCents,
          amountReceivedCents: amountReceivedCents,
          paymentMethod: Value(paymentMethod),
        ),
      );

      for (final l in lines) {
        final lineTotal = l.resolveLineTotalCents();
        final unit = l.resolveUnitPriceCents();

        await into(saleLines).insert(
          SaleLinesCompanion.insert(
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
            final p = await (select(products)..where((t) => t.id.equals(pid)))
                .getSingle();
            if (p.trackStock) {
              await (update(products)..where((t) => t.id.equals(pid))).write(
                ProductsCompanion(stockQty: Value(p.stockQty - l.qty)),
              );
            }
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

  /// Registra fichas dadas no troco (soma deve ser igual ao troco).
  Future<void> confirmChangeDots({
    required int saleId,
    required int eventId,
    required int changeCents,
    required List<({int dotDenominationId, int qty})> allocation,
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

      final merged = <int, int>{};
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
        await into(saleChangeDotAllocations).insert(
          SaleChangeDotAllocationsCompanion.insert(
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

  Future<List<SaleLineExportRow>> exportSaleLinesBetween({
    required int startMs,
    required int endMs,
  }) async {
    final q = select(saleLines).join([
      innerJoin(sales, sales.id.equalsExp(saleLines.saleId)),
      innerJoin(events, events.id.equalsExp(sales.eventId)),
      leftOuterJoin(products, products.id.equalsExp(saleLines.productId)),
      leftOuterJoin(
        eventDotDenominations,
        eventDotDenominations.id.equalsExp(saleLines.dotDenominationId),
      ),
    ])
      ..where(
        sales.soldAtMs.isBiggerOrEqualValue(startMs) &
            sales.soldAtMs.isSmallerOrEqualValue(endMs),
      )
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
}
