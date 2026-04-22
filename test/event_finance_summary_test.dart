import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/domain/payment_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EventFinanceSummary.fromSales com lista vazia', () {
    final s = EventFinanceSummary.fromSales([]);
    expect(s.saleCount, 0);
    expect(s.totalCents, 0);
    expect(s.cashChangeGivenCents, 0);
    expect(s.byMethod, isEmpty);
  });

  test('EventFinanceSummary.fromSales agrega métodos e troco em dinheiro', () {
    final sales = [
      const PosSale(
        id: 1,
        eventId: 1,
        soldAtMs: 1,
        totalCents: 1000,
        amountReceivedCents: 1500,
        paymentMethod: PaymentMethod.dinheiro,
      ),
      const PosSale(
        id: 2,
        eventId: 1,
        soldAtMs: 2,
        totalCents: 200,
        amountReceivedCents: 200,
        paymentMethod: PaymentMethod.pix,
      ),
    ];
    final s = EventFinanceSummary.fromSales(sales);
    expect(s.saleCount, 2);
    expect(s.totalCents, 1200);
    expect(s.cashChangeGivenCents, 500);
    expect(s.byMethod.length, 2);
    final dinheiro = s.byMethod.firstWhere((b) => b.method == PaymentMethod.dinheiro);
    expect(dinheiro.saleCount, 1);
    expect(dinheiro.totalCents, 1000);
    final pix = s.byMethod.firstWhere((b) => b.method == PaymentMethod.pix);
    expect(pix.totalCents, 200);
  });
}
