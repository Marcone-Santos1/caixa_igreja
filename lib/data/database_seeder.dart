import 'package:drift/drift.dart';

import '../domain/payment_method.dart';
import '../domain/sale_line_kind.dart';
import '../utils/date_time_utils.dart';
import 'database.dart';

/// Estatísticas do processo de seed.
class SeederResult {
  const SeederResult({
    required this.eventsCount,
    required this.productsCount,
    required this.dotDenominationsCount,
    required this.salesCount,
    required this.totalRevenueCents,
  });

  final int eventsCount;
  final int productsCount;
  final int dotDenominationsCount;
  final int salesCount;
  final int totalRevenueCents;

  @override
  String toString() {
    return 'SeederResult(events: $eventsCount, products: $productsCount, denoms: $dotDenominationsCount, sales: $salesCount, revenue: R\$ ${(totalRevenueCents / 100).toStringAsFixed(2)})';
  }
}

/// Utilitário para popular o banco de dados com dados realistas de teste e demonstração.
class DatabaseSeeder {
  DatabaseSeeder(this.db);

  final AppDatabase db;

  /// Limpa todas as tabelas em ordem de dependência (sem quebrar integridade referencial).
  Future<void> clearAll() async {
    await db.transaction(() async {
      await db.delete(db.stockMovements).go();
      await db.delete(db.saleChangeDotAllocations).go();
      await db.delete(db.saleLines).go();
      await db.delete(db.sales).go();
      await db.delete(db.cashSessions).go();
      await db.delete(db.productComboItems).go();
      await db.delete(db.products).go();
      await db.delete(db.eventDotDenominations).go();
      await db.delete(db.events).go();
    });
  }

  /// Popula todos os cenários pré-definidos (Festa Junina, Bazar Beneficente e Almoço Comunitário).
  Future<SeederResult> seedAll({bool clearExisting = false}) async {
    if (clearExisting) {
      await clearAll();
    }

    final now = DateTime.now();

    final r1 = await seedFestaJunina(
      baseDate: now,
    );
    final r2 = await seedBazarBeneficente(
      baseDate: now.subtract(const Duration(days: 3)),
    );
    final r3 = await seedAlmocoComunitario(
      baseDate: now.add(const Duration(days: 4)),
    );

    // Os cenários inserem contadores de estoque diretamente; recria o baseline
    // de movimentações para manter soma(movimentações) == stockQty.
    await db.rebaselineStockMovements();

    return SeederResult(
      eventsCount: r1.eventsCount + r2.eventsCount + r3.eventsCount,
      productsCount: r1.productsCount + r2.productsCount + r3.productsCount,
      dotDenominationsCount:
          r1.dotDenominationsCount + r2.dotDenominationsCount + r3.dotDenominationsCount,
      salesCount: r1.salesCount + r2.salesCount + r3.salesCount,
      totalRevenueCents:
          r1.totalRevenueCents + r2.totalRevenueCents + r3.totalRevenueCents,
    );
  }

  /// 1. Festa Junina Paroquial: evento ativo com produtos, estoque baixo, fichas,
  /// combos e histórico variado de vendas (dinheiro com troco em fichas, PIX, cartões, troco pendente).
  Future<SeederResult> seedFestaJunina({DateTime? baseDate}) async {
    final refDate = baseDate ?? DateTime.now();
    final dayMs = startOfLocalDayMs(refDate);

    return db.transaction(() async {
      final eventId = db.generateUuid();

      await db.into(db.events).insert(
            EventsCompanion.insert(
              id: eventId,
              title: 'Festa Junina Paroquial 2026',
              notes: const Value(
                'Barracas de comidas típicas, bebidas, brincadeiras e fichas.',
              ),
              dateEpochMs: dayMs,
            ),
          );

      // Fichas (Denominações)
      final ficha2Id = db.generateUuid();
      final ficha5Id = db.generateUuid();
      final ficha10Id = db.generateUuid();

      await db.into(db.eventDotDenominations).insert(
            EventDotDenominationsCompanion.insert(
              id: ficha2Id,
              eventId: eventId,
              label: 'Ficha R\$ 2,00',
              valueCents: 200,
              stockQty: const Value(280),
            ),
          );
      await db.into(db.eventDotDenominations).insert(
            EventDotDenominationsCompanion.insert(
              id: ficha5Id,
              eventId: eventId,
              label: 'Ficha R\$ 5,00',
              valueCents: 500,
              stockQty: const Value(240),
            ),
          );
      await db.into(db.eventDotDenominations).insert(
            EventDotDenominationsCompanion.insert(
              id: ficha10Id,
              eventId: eventId,
              label: 'Ficha R\$ 10,00',
              valueCents: 1000,
              stockQty: const Value(140),
            ),
          );

      // Produtos
      final pCarneId = db.generateUuid();
      final pQueijoId = db.generateUuid();
      final pEspetoId = db.generateUuid();
      final pCachorroId = db.generateUuid();
      final pRefriId = db.generateUuid();
      final pAguaId = db.generateUuid();
      final pQuentaoId = db.generateUuid();
      final pBoloMilhoId = db.generateUuid();
      final pCanjicaId = db.generateUuid();

      final productsData = [
        (pCarneId, 'Pastel de Carne', 'Carne moída temperada', 1000, true, 48),
        (pQueijoId, 'Pastel de Queijo', 'Queijo mussarela derretido', 1000, true, 38),
        (pEspetoId, 'Espetinho de Carne', 'Acompanha farofa e vinagrete', 1200, true, 32),
        (pCachorroId, 'Cachorro-Quente', 'Molho caseiro com batata palha', 800, true, 55),
        // Refrigerante com estoque baixo (5 un) para testar alerta de estoque baixo
        (pRefriId, 'Refrigerante Lata', 'Coca-Cola, Guaraná, Fanta 350ml', 600, true, 5),
        (pAguaId, 'Água Mineral 500ml', 'Com ou sem gás', 400, true, 78),
        (pQuentaoId, 'Quentão Copo', 'Bebida quente típica sem álcool', 500, false, 0),
        // Bolo de milho com estoque baixo (2 un)
        (pBoloMilhoId, 'Bolo de Milho (Fatia)', 'Receita caseira da paróquia', 500, true, 2),
        (pCanjicaId, 'Canjica Cremosa', 'Pote com canela em pó', 600, false, 0),
      ];

      for (final p in productsData) {
        await db.into(db.products).insert(
              ProductsCompanion.insert(
                id: p.$1,
                eventId: eventId,
                name: p.$2,
                description: Value(p.$3),
                priceCents: p.$4,
                trackStock: Value(p.$5),
                stockQty: Value(p.$6),
                active: const Value(true),
                isCombo: const Value(false),
              ),
            );
      }

      // Combos
      final comboJuninoId = db.generateUuid();
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: comboJuninoId,
              eventId: eventId,
              name: 'Combo Junino',
              description: const Value('1 Pastel de Carne + 1 Refrigerante Lata'),
              priceCents: 1500,
              trackStock: const Value(false),
              isCombo: const Value(true),
              active: const Value(true),
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboJuninoId,
              childProductId: pCarneId,
              qty: 1,
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboJuninoId,
              childProductId: pRefriId,
              qty: 1,
            ),
          );

      final comboFamiliaId = db.generateUuid();
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: comboFamiliaId,
              eventId: eventId,
              name: 'Combo Família',
              description: const Value('2 Pastéis de Carne + 1 de Queijo + 2 Refrigerantes'),
              priceCents: 3800,
              trackStock: const Value(false),
              isCombo: const Value(true),
              active: const Value(true),
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboFamiliaId,
              childProductId: pCarneId,
              qty: 2,
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboFamiliaId,
              childProductId: pQueijoId,
              qty: 1,
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboFamiliaId,
              childProductId: pRefriId,
              qty: 2,
            ),
          );

      // Vendas
      var totalRevenue = 0;
      var salesCount = 0;

      // Venda 1: Dinheiro com troco pago em fichas (R$ 26,00 total; R$ 30,00 recebido; R$ 4,00 troco = 2 fichas de R$ 2)
      final sale1Id = db.generateUuid();
      final sale1Time = refDate.subtract(const Duration(hours: 3)).millisecondsSinceEpoch;
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: sale1Id,
              eventId: eventId,
              soldAtMs: sale1Time,
              totalCents: 2600,
              amountReceivedCents: 3000,
              paymentMethod: const Value(PaymentMethod.dinheiro),
              customerName: const Value('D. Maria de Lourdes'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale1Id,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pCarneId),
              qty: 2,
              unitPriceCents: 1000,
              lineTotalCents: 2000,
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale1Id,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pRefriId),
              qty: 1,
              unitPriceCents: 600,
              lineTotalCents: 600,
            ),
          );
      // Alocação de fichas como troco (2 fichas de R$ 2,00 = R$ 4,00)
      await db.into(db.saleChangeDotAllocations).insert(
            SaleChangeDotAllocationsCompanion.insert(
              id: db.generateUuid(),
              saleId: sale1Id,
              dotDenominationId: ficha2Id,
              qty: 2,
            ),
          );
      totalRevenue += 2600;
      salesCount++;

      // Venda 2: PIX com Combo Família + Quentão (R$ 43,00)
      final sale2Id = db.generateUuid();
      final sale2Time = refDate.subtract(const Duration(hours: 2, minutes: 15)).millisecondsSinceEpoch;
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: sale2Id,
              eventId: eventId,
              soldAtMs: sale2Time,
              totalCents: 4300,
              amountReceivedCents: 4300,
              paymentMethod: const Value(PaymentMethod.pix),
              customerName: const Value('Carlos Eduardo'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale2Id,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(comboFamiliaId),
              qty: 1,
              unitPriceCents: 3800,
              lineTotalCents: 3800,
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale2Id,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pQuentaoId),
              qty: 1,
              unitPriceCents: 500,
              lineTotalCents: 500,
            ),
          );
      totalRevenue += 4300;
      salesCount++;

      // Venda 3: Cartão de Crédito com Espetinho e Refrigerante (R$ 36,00)
      final sale3Id = db.generateUuid();
      final sale3Time = refDate.subtract(const Duration(hours: 1, minutes: 30)).millisecondsSinceEpoch;
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: sale3Id,
              eventId: eventId,
              soldAtMs: sale3Time,
              totalCents: 3600,
              amountReceivedCents: 3600,
              paymentMethod: const Value(PaymentMethod.cartaoCredito),
              customerName: const Value('Ana Paula Ferreira'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale3Id,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pEspetoId),
              qty: 2,
              unitPriceCents: 1200,
              lineTotalCents: 2400,
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale3Id,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pRefriId),
              qty: 2,
              unitPriceCents: 600,
              lineTotalCents: 1200,
            ),
          );
      totalRevenue += 3600;
      salesCount++;

      // Venda 4: Compra direta de Fichas (Cartão de Débito - R$ 40,00)
      final sale4Id = db.generateUuid();
      final sale4Time = refDate.subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: sale4Id,
              eventId: eventId,
              soldAtMs: sale4Time,
              totalCents: 4000,
              amountReceivedCents: 4000,
              paymentMethod: const Value(PaymentMethod.cartaoDebito),
              customerName: const Value('Roberto Santos'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale4Id,
              lineKind: const Value(SaleLineKind.ficha),
              dotDenominationId: Value(ficha5Id),
              qty: 4,
              unitPriceCents: 500,
              lineTotalCents: 2000,
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale4Id,
              lineKind: const Value(SaleLineKind.ficha),
              dotDenominationId: Value(ficha10Id),
              qty: 2,
              unitPriceCents: 1000,
              lineTotalCents: 2000,
            ),
          );
      totalRevenue += 4000;
      salesCount++;

      // Venda 5: Dinheiro com troco pendente (R$ 15,00 recebido R$ 20,00; troco pendente R$ 5,00)
      final sale5Id = db.generateUuid();
      final sale5Time = refDate.subtract(const Duration(minutes: 35)).millisecondsSinceEpoch;
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: sale5Id,
              eventId: eventId,
              soldAtMs: sale5Time,
              totalCents: 1500,
              amountReceivedCents: 2000,
              paymentMethod: const Value(PaymentMethod.dinheiro),
              changePending: const Value(true),
              customerName: const Value('Seu Geraldo'),
              notes: const Value('Aguardando cédulas de R\$ 5 para entregar o troco'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale5Id,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(comboJuninoId),
              qty: 1,
              unitPriceCents: 1500,
              lineTotalCents: 1500,
            ),
          );
      totalRevenue += 1500;
      salesCount++;

      // Venda 6: Valor Livre / Doação avulsa (R$ 50,00 via PIX)
      final sale6Id = db.generateUuid();
      final sale6Time = refDate.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch;
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: sale6Id,
              eventId: eventId,
              soldAtMs: sale6Time,
              totalCents: 5000,
              amountReceivedCents: 5000,
              paymentMethod: const Value(PaymentMethod.pix),
              notes: const Value('Doação espontânea de visitante para a festa'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: sale6Id,
              lineKind: const Value(SaleLineKind.valorLivre),
              freeLabel: const Value('Doação espontânea para a paróquia'),
              qty: 1,
              unitPriceCents: 5000,
              lineTotalCents: 5000,
            ),
          );
      totalRevenue += 5000;
      salesCount++;

      return SeederResult(
        eventsCount: 1,
        productsCount: productsData.length + 2, // 9 simples + 2 combos
        dotDenominationsCount: 3,
        salesCount: salesCount,
        totalRevenueCents: totalRevenue,
      );
    });
  }

  /// 2. Bazar da Solidariedade: evento já ocorrido há alguns dias com produtos e vendas
  /// registradas (ideal para testar relatórios de fechamento e exportação de CSV).
  Future<SeederResult> seedBazarBeneficente({DateTime? baseDate}) async {
    final refDate = baseDate ?? DateTime.now().subtract(const Duration(days: 3));
    final dayMs = startOfLocalDayMs(refDate);

    return db.transaction(() async {
      final eventId = db.generateUuid();

      await db.into(db.events).insert(
            EventsCompanion.insert(
              id: eventId,
              title: 'Bazar da Solidariedade',
              notes: const Value(
                'Venda de roupas, calçados, artesanato e artigos doados.',
              ),
              dateEpochMs: dayMs,
            ),
          );

      final pRoupaAdulto = db.generateUuid();
      final pRoupaInfantil = db.generateUuid();
      final pCalcado = db.generateUuid();
      final pArtesanato = db.generateUuid();
      final pLivro = db.generateUuid();

      final productsData = [
        (pRoupaAdulto, 'Peça de Roupa Adulto', 'Camisas, calças e vestidos', 1500, true, 65),
        (pRoupaInfantil, 'Peça de Roupa Infantil', 'Roupas infantis selecionadas', 1000, true, 40),
        (pCalcado, 'Calçado Usado Selecionado', 'Pares em bom estado', 2000, true, 18),
        (pArtesanato, 'Toalha de Mesa Bordada', 'Feita pela pastoral da costura', 3500, true, 10),
        (pLivro, 'Livro Usado Diversos', 'Literatura e religiosos', 500, false, 0),
      ];

      for (final p in productsData) {
        await db.into(db.products).insert(
              ProductsCompanion.insert(
                id: p.$1,
                eventId: eventId,
                name: p.$2,
                description: Value(p.$3),
                priceCents: p.$4,
                trackStock: Value(p.$5),
                stockQty: Value(p.$6),
                active: const Value(true),
                isCombo: const Value(false),
              ),
            );
      }

      var totalRevenue = 0;
      var salesCount = 0;

      // Venda B1
      final s1 = db.generateUuid();
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: s1,
              eventId: eventId,
              soldAtMs: refDate.add(const Duration(hours: 9, minutes: 30)).millisecondsSinceEpoch,
              totalCents: 4500,
              amountReceivedCents: 5000,
              paymentMethod: const Value(PaymentMethod.dinheiro),
              customerName: const Value('Marcos Vinicius'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: s1,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pRoupaAdulto),
              qty: 3,
              unitPriceCents: 1500,
              lineTotalCents: 4500,
            ),
          );
      totalRevenue += 4500;
      salesCount++;

      // Venda B2
      final s2 = db.generateUuid();
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: s2,
              eventId: eventId,
              soldAtMs: refDate.add(const Duration(hours: 11, minutes: 10)).millisecondsSinceEpoch,
              totalCents: 5500,
              amountReceivedCents: 5500,
              paymentMethod: const Value(PaymentMethod.pix),
              customerName: const Value('Juliana Ramos'),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: s2,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pArtesanato),
              qty: 1,
              unitPriceCents: 3500,
              lineTotalCents: 3500,
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: s2,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pCalcado),
              qty: 1,
              unitPriceCents: 2000,
              lineTotalCents: 2000,
            ),
          );
      totalRevenue += 5500;
      salesCount++;

      // Venda B3
      final s3 = db.generateUuid();
      await db.into(db.sales).insert(
            SalesCompanion.insert(
              id: s3,
              eventId: eventId,
              soldAtMs: refDate.add(const Duration(hours: 14, minutes: 40)).millisecondsSinceEpoch,
              totalCents: 3000,
              amountReceivedCents: 3000,
              paymentMethod: const Value(PaymentMethod.cartaoDebito),
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: s3,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pRoupaInfantil),
              qty: 2,
              unitPriceCents: 1000,
              lineTotalCents: 2000,
            ),
          );
      await db.into(db.saleLines).insert(
            SaleLinesCompanion.insert(
              id: db.generateUuid(),
              saleId: s3,
              lineKind: const Value(SaleLineKind.product),
              productId: Value(pLivro),
              qty: 2,
              unitPriceCents: 500,
              lineTotalCents: 1000,
            ),
          );
      totalRevenue += 3000;
      salesCount++;

      return SeederResult(
        eventsCount: 1,
        productsCount: productsData.length,
        dotDenominationsCount: 0,
        salesCount: salesCount,
        totalRevenueCents: totalRevenue,
      );
    });
  }

  /// 3. Almoço Comunitário: evento futuro já planejado com produtos e fichas,
  /// mas com 0 vendas, pronto para abrir caixa e testar o PDV sem dados prévios.
  Future<SeederResult> seedAlmocoComunitario({DateTime? baseDate}) async {
    final refDate = baseDate ?? DateTime.now().add(const Duration(days: 4));
    final dayMs = startOfLocalDayMs(refDate);

    return db.transaction(() async {
      final eventId = db.generateUuid();

      await db.into(db.events).insert(
            EventsCompanion.insert(
              id: eventId,
              title: 'Almoço Comunitário de São Pedro',
              notes: const Value(
                'Churrasco comunitário de confraternização. Vendas ainda não iniciadas.',
              ),
              dateEpochMs: dayMs,
            ),
          );

      // Fichas
      await db.into(db.eventDotDenominations).insert(
            EventDotDenominationsCompanion.insert(
              id: db.generateUuid(),
              eventId: eventId,
              label: 'Ficha Bebida R\$ 5,00',
              valueCents: 500,
              stockQty: const Value(300),
            ),
          );
      await db.into(db.eventDotDenominations).insert(
            EventDotDenominationsCompanion.insert(
              id: db.generateUuid(),
              eventId: eventId,
              label: 'Ficha Sobremesa R\$ 7,00',
              valueCents: 700,
              stockQty: const Value(150),
            ),
          );

      // Produtos
      final pAlmoco = db.generateUuid();
      final pEspeto = db.generateUuid();
      final pSalada = db.generateUuid();
      final pRefri2L = db.generateUuid();
      final pPudim = db.generateUuid();

      final productsData = [
        (pAlmoco, 'Convite Almoço Completo', 'Carne assada, arroz, feijão tropeiro e salada', 3500, true, 120),
        (pEspeto, 'Espeto de Alcatra Individual', 'Acompanha mandioca e vinagrete', 2500, true, 70),
        (pSalada, 'Porção Maionese / Salada de Batata', 'Porção individual adicional', 1000, false, 0),
        (pRefri2L, 'Refrigerante 2L', 'Coca-Cola ou Guaraná Antarctica', 1200, true, 45),
        (pPudim, 'Pudim de Leite Condensado (Fatia)', 'Sobremesa caseira', 700, true, 40),
      ];

      for (final p in productsData) {
        await db.into(db.products).insert(
              ProductsCompanion.insert(
                id: p.$1,
                eventId: eventId,
                name: p.$2,
                description: Value(p.$3),
                priceCents: p.$4,
                trackStock: Value(p.$5),
                stockQty: Value(p.$6),
                active: const Value(true),
                isCombo: const Value(false),
              ),
            );
      }

      // Combo Almoço + Bebida + Pudim
      final comboId = db.generateUuid();
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              id: comboId,
              eventId: eventId,
              name: 'Combo Almoço Completo Especial',
              description: const Value('1 Convite Almoço + 1 Refrigerante 2L + 1 Pudim'),
              priceCents: 4800,
              trackStock: const Value(false),
              isCombo: const Value(true),
              active: const Value(true),
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboId,
              childProductId: pAlmoco,
              qty: 1,
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboId,
              childProductId: pRefri2L,
              qty: 1,
            ),
          );
      await db.into(db.productComboItems).insert(
            ProductComboItemsCompanion.insert(
              comboProductId: comboId,
              childProductId: pPudim,
              qty: 1,
            ),
          );

      // 0 vendas propositalmente
      return SeederResult(
        eventsCount: 1,
        productsCount: productsData.length + 1,
        dotDenominationsCount: 2,
        salesCount: 0,
        totalRevenueCents: 0,
      );
    });
  }
}
