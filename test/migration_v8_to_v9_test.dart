import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/database_backup.dart';

/// Cria um banco bruto no schema v8 (como existia antes da sincronização) e
/// verifica que a migração para v9:
/// - adiciona as colunas de sincronização com valores saudáveis;
/// - cria o baseline de movimentações (soma == stockQty);
/// - instala os triggers de carimbo.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('caixa_migration');
    dbFile = File(p.join(tempDir.path, 'v8.sqlite'));
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  void createV8Database() {
    final db = raw.sqlite3.open(dbFile.path);
    db.execute('''
CREATE TABLE events (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  notes TEXT NOT NULL DEFAULT '',
  date_epoch_ms INTEGER NOT NULL,
  pix_key TEXT,
  pix_merchant_name TEXT,
  pix_merchant_city TEXT
);
CREATE TABLE event_dot_denominations (
  id TEXT NOT NULL PRIMARY KEY,
  event_id TEXT NOT NULL REFERENCES events (id),
  label TEXT NOT NULL,
  value_cents INTEGER NOT NULL,
  stock_qty INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE products (
  id TEXT NOT NULL PRIMARY KEY,
  event_id TEXT NOT NULL REFERENCES events (id),
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  price_cents INTEGER NOT NULL,
  track_stock INTEGER NOT NULL DEFAULT 0,
  stock_qty INTEGER NOT NULL DEFAULT 0,
  active INTEGER NOT NULL DEFAULT 1,
  is_combo INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE product_combo_items (
  combo_product_id TEXT NOT NULL REFERENCES products (id),
  child_product_id TEXT NOT NULL REFERENCES products (id),
  qty INTEGER NOT NULL,
  PRIMARY KEY (combo_product_id, child_product_id)
);
CREATE TABLE cash_sessions (
  id TEXT NOT NULL PRIMARY KEY,
  event_id TEXT NOT NULL REFERENCES events (id),
  title TEXT NOT NULL,
  opened_at_ms INTEGER NOT NULL,
  closed_at_ms INTEGER,
  initial_cash_float_cents INTEGER NOT NULL DEFAULT 0,
  closed_cash_drawer_cents INTEGER,
  closed_notes TEXT,
  closed_by TEXT
);
CREATE TABLE sales (
  id TEXT NOT NULL PRIMARY KEY,
  event_id TEXT NOT NULL REFERENCES events (id),
  session_id TEXT REFERENCES cash_sessions (id),
  sold_at_ms INTEGER NOT NULL,
  total_cents INTEGER NOT NULL,
  amount_received_cents INTEGER NOT NULL,
  payment_method TEXT NOT NULL DEFAULT 'dinheiro',
  notes TEXT,
  change_pending INTEGER NOT NULL DEFAULT 0,
  customer_name TEXT
);
CREATE TABLE sale_lines (
  id TEXT NOT NULL PRIMARY KEY,
  sale_id TEXT NOT NULL REFERENCES sales (id),
  line_kind INTEGER NOT NULL DEFAULT 0,
  product_id TEXT REFERENCES products (id),
  dot_denomination_id TEXT REFERENCES event_dot_denominations (id),
  free_label TEXT,
  qty INTEGER NOT NULL,
  unit_price_cents INTEGER NOT NULL,
  line_total_cents INTEGER NOT NULL
);
CREATE TABLE sale_change_dot_allocations (
  id TEXT NOT NULL PRIMARY KEY,
  sale_id TEXT NOT NULL REFERENCES sales (id),
  dot_denomination_id TEXT NOT NULL REFERENCES event_dot_denominations (id),
  qty INTEGER NOT NULL
);
''');
    db.execute('''
INSERT INTO events (id, title, notes, date_epoch_ms) VALUES ('ev1', 'Festa 2026', '', 1000);
INSERT INTO products (id, event_id, name, price_cents, track_stock, stock_qty) VALUES
  ('p1', 'ev1', 'Pastel', 800, 1, 40),
  ('p2', 'ev1', 'Valor sem estoque', 100, 0, 0);
INSERT INTO event_dot_denominations (id, event_id, label, value_cents, stock_qty) VALUES
  ('d1', 'ev1', 'Ficha R\$1', 100, 25);
INSERT INTO cash_sessions (id, event_id, title, opened_at_ms, closed_by) VALUES
  ('cs1', 'ev1', 'Sessão antiga', 500, 'Maria');
INSERT INTO sales (id, event_id, session_id, sold_at_ms, total_cents, amount_received_cents) VALUES
  ('s1', 'ev1', 'cs1', 600, 800, 1000);
INSERT INTO sale_lines (id, sale_id, line_kind, product_id, qty, unit_price_cents, line_total_cents) VALUES
  ('l1', 's1', 0, 'p1', 1, 800, 800);
''');
    db.execute('PRAGMA user_version = 8');
    db.dispose();
  }

  test('migração v8 -> v9 preserva dados e cria baseline de movimentações',
      () async {
    createV8Database();

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);

    // Dados antigos intactos, colunas novas com valores saudáveis.
    final ev = await (db.select(db.events)..where((e) => e.id.equals('ev1')))
        .getSingle();
    expect(ev.title, 'Festa 2026');
    expect(ev.rowVersion, 1);
    expect(ev.updatedAtMs, greaterThan(0));
    expect(ev.deletedAtMs, isNull);

    final sale = await (db.select(db.sales)..where((s) => s.id.equals('s1')))
        .getSingle();
    expect(sale.totalCents, 800);
    expect(sale.rowVersion, 1);

    // Baseline: produto com track_stock=1 e ficha geram movimentações iniciais.
    final sumP = await db.stockMovementSum(AppDatabase.kStockItemProduct, 'p1');
    expect(sumP, 40);
    final sumP2 = await db.stockMovementSum(AppDatabase.kStockItemProduct, 'p2');
    expect(sumP2, 0, reason: 'sem rastreio de estoque, sem baseline');
    final sumD = await db.stockMovementSum(AppDatabase.kStockItemDot, 'd1');
    expect(sumD, 25);

    // Triggers instalados: um update bumpa a versão.
    await (db.update(db.products)..where((t) => t.id.equals('p1'))).write(
      const ProductsCompanion(),
    );
    // (update vazio não conta) — valida com uma escrita real:
    final prod = await db.saveProduct(
      id: 'p1',
      eventId: 'ev1',
      name: 'Pastel de carne',
      priceCents: 900,
      trackStock: true,
      stockQty: 40,
      active: true,
    );
    expect(prod, 'p1');
    final updated = await (db.select(db.products)..where((t) => t.id.equals('p1')))
        .getSingle();
    expect(updated.rowVersion, greaterThan(1));
    expect(updated.updatedByDevice, 'local');
  });

  test('validateSqliteHeader lê a versão de schema do arquivo', () async {
    createV8Database();
    final bytes = await dbFile.readAsBytes();
    final check = validateSqliteHeader(bytes);
    expect(check.isValid, isTrue);
    expect(check.schemaVersion, 8);

    final garbage = List<int>.filled(120, 7);
    final bad = validateSqliteHeader(
        Uint8List.fromList(garbage));
    expect(bad.isValid, isFalse);
  });
}
