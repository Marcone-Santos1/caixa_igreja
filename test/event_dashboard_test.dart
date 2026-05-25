import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/domain/sale_line_kind.dart';
import 'package:caixa_igreja/providers/event_dashboard_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EventDashboardData.compute com dados vazios', () {
    final data = EventDashboardData.compute(
      sales: [],
      lines: [],
      products: [],
      denoms: [],
      changeDotAllocations: [],
    );
    expect(data.totalSalesCount, 0);
    expect(data.totalRevenueCents, 0);
  });

  test('EventDashboardData.compute com dados populados simples', () {
    final sales = [
      const PosSale(
        id: 'sale_1',
        eventId: 'event_1',
        soldAtMs: 1716500000000, //algum timestamp
        totalCents: 1000,
        amountReceivedCents: 1000,
        paymentMethod: 'pix',
        changePending: false,
      ),
    ];
    final products = [
      const ChurchProduct(
        id: 'product_1',
        eventId: 'event_1',
        name: 'Produto 1',
        description: '',
        priceCents: 1000,
        trackStock: false,
        stockQty: 0,
        active: true,
        isCombo: false,
      ),
    ];
    final lines = [
      const PosSaleLine(
        id: 'line_1',
        saleId: 'sale_1',
        lineKind: SaleLineKind.product,
        productId: 'product_1',
        qty: 1,
        unitPriceCents: 1000,
        lineTotalCents: 1000,
      ),
    ];

    final data = EventDashboardData.compute(
      sales: sales,
      lines: lines,
      products: products,
      denoms: [],
      changeDotAllocations: [],
    );

    expect(data.totalSalesCount, 1);
    expect(data.totalRevenueCents, 1000);
    expect(data.productStats.length, 1);
    expect(data.productStats.first.qtySold, 1);
  });
}
