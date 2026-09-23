import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/database_seeder.dart';
import 'package:caixa_igreja/domain/payment_method.dart';
import 'package:caixa_igreja/domain/sale_line_kind.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DatabaseSeeder seeder;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    seeder = DatabaseSeeder(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('DatabaseSeeder.seedAll popula os 3 eventos e seus dados associados', () async {
    final result = await seeder.seedAll();

    expect(result.eventsCount, 3);
    expect(result.productsCount, greaterThan(15));
    expect(result.dotDenominationsCount, 5);
    expect(result.salesCount, 9); // 6 na Festa Junina + 3 no Bazar + 0 no Almoço
    expect(result.totalRevenueCents, greaterThan(0));

    final events = await db.select(db.events).get();
    expect(events.length, 3);

    final eventTitles = events.map((e) => e.title).toList();
    expect(eventTitles, contains('Festa Junina Paroquial 2026'));
    expect(eventTitles, contains('Bazar da Solidariedade'));
    expect(eventTitles, contains('Almoço Comunitário de São Pedro'));

    // Verifica produtos e combos
    final allProducts = await db.select(db.products).get();
    final combos = allProducts.where((p) => p.isCombo).toList();
    expect(combos.length, 3); // 2 na Festa Junina + 1 no Almoço

    final comboItems = await db.select(db.productComboItems).get();
    expect(comboItems, isNotEmpty);

    // Verifica fichas (denominações)
    final denoms = await db.select(db.eventDotDenominations).get();
    expect(denoms.length, 5);

    // Verifica vendas e linhas de venda
    final sales = await db.select(db.sales).get();
    expect(sales.length, 9);

    final lines = await db.select(db.saleLines).get();
    expect(lines, isNotEmpty);

    // Verifica integridade matemática de cada venda e suas linhas
    for (final sale in sales) {
      final saleLines = lines.where((l) => l.saleId == sale.id).toList();
      expect(saleLines, isNotEmpty, reason: 'Toda venda deve ter linhas de venda');
      final linesSum = saleLines.fold<int>(0, (acc, l) => acc + l.lineTotalCents);
      expect(linesSum, equals(sale.totalCents),
          reason: 'A soma das linhas deve bater com o total da venda');
      expect(sale.amountReceivedCents, greaterThanOrEqualTo(sale.totalCents),
          reason: 'Valor recebido deve ser >= total');
    }

    // Verifica troco em fichas registrado
    final changeDots = await db.select(db.saleChangeDotAllocations).get();
    expect(changeDots.length, 1);
    final changeSale = sales.firstWhere((s) => s.id == changeDots.first.saleId);
    expect(changeSale.paymentMethod, PaymentMethod.dinheiro);
    final denomFicha2 = denoms.firstWhere((d) => d.id == changeDots.first.dotDenominationId);
    expect(changeDots.first.qty * denomFicha2.valueCents,
        equals(changeSale.amountReceivedCents - changeSale.totalCents));

    // Verifica venda com troco pendente
    final pendingSales = sales.where((s) => s.changePending).toList();
    expect(pendingSales.length, 1);
    expect(pendingSales.first.customerName, 'Seu Geraldo');

    // Verifica venda com valor livre (doação avulsa)
    final freeValueLines = lines.where((l) => l.lineKind == SaleLineKind.valorLivre).toList();
    expect(freeValueLines.length, 1);
    expect(freeValueLines.first.lineTotalCents, 5000);
  });

  test('DatabaseSeeder.clearAll esvazia todas as tabelas corretamente', () async {
    await seeder.seedAll();

    expect((await db.select(db.events).get()).length, 3);
    expect((await db.select(db.sales).get()).length, 9);

    await seeder.clearAll();

    expect((await db.select(db.events).get()), isEmpty);
    expect((await db.select(db.products).get()), isEmpty);
    expect((await db.select(db.productComboItems).get()), isEmpty);
    expect((await db.select(db.eventDotDenominations).get()), isEmpty);
    expect((await db.select(db.sales).get()), isEmpty);
    expect((await db.select(db.saleLines).get()), isEmpty);
    expect((await db.select(db.saleChangeDotAllocations).get()), isEmpty);
  });

  test('DatabaseSeeder.seedAll(clearExisting: true) substitui os dados sem erro', () async {
    await seeder.seedAll();
    final result2 = await seeder.seedAll(clearExisting: true);

    expect(result2.eventsCount, 3);
    final events = await db.select(db.events).get();
    expect(events.length, 3);
  });

  test('EventFinanceSummary calcula corretamente os dados semeados da Festa Junina', () async {
    await seeder.seedFestaJunina();

    final events = await db.select(db.events).get();
    expect(events.length, 1);
    final festaJuninaId = events.first.id;

    final summary = await db.eventFinanceSummary(festaJuninaId);
    expect(summary.saleCount, 6);
    expect(summary.totalCents, equals(21000)); // 2600 + 4300 + 3600 + 4000 + 1500 + 5000 = 21000
    final byMethodMap = {for (final m in summary.byMethod) m.method: m.totalCents};
    expect(byMethodMap[PaymentMethod.dinheiro], equals(4100)); // 2600 + 1500
    expect(byMethodMap[PaymentMethod.pix], equals(9300)); // 4300 + 5000
    expect(byMethodMap[PaymentMethod.cartaoCredito], equals(3600));
    expect(byMethodMap[PaymentMethod.cartaoDebito], equals(4000));
  });

  test('Almoço Comunitário semeado possui cardápio pronto mas 0 vendas', () async {
    await seeder.seedAlmocoComunitario();

    final events = await db.select(db.events).get();
    expect(events.length, 1);
    final almocoId = events.first.id;

    final products = await (db.select(db.products)..where((p) => p.eventId.equals(almocoId))).get();
    expect(products.length, greaterThan(4));

    final denoms = await (db.select(db.eventDotDenominations)..where((d) => d.eventId.equals(almocoId))).get();
    expect(denoms.length, 2);

    final sales = await (db.select(db.sales)..where((s) => s.eventId.equals(almocoId))).get();
    expect(sales, isEmpty);
  });
}
