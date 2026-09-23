import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('CashSession: Abertura e fechamento de sessão de caixa', () async {
    final eventId = db.generateUuid();
    await db.into(db.events).insert(
      EventsCompanion.insert(
        id: eventId,
        title: 'Festa da Padroeira',
        dateEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // 1. Não há sessão ativa inicialmente
    var active = await db.getActiveSession(eventId);
    expect(active, isNull);

    // 2. Abrir sessão com fundo de troco de R$ 150,00 (15000 centavos)
    final sessionId = await db.openCashSession(
      eventId: eventId,
      title: 'Domingo 23/09',
      initialCashFloatCents: 15000,
      openedBy: 'Maria',
    );
    expect(sessionId, isNotEmpty);

    active = await db.getActiveSession(eventId);
    expect(active, isNotNull);
    expect(active!.id, equals(sessionId));
    expect(active.initialCashFloatCents, equals(15000));
    expect(active.closedAtMs, isNull);

    // 3. Cadastrar produto e fazer uma venda associada
    final prodId = db.generateUuid();
    await db.into(db.products).insert(
      ProductsCompanion.insert(
        id: prodId,
        eventId: eventId,
        name: 'Pastel de Carne',
        priceCents: 800,
      ),
    );

    final saleId = await db.completeSale(
      eventId: eventId,
      sessionId: sessionId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1000,
      lines: [
        SaleLineDraft.product(
          productId: prodId,
          qty: 1,
          unitPriceCents: 800,
        ),
      ],
    );

    final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId))).getSingle();
    expect(sale.sessionId, equals(sessionId));
    expect(sale.totalCents, equals(800));

    // 4. Fechar sessão com conferência de gaveta
    await db.closeCashSession(
      sessionId: sessionId,
      closedCashDrawerCents: 15800, // 15000 float + 800 sale
      closedNotes: 'Tudo conferido e correto',
      closedBy: 'Maria',
    );

    active = await db.getActiveSession(eventId);
    expect(active, isNull); // Agora está fechada

    final sessions = await db.getSessions(eventId);
    expect(sessions.length, equals(1));
    expect(sessions.first.closedAtMs, isNotNull);
    expect(sessions.first.closedCashDrawerCents, equals(15800));
  });

  test('CashSession: ensureActiveSession cria sessão automaticamente ao vender', () async {
    final eventId = db.generateUuid();
    await db.into(db.events).insert(
      EventsCompanion.insert(
        id: eventId,
        title: 'Cantina do Domingo',
        dateEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    final prodId = db.generateUuid();
    await db.into(db.products).insert(
      ProductsCompanion.insert(
        id: prodId,
        eventId: eventId,
        name: 'Refrigerante',
        priceCents: 500,
      ),
    );

    // Venda sem abrir sessão previamente
    final saleId = await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 500,
      lines: [
        SaleLineDraft.product(
          productId: prodId,
          qty: 1,
          unitPriceCents: 500,
        ),
      ],
    );

    final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId))).getSingle();
    expect(sale.sessionId, isNotNull);

    final session = await (db.select(db.cashSessions)..where((s) => s.id.equals(sale.sessionId!))).getSingle();
    expect(session.initialCashFloatCents, equals(0));
    expect(session.closedAtMs, isNull);
  });
}
