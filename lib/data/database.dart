import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/payment_method.dart';
import '../domain/stock_constants.dart';
import '../domain/stock_movement_reason.dart';
import 'device_identity.dart';
import 'drift_database_paths.dart';
import '../domain/sale_line_kind.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'sale_line_draft.dart';

part 'database.g.dart';

const _uuid = Uuid();

/// Versão atual do schema. Deve coincidir com [AppDatabase.schemaVersion].
/// Usada pelo backup/nuvem para bloquear restauração de bases mais novas.
const kAppSchemaVersion = 10;

/// Colunas de sincronização presentes em todas as tabelas (schema v9).
///
/// `rowVersion` é um relógio lógico por linha (Lamport): começa em 1 no
/// insert e é incrementado por trigger a cada UPDATE local. Decide "quem é
/// mais novo" na junção, com desempate por `updatedByDevice`.
/// `updatedAtMs` é relógio de parede e serve APENAS para exibição.
/// `deletedAtMs` é a exclusão lógica (tombstone): linhas nunca são apagadas
/// fisicamente fora de fluxos internos de agregado.
///
/// As colunas são mantidas por triggers SQLite instalados em `beforeOpen`
/// (ver `_installSyncInfrastructure`), para que nenhum ponto de escrita
/// precise lembrar de atualizá-las.
mixin SyncColumns on Table {
  IntColumn get rowVersion => integer().withDefault(const Constant(1))();
  IntColumn get updatedAtMs => integer().withDefault(const Constant(0))();
  TextColumn get updatedByDevice => text().nullable()();
  IntColumn get deletedAtMs => integer().nullable()();
}

@DataClassName('ChurchEvent')
class Events extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get dateEpochMs => integer()();
  TextColumn get pixKey => text().nullable()();
  TextColumn get pixMerchantName => text().nullable()();
  TextColumn get pixMerchantCity => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// “Fichas” / pontos do evento (valor unitário + estoque).
@DataClassName('EventDotDenom')
class EventDotDenominations extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get label => text()();
  IntColumn get valueCents => integer()();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ChurchProduct')
class Products extends Table with SyncColumns {
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

class ProductComboItems extends Table with SyncColumns {
  TextColumn get comboProductId => text().references(Products, #id)();
  TextColumn get childProductId => text().references(Products, #id)();
  IntColumn get qty => integer()();

  @override
  Set<Column> get primaryKey => {comboProductId, childProductId};
}

@DataClassName('CashSession')
class CashSessions extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get title => text()();
  IntColumn get openedAtMs => integer()();
  TextColumn get openedBy => text().nullable()();
  IntColumn get closedAtMs => integer().nullable()();
  IntColumn get initialCashFloatCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get closedCashDrawerCents => integer().nullable()();
  TextColumn get closedNotes => text().nullable()();
  TextColumn get closedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PosSale')
class Sales extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id)();
  TextColumn get sessionId =>
      text().nullable().references(CashSessions, #id)();
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
class SaleLines extends Table with SyncColumns {
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
class SaleChangeDotAllocations extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get dotDenominationId =>
      text().references(EventDotDenominations, #id)();
  IntColumn get qty => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Recebimentos de vendas fiadas (RFC venda fiada).
///
/// Append-only, como as movimentações de estoque: cada recebimento (total ou
/// parcial, inclusive a "entrada" paga na hora da venda) é uma linha. O saldo
/// devedor é sempre derivado: `sale.totalCents − soma(lançamentos vivos)`.
/// Lançamento errado se desfaz por tombstone. Na sincronização, as linhas se
/// unem por UUID — zero conflito entre celulares.
@DataClassName('FiadoPayment')
class FiadoPayments extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  IntColumn get amountCents => integer()();

  /// [PaymentMethod.settlementMethods] (nunca 'fiado').
  TextColumn get method => text()();
  IntColumn get paidAtMs => integer()();

  /// Sessão de caixa em que o dinheiro entrou (a da venda NÃO vale: fiado
  /// pode ser recebido semanas depois). Nulo = recebido fora de caixa.
  TextColumn get sessionId =>
      text().nullable().references(CashSessions, #id)();
  TextColumn get notes => text().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Movimentações de estoque (E1 da RFC de sincronização).
///
/// Append-only: cada alteração de estoque gera uma linha com `delta`.
/// `stockQty` nos produtos/fichas é um cache derivado — o saldo verdadeiro é
/// a soma dos deltas. Na junção entre celulares as movimentações são unidas
/// por UUID e o cache é recalculado, nunca somando contadores.
@DataClassName('StockMovement')
class StockMovements extends Table with SyncColumns {
  TextColumn get id => text()();

  /// 0 = produto, 1 = ficha.
  IntColumn get itemType => integer()();
  TextColumn get itemId => text()();
  IntColumn get delta => integer()();

  /// Ver [StockMovementReason].
  IntColumn get reason => integer()();
  TextColumn get saleId => text().nullable()();
  IntColumn get atMs => integer()();
  TextColumn get deviceId => text()();

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

/// Venda fiada com o total já recebido (saldo devedor derivado).
class FiadoSaleInfo {
  const FiadoSaleInfo({required this.sale, required this.paidCents});

  final PosSale sale;
  final int paidCents;

  int get openCents =>
      (sale.totalCents - paidCents) < 0 ? 0 : sale.totalCents - paidCents;
  bool get isSettled => openCents == 0;
}

/// Saldo devedor consolidado de um cliente (todas as vendas fiadas).
class FiadoCustomerBalance {
  const FiadoCustomerBalance({
    required this.customerName,
    required this.openCents,
    required this.openSaleCount,
    required this.lastSaleAtMs,
  });

  final String customerName;
  final int openCents;
  final int openSaleCount;
  final int lastSaleAtMs;
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
    CashSessions,
    Sales,
    SaleLines,
    SaleChangeDotAllocations,
    FiadoPayments,
    StockMovements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => kAppSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA recursive_triggers = OFF');
          await _installSyncInfrastructure();
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
          if (from < 7) {
            await m.createTable(cashSessions);
            await m.addColumn(sales, sales.sessionId);
          }
          if (from < 8) {
            await m.addColumn(events, events.pixKey);
            await m.addColumn(events, events.pixMerchantName);
            await m.addColumn(events, events.pixMerchantCity);
          }
          if (from < 9) {
            // Sincronização (RFC nuvem, revisão D2): colunas de versão lógica,
            // tombstones, operador de abertura e movimentações de estoque.
            final syncedTables = <TableInfo>[
              events,
              eventDotDenominations,
              products,
              productComboItems,
              cashSessions,
              sales,
              saleLines,
              saleChangeDotAllocations,
            ];
            for (final t in syncedTables) {
              for (final name in const [
                'row_version',
                'updated_at_ms',
                'updated_by_device',
                'deleted_at_ms',
              ]) {
                final col = t.columnsByName[name];
                if (col != null) {
                  await m.addColumn(t, col);
                }
              }
            }
            await m.addColumn(cashSessions, cashSessions.openedBy);
            await m.createTable(stockMovements);

            final now = DateTime.now().millisecondsSinceEpoch;
            final dev = _sqlQuote(DeviceIdentity.deviceId);
            for (final t in syncedTables) {
              await customStatement(
                'UPDATE ${t.actualTableName} SET updated_at_ms = $now',
              );
            }
            // Baseline das movimentações: uma carga inicial por item com
            // estoque, para que soma(movimentações) == stock_qty.
            await customStatement('''
INSERT INTO stock_movements
  (id, item_type, item_id, delta, reason, sale_id, at_ms, device_id,
   row_version, updated_at_ms, updated_by_device, deleted_at_ms)
SELECT lower(hex(randomblob(16))), 0, id, stock_qty, ${StockMovementReason.initial}, NULL, $now, $dev,
       1, $now, $dev, NULL
FROM products WHERE track_stock = 1 AND stock_qty != 0;
''');
            await customStatement('''
INSERT INTO stock_movements
  (id, item_type, item_id, delta, reason, sale_id, at_ms, device_id,
   row_version, updated_at_ms, updated_by_device, deleted_at_ms)
SELECT lower(hex(randomblob(16))), 1, id, stock_qty, ${StockMovementReason.initial}, NULL, $now, $dev,
       1, $now, $dev, NULL
FROM event_dot_denominations WHERE stock_qty != 0;
''');
          }
          if (from < 10) {
            // Venda fiada: lançamentos de recebimento (append-only).
            await m.createTable(fiadoPayments);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: kCaixaIgrejaDriftDbName);
  }

  static String _sqlQuote(String value) => "'${value.replaceAll("'", "''")}'";

  /// Tabela auxiliar local (fora do schema Drift) + triggers que mantêm as
  /// colunas de sincronização em TODA escrita, independentemente do caminho
  /// de código. Ver [SyncColumns].
  ///
  /// `local_kv` guarda o id deste aparelho e a flag `sync_bypass`. A flag é
  /// ligada por [runWithSyncBypass] durante a aplicação de dados remotos
  /// (sync Wi-Fi, junção da nuvem), para que os valores vindos de fora sejam
  /// preservados em vez de carimbados como alterações locais.
  ///
  /// Importante: `local_kv` viaja dentro do arquivo em snapshots/restaurações,
  /// por isso `device_id` é reescrito a cada abertura do banco.
  Future<void> _installSyncInfrastructure() async {
    await customStatement(
      'CREATE TABLE IF NOT EXISTS local_kv ('
      'key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL)',
    );
    await customStatement(
      "INSERT OR REPLACE INTO local_kv (key, value) "
      "VALUES ('device_id', ${_sqlQuote(DeviceIdentity.deviceId)})",
    );
    await customStatement(
      "INSERT OR REPLACE INTO local_kv (key, value) VALUES ('sync_bypass', '0')",
    );

    const tablePk = <String, String>{
      'events': 'id = NEW.id',
      'event_dot_denominations': 'id = NEW.id',
      'products': 'id = NEW.id',
      'product_combo_items': 'combo_product_id = NEW.combo_product_id '
          'AND child_product_id = NEW.child_product_id',
      'cash_sessions': 'id = NEW.id',
      'sales': 'id = NEW.id',
      'sale_lines': 'id = NEW.id',
      'sale_change_dot_allocations': 'id = NEW.id',
      'fiado_payments': 'id = NEW.id',
      'stock_movements': 'id = NEW.id',
    };
    const bypassOff =
        "COALESCE((SELECT value FROM local_kv WHERE key = 'sync_bypass'), '0') <> '1'";
    const nowMs =
        "CAST((julianday('now') - 2440587.5) * 86400000 AS INTEGER)";
    const deviceSql =
        "COALESCE((SELECT value FROM local_kv WHERE key = 'device_id'), 'local')";

    for (final entry in tablePk.entries) {
      final t = entry.key;
      final pk = entry.value;
      await customStatement('DROP TRIGGER IF EXISTS trg_touch_ins_$t');
      await customStatement('''
CREATE TRIGGER trg_touch_ins_$t AFTER INSERT ON $t
WHEN $bypassOff AND NEW.updated_at_ms = 0
BEGIN
  UPDATE $t SET
    updated_at_ms = $nowMs,
    updated_by_device = $deviceSql
  WHERE $pk;
END''');
      await customStatement('DROP TRIGGER IF EXISTS trg_touch_upd_$t');
      // O filtro NEW.updated_at_ms = OLD.updated_at_ms impede o re-disparo
      // pelo UPDATE interno do trigger de INSERT (que muda o updated_at_ms);
      // escritas normais do app nunca tocam nessa coluna diretamente.
      await customStatement('''
CREATE TRIGGER trg_touch_upd_$t AFTER UPDATE ON $t
WHEN $bypassOff AND NEW.row_version = OLD.row_version
  AND NEW.updated_at_ms = OLD.updated_at_ms
BEGIN
  UPDATE $t SET
    row_version = OLD.row_version + 1,
    updated_at_ms = $nowMs,
    updated_by_device = $deviceSql
  WHERE $pk;
END''');
    }
  }

  /// Executa [action] numa transação com os triggers de carimbo desligados.
  ///
  /// Usado ao aplicar dados vindos de outro aparelho (sync Wi-Fi, junção da
  /// nuvem): as colunas `rowVersion`/`updatedAtMs`/`updatedByDevice` chegam
  /// prontas e NÃO devem ser tratadas como alteração local.
  Future<T> runWithSyncBypass<T>(Future<T> Function() action) {
    return transaction(() async {
      await customStatement(
        "INSERT OR REPLACE INTO local_kv (key, value) VALUES ('sync_bypass', '1')",
      );
      try {
        return await action();
      } finally {
        await customStatement(
          "INSERT OR REPLACE INTO local_kv (key, value) VALUES ('sync_bypass', '0')",
        );
      }
    });
  }

  String generateUuid() => _uuid.v7();

  Stream<ChurchEvent?> watchEvent(String id) {
    return (select(events)
          ..where((e) => e.id.equals(id) & e.deletedAtMs.isNull()))
        .watchSingleOrNull();
  }

  Stream<List<EventDotDenom>> watchDotDenominations(String eventId) {
    return (select(eventDotDenominations)
          ..where((t) => t.eventId.equals(eventId) & t.deletedAtMs.isNull())
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
          ..where((p) => p.deletedAtMs.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch()
        .asyncMap(_mapProductsWithEffectiveStock);
  }

  Stream<List<ChurchProduct>> watchAllProductsForEvent(String eventId) {
    return (select(products)
          ..where((p) => p.eventId.equals(eventId))
          ..where((p) => p.deletedAtMs.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch()
        .asyncMap(_mapProductsWithEffectiveStock);
  }

  Stream<List<ChurchEvent>> watchAllEvents() {
    return (select(events)
          ..where((e) => e.deletedAtMs.isNull())
          ..orderBy([(e) => OrderingTerm.desc(e.dateEpochMs)]))
        .watch();
  }

  /// Vendas do evento, mais recentes primeiro (registro / livro-caixa).
  Stream<List<PosSale>> watchSalesForEvent(String eventId) {
    return (select(sales)
          ..where((s) => s.eventId.equals(eventId) & s.deletedAtMs.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.soldAtMs)]))
        .watch();
  }

  Stream<List<PosSaleLine>> watchSaleLinesForEvent(String eventId) {
    final q = select(saleLines).join([
      innerJoin(sales, sales.id.equalsExp(saleLines.saleId)),
    ])..where(sales.eventId.equals(eventId) & sales.deletedAtMs.isNull());
    return q.watch().map((rows) => rows.map((r) => r.readTable(saleLines)).toList());
  }

  Stream<List<ChangeDotRow>> watchChangeDotAllocationsForEvent(String eventId) {
    final q = select(saleChangeDotAllocations).join([
      innerJoin(sales, sales.id.equalsExp(saleChangeDotAllocations.saleId)),
    ])..where(sales.eventId.equals(eventId) & sales.deletedAtMs.isNull());
    return q.watch().map((rows) => rows.map((r) => r.readTable(saleChangeDotAllocations)).toList());
  }

  Stream<EventFinanceSummary> watchEventFinanceSummary(String eventId) {
    return (select(sales)
          ..where((s) => s.eventId.equals(eventId) & s.deletedAtMs.isNull()))
        .watch()
        .map(EventFinanceSummary.fromSales);
  }

  Future<EventFinanceSummary> eventFinanceSummary(String eventId) {
    return (select(sales)
          ..where((s) => s.eventId.equals(eventId) & s.deletedAtMs.isNull()))
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
        sub1 = (select(products)
              ..where((p) => p.eventId.equals(eventId) & p.deletedAtMs.isNull()))
            .watch()
            .asyncMap(_mapProductsWithEffectiveStock)
            .listen((list) {
          latestP = list;
          emit();
        });
        sub2 = (select(eventDotDenominations)
              ..where((d) => d.eventId.equals(eventId) & d.deletedAtMs.isNull()))
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
    return (select(events)
          ..where((e) => e.dateEpochMs.equals(dayStartMs) & e.deletedAtMs.isNull()))
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

  /// Item de produto em [StockMovements.itemType].
  static const kStockItemProduct = 0;

  /// Item de ficha em [StockMovements.itemType].
  static const kStockItemDot = 1;

  /// Registra uma movimentação de estoque (trilha append-only, E1).
  Future<void> _recordStockMovement({
    required int itemType,
    required String itemId,
    required int delta,
    required int reason,
    String? saleId,
  }) async {
    if (delta == 0) return;
    await into(stockMovements).insert(
      StockMovementsCompanion.insert(
        id: _uuid.v7(),
        itemType: itemType,
        itemId: itemId,
        delta: delta,
        reason: reason,
        saleId: Value(saleId),
        atMs: DateTime.now().millisecondsSinceEpoch,
        deviceId: DeviceIdentity.deviceId,
      ),
    );
  }

  /// Ajusta o estoque de uma ficha (contador + movimentação), validando
  /// disponibilidade quando [delta] é negativo.
  Future<void> _adjustDotStock(
    String dotDenominationId,
    int delta, {
    required int reason,
    String? saleId,
    bool tolerateMissing = false,
  }) async {
    if (delta == 0) return;
    final d = await (select(eventDotDenominations)
          ..where((t) => t.id.equals(dotDenominationId)))
        .getSingleOrNull();
    if (d == null) {
      if (tolerateMissing) return;
      throw StateError('Ficha não encontrada');
    }
    if (delta < 0 && d.stockQty < -delta) {
      throw StateError('Estoque de fichas insuficiente (${d.label})');
    }
    await (update(eventDotDenominations)
          ..where((t) => t.id.equals(dotDenominationId)))
        .write(
      EventDotDenominationsCompanion(stockQty: Value(d.stockQty + delta)),
    );
    await _recordStockMovement(
      itemType: kStockItemDot,
      itemId: dotDenominationId,
      delta: delta,
      reason: reason,
      saleId: saleId,
    );
  }

  Future<void> _abateProductStock(
    String productId,
    int qtyMultiplier, {
    String? saleId,
  }) async {
    final p = await (select(products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (p == null) return;
    if (p.isCombo) {
      final children = await (select(productComboItems)..where((t) => t.comboProductId.equals(productId))).get();
      for (final child in children) {
        await _abateProductStock(child.childProductId, child.qty * qtyMultiplier,
            saleId: saleId);
      }
    } else {
      if (p.trackStock) {
        if (p.stockQty < qtyMultiplier) {
          throw StateError('Estoque insuficiente para ${p.name}');
        }
        await (update(products)..where((t) => t.id.equals(productId))).write(
          ProductsCompanion(stockQty: Value(p.stockQty - qtyMultiplier)),
        );
        await _recordStockMovement(
          itemType: kStockItemProduct,
          itemId: productId,
          delta: -qtyMultiplier,
          reason: StockMovementReason.sale,
          saleId: saleId,
        );
      }
    }
  }

  Future<void> _revertProductStock(
    String productId,
    int qtyMultiplier, {
    String? saleId,
  }) async {
    final p = await (select(products)..where((t) => t.id.equals(productId))).getSingleOrNull();
    if (p == null) return;
    if (p.isCombo) {
      final children = await (select(productComboItems)..where((t) => t.comboProductId.equals(productId))).get();
      for (final child in children) {
        await _revertProductStock(child.childProductId, child.qty * qtyMultiplier,
            saleId: saleId);
      }
    } else {
      if (p.trackStock) {
        await (update(products)..where((t) => t.id.equals(productId))).write(
          ProductsCompanion(stockQty: Value(p.stockQty + qtyMultiplier)),
        );
        await _recordStockMovement(
          itemType: kStockItemProduct,
          itemId: productId,
          delta: qtyMultiplier,
          reason: StockMovementReason.saleRevert,
          saleId: saleId,
        );
      }
    }
  }

  // --- Sessões de Caixa (Cash Sessions) ---

  Stream<CashSession?> watchActiveSession(String eventId) {
    return (select(cashSessions)
          ..where((s) =>
              s.eventId.equals(eventId) &
              s.closedAtMs.isNull() &
              s.deletedAtMs.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.openedAtMs)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<CashSession?> getActiveSession(String eventId) {
    return (select(cashSessions)
          ..where((s) =>
              s.eventId.equals(eventId) &
              s.closedAtMs.isNull() &
              s.deletedAtMs.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.openedAtMs)])
          ..limit(1))
        .getSingleOrNull();
  }

  Stream<List<CashSession>> watchSessions(String eventId) {
    return (select(cashSessions)
          ..where((s) => s.eventId.equals(eventId) & s.deletedAtMs.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.openedAtMs)]))
        .watch();
  }

  Future<List<CashSession>> getSessions(String eventId) {
    return (select(cashSessions)
          ..where((s) => s.eventId.equals(eventId) & s.deletedAtMs.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.openedAtMs)]))
        .get();
  }

  Future<String> openCashSession({
    required String eventId,
    required String title,
    int initialCashFloatCents = 0,
    String? openedBy,
  }) async {
    final id = _uuid.v7();
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(cashSessions).insert(
      CashSessionsCompanion.insert(
        id: id,
        eventId: eventId,
        title: title,
        openedAtMs: now,
        initialCashFloatCents: Value(initialCashFloatCents),
        openedBy: Value(openedBy),
      ),
    );
    return id;
  }

  Future<void> closeCashSession({
    required String sessionId,
    required int closedCashDrawerCents,
    String? closedNotes,
    String? closedBy,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(cashSessions)..where((s) => s.id.equals(sessionId))).write(
      CashSessionsCompanion(
        closedAtMs: Value(now),
        closedCashDrawerCents: Value(closedCashDrawerCents),
        closedNotes: Value(closedNotes),
        closedBy: closedBy != null ? Value(closedBy) : const Value.absent(),
      ),
    );
  }

  Future<String> ensureActiveSession(String eventId) async {
    final active = await getActiveSession(eventId);
    if (active != null) return active.id;

    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    final title = 'Sessão $dateStr';
    return openCashSession(
      eventId: eventId,
      title: title,
      initialCashFloatCents: 0,
    );
  }

  /// Venda completa: linhas (produto, valor livre ou ficha), pagamento e estoques.
  ///
  /// [saleId] e [soldAtMs] permitem preservar a identidade de uma venda criada
  /// offline num terminal Wi-Fi e reenviada ao host depois.
  Future<String> completeSale({
    required String eventId,
    required String paymentMethod,
    required int amountReceivedCents,
    String? notes,
    bool changePending = false,
    String? customerName,
    String? sessionId,
    String? saleId,
    int? soldAtMs,
    required List<SaleLineDraft> lines,
  }) {
    if (lines.isEmpty) {
      throw ArgumentError('Carrinho vazio');
    }

    return transaction(() async {
      final activeSessionId = sessionId ?? await ensureActiveSession(eventId);

      var totalCents = 0;
      for (final l in lines) {
        if (l.qty <= 0 && l.kind != SaleLineKind.valorLivre) {
          throw ArgumentError('Quantidade inválida');
        }
        totalCents += l.resolveLineTotalCents();
      }
      final isFiado = paymentMethod == PaymentMethod.fiado;
      if (isFiado) {
        // Fiado: itens entregues, pagamento em aberto em nome do cliente.
        // amountReceivedCents aqui é a ENTRADA paga na hora (vira o primeiro
        // lançamento); na venda fica 0 — o recebido real é derivado dos
        // lançamentos.
        if ((customerName ?? '').trim().isEmpty) {
          throw ArgumentError('Venda fiada exige o nome do cliente');
        }
        if (amountReceivedCents < 0 || amountReceivedCents >= totalCents) {
          throw ArgumentError(
              'A entrada do fiado deve ser menor que o total (ou zero)');
        }
        if (changePending) {
          throw ArgumentError('Venda fiada não tem troco pendente');
        }
      } else if (amountReceivedCents < totalCents) {
        throw ArgumentError('Valor recebido menor que o total');
      }

      for (final l in lines) {
        switch (l.kind) {
          case SaleLineKind.product:
            final pid = l.productId;
            if (pid == null) throw ArgumentError('Produto inválido');
            final p = await (select(products)
                  ..where((t) => t.id.equals(pid))
                  ..where((t) => t.eventId.equals(eventId))
                  ..where((t) => t.deletedAtMs.isNull()))
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
            final d = await (select(eventDotDenominations)
                  ..where((t) => t.id.equals(did))
                  ..where((t) => t.deletedAtMs.isNull()))
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

      final soldAt = soldAtMs ?? DateTime.now().millisecondsSinceEpoch;
      final newSaleId = saleId ?? _uuid.v7();
      await into(sales).insert(
        SalesCompanion.insert(
          id: newSaleId,
          eventId: eventId,
          sessionId: Value(activeSessionId),
          soldAtMs: soldAt,
          totalCents: totalCents,
          amountReceivedCents: isFiado ? 0 : amountReceivedCents,
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
            saleId: newSaleId,
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
            await _abateProductStock(pid, l.qty, saleId: newSaleId);
            break;
          case SaleLineKind.ficha:
            await _adjustDotStock(
              l.dotDenominationId!,
              -l.qty,
              reason: StockMovementReason.sale,
              saleId: newSaleId,
            );
            break;
          case SaleLineKind.valorLivre:
            break;
        }
      }

      // Entrada do fiado paga na hora: primeiro lançamento de recebimento.
      if (isFiado && amountReceivedCents > 0) {
        await into(fiadoPayments).insert(
          FiadoPaymentsCompanion.insert(
            id: _uuid.v7(),
            saleId: newSaleId,
            amountCents: amountReceivedCents,
            method: PaymentMethod.dinheiro,
            paidAtMs: soldAt,
            sessionId: Value(activeSessionId),
            notes: const Value('Entrada'),
            deviceId: DeviceIdentity.deviceId,
          ),
        );
      }

      return newSaleId;
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

      // 2. Novo total (não depende do banco) — decide o destino do troco em fichas
      var totalCents = 0;
      for (final l in lines) {
        if (l.qty <= 0 && l.kind != SaleLineKind.valorLivre) {
          throw ArgumentError('Quantidade inválida');
        }
        totalCents += l.resolveLineTotalCents();
      }
      final isFiado = paymentMethod == PaymentMethod.fiado;
      final paidFiadoCents = await fiadoPaidCents(saleId);
      if (isFiado) {
        if ((customerName ?? '').trim().isEmpty) {
          throw ArgumentError('Venda fiada exige o nome do cliente');
        }
        if (changePending) {
          throw ArgumentError('Venda fiada não tem troco pendente');
        }
        if (totalCents < paidFiadoCents) {
          throw StateError(
              'O novo total é menor que o valor já recebido deste fiado. '
              'Estorne os recebimentos antes.');
        }
      } else {
        if (paidFiadoCents > 0) {
          throw StateError(
              'Esta venda tem recebimentos de fiado registrados. '
              'Estorne-os antes de mudar o método de pagamento.');
        }
        if (amountReceivedCents < totalCents) {
          throw ArgumentError('Valor recebido menor que o total');
        }
      }

      // 3. Troco em fichas: se o troco não mudou, as alocações são mantidas
      //    intactas; caso contrário, devolvem-se as fichas ao estoque e as
      //    alocações são removidas (o operador refaz o troco se precisar).
      final changeAllocations = await (select(saleChangeDotAllocations)
            ..where((t) => t.saleId.equals(saleId)))
          .get();
      if (changeAllocations.isNotEmpty) {
        var allocatedSum = 0;
        for (final a in changeAllocations) {
          final d = await (select(eventDotDenominations)
                ..where((t) => t.id.equals(a.dotDenominationId)))
              .getSingleOrNull();
          if (d == null) {
            allocatedSum = -1;
            break;
          }
          allocatedSum += a.qty * d.valueCents;
        }
        final newChange = amountReceivedCents - totalCents;
        final keepAllocations = paymentMethod == PaymentMethod.dinheiro &&
            allocatedSum >= 0 &&
            newChange == allocatedSum;
        if (!keepAllocations) {
          for (final a in changeAllocations) {
            await _adjustDotStock(
              a.dotDenominationId,
              a.qty,
              reason: StockMovementReason.changeDotsRevert,
              saleId: saleId,
              tolerateMissing: true,
            );
          }
          await (delete(saleChangeDotAllocations)
                ..where((t) => t.saleId.equals(saleId)))
              .go();
        }
      }

      // 4. Reverter os estoques e apagar as linhas antigas. O DELETE físico
      //    aqui é interno ao agregado da venda: as linhas são recriadas abaixo
      //    e, na sincronização, a venda vence ou perde como bloco.
      final oldLines = await (select(saleLines)..where((l) => l.saleId.equals(saleId))).get();
      for (final l in oldLines) {
        if (l.lineKind == SaleLineKind.product && l.productId != null) {
          await _revertProductStock(l.productId!, l.qty, saleId: saleId);
        } else if (l.lineKind == SaleLineKind.ficha && l.dotDenominationId != null) {
          await _adjustDotStock(
            l.dotDenominationId!,
            l.qty,
            reason: StockMovementReason.saleRevert,
            saleId: saleId,
            tolerateMissing: true,
          );
        }
      }
      await (delete(saleLines)..where((t) => t.saleId.equals(saleId))).go();

      // 5. Validar os novos itens
      for (final l in lines) {
        switch (l.kind) {
          case SaleLineKind.product:
            final pid = l.productId;
            if (pid == null) throw ArgumentError('Produto inválido');
            final p = await (select(products)
                  ..where((t) => t.id.equals(pid))
                  ..where((t) => t.eventId.equals(eventId))
                  ..where((t) => t.deletedAtMs.isNull()))
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
            final d = await (select(eventDotDenominations)
                  ..where((t) => t.id.equals(did))
                  ..where((t) => t.deletedAtMs.isNull()))
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

      // 6. Atualizar os dados da venda original (fiado guarda recebido = 0;
      //    o recebido real vem dos lançamentos)
      await updateSaleDetails(
        saleId: saleId,
        paymentMethod: paymentMethod,
        amountReceivedCents: isFiado ? 0 : amountReceivedCents,
        notes: notes,
        changePending: changePending,
        customerName: customerName,
      );
      await (update(sales)..where((s) => s.id.equals(saleId))).write(
        SalesCompanion(totalCents: Value(totalCents)),
      );

      // 7. Inserir novas linhas e abater novos estoques
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
            await _abateProductStock(pid, l.qty, saleId: saleId);
            break;
          case SaleLineKind.ficha:
            await _adjustDotStock(
              l.dotDenominationId!,
              -l.qty,
              reason: StockMovementReason.sale,
              saleId: saleId,
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
        final allocId = _uuid.v7();
        await into(saleChangeDotAllocations).insert(
          SaleChangeDotAllocationsCompanion.insert(
            id: allocId,
            saleId: saleId,
            dotDenominationId: a.dotDenominationId,
            qty: a.qty,
          ),
        );
        await _adjustDotStock(
          a.dotDenominationId,
          -a.qty,
          reason: StockMovementReason.changeDots,
          saleId: saleId,
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
  ///
  /// Duas garantias importantes:
  /// - Roda com [runWithSyncBypass]: os valores de `rowVersion`/`updatedAtMs`
  ///   vindos do host são preservados, não carimbados como alteração local.
  /// - **Vendas locais que o host não conhece são preservadas** (ex.: venda
  ///   registrada offline enquanto o terminal estava desconectado). Elas são
  ///   reenviadas ao host pelo fluxo de push do `SyncNotifier`; até lá, nunca
  ///   são apagadas em silêncio.
  Future<void> syncEventData({
    required String eventId,
    required ChurchEvent event,
    required List<EventDotDenom> denoms,
    required List<ChurchProduct> productsList,
    required List<ProductComboItem> comboItems,
    required List<PosSale> salesList,
    required List<PosSaleLine> saleLinesList,
    required List<ChangeDotRow> changeAllocationsList,
    List<FiadoPayment> fiadoPaymentsList = const [],
  }) async {
    await runWithSyncBypass(() async {
      // 1. Obter informações de produtos e denominações locais antes de limpar
      final productRows = await (select(products)..where((p) => p.eventId.equals(eventId))).get();
      final productIds = productRows.map((p) => p.id).toList();

      final denomRows = await (select(eventDotDenominations)..where((d) => d.eventId.equals(eventId))).get();
      final denomIds = denomRows.map((d) => d.id).toList();

      // 2. Separar vendas locais que o host não conhece (criadas offline)
      final incomingSaleIds = salesList.map((s) => s.id).toSet();
      final localSaleRows =
          await (select(sales)..where((s) => s.eventId.equals(eventId))).get();
      final preservedSaleIds = localSaleRows
          .map((s) => s.id)
          .where((id) => !incomingSaleIds.contains(id))
          .toSet();
      final replacedSaleIds = localSaleRows
          .map((s) => s.id)
          .where((id) => !preservedSaleIds.contains(id))
          .toList();

      // 3. Limpar apenas os dados substituídos pelo snapshot do host
      if (replacedSaleIds.isNotEmpty) {
        await (delete(saleChangeDotAllocations)..where((t) => t.saleId.isIn(replacedSaleIds))).go();
        await (delete(fiadoPayments)..where((t) => t.saleId.isIn(replacedSaleIds))).go();
        await (delete(saleLines)..where((t) => t.saleId.isIn(replacedSaleIds))).go();
      }

      // Limpeza de contingência para linhas órfãs vinculadas a produtos/fichas
      // do evento, poupando as linhas das vendas preservadas
      if (productIds.isNotEmpty) {
        await (delete(saleLines)
              ..where((t) =>
                  t.productId.isIn(productIds) &
                  t.saleId.isNotIn(preservedSaleIds.toList())))
            .go();
      }
      if (denomIds.isNotEmpty) {
        await (delete(saleChangeDotAllocations)
              ..where((t) =>
                  t.dotDenominationId.isIn(denomIds) &
                  t.saleId.isNotIn(preservedSaleIds.toList())))
            .go();
      }

      await (delete(sales)
            ..where((s) =>
                s.eventId.equals(eventId) &
                s.id.isNotIn(preservedSaleIds.toList())))
          .go();

      if (productIds.isNotEmpty) {
        await (delete(productComboItems)
              ..where((t) => t.comboProductId.isIn(productIds) | t.childProductId.isIn(productIds)))
            .go();
      }

      await (delete(products)..where((p) => p.eventId.equals(eventId))).go();
      await (delete(eventDotDenominations)..where((d) => d.eventId.equals(eventId))).go();

      // 4. Atualizar ou inserir o evento
      await into(events).insert(event, mode: InsertMode.insertOrReplace);

      // 5. Inserir denominações
      for (final d in denoms) {
        await into(eventDotDenominations).insert(d, mode: InsertMode.insertOrReplace);
      }

      // 6. Inserir produtos
      for (final p in productsList) {
        await into(products).insert(p, mode: InsertMode.insertOrReplace);
      }

      // 7. Inserir itens de combo
      for (final ci in comboItems) {
        await into(productComboItems).insert(ci, mode: InsertMode.insertOrReplace);
      }

      // 8. Inserir vendas
      for (final s in salesList) {
        await into(sales).insert(s, mode: InsertMode.insertOrReplace);
      }

      // 9. Inserir linhas de vendas
      for (final sl in saleLinesList) {
        await into(saleLines).insert(sl, mode: InsertMode.insertOrReplace);
      }

      // 10. Inserir alocações de troco
      for (final ca in changeAllocationsList) {
        await into(saleChangeDotAllocations).insert(ca, mode: InsertMode.insertOrReplace);
      }

      // 11. Inserir recebimentos de fiado
      for (final fp in fiadoPaymentsList) {
        await into(fiadoPayments).insert(fp, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Vendas deste evento que existem só localmente (não vieram do host) e não
  /// estão excluídas — candidatas a reenvio quando a conexão voltar.
  Future<List<PosSale>> localOnlySalesForEvent(
    String eventId,
    Set<String> hostSaleIds,
  ) async {
    final localSales = await (select(sales)
          ..where((s) => s.eventId.equals(eventId) & s.deletedAtMs.isNull()))
        .get();
    return localSales.where((s) => !hostSaleIds.contains(s.id)).toList();
  }

  Future<List<PosSaleLine>> saleLinesRaw(String saleId) {
    return (select(saleLines)..where((l) => l.saleId.equals(saleId))).get();
  }

  /// Exclusão lógica do produto (tombstone). As vendas que o referenciam são
  /// preservadas; o produto apenas some do catálogo.
  /// Retorna `null` em caso de sucesso, ou mensagem para o utilizador.
  Future<String?> deleteProduct({
    required String eventId,
    required String productId,
  }) async {
    final p = await (select(products)
          ..where((t) => t.id.equals(productId))
          ..where((t) => t.eventId.equals(eventId))
          ..where((t) => t.deletedAtMs.isNull()))
        .getSingleOrNull();
    if (p == null) return 'Produto não encontrado';
    final inCombos = await (select(productComboItems)..where((t) => t.childProductId.equals(productId))).get();
    if (inCombos.isNotEmpty) {
      return 'Este produto faz parte de um combo. Remova-o do combo antes de excluir.';
    }

    await (update(products)
          ..where((t) => t.id.equals(productId))
          ..where((t) => t.eventId.equals(eventId)))
        .write(ProductsCompanion(
      deletedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return null;
  }

  /// Exclusão lógica da ficha (tombstone). Vendas e trocos antigos que a
  /// referenciam continuam íntegros no histórico.
  Future<String?> deleteDotDenomination({
    required String eventId,
    required String dotDenominationId,
  }) async {
    final d = await (select(eventDotDenominations)
          ..where((t) => t.id.equals(dotDenominationId))
          ..where((t) => t.eventId.equals(eventId))
          ..where((t) => t.deletedAtMs.isNull()))
        .getSingleOrNull();
    if (d == null) return 'Ficha não encontrada';
    await (update(eventDotDenominations)
          ..where((t) => t.id.equals(dotDenominationId))
          ..where((t) => t.eventId.equals(eventId)))
        .write(EventDotDenominationsCompanion(
      deletedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return null;
  }

  /// Exclusão lógica do evento (tombstone). Os dados associados (vendas,
  /// produtos, fichas, sessões) são mantidos para histórico e sincronização;
  /// o evento apenas deixa de aparecer nas listas.
  Future<void> deleteEventCascade(String eventId) async {
    await (update(events)..where((e) => e.id.equals(eventId))).write(
      EventsCompanion(
        deletedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
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

  /// Exclusão lógica da venda (tombstone) devolvendo produtos e fichas ao
  /// estoque. As linhas e alocações são mantidas no histórico; as consultas
  /// filtram pelo tombstone da venda.
  Future<void> deleteSale(String saleId) async {
    await transaction(() async {
      final sale = await (select(sales)..where((s) => s.id.equals(saleId)))
          .getSingleOrNull();
      if (sale == null) return;
      // Já excluída: não reverter estoque duas vezes.
      if (sale.deletedAtMs != null) return;
      if (sale.paymentMethod == PaymentMethod.fiado &&
          await fiadoPaidCents(saleId) > 0) {
        throw StateError(
            'Este fiado tem recebimentos registrados. Estorne-os antes de excluir a venda.');
      }

      final lines = await (select(saleLines)..where((l) => l.saleId.equals(saleId))).get();

      for (final l in lines) {
        if (l.lineKind == SaleLineKind.product && l.productId != null) {
          await _revertProductStock(l.productId!, l.qty, saleId: saleId);
        } else if (l.lineKind == SaleLineKind.ficha && l.dotDenominationId != null) {
          await _adjustDotStock(
            l.dotDenominationId!,
            l.qty,
            reason: StockMovementReason.saleRevert,
            saleId: saleId,
            tolerateMissing: true,
          );
        }
      }

      // Reverter estoques das fichas dadas de troco (caso existam)
      final changeAllocations = await (select(saleChangeDotAllocations)..where((t) => t.saleId.equals(saleId))).get();
      for (final a in changeAllocations) {
        await _adjustDotStock(
          a.dotDenominationId,
          a.qty,
          reason: StockMovementReason.changeDotsRevert,
          saleId: saleId,
          tolerateMissing: true,
        );
      }

      await (update(sales)..where((t) => t.id.equals(saleId))).write(
        SalesCompanion(
          deletedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    });
  }

  // ─── Venda fiada ─────────────────────────────────────────────────────────

  /// Soma dos recebimentos vivos de um fiado.
  Future<int> fiadoPaidCents(String saleId) async {
    final sum = fiadoPayments.amountCents.sum();
    final q = selectOnly(fiadoPayments)
      ..addColumns([sum])
      ..where(fiadoPayments.saleId.equals(saleId) &
          fiadoPayments.deletedAtMs.isNull());
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  /// Registra um recebimento (total ou parcial) de uma venda fiada.
  /// O dinheiro entra na sessão ATIVA do evento da venda, se houver —
  /// recebimentos fora de caixa ficam com sessão nula.
  Future<String> registerFiadoPayment({
    required String saleId,
    required int amountCents,
    required String method,
    String? notes,
  }) {
    return transaction(() async {
      if (amountCents <= 0) throw ArgumentError('Valor inválido');
      if (method == PaymentMethod.fiado ||
          !PaymentMethod.settlementMethods.contains(method)) {
        throw ArgumentError('Método de recebimento inválido');
      }
      final sale = await (select(sales)
            ..where((s) => s.id.equals(saleId) & s.deletedAtMs.isNull()))
          .getSingleOrNull();
      if (sale == null) throw StateError('Venda não encontrada');
      if (sale.paymentMethod != PaymentMethod.fiado) {
        throw StateError('Esta venda não é fiada');
      }
      final paid = await fiadoPaidCents(saleId);
      final open = sale.totalCents - paid;
      if (open <= 0) throw StateError('Este fiado já está quitado');
      if (amountCents > open) {
        throw ArgumentError(
            'Valor maior que o saldo devedor (${open / 100} restante)');
      }
      final session = await getActiveSession(sale.eventId);
      final id = _uuid.v7();
      await into(fiadoPayments).insert(
        FiadoPaymentsCompanion.insert(
          id: id,
          saleId: saleId,
          amountCents: amountCents,
          method: method,
          paidAtMs: DateTime.now().millisecondsSinceEpoch,
          sessionId: Value(session?.id),
          notes: Value(notes),
          deviceId: DeviceIdentity.deviceId,
        ),
      );
      return id;
    });
  }

  /// Estorna um lançamento de recebimento (tombstone — o histórico fica).
  Future<void> undoFiadoPayment(String paymentId) async {
    await (update(fiadoPayments)..where((p) => p.id.equals(paymentId))).write(
      FiadoPaymentsCompanion(
        deletedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Recebimentos de fiado do evento (snapshot Wi-Fi; só os vivos, como as
  /// demais listas do host).
  Future<List<FiadoPayment>> fiadoPaymentsForEvent(String eventId) async {
    final q = select(fiadoPayments).join([
      innerJoin(sales, sales.id.equalsExp(fiadoPayments.saleId),
          useColumns: false),
    ])
      ..where(sales.eventId.equals(eventId) &
          fiadoPayments.deletedAtMs.isNull());
    final rows = await q.get();
    return rows.map((r) => r.readTable(fiadoPayments)).toList();
  }

  Future<List<FiadoPayment>> fiadoPaymentsForSale(String saleId) {
    return (select(fiadoPayments)
          ..where((p) => p.saleId.equals(saleId) & p.deletedAtMs.isNull())
          ..orderBy([(p) => OrderingTerm.desc(p.paidAtMs)]))
        .get();
  }

  /// Vendas fiadas (com total recebido) — reage a vendas E a lançamentos.
  /// [eventId] nulo = todos os eventos (tela geral); [onlyOpen] filtra as
  /// que ainda têm saldo devedor.
  Stream<List<FiadoSaleInfo>> watchFiadoSales({
    String? eventId,
    bool onlyOpen = false,
  }) {
    final paidSum = fiadoPayments.amountCents.sum();
    final q = select(sales).join([
      leftOuterJoin(
        fiadoPayments,
        fiadoPayments.saleId.equalsExp(sales.id) &
            fiadoPayments.deletedAtMs.isNull(),
        useColumns: false,
      ),
      innerJoin(events, events.id.equalsExp(sales.eventId),
          useColumns: false),
    ])
      ..addColumns([paidSum])
      ..where(sales.paymentMethod.equals(PaymentMethod.fiado) &
          sales.deletedAtMs.isNull() &
          (eventId != null
              ? sales.eventId.equals(eventId)
              : events.deletedAtMs.isNull()))
      ..groupBy([sales.id])
      ..orderBy([OrderingTerm.desc(sales.soldAtMs)]);

    return q.watch().map((rows) {
      final list = rows.map((row) {
        final sale = row.readTable(sales);
        final paid = row.read(paidSum) ?? 0;
        return FiadoSaleInfo(sale: sale, paidCents: paid);
      }).toList();
      return onlyOpen ? list.where((f) => f.openCents > 0).toList() : list;
    });
  }

  /// Saldo devedor agrupado por cliente (tela geral "Fiados").
  Stream<List<FiadoCustomerBalance>> watchFiadoBalancesByCustomer() {
    return watchFiadoSales(onlyOpen: false).map((all) {
      final byName = <String, List<FiadoSaleInfo>>{};
      for (final f in all) {
        final name = (f.sale.customerName ?? '').trim();
        byName.putIfAbsent(name.isEmpty ? 'Sem nome' : name, () => []).add(f);
      }
      final result = byName.entries
          .map((e) {
            final open =
                e.value.fold<int>(0, (acc, f) => acc + f.openCents);
            var lastMs = 0;
            for (final f in e.value) {
              if (f.sale.soldAtMs > lastMs) lastMs = f.sale.soldAtMs;
            }
            return FiadoCustomerBalance(
              customerName: e.key,
              openCents: open,
              openSaleCount:
                  e.value.where((f) => f.openCents > 0).length,
              lastSaleAtMs: lastMs,
            );
          })
          .where((b) => b.openCents > 0)
          .toList()
        ..sort((a, b) => b.openCents.compareTo(a.openCents));
      return result;
    });
  }

  /// Saldo devedor em aberto de um cliente (aviso no checkout).
  Future<int> customerFiadoOpenCents(String customerName) async {
    final name = customerName.trim();
    if (name.isEmpty) return 0;
    final fiados = await (select(sales)
          ..where((s) =>
              s.paymentMethod.equals(PaymentMethod.fiado) &
              s.deletedAtMs.isNull() &
              s.customerName.trim().lower().equals(name.toLowerCase())))
        .get();
    var open = 0;
    for (final sale in fiados) {
      open += sale.totalCents - await fiadoPaidCents(sale.id);
    }
    return open < 0 ? 0 : open;
  }

  /// Nomes de cliente já usados (autocomplete do checkout).
  Future<List<String>> customerNameSuggestions(String query) async {
    final rows = await (selectOnly(sales, distinct: true)
          ..addColumns([sales.customerName])
          ..where(sales.customerName.isNotNull() & sales.deletedAtMs.isNull()))
        .get();
    final q = query.trim().toLowerCase();
    final names = rows
        .map((r) => (r.read(sales.customerName) ?? '').trim())
        .where((n) => n.isNotEmpty)
        .toSet()
        .where((n) => q.isEmpty || n.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names.take(8).toList();
  }

  /// Fiados recebidos em dinheiro numa sessão (entra na gaveta esperada).
  Future<int> fiadoCashReceivedForSession(String sessionId) async {
    final sum = fiadoPayments.amountCents.sum();
    final q = selectOnly(fiadoPayments)
      ..addColumns([sum])
      ..where(fiadoPayments.sessionId.equals(sessionId) &
          fiadoPayments.method.equals(PaymentMethod.dinheiro) &
          fiadoPayments.deletedAtMs.isNull());
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  /// Salva (cria ou atualiza) um produto simples registrando a diferença de
  /// estoque como movimentação. Ponto único de escrita para formulários e
  /// endpoints do host Wi-Fi.
  Future<String> saveProduct({
    String? id,
    required String eventId,
    required String name,
    required int priceCents,
    String description = '',
    required bool trackStock,
    required int stockQty,
    required bool active,
  }) {
    return transaction(() async {
      if (id == null) {
        final newId = _uuid.v7();
        await into(products).insert(
          ProductsCompanion.insert(
            id: newId,
            eventId: eventId,
            name: name,
            priceCents: priceCents,
            description: Value(description),
            trackStock: Value(trackStock),
            stockQty: Value(stockQty),
            active: Value(active),
            isCombo: const Value(false),
          ),
        );
        if (trackStock && stockQty != 0) {
          await _recordStockMovement(
            itemType: kStockItemProduct,
            itemId: newId,
            delta: stockQty,
            reason: StockMovementReason.initial,
          );
        }
        return newId;
      }

      final old = await (select(products)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.eventId.equals(eventId)))
          .getSingleOrNull();
      if (old == null) throw StateError('Produto não encontrado');
      await (update(products)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.eventId.equals(eventId)))
          .write(ProductsCompanion(
        name: Value(name),
        description: Value(description),
        priceCents: Value(priceCents),
        trackStock: Value(trackStock),
        stockQty: Value(stockQty),
        active: Value(active),
      ));
      final delta = stockQty - old.stockQty;
      if (delta != 0) {
        await _recordStockMovement(
          itemType: kStockItemProduct,
          itemId: id,
          delta: delta,
          reason: StockMovementReason.manualAdjust,
        );
      }
      return id;
    });
  }

  /// Salva (cria ou atualiza) uma ficha registrando a diferença de estoque
  /// como movimentação. Ponto único de escrita para formulários e host Wi-Fi.
  Future<String> saveDotDenomination({
    String? id,
    required String eventId,
    required String label,
    required int valueCents,
    required int stockQty,
  }) {
    return transaction(() async {
      if (id == null) {
        final newId = _uuid.v7();
        await into(eventDotDenominations).insert(
          EventDotDenominationsCompanion.insert(
            id: newId,
            eventId: eventId,
            label: label,
            valueCents: valueCents,
            stockQty: Value(stockQty),
          ),
        );
        if (stockQty != 0) {
          await _recordStockMovement(
            itemType: kStockItemDot,
            itemId: newId,
            delta: stockQty,
            reason: StockMovementReason.initial,
          );
        }
        return newId;
      }

      final old = await (select(eventDotDenominations)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (old == null) throw StateError('Ficha não encontrada');
      await (update(eventDotDenominations)..where((t) => t.id.equals(id)))
          .write(EventDotDenominationsCompanion(
        label: Value(label),
        valueCents: Value(valueCents),
        stockQty: Value(stockQty),
      ));
      final delta = stockQty - old.stockQty;
      if (delta != 0) {
        await _recordStockMovement(
          itemType: kStockItemDot,
          itemId: id,
          delta: delta,
          reason: StockMovementReason.manualAdjust,
        );
      }
      return id;
    });
  }

  /// Recria o baseline das movimentações a partir dos contadores atuais.
  /// Usado após o seed de dados de demonstração.
  Future<void> rebaselineStockMovements() async {
    await transaction(() async {
      await delete(stockMovements).go();
      final trackedProducts = await (select(products)
            ..where((p) => p.trackStock.equals(true) & p.deletedAtMs.isNull()))
          .get();
      for (final p in trackedProducts) {
        await _recordStockMovement(
          itemType: kStockItemProduct,
          itemId: p.id,
          delta: p.stockQty,
          reason: StockMovementReason.initial,
        );
      }
      final denoms = await (select(eventDotDenominations)
            ..where((d) => d.deletedAtMs.isNull()))
          .get();
      for (final d in denoms) {
        await _recordStockMovement(
          itemType: kStockItemDot,
          itemId: d.id,
          delta: d.stockQty,
          reason: StockMovementReason.initial,
        );
      }
    });
  }

  /// Soma das movimentações de um item (saldo verdadeiro no modelo E1).
  Future<int> stockMovementSum(int itemType, String itemId) async {
    final sum = stockMovements.delta.sum();
    final q = selectOnly(stockMovements)
      ..addColumns([sum])
      ..where(stockMovements.itemType.equals(itemType) &
          stockMovements.itemId.equals(itemId) &
          stockMovements.deletedAtMs.isNull());
    final row = await q.getSingle();
    return row.read(sum) ?? 0;
  }

  /// Recalcula os caches `stockQty` a partir das movimentações.
  /// Usado após junção/restauração de dados de outro aparelho.
  Future<void> recalcStockFromMovements() async {
    await runWithSyncBypass(() async {
      final trackedProducts = await (select(products)
            ..where((p) => p.trackStock.equals(true)))
          .get();
      for (final p in trackedProducts) {
        final total = await stockMovementSum(kStockItemProduct, p.id);
        if (total != p.stockQty) {
          await (update(products)..where((t) => t.id.equals(p.id))).write(
            ProductsCompanion(stockQty: Value(total)),
          );
        }
      }
      final denoms = await select(eventDotDenominations).get();
      for (final d in denoms) {
        final total = await stockMovementSum(kStockItemDot, d.id);
        if (total != d.stockQty) {
          await (update(eventDotDenominations)..where((t) => t.id.equals(d.id)))
              .write(EventDotDenominationsCompanion(stockQty: Value(total)));
        }
      }
    });
  }
}
