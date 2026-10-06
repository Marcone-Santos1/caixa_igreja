import 'package:drift/native.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';
import 'package:caixa_igreja/providers/consolidated_report_provider.dart';

/// Relatório consolidado: filtro de período, consolidação de produto por
/// nome entre eventos, métodos, fiado e exclusões lógicas.
void main() {
  late AppDatabase db;
  late String ev1;
  late String ev2;
  late String pastel1;
  late String pastel2;

  final jan = DateTime(2026, 1, 15).millisecondsSinceEpoch;
  final jun = DateTime(2026, 6, 10).millisecondsSinceEpoch;

  Future<ConsolidatedReportData> compute(ReportPeriod period) async {
    return ConsolidatedReportData.compute(
      period: period,
      events: await db.select(db.events).get(),
      sales: await db.select(db.sales).get(),
      lines: await db.select(db.saleLines).get(),
      products: await db.select(db.products).get(),
      fiadoPayments: await db.select(db.fiadoPayments).get(),
    );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    ev1 = db.generateUuid();
    ev2 = db.generateUuid();
    await db.into(db.events).insert(
        EventsCompanion.insert(id: ev1, title: 'Festa Junina', dateEpochMs: jun));
    await db.into(db.events).insert(EventsCompanion.insert(
        id: ev2, title: 'Almoço de Janeiro', dateEpochMs: jan));
    // Mesmo nome em eventos diferentes (variação de caixa/espaço).
    pastel1 = await db.saveProduct(
        eventId: ev1, name: 'Pastel', priceCents: 800,
        trackStock: false, stockQty: 0, active: true);
    pastel2 = await db.saveProduct(
        eventId: ev2, name: ' pastel', priceCents: 700,
        trackStock: false, stockQty: 0, active: true);

    // Junho: 2 pastéis em dinheiro + 1 fiado de 800 (João).
    await db.completeSale(
      eventId: ev1,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1600,
      soldAtMs: jun,
      lines: [SaleLineDraft.product(productId: pastel1, qty: 2, unitPriceCents: 800)],
    );
    await db.completeSale(
      eventId: ev1,
      paymentMethod: PaymentMethod.fiado,
      amountReceivedCents: 0,
      customerName: 'João',
      soldAtMs: jun,
      lines: [SaleLineDraft.product(productId: pastel1, qty: 1, unitPriceCents: 800)],
    );
    // Janeiro: 3 pastéis no PIX.
    await db.completeSale(
      eventId: ev2,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 2100,
      soldAtMs: jan,
      lines: [SaleLineDraft.product(productId: pastel2, qty: 3, unitPriceCents: 700)],
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('tudo: consolida produto por nome entre eventos e soma métodos',
      () async {
    final data = await compute(ReportPeriod.all);
    expect(data.saleCount, 3);
    expect(data.totalCents, 1600 + 800 + 2100);
    expect(data.ticketMedioCents, (4500 / 3).floor());

    expect(data.byMethodCents[PaymentMethod.dinheiro], 1600);
    expect(data.byMethodCents[PaymentMethod.pix], 2100);
    expect(data.byMethodCents[PaymentMethod.fiado], 800);

    // "Pastel" + " pastel" = um produto só, 6 unidades, 2 eventos.
    expect(data.topProducts, hasLength(1));
    final p = data.topProducts.single;
    expect(p.qtySold, 6);
    expect(p.totalCents, 1600 + 800 + 2100);
    expect(p.eventCount, 2);

    // Ranking de eventos por faturamento.
    expect(data.events.first.event.id, ev1);
    expect(data.events.first.totalCents, 2400);
    expect(data.events.last.totalCents, 2100);

    expect(data.fiadoOpenTodayCents, 800);
  });

  test('período filtra pela data da venda', () async {
    final junho = ReportPeriod.custom(DateTimeRange(
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 30),
    ));
    final data = await compute(junho);
    expect(data.saleCount, 2);
    expect(data.totalCents, 2400);
    expect(data.events, hasLength(1));
    expect(data.topProducts.single.qtySold, 3);
    expect(data.topProducts.single.eventCount, 1);
    // Fiado em aberto é de HOJE, não do período.
    expect(data.fiadoOpenTodayCents, 800);
  });

  test('fiado recebido conta pela data do pagamento', () async {
    final fiadoSale = (await db.watchFiadoSales(onlyOpen: true).first).single;
    await db.registerFiadoPayment(
        saleId: fiadoSale.sale.id,
        amountCents: 300,
        method: PaymentMethod.dinheiro);

    // Pagamento é de hoje: aparece em "tudo" e no mês atual, não em junho/2026.
    final all = await compute(ReportPeriod.all);
    expect(all.fiadoReceivedInPeriodCents, 300);
    expect(all.fiadoOpenTodayCents, 500);

    final junho2026 = ReportPeriod.custom(DateTimeRange(
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 30),
    ));
    final junData = await compute(junho2026);
    expect(junData.fiadoReceivedInPeriodCents,
        DateTime.now().year == 2026 && DateTime.now().month == 6 ? 300 : 0);
  });

  test('venda excluída e evento excluído ficam fora', () async {
    // Exclui a venda em dinheiro de junho.
    final sales = await (db.select(db.sales)
          ..where((s) => s.eventId.equals(ev1)))
        .get();
    final cashSale = sales
        .firstWhere((s) => s.paymentMethod == PaymentMethod.dinheiro);
    await db.deleteSale(cashSale.id);

    var data = await compute(ReportPeriod.all);
    expect(data.saleCount, 2);
    expect(data.totalCents, 800 + 2100);

    // Tombstone do evento de janeiro tira tudo dele do relatório.
    await db.deleteEventCascade(ev2);
    data = await compute(ReportPeriod.all);
    expect(data.saleCount, 1);
    expect(data.totalCents, 800);
    expect(data.events.single.event.id, ev1);
    expect(data.topProducts.single.qtySold, 1);
  });

  test('fichas e avulsos vão para os próprios baldes, fora do ranking',
      () async {
    final dotId = await db.saveDotDenomination(
        eventId: ev1, label: 'Ficha R\$2', valueCents: 200, stockQty: 50);
    await db.completeSale(
      eventId: ev1,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1000,
      soldAtMs: jun,
      lines: [
        SaleLineDraft.ficha(dotDenominationId: dotId, qty: 3, unitPriceCents: 200),
        SaleLineDraft.valorLivre(freeLabel: 'Doação', lineTotalCents: 400),
      ],
    );
    final data = await compute(ReportPeriod.all);
    expect(data.fichasQty, 3);
    expect(data.fichasCents, 600);
    expect(data.avulsosCents, 400);
    expect(data.topProducts.single.qtySold, 6,
        reason: 'fichas/avulsos não entram no ranking de produtos');
  });
}
