import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/event_cloud_aggregate.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';
import 'package:caixa_igreja/providers/consolidated_report_provider.dart';

/// Pacote 1.6.0: descontos/cortesias, duplicar evento e custos (lucro).
void main() {
  late AppDatabase db;
  late String eventId;
  late String productId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    eventId = db.generateUuid();
    await db.into(db.events).insert(EventsCompanion.insert(
          id: eventId,
          title: 'Festa',
          dateEpochMs: DateTime.now().millisecondsSinceEpoch,
          pixKey: const Value('chave-pix'),
        ));
    productId = await db.saveProduct(
      eventId: eventId,
      name: 'Pastel',
      priceCents: 800,
      trackStock: true,
      stockQty: 20,
      active: true,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('desconto', () {
    test('total final = soma das linhas − desconto; motivo obrigatório',
        () async {
      expect(
        () => db.completeSale(
          eventId: eventId,
          paymentMethod: PaymentMethod.dinheiro,
          amountReceivedCents: 1500,
          discountCents: 100,
          lines: [
            SaleLineDraft.product(
                productId: productId, qty: 2, unitPriceCents: 800),
          ],
        ),
        throwsA(isA<ArgumentError>()),
        reason: 'desconto sem motivo é bloqueado',
      );

      final saleId = await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 1500,
        discountCents: 100,
        discountReason: 'Voluntário da cozinha',
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 2, unitPriceCents: 800),
        ],
      );
      final sale =
          await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
              .getSingle();
      expect(sale.totalCents, 1500, reason: '1600 − 100');
      expect(sale.discountCents, 100);
      expect(sale.discountReason, 'Voluntário da cozinha');
      // Estoque baixa pelo que saiu, não pelo valor.
      final p = await (db.select(db.products)
            ..where((t) => t.id.equals(productId)))
          .getSingle();
      expect(p.stockQty, 18);
    });

    test('cortesia: total 0, não pode ser fiada', () async {
      final saleId = await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.outros,
        amountReceivedCents: 0,
        discountCents: 800,
        discountReason: 'Cortesia para o padre',
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 800),
        ],
      );
      final sale =
          await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
              .getSingle();
      expect(sale.totalCents, 0);

      expect(
        () => db.completeSale(
          eventId: eventId,
          paymentMethod: PaymentMethod.fiado,
          amountReceivedCents: 0,
          customerName: 'João',
          discountCents: 800,
          discountReason: 'cortesia',
          lines: [
            SaleLineDraft.product(
                productId: productId, qty: 1, unitPriceCents: 800),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fiado com desconto: saldo devedor é o total com desconto', () async {
      final saleId = await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.fiado,
        amountReceivedCents: 0,
        customerName: 'Maria',
        discountCents: 300,
        discountReason: 'Promoção',
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 2, unitPriceCents: 800),
        ],
      );
      final info = (await db.watchFiadoSales(eventId: eventId).first).single;
      expect(info.sale.id, saleId);
      expect(info.openCents, 1300, reason: '1600 − 300 de desconto');
    });

    test('edição mantém a regra do desconto', () async {
      final saleId = await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 800,
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 800),
        ],
      );
      await db.updateSaleWithLines(
        saleId: saleId,
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 700,
        discountCents: 100,
        discountReason: 'Ajuste',
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 800),
        ],
      );
      final sale =
          await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
              .getSingle();
      expect(sale.totalCents, 700);
      expect(sale.discountCents, 100);
    });
  });

  group('duplicar evento', () {
    test('copia catálogo com combos remapeados e baseline de estoque',
        () async {
      final refriId = await db.saveProduct(
        eventId: eventId,
        name: 'Refri',
        priceCents: 500,
        trackStock: true,
        stockQty: 30,
        active: true,
      );
      await db.createCombo(
        eventId: eventId,
        name: 'Combo Pastel+Refri',
        priceCents: 1200,
        items: [
          (childProductId: productId, qty: 1),
          (childProductId: refriId, qty: 1),
        ],
      );
      final dotId = await db.saveDotDenomination(
          eventId: eventId, label: 'Ficha', valueCents: 100, stockQty: 40);
      // Uma venda no original, que NÃO pode ir junto.
      await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.pix,
        amountReceivedCents: 800,
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 800),
        ],
      );

      final newId = await db.duplicateEvent(
        sourceEventId: eventId,
        title: 'Festa 2027',
        dateEpochMs: 123456,
        copyStock: true,
      );

      final newEvent = await (db.select(db.events)
            ..where((e) => e.id.equals(newId)))
          .getSingle();
      expect(newEvent.pixKey, 'chave-pix');

      final newProducts = await (db.select(db.products)
            ..where((pr) => pr.eventId.equals(newId)))
          .get();
      expect(newProducts, hasLength(3));
      expect(newProducts.map((pr) => pr.id),
          isNot(contains(productId)), reason: 'ids novos');

      // Combo remapeado para os filhos NOVOS.
      final newCombo = newProducts.firstWhere((pr) => pr.isCombo);
      final items = await db.getComboItems(newCombo.id);
      expect(items, hasLength(2));
      final newIds = newProducts.map((pr) => pr.id).toSet();
      for (final item in items) {
        expect(newIds, contains(item.childProductId));
      }

      // Estoques copiados COM baseline (invariante E1 no evento novo).
      final newPastel = newProducts.firstWhere((pr) => pr.name == 'Pastel');
      expect(newPastel.stockQty, 19, reason: '20 − 1 vendido no original');
      expect(
          await db.stockMovementSum(
              AppDatabase.kStockItemProduct, newPastel.id),
          19);
      final newDots = await (db.select(db.eventDotDenominations)
            ..where((d) => d.eventId.equals(newId)))
          .get();
      expect(newDots.single.stockQty, 40);
      expect(newDots.single.id, isNot(dotId));

      // Vendas não foram copiadas.
      final newSales = await (db.select(db.sales)
            ..where((sl) => sl.eventId.equals(newId)))
          .get();
      expect(newSales, isEmpty);
    });

    test('copyStock=false zera tudo', () async {
      final newId = await db.duplicateEvent(
        sourceEventId: eventId,
        title: 'Zerado',
        dateEpochMs: 1,
        copyStock: false,
      );
      final newProducts = await (db.select(db.products)
            ..where((pr) => pr.eventId.equals(newId)))
          .get();
      expect(newProducts.single.stockQty, 0);
      expect(
          await db.stockMovementSum(
              AppDatabase.kStockItemProduct, newProducts.single.id),
          0);
    });
  });

  group('custos e lucro', () {
    test('CRUD com tombstone e lucro no relatório', () async {
      await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 1600,
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 2, unitPriceCents: 800),
        ],
      );
      final gasId = await db.saveEventExpense(
        eventId: eventId,
        description: 'Botijão de gás',
        amountCents: 12000,
        category: 'Gás',
      );
      await db.saveEventExpense(
        eventId: eventId,
        description: 'Carne',
        amountCents: 30000,
        category: 'Insumos',
      );
      var expenses = await db.watchEventExpenses(eventId).first;
      expect(expenses, hasLength(2));

      await db.deleteEventExpense(gasId);
      expenses = await db.watchEventExpenses(eventId).first;
      expect(expenses, hasLength(1), reason: 'tombstone some da lista');

      final report = ConsolidatedReportData.compute(
        period: ReportPeriod.all,
        events: await db.select(db.events).get(),
        sales: await db.select(db.sales).get(),
        lines: await db.select(db.saleLines).get(),
        products: await db.select(db.products).get(),
        fiadoPayments: await db.select(db.fiadoPayments).get(),
        expenses: await db.select(db.eventExpenses).get(),
      );
      expect(report.expensesCents, 30000,
          reason: 'custo excluído fica fora');
      expect(report.totalCents, 1600);
      expect(report.profitCents, 1600 - 30000);
    });

    test('custos e desconto viajam no agregado do evento (formato v3)',
        () async {
      await db.saveEventExpense(
          eventId: eventId, description: 'Gás', amountCents: 9000);
      await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 700,
        discountCents: 100,
        discountReason: 'Promo',
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 800),
        ],
      );
      final json = await db.exportEventAggregate(eventId);
      expect(json!['formatVersion'], 3);
      expect((json['eventExpenses'] as List), hasLength(1));

      final other = AppDatabase(NativeDatabase.memory());
      addTearDown(other.close);
      await other.applyEventAggregate(json);
      final expenses = await other.watchEventExpenses(eventId).first;
      expect(expenses.single.amountCents, 9000);
      final sale = (await (other.select(other.sales)
              ..where((sl) => sl.eventId.equals(eventId)))
          .get())
          .single;
      expect(sale.discountCents, 100);
      expect(sale.totalCents, 700);
    });

    test('relatório: descontos e cortesias contados', () async {
      await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.outros,
        amountReceivedCents: 0,
        discountCents: 800,
        discountReason: 'Cortesia padre',
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 1, unitPriceCents: 800),
        ],
      );
      await db.completeSale(
        eventId: eventId,
        paymentMethod: PaymentMethod.dinheiro,
        amountReceivedCents: 1400,
        discountCents: 200,
        discountReason: 'Promo',
        lines: [
          SaleLineDraft.product(
              productId: productId, qty: 2, unitPriceCents: 800),
        ],
      );
      final report = ConsolidatedReportData.compute(
        period: ReportPeriod.all,
        events: await db.select(db.events).get(),
        sales: await db.select(db.sales).get(),
        lines: await db.select(db.saleLines).get(),
        products: await db.select(db.products).get(),
        fiadoPayments: await db.select(db.fiadoPayments).get(),
        expenses: const [],
      );
      expect(report.discountCents, 1000);
      expect(report.courtesyCount, 1);
      expect(report.totalCents, 1400);
    });
  });
}
