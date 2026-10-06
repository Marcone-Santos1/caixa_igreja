import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';
import 'package:caixa_igreja/domain/sale_line_kind.dart';

/// `syncEventData` (snapshot do host Wi-Fi aplicado no cliente):
/// - vendas locais que o host não conhece são PRESERVADAS (fix do bug de
///   perda de dados de venda offline);
/// - os valores de sincronização vindos do host são mantidos (bypass).
void main() {
  late AppDatabase db;
  late String eventId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Evento',
            dateEpochMs: 1000,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  ChurchEvent hostEvent() => ChurchEvent(
        id: eventId,
        title: 'Evento (host)',
        notes: '',
        dateEpochMs: 1000,
        rowVersion: 5,
        updatedAtMs: 99999,
        updatedByDevice: 'host-device',
      );

  ChurchProduct hostProduct(String id) => ChurchProduct(
        id: id,
        eventId: eventId,
        name: 'Produto do host',
        description: '',
        priceCents: 500,
        trackStock: false,
        stockQty: 0,
        active: true,
        isCombo: false,
        rowVersion: 3,
        updatedAtMs: 88888,
        updatedByDevice: 'host-device',
      );

  PosSale hostSale(String id, String? sessionId) => PosSale(
        id: id,
        eventId: eventId,
        sessionId: sessionId,
        soldAtMs: 2000,
        totalCents: 500,
        amountReceivedCents: 500,
        paymentMethod: PaymentMethod.pix,
        changePending: false,
        discountCents: 0,
        rowVersion: 2,
        updatedAtMs: 77777,
        updatedByDevice: 'host-device',
      );

  test('venda offline local é preservada; dados do host entram com versão intacta',
      () async {
    // 1. Venda local criada offline (o host não a conhece).
    final localProductId = await db.saveProduct(
      eventId: eventId,
      name: 'Produto local',
      priceCents: 300,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    final offlineSaleId = await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 300,
      lines: [
        SaleLineDraft.product(
            productId: localProductId, qty: 1, unitPriceCents: 300),
      ],
    );

    // 2. Snapshot do host chega sem essa venda.
    final hostProductId = db.generateUuid();
    final hostSaleId = db.generateUuid();
    final hostLineId = db.generateUuid();
    await db.syncEventData(
      eventId: eventId,
      event: hostEvent(),
      denoms: [],
      productsList: [hostProduct(hostProductId)],
      comboItems: [],
      salesList: [hostSale(hostSaleId, null)],
      saleLinesList: [
        PosSaleLine(
          id: hostLineId,
          saleId: hostSaleId,
          lineKind: SaleLineKind.product,
          productId: hostProductId,
          qty: 1,
          unitPriceCents: 500,
          lineTotalCents: 500,
          rowVersion: 1,
          updatedAtMs: 77777,
          updatedByDevice: 'host-device',
        ),
      ],
      changeAllocationsList: [],
    );

    // A venda offline sobreviveu, com as linhas.
    final offlineSale = await (db.select(db.sales)
          ..where((s) => s.id.equals(offlineSaleId)))
        .getSingleOrNull();
    expect(offlineSale, isNotNull,
        reason: 'venda offline não pode ser apagada pelo snapshot do host');
    expect(await db.saleLinesRaw(offlineSaleId), hasLength(1));

    // A venda do host entrou com rowVersion/updatedBy preservados (bypass).
    final imported = await (db.select(db.sales)
          ..where((s) => s.id.equals(hostSaleId)))
        .getSingle();
    expect(imported.rowVersion, 2);
    expect(imported.updatedByDevice, 'host-device');

    final ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.rowVersion, 5);
    expect(ev.title, 'Evento (host)');

    // localOnlySalesForEvent aponta exatamente a venda pendente de push.
    final pending =
        await db.localOnlySalesForEvent(eventId, {hostSaleId});
    expect(pending.map((s) => s.id), [offlineSaleId]);
  });

  test('venda conhecida pelo host é substituída pelo estado do host', () async {
    final saleId = db.generateUuid();
    // Estado local antigo da venda.
    await db.runWithSyncBypass(() async {
      await db.into(db.sales).insert(hostSale(saleId, null));
    });

    final updated = PosSale(
      id: saleId,
      eventId: eventId,
      sessionId: null,
      soldAtMs: 2000,
      totalCents: 999,
      amountReceivedCents: 999,
      paymentMethod: PaymentMethod.cartaoCredito,
      changePending: false,
        discountCents: 0,
      rowVersion: 4,
      updatedAtMs: 123,
      updatedByDevice: 'host-device',
    );
    await db.syncEventData(
      eventId: eventId,
      event: hostEvent(),
      denoms: [],
      productsList: [],
      comboItems: [],
      salesList: [updated],
      saleLinesList: [],
      changeAllocationsList: [],
    );
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
        .getSingle();
    expect(sale.totalCents, 999);
    expect(sale.rowVersion, 4);
  });

  test('completeSale aceita saleId e soldAtMs explícitos (push de venda offline)',
      () async {
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Produto',
      priceCents: 500,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    final forcedId = db.generateUuid();
    final returned = await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 500,
      saleId: forcedId,
      soldAtMs: 424242,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 500),
      ],
    );
    expect(returned, forcedId);
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(forcedId)))
        .getSingle();
    expect(sale.soldAtMs, 424242);

    // Reenvio duplicado falha (PK), nunca duplica a venda.
    expect(
      () => db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 500,
        saleId: forcedId,
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 500),
        ],
      ),
      throwsA(anything),
    );
    final count = await (db.select(db.sales)
          ..where((s) => s.id.equals(forcedId)))
        .get();
    expect(count, hasLength(1));
  });
}
