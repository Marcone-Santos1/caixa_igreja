import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/payment_method.dart';
import '../domain/sale_line_kind.dart';
import 'database_provider.dart';

/// Período do relatório consolidado.
enum ReportPeriodKind { thisMonth, thisYear, all, custom }

@immutable
class ReportPeriod {
  const ReportPeriod(this.kind, {this.range});

  final ReportPeriodKind kind;
  final DateTimeRange? range;

  static const all = ReportPeriod(ReportPeriodKind.all);

  factory ReportPeriod.thisMonth(DateTime now) => ReportPeriod(
        ReportPeriodKind.thisMonth,
        range: DateTimeRange(
          start: DateTime(now.year, now.month),
          end: DateTime(now.year, now.month + 1),
        ),
      );

  factory ReportPeriod.thisYear(DateTime now) => ReportPeriod(
        ReportPeriodKind.thisYear,
        range: DateTimeRange(
          start: DateTime(now.year),
          end: DateTime(now.year + 1),
        ),
      );

  factory ReportPeriod.custom(DateTimeRange range) => ReportPeriod(
        ReportPeriodKind.custom,
        // Inclui o dia final inteiro.
        range: DateTimeRange(
          start: DateTime(range.start.year, range.start.month, range.start.day),
          end: DateTime(range.end.year, range.end.month, range.end.day + 1),
        ),
      );

  bool containsMs(int epochMs) {
    final r = range;
    if (r == null) return true;
    return epochMs >= r.start.millisecondsSinceEpoch &&
        epochMs < r.end.millisecondsSinceEpoch;
  }

  @override
  bool operator ==(Object other) =>
      other is ReportPeriod && other.kind == kind && other.range == range;

  @override
  int get hashCode => Object.hash(kind, range);
}

/// Total de um evento dentro do período.
class EventReportStat {
  const EventReportStat({
    required this.event,
    required this.saleCount,
    required this.totalCents,
  });

  final ChurchEvent event;
  final int saleCount;
  final int totalCents;
}

/// Produto consolidado por NOME entre eventos (o "Pastel" da festa e o do
/// almoço somam juntos; nome normalizado por trim + minúsculas).
class ConsolidatedProductStat {
  const ConsolidatedProductStat({
    required this.name,
    required this.qtySold,
    required this.totalCents,
    required this.eventCount,
  });

  final String name;
  final int qtySold;
  final int totalCents;
  final int eventCount;
}

/// Relatório consolidado entre eventos. Puro e síncrono (testável): as
/// listas chegam já carregadas; o filtro de período é aplicado aqui.
class ConsolidatedReportData {
  const ConsolidatedReportData({
    required this.period,
    required this.saleCount,
    required this.totalCents,
    required this.byMethodCents,
    required this.byMethodCount,
    required this.events,
    required this.topProducts,
    required this.fichasQty,
    required this.fichasCents,
    required this.avulsosCents,
    required this.fiadoReceivedInPeriodCents,
    required this.fiadoOpenTodayCents,
  });

  final ReportPeriod period;
  final int saleCount;
  final int totalCents;
  final Map<String, int> byMethodCents;
  final Map<String, int> byMethodCount;

  /// Eventos com venda no período, do maior para o menor faturamento.
  final List<EventReportStat> events;

  /// Produtos consolidados por nome, do mais vendido para o menos.
  final List<ConsolidatedProductStat> topProducts;
  final int fichasQty;
  final int fichasCents;
  final int avulsosCents;

  /// Recebimentos de fiado cujo PAGAMENTO caiu no período.
  final int fiadoReceivedInPeriodCents;

  /// Saldo de fiado em aberto HOJE (independe do período).
  final int fiadoOpenTodayCents;

  int get ticketMedioCents => saleCount == 0 ? 0 : totalCents ~/ saleCount;

  static ConsolidatedReportData compute({
    required ReportPeriod period,
    required List<ChurchEvent> events,
    required List<PosSale> sales,
    required List<PosSaleLine> lines,
    required List<ChurchProduct> products,
    required List<FiadoPayment> fiadoPayments,
  }) {
    final liveEventIds = {
      for (final e in events)
        if (e.deletedAtMs == null) e.id,
    };
    final eventById = {for (final e in events) e.id: e};

    // Vendas vivas, de eventos vivos, dentro do período.
    final periodSales = sales
        .where((s) =>
            s.deletedAtMs == null &&
            liveEventIds.contains(s.eventId) &&
            period.containsMs(s.soldAtMs))
        .toList();
    final periodSaleIds = {for (final s in periodSales) s.id};

    var totalCents = 0;
    final byMethodCents = <String, int>{};
    final byMethodCount = <String, int>{};
    final perEventTotal = <String, int>{};
    final perEventCount = <String, int>{};
    for (final s in periodSales) {
      totalCents += s.totalCents;
      byMethodCents[s.paymentMethod] =
          (byMethodCents[s.paymentMethod] ?? 0) + s.totalCents;
      byMethodCount[s.paymentMethod] =
          (byMethodCount[s.paymentMethod] ?? 0) + 1;
      perEventTotal[s.eventId] = (perEventTotal[s.eventId] ?? 0) + s.totalCents;
      perEventCount[s.eventId] = (perEventCount[s.eventId] ?? 0) + 1;
    }

    final eventStats = perEventTotal.entries
        .map((e) => EventReportStat(
              event: eventById[e.key]!,
              saleCount: perEventCount[e.key] ?? 0,
              totalCents: e.value,
            ))
        .toList()
      ..sort((a, b) => b.totalCents.compareTo(a.totalCents));

    // Produtos consolidados por nome (linhas vivas de vendas do período).
    final productById = {for (final p in products) p.id: p};
    final byName = <String, _ProductAcc>{};
    var fichasQty = 0;
    var fichasCents = 0;
    var avulsosCents = 0;
    for (final l in lines) {
      if (l.deletedAtMs != null) continue;
      if (!periodSaleIds.contains(l.saleId)) continue;
      if (l.lineKind == SaleLineKind.ficha) {
        fichasQty += l.qty;
        fichasCents += l.lineTotalCents;
        continue;
      }
      if (l.lineKind == SaleLineKind.valorLivre) {
        avulsosCents += l.lineTotalCents;
        continue;
      }
      final product = l.productId == null ? null : productById[l.productId];
      final displayName = product?.name.trim() ?? 'Produto removido';
      final key = displayName.toLowerCase();
      final acc = byName.putIfAbsent(key, () => _ProductAcc(displayName));
      acc.qty += l.qty;
      acc.cents += l.lineTotalCents;
      if (product != null) acc.eventIds.add(product.eventId);
    }
    final topProducts = byName.values
        .map((a) => ConsolidatedProductStat(
              name: a.displayName,
              qtySold: a.qty,
              totalCents: a.cents,
              eventCount: a.eventIds.isEmpty ? 1 : a.eventIds.length,
            ))
        .toList()
      ..sort((a, b) => b.qtySold.compareTo(a.qtySold));

    // Fiado: recebido no período (pela data do PAGAMENTO) e aberto hoje.
    final saleById = {for (final s in sales) s.id: s};
    var fiadoReceived = 0;
    final fiadoPaidBySale = <String, int>{};
    for (final p in fiadoPayments) {
      if (p.deletedAtMs != null) continue;
      final sale = saleById[p.saleId];
      if (sale == null ||
          sale.deletedAtMs != null ||
          !liveEventIds.contains(sale.eventId)) {
        continue;
      }
      fiadoPaidBySale[p.saleId] = (fiadoPaidBySale[p.saleId] ?? 0) + p.amountCents;
      if (period.containsMs(p.paidAtMs)) fiadoReceived += p.amountCents;
    }
    var fiadoOpenToday = 0;
    for (final s in sales) {
      if (s.paymentMethod != PaymentMethod.fiado) continue;
      if (s.deletedAtMs != null || !liveEventIds.contains(s.eventId)) continue;
      final open = s.totalCents - (fiadoPaidBySale[s.id] ?? 0);
      if (open > 0) fiadoOpenToday += open;
    }

    return ConsolidatedReportData(
      period: period,
      saleCount: periodSales.length,
      totalCents: totalCents,
      byMethodCents: byMethodCents,
      byMethodCount: byMethodCount,
      events: eventStats,
      topProducts: topProducts,
      fichasQty: fichasQty,
      fichasCents: fichasCents,
      avulsosCents: avulsosCents,
      fiadoReceivedInPeriodCents: fiadoReceived,
      fiadoOpenTodayCents: fiadoOpenToday,
    );
  }
}

class _ProductAcc {
  _ProductAcc(this.displayName);
  final String displayName;
  int qty = 0;
  int cents = 0;
  final Set<String> eventIds = {};
}

/// Carrega tudo do banco e computa o relatório para o período.
final consolidatedReportProvider = FutureProvider.autoDispose
    .family<ConsolidatedReportData, ReportPeriod>((ref, period) async {
  final db = ref.watch(appDatabaseProvider);
  final events = await db.select(db.events).get();
  final sales = await db.select(db.sales).get();
  final lines = await db.select(db.saleLines).get();
  final products = await db.select(db.products).get();
  final fiadoPayments = await db.select(db.fiadoPayments).get();
  return ConsolidatedReportData.compute(
    period: period,
    events: events,
    sales: sales,
    lines: lines,
    products: products,
    fiadoPayments: fiadoPayments,
  );
});
