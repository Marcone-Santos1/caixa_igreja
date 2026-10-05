import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';

/// Invariante E1: para todo item, soma(movimentações) == stockQty (cache).
void main() {
  late AppDatabase db;
  late String eventId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Festa',
            dateEpochMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> expectConsistent(int itemType, String itemId) async {
    final sum = await db.stockMovementSum(itemType, itemId);
    if (itemType == AppDatabase.kStockItemProduct) {
      final p = await (db.select(db.products)..where((t) => t.id.equals(itemId)))
          .getSingle();
      expect(sum, p.stockQty,
          reason: 'soma(movimentações) difere do stockQty do produto');
    } else {
      final d = await (db.select(db.eventDotDenominations)
            ..where((t) => t.id.equals(itemId)))
          .getSingle();
      expect(sum, d.stockQty,
          reason: 'soma(movimentações) difere do stockQty da ficha');
    }
  }

  test('saveProduct: carga inicial e ajuste manual geram movimentações',
      () async {
    final id = await db.saveProduct(
      eventId: eventId,
      name: 'Pastel',
      priceCents: 800,
      trackStock: true,
      stockQty: 50,
      active: true,
    );
    await expectConsistent(AppDatabase.kStockItemProduct, id);

    await db.saveProduct(
      id: id,
      eventId: eventId,
      name: 'Pastel',
      priceCents: 800,
      trackStock: true,
      stockQty: 42, // ajuste manual -8
      active: true,
    );
    await expectConsistent(AppDatabase.kStockItemProduct, id);

    final movements = await db.select(db.stockMovements).get();
    expect(movements.length, 2);
    expect(movements.map((m) => m.delta), containsAll([50, -8]));
  });

  test('venda, edição e exclusão mantêm o invariante', () async {
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Refri',
      priceCents: 500,
      trackStock: true,
      stockQty: 10,
      active: true,
    );

    final saleId = await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1500,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 3, unitPriceCents: 500),
      ],
    );
    await expectConsistent(AppDatabase.kStockItemProduct, productId);
    var p = await (db.select(db.products)..where((t) => t.id.equals(productId)))
        .getSingle();
    expect(p.stockQty, 7);

    // Edição: 3 -> 2 unidades
    await db.updateSaleWithLines(
      saleId: saleId,
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1000,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 2, unitPriceCents: 500),
      ],
    );
    await expectConsistent(AppDatabase.kStockItemProduct, productId);
    p = await (db.select(db.products)..where((t) => t.id.equals(productId)))
        .getSingle();
    expect(p.stockQty, 8);

    // Exclusão devolve tudo
    await db.deleteSale(saleId);
    await expectConsistent(AppDatabase.kStockItemProduct, productId);
    p = await (db.select(db.products)..where((t) => t.id.equals(productId)))
        .getSingle();
    expect(p.stockQty, 10);

    // Exclusão repetida não devolve duas vezes
    await db.deleteSale(saleId);
    p = await (db.select(db.products)..where((t) => t.id.equals(productId)))
        .getSingle();
    expect(p.stockQty, 10);
  });

  test('troco em fichas: confirmação, preservação na edição e descarte',
      () async {
    final dotId = await db.saveDotDenomination(
      eventId: eventId,
      label: 'Ficha R\$1',
      valueCents: 100,
      stockQty: 20,
    );
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Bolo',
      priceCents: 700,
      trackStock: false,
      stockQty: 0,
      active: true,
    );

    // Venda de 700 paga com 1000 -> troco 300 em 3 fichas
    final saleId = await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1000,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 700),
      ],
    );
    await db.confirmChangeDots(
      saleId: saleId,
      eventId: eventId,
      changeCents: 300,
      allocation: [(dotDenominationId: dotId, qty: 3)],
    );
    await expectConsistent(AppDatabase.kStockItemDot, dotId);
    var d = await (db.select(db.eventDotDenominations)
          ..where((t) => t.id.equals(dotId)))
        .getSingle();
    expect(d.stockQty, 17);

    // Edição que NÃO muda o troco (mesmo total e recebido):
    // as alocações são preservadas e o estoque não é mexido.
    await db.updateSaleWithLines(
      saleId: saleId,
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1000,
      customerName: 'João',
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 700),
      ],
    );
    final keptAllocations = await (db.select(db.saleChangeDotAllocations)
          ..where((t) => t.saleId.equals(saleId)))
        .get();
    expect(keptAllocations.length, 1,
        reason: 'alocações de troco devem sobreviver à edição sem mudança de troco');
    d = await (db.select(db.eventDotDenominations)
          ..where((t) => t.id.equals(dotId)))
        .getSingle();
    expect(d.stockQty, 17);
    await expectConsistent(AppDatabase.kStockItemDot, dotId);

    // Edição que MUDA o troco: alocações descartadas, fichas devolvidas.
    await db.updateSaleWithLines(
      saleId: saleId,
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 700,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 700),
      ],
    );
    final droppedAllocations = await (db.select(db.saleChangeDotAllocations)
          ..where((t) => t.saleId.equals(saleId)))
        .get();
    expect(droppedAllocations, isEmpty);
    d = await (db.select(db.eventDotDenominations)
          ..where((t) => t.id.equals(dotId)))
        .getSingle();
    expect(d.stockQty, 20);
    await expectConsistent(AppDatabase.kStockItemDot, dotId);
  });

  test('venda de ficha movimenta o estoque da ficha', () async {
    final dotId = await db.saveDotDenomination(
      eventId: eventId,
      label: 'Ficha R\$5',
      valueCents: 500,
      stockQty: 10,
    );
    await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 1000,
      lines: [
        SaleLineDraft.ficha(dotDenominationId: dotId, qty: 2, unitPriceCents: 500),
      ],
    );
    await expectConsistent(AppDatabase.kStockItemDot, dotId);
    final d = await (db.select(db.eventDotDenominations)
          ..where((t) => t.id.equals(dotId)))
        .getSingle();
    expect(d.stockQty, 8);
  });

  test('recalcStockFromMovements corrige caches divergentes', () async {
    final id = await db.saveProduct(
      eventId: eventId,
      name: 'Suco',
      priceCents: 300,
      trackStock: true,
      stockQty: 30,
      active: true,
    );
    // Corrompe o cache de propósito (simula pós-junção).
    await db.customStatement(
        "UPDATE products SET stock_qty = 999 WHERE id = '$id'");
    await db.recalcStockFromMovements();
    final p = await (db.select(db.products)..where((t) => t.id.equals(id)))
        .getSingle();
    expect(p.stockQty, 30);
  });
}
