import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;

import '../../domain/payment_method.dart';
import '../../providers/consolidated_report_provider.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';

/// Aba "Relatórios": consolidado entre eventos por período, fiados,
/// ranking de eventos e produtos, e exportações CSV.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late ReportPeriod _period = ReportPeriod.thisMonth(DateTime.now());
  bool _exporting = false;

  String get _periodLabel {
    final r = _period.range;
    return switch (_period.kind) {
      ReportPeriodKind.thisMonth =>
        DateFormat('MMMM yyyy', 'pt_BR').format(r!.start),
      ReportPeriodKind.thisYear => DateFormat('yyyy').format(r!.start),
      ReportPeriodKind.all => 'Todo o histórico',
      ReportPeriodKind.custom =>
        '${DateFormat('dd/MM/yy').format(r!.start)} – '
            '${DateFormat('dd/MM/yy').format(r.end.subtract(const Duration(days: 1)))}',
    };
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() => _period = ReportPeriod.custom(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(consolidatedReportProvider(_period));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(consolidatedReportProvider(_period)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seletor de período
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('Mês'),
                  selected: _period.kind == ReportPeriodKind.thisMonth,
                  onSelected: (_) => setState(
                      () => _period = ReportPeriod.thisMonth(DateTime.now())),
                ),
                ChoiceChip(
                  label: const Text('Ano'),
                  selected: _period.kind == ReportPeriodKind.thisYear,
                  onSelected: (_) => setState(
                      () => _period = ReportPeriod.thisYear(DateTime.now())),
                ),
                ChoiceChip(
                  label: const Text('Tudo'),
                  selected: _period.kind == ReportPeriodKind.all,
                  onSelected: (_) =>
                      setState(() => _period = ReportPeriod.all),
                ),
                ChoiceChip(
                  label: Text(_period.kind == ReportPeriodKind.custom
                      ? _periodLabel
                      : 'Período…'),
                  selected: _period.kind == ReportPeriodKind.custom,
                  onSelected: (_) => _pickCustomRange(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _periodLabel,
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            report.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao montar o relatório: $e',
                    style: TextStyle(color: theme.colorScheme.error)),
              ),
              data: (data) => _ReportBody(
                data: data,
                exporting: _exporting,
                onExportCsv: () => _exportConsolidatedCsv(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CSV consolidado: uma linha por item vendido, com a coluna do evento.
  Future<void> _exportConsolidatedCsv(ConsolidatedReportData data) async {
    setState(() => _exporting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final events = await db.select(db.events).get();
      final eventById = {for (final e in events) e.id: e};
      final liveEventIds = {
        for (final e in events)
          if (e.deletedAtMs == null) e.id,
      };
      final allSales = await db.select(db.sales).get();
      final sales = allSales
          .where((s) =>
              s.deletedAtMs == null &&
              liveEventIds.contains(s.eventId) &&
              _period.containsMs(s.soldAtMs))
          .toList()
        ..sort((a, b) => a.soldAtMs.compareTo(b.soldAtMs));

      final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
      final csvData = <List<String>>[
        [
          'evento',
          'data',
          'item',
          'qtd',
          'valor_unitario',
          'total_linha',
          'total_venda',
          'forma_pagamento',
          'cliente',
          'desconto',
          'motivo_desconto',
        ],
      ];
      for (final s in sales) {
        final lines = await db.saleLinesForSale(s.id);
        for (final l in lines) {
          csvData.add([
            eventById[s.eventId]?.title ?? s.eventId,
            dateFmt.format(DateTime.fromMillisecondsSinceEpoch(s.soldAtMs)),
            l.itemLabel,
            '${l.qty}',
            formatCents(l.unitPriceCents),
            formatCents(l.lineTotalCents),
            formatCents(s.totalCents),
            PaymentMethod.label(s.paymentMethod),
            s.customerName ?? '',
            s.discountCents > 0 ? formatCents(s.discountCents) : '',
            s.discountReason ?? '',
          ]);
        }
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      final dir = await getTemporaryDirectory();
      final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final file = File('${dir.path}/relatorio_consolidado_$stamp.csv');
      await file.writeAsBytes(utf8.encode('﻿$csvString'), flush: true);
      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Relatório consolidado — $_periodLabel',
            text: '${sales.length} vendas de ${data.events.length} evento(s).',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao exportar: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.data,
    required this.exporting,
    required this.onExportCsv,
  });

  final ConsolidatedReportData data;
  final bool exporting;
  final VoidCallback onExportCsv;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cartões-resumo
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Faturamento',
                value: formatCents(data.totalCents),
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Vendas',
                value: '${data.saleCount}',
                icon: Icons.receipt_long_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Ticket médio',
                value: formatCents(data.ticketMedioCents),
                icon: Icons.sell_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Custos',
                value: formatCents(data.expensesCents),
                icon: Icons.shopping_cart_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Lucro',
                value: formatCents(data.profitCents),
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Descontos',
                value: data.courtesyCount > 0
                    ? '${formatCents(data.discountCents)} · ${data.courtesyCount}🎁'
                    : formatCents(data.discountCents),
                icon: Icons.percent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Fiado
        Card(
          child: ListTile(
            leading: Icon(Icons.handshake_outlined,
                color: data.fiadoOpenTodayCents > 0
                    ? theme.colorScheme.error
                    : Colors.green),
            title: Text(
                'Fiado em aberto: ${formatCents(data.fiadoOpenTodayCents)}'),
            subtitle: Text(
                'Recebido no período: ${formatCents(data.fiadoReceivedInPeriodCents)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/fiados'),
          ),
        ),
        const SizedBox(height: 16),

        if (data.saleCount == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nenhuma venda no período selecionado.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else ...[
          // Por método de pagamento
          _SectionTitle('Por forma de pagamento'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  for (final entry in (data.byMethodCents.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value))))
                    _BarRow(
                      label:
                          '${PaymentMethod.label(entry.key)} (${data.byMethodCount[entry.key]})',
                      valueLabel: formatCents(entry.value),
                      fraction: data.totalCents == 0
                          ? 0
                          : entry.value / data.totalCents,
                      color: entry.key == PaymentMethod.fiado
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Eventos
          _SectionTitle('Eventos do período'),
          Card(
            child: Column(
              children: [
                for (final e in data.events)
                  ListTile(
                    dense: true,
                    title: Text(e.event.title),
                    subtitle: Text(
                      '${DateFormat('dd/MM/yy').format(DateTime.fromMillisecondsSinceEpoch(e.event.dateEpochMs))} · ${e.saleCount} vendas',
                    ),
                    trailing: Text(
                      formatCents(e.totalCents),
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    onTap: () =>
                        context.push('/event/${e.event.id}/dashboard'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Produtos
          _SectionTitle('Produtos mais vendidos (todos os eventos)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in data.topProducts.take(10))
                    _BarRow(
                      label:
                          '${p.name}${p.eventCount > 1 ? ' · ${p.eventCount} eventos' : ''}',
                      valueLabel:
                          '${p.qtySold}× · ${formatCents(p.totalCents)}',
                      fraction: data.topProducts.isEmpty
                          ? 0
                          : p.qtySold / data.topProducts.first.qtySold,
                      color: theme.colorScheme.tertiary,
                    ),
                  if (data.fichasQty > 0 || data.avulsosCents > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        [
                          if (data.fichasQty > 0)
                            'Fichas: ${data.fichasQty}× (${formatCents(data.fichasCents)})',
                          if (data.avulsosCents > 0)
                            'Avulsos: ${formatCents(data.avulsosCents)}',
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Exportações
        _SectionTitle('Exportar'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: exporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.table_view_outlined),
                title: const Text('CSV consolidado do período'),
                subtitle:
                    const Text('Uma linha por item, com a coluna do evento'),
                onTap: exporting || data.saleCount == 0 ? null : onExportCsv,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.ios_share_outlined),
                title: const Text('CSV de um evento'),
                subtitle: const Text('Exportação individual, como antes'),
                onTap: () => context.push('/reports/export-csv'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha com barra de proporção (sem lib de gráfico — padrão do app).
class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.valueLabel,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              Text(valueLabel, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.02, 1),
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
