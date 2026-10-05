import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/event_cloud_aggregate.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';

/// Agregado de evento (RFC v2): export/apply roundtrip entre dois "celulares"
/// e fingerprint derivado dos dados.
void main() {
  late AppDatabase deviceA;
  late AppDatabase deviceB;
  late String eventId;

  setUp(() async {
    deviceA = AppDatabase(NativeDatabase.memory());
    deviceB = AppDatabase(NativeDatabase.memory());
    eventId = deviceA.generateUuid();
    await deviceA.into(deviceA.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Quermesse',
            dateEpochMs: 1234,
          ),
        );
  });

  tearDown(() async {
    await deviceA.close();
    await deviceB.close();
  });

  Future<String> seedEventData() async {
    final productId = await deviceA.saveProduct(
      eventId: eventId,
      name: 'Pastel',
      priceCents: 800,
      trackStock: true,
      stockQty: 30,
      active: true,
    );
    final dotId = await deviceA.saveDotDenomination(
      eventId: eventId,
      label: 'Ficha R\$1',
      valueCents: 100,
      stockQty: 50,
    );
    final saleId = await deviceA.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 2000,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 2, unitPriceCents: 800),
      ],
    );
    await deviceA.confirmChangeDots(
      saleId: saleId,
      eventId: eventId,
      changeCents: 400,
      allocation: [(dotDenominationId: dotId, qty: 4)],
    );
    // Uma venda excluída: o tombstone precisa viajar no agregado.
    final deletedSaleId = await deviceA.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 800,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 800),
      ],
    );
    await deviceA.deleteSale(deletedSaleId);
    return productId;
  }

  test('roundtrip: exportar no celular A e aplicar no celular B', () async {
    final productId = await seedEventData();

    final json = await deviceA.exportEventAggregate(eventId);
    expect(json, isNotNull);
    // Simula o transporte (JSON de verdade, como vai pela rede).
    final wire =
        jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
    await deviceB.applyEventAggregate(wire);

    // O evento chegou com tudo.
    final ev = await (deviceB.select(deviceB.events)
          ..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.title, 'Quermesse');

    final visibleSales = await deviceB.watchSalesForEvent(eventId).first;
    expect(visibleSales, hasLength(1), reason: 'venda excluída não reaparece');
    final allSales = await (deviceB.select(deviceB.sales)
          ..where((s) => s.eventId.equals(eventId)))
        .get();
    expect(allSales, hasLength(2), reason: 'tombstone viaja no agregado');

    final p = await (deviceB.select(deviceB.products)
          ..where((t) => t.id.equals(productId)))
        .getSingle();
    expect(p.stockQty, 28,
        reason: '30 - 2 vendidos; a venda excluída devolveu o que baixou');
    // Invariante E1 preservado no destino.
    final sum = await deviceB.stockMovementSum(
        AppDatabase.kStockItemProduct, productId);
    expect(sum, p.stockQty);

    // Sessão de caixa também viaja (não viajava no sync Wi-Fi).
    final sessions = await deviceB.getSessions(eventId);
    expect(sessions, hasLength(1));

    // Fingerprints iguais nos dois lados após o apply.
    final fpA = await deviceA.eventCloudFingerprint(eventId);
    final fpB = await deviceB.eventCloudFingerprint(eventId);
    expect(fpB, fpA);
  });

  test('apply substitui o estado anterior do evento (fast-forward)', () async {
    await seedEventData();
    final json = await deviceA.exportEventAggregate(eventId);

    // B tem uma versão velha do mesmo evento com outro produto.
    await deviceB.runWithSyncBypass(() async {
      await deviceB.into(deviceB.events).insert(
            EventsCompanion.insert(
                id: eventId, title: 'Velho título', dateEpochMs: 1),
          );
    });
    await deviceB.saveProduct(
      eventId: eventId,
      name: 'Produto antigo',
      priceCents: 100,
      trackStock: false,
      stockQty: 0,
      active: true,
    );

    await deviceB.applyEventAggregate(json!);

    final ev = await (deviceB.select(deviceB.events)
          ..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.title, 'Quermesse');
    final products = await (deviceB.select(deviceB.products)
          ..where((t) => t.eventId.equals(eventId)))
        .get();
    expect(products.map((p) => p.name), isNot(contains('Produto antigo')));
  });

  test('fingerprint: estável sem escrita, muda a cada alteração', () async {
    final productId = await seedEventData();

    final fp1 = await deviceA.eventCloudFingerprint(eventId);
    final fp1b = await deviceA.eventCloudFingerprint(eventId);
    expect(fp1b, fp1, reason: 'leitura não altera o fingerprint');

    final saleId = await deviceA.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 800,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 800),
      ],
    );
    final fp2 = await deviceA.eventCloudFingerprint(eventId);
    expect(fp2, isNot(fp1), reason: 'venda nova muda o fingerprint');

    await deviceA.deleteSale(saleId);
    final fp3 = await deviceA.eventCloudFingerprint(eventId);
    expect(fp3, isNot(fp2), reason: 'exclusão (tombstone) muda o fingerprint');

    await (deviceA.update(deviceA.events)
          ..where((e) => e.id.equals(eventId)))
        .write(const EventsCompanion());
    final fp4 = await deviceA.eventCloudFingerprint(eventId);
    expect(fp4, fp3, reason: 'update vazio não muda nada');
  });

  test('apply bloqueia formato/schema mais novos', () async {
    await seedEventData();
    final json = await deviceA.exportEventAggregate(eventId);

    final newerFormat = Map<String, dynamic>.from(json!);
    newerFormat['formatVersion'] = kEventAggregateFormatVersion + 1;
    expect(() => deviceB.applyEventAggregate(newerFormat),
        throwsA(isA<StateError>()));

    final newerSchema = Map<String, dynamic>.from(json);
    newerSchema['schemaVersion'] = kAppSchemaVersion + 1;
    expect(() => deviceB.applyEventAggregate(newerSchema),
        throwsA(isA<StateError>()));
  });

  test('evento inexistente: export e fingerprint retornam null', () async {
    expect(await deviceA.exportEventAggregate('nao-existe'), isNull);
    expect(await deviceA.eventCloudFingerprint('nao-existe'), isNull);
  });
}
