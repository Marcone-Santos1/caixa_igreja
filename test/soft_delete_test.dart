import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';

/// Exclusões lógicas (tombstones): nada é apagado fisicamente, as consultas
/// filtram, e o histórico fica preservado para a sincronização.
void main() {
  late AppDatabase db;
  late String eventId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Quermesse',
            dateEpochMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('deleteSale: some das consultas, linha permanece no banco', () async {
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Cachorro-quente',
      priceCents: 1200,
      trackStock: true,
      stockQty: 5,
      active: true,
    );
    final saleId = await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1200,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 1200),
      ],
    );

    await db.deleteSale(saleId);

    final visible = await db.watchSalesForEvent(eventId).first;
    expect(visible, isEmpty);
    final visibleLines = await db.watchSaleLinesForEvent(eventId).first;
    expect(visibleLines, isEmpty);
    final summary = await db.eventFinanceSummary(eventId);
    expect(summary.saleCount, 0);

    // A linha física continua lá (tombstone na venda).
    final rawSale = await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
        .getSingle();
    expect(rawSale.deletedAtMs, isNotNull);
    final rawLines = await db.saleLinesRaw(saleId);
    expect(rawLines, hasLength(1));
  });

  test('deleteProduct: tombstone preserva vendas e permite excluir vendidos',
      () async {
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Pipoca',
      priceCents: 500,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 500,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 500),
      ],
    );

    // Com exclusão lógica, produto vendido PODE ser excluído (RFC cenário 5).
    final err = await db.deleteProduct(eventId: eventId, productId: productId);
    expect(err, isNull);

    final products = await db.watchAllProductsForEvent(eventId).first;
    expect(products, isEmpty);
    // A venda continua visível e íntegra.
    final sales = await db.watchSalesForEvent(eventId).first;
    expect(sales, hasLength(1));
  });

  test('deleteDotDenomination: tombstone preserva vendas antigas', () async {
    final dotId = await db.saveDotDenomination(
      eventId: eventId,
      label: 'Ficha',
      valueCents: 100,
      stockQty: 10,
    );
    await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 100,
      lines: [
        SaleLineDraft.ficha(dotDenominationId: dotId, qty: 1, unitPriceCents: 100),
      ],
    );
    final err = await db.deleteDotDenomination(
        eventId: eventId, dotDenominationId: dotId);
    expect(err, isNull);
    final denoms = await db.watchDotDenominations(eventId).first;
    expect(denoms, isEmpty);
    final sales = await db.watchSalesForEvent(eventId).first;
    expect(sales, hasLength(1));
  });

  test('deleteEventCascade: tombstone só no evento, dados preservados',
      () async {
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Doce',
      priceCents: 300,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 300,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 300),
      ],
    );

    await db.deleteEventCascade(eventId);

    final events = await db.watchAllEvents().first;
    expect(events, isEmpty);
    // Dados físicos continuam lá (histórico/sincronização).
    final rawSales = await (db.select(db.sales)
          ..where((s) => s.eventId.equals(eventId)))
        .get();
    expect(rawSales, hasLength(1));
    final rawEvent = await (db.select(db.events)
          ..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(rawEvent.deletedAtMs, isNotNull);
  });

  test('produto excluído não pode ser vendido', () async {
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Torta',
      priceCents: 900,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    await db.deleteProduct(eventId: eventId, productId: productId);
    expect(
      () => db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 900,
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 900),
        ],
      ),
      throwsA(isA<StateError>()),
    );
  });
}
