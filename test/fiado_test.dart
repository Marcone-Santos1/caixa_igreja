import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/event_cloud_aggregate.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';

/// Venda fiada: saldo devedor derivado dos lançamentos (nunca flag),
/// pagamento parcial, estorno por tombstone e dinheiro na sessão certa.
void main() {
  late AppDatabase db;
  late String eventId;
  late String productId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Almoço',
            dateEpochMs: DateTime.now().millisecondsSinceEpoch,
          ),
        );
    productId = await db.saveProduct(
      eventId: eventId,
      name: 'Marmita',
      priceCents: 1500,
      trackStock: true,
      stockQty: 10,
      active: true,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> fiadoSale({int entrada = 0, String name = 'João'}) {
    return db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.fiado,
      amountReceivedCents: entrada,
      customerName: name,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 2, unitPriceCents: 1500),
      ],
    );
  }

  test('fiado exige nome e entrada menor que o total; baixa estoque', () async {
    expect(
      () => db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.fiado,
        amountReceivedCents: 0,
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 1500),
        ],
      ),
      throwsA(isA<ArgumentError>()),
      reason: 'sem nome do cliente',
    );
    expect(
      () => fiadoSale(entrada: 3000),
      throwsA(isA<ArgumentError>()),
      reason: 'entrada igual ao total não é fiado',
    );

    final saleId = await fiadoSale();
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
        .getSingle();
    expect(sale.amountReceivedCents, 0,
        reason: 'fiado guarda recebido 0; o recebido real vem dos lançamentos');
    final p = await (db.select(db.products)
          ..where((t) => t.id.equals(productId)))
        .getSingle();
    expect(p.stockQty, 8, reason: 'estoque baixa na hora da venda');
  });

  test('entrada vira o primeiro lançamento', () async {
    final saleId = await fiadoSale(entrada: 1000);
    expect(await db.fiadoPaidCents(saleId), 1000);
    final payments = await db.fiadoPaymentsForSale(saleId);
    expect(payments.single.notes, 'Entrada');
    expect(payments.single.method, PaymentMethod.dinheiro);
    expect(payments.single.sessionId, isNotNull,
        reason: 'entrada entra na gaveta da sessão da venda');
  });

  test('recebimento parcial, quitação, limite e estorno', () async {
    final saleId = await fiadoSale(); // deve 3000

    await db.registerFiadoPayment(
        saleId: saleId, amountCents: 1000, method: PaymentMethod.pix);
    expect(await db.fiadoPaidCents(saleId), 1000);

    // Receber mais que o saldo é bloqueado.
    expect(
      () => db.registerFiadoPayment(
          saleId: saleId, amountCents: 2500, method: PaymentMethod.dinheiro),
      throwsA(isA<ArgumentError>()),
    );

    final payId = await db.registerFiadoPayment(
        saleId: saleId, amountCents: 2000, method: PaymentMethod.dinheiro);
    expect(await db.fiadoPaidCents(saleId), 3000);

    // Quitado: não recebe mais.
    expect(
      () => db.registerFiadoPayment(
          saleId: saleId, amountCents: 100, method: PaymentMethod.dinheiro),
      throwsA(isA<StateError>()),
    );

    // Estorno reabre o saldo (tombstone, o histórico fica no banco).
    await db.undoFiadoPayment(payId);
    expect(await db.fiadoPaidCents(saleId), 1000);
    final raw = await (db.select(db.fiadoPayments)
          ..where((p) => p.id.equals(payId)))
        .getSingle();
    expect(raw.deletedAtMs, isNotNull);
  });

  test('saldo por cliente cruza eventos; aviso de saldo no checkout', () async {
    await fiadoSale(name: 'João'); // 3000 no evento 1

    final event2 = db.generateUuid();
    await db.into(db.events).insert(EventsCompanion.insert(
        id: event2, title: 'Festa', dateEpochMs: 2));
    final p2 = await db.saveProduct(
      eventId: event2,
      name: 'Bolo',
      priceCents: 500,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    await db.completeSale(
      eventId: event2,
      paymentMethod: PaymentMethod.fiado,
      amountReceivedCents: 0,
      customerName: 'joão ', // caixa/espaços diferentes agrupam no aviso
      lines: [SaleLineDraft.product(productId: p2, qty: 1, unitPriceCents: 500)],
    );

    expect(await db.customerFiadoOpenCents('João'), 3500);

    final balances = await db.watchFiadoBalancesByCustomer().first;
    final total = balances.fold<int>(0, (a, b) => a + b.openCents);
    expect(total, 3500);

    final suggestions = await db.customerNameSuggestions('jo');
    expect(suggestions, isNotEmpty);
  });

  test('dinheiro do fiado entra na gaveta da sessão em que foi recebido',
      () async {
    // Sessão 1: venda fiada (nenhum dinheiro).
    final session1 = await db.openCashSession(
        eventId: eventId, title: 'Domingo', initialCashFloatCents: 0);
    final saleId = await fiadoSale();
    expect(await db.fiadoCashReceivedForSession(session1), 0);
    await db.closeCashSession(sessionId: session1, closedCashDrawerCents: 0);

    // Sessão 2 (outra semana): recebe em dinheiro → gaveta da sessão 2.
    final session2 = await db.openCashSession(
        eventId: eventId, title: 'Domingo seguinte', initialCashFloatCents: 0);
    await db.registerFiadoPayment(
        saleId: saleId, amountCents: 3000, method: PaymentMethod.dinheiro);
    expect(await db.fiadoCashReceivedForSession(session2), 3000);
    expect(await db.fiadoCashReceivedForSession(session1), 0);

    // PIX não entra na conta da gaveta.
    final sale2 = await fiadoSale(name: 'Maria');
    await db.registerFiadoPayment(
        saleId: sale2, amountCents: 500, method: PaymentMethod.pix);
    expect(await db.fiadoCashReceivedForSession(session2), 3000);
  });

  test('editar/excluir fiado com recebimentos é bloqueado; sem eles, flui',
      () async {
    final saleId = await fiadoSale(entrada: 1000);

    // Mudar o método com recebimentos: bloqueado.
    expect(
      () => db.updateSaleWithLines(
        saleId: saleId,
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 3000,
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 2, unitPriceCents: 1500),
        ],
      ),
      throwsA(isA<StateError>()),
    );
    // Reduzir o total abaixo do já recebido: bloqueado.
    expect(
      () => db.updateSaleWithLines(
        saleId: saleId,
        eventId: eventId,
        paymentMethod: PaymentMethod.fiado,
        amountReceivedCents: 0,
        customerName: 'João',
        lines: [
          SaleLineDraft.valorLivre(freeLabel: 'Ajuste', lineTotalCents: 500),
        ],
      ),
      throwsA(isA<StateError>()),
    );
    // Excluir com recebimentos: bloqueado.
    expect(() => db.deleteSale(saleId), throwsA(isA<StateError>()));

    // Sem recebimentos, tudo flui.
    final livre = await fiadoSale(name: 'Pedro');
    await db.deleteSale(livre);
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(livre)))
        .getSingle();
    expect(sale.deletedAtMs, isNotNull);
  });

  test('lançamentos viajam no agregado do evento (nuvem)', () async {
    final saleId = await fiadoSale(entrada: 500);
    await db.registerFiadoPayment(
        saleId: saleId, amountCents: 1000, method: PaymentMethod.pix);

    final fpBefore = await db.eventCloudFingerprint(eventId);
    final json = await db.exportEventAggregate(eventId);
    expect((json!['fiadoPayments'] as List), hasLength(2));
    expect(json['formatVersion'], kEventAggregateFormatVersion);

    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await other.applyEventAggregate(json);
    expect(await other.fiadoPaidCents(saleId), 1500);
    expect(await other.eventCloudFingerprint(eventId), fpBefore);

    // Receber no outro aparelho muda o fingerprint (vai subir na nuvem).
    await other.registerFiadoPayment(
        saleId: saleId, amountCents: 1500, method: PaymentMethod.dinheiro);
    expect(await other.eventCloudFingerprint(eventId), isNot(fpBefore));
  });
}
