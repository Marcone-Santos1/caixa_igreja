import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;
import 'package:csv/csv.dart';

import '../../domain/payment_method.dart';
import '../../providers/database_provider.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/money_format.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  bool _busy = false;

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (d != null) setState(() => _start = d);
  }

  Future<void> _pickEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (d != null) setState(() => _end = d);
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final startMs = startOfLocalDayMs(_start);
      final endMs = endOfLocalDayMs(_end);
      if (endMs < startMs) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data final antes da inicial')),
          );
        }
        return;
      }

      final db = ref.read(appDatabaseProvider);
      final rows = await db.exportSaleLinesBetween(
        startMs: startMs,
        endMs: endMs,
      );

      final dtFmt = DateFormat('yyyy-MM-dd HH:mm:ss', 'pt_BR');
      final dayFmt = DateFormat.yMMMd('pt_BR');

      final csvData = <List<String>>[
        [
          'data_hora_venda',
          'evento_titulo',
          'evento_data',
          'item',
          'quantidade',
          'preco_unitario',
          'total_linha',
          'total_venda',
          'valor_recebido',
          'troco',
          'forma_pagamento',
        ],
        ...rows.map((r) {
          final sold = DateTime.fromMillisecondsSinceEpoch(r.soldAtMs);
          final evDay =
              DateTime.fromMillisecondsSinceEpoch(r.eventDateMs);
          return [
            dtFmt.format(sold),
            r.eventTitle,
            dayFmt.format(evDay),
            r.itemDescription,
            r.qty.toString(),
            formatCents(r.unitPriceCents),
            formatCents(r.lineTotalCents),
            formatCents(r.saleTotalCents),
            formatCents(r.amountReceivedCents),
            formatCents(r.changeCents),
            PaymentMethod.label(r.paymentMethod),
          ];
        }),
      ];

      final csvString = const ListToCsvConverter().convert(csvData);
      final bytes = utf8.encode('\ufeff$csvString'); // UTF-8 BOM for Excel

      if (kIsWeb) {
        if (mounted) {
          await SharePlus.instance.share(
            ShareParams(
              text: csvString,
              subject: 'Vendas Caixa Igreja',
            ),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final safeStart = DateFormat('yyyyMMdd').format(_start);
      final safeEnd = DateFormat('yyyyMMdd').format(_end);
      final file = File('${dir.path}/vendas_${safeStart}_$safeEnd.csv');
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: 'Vendas Caixa Igreja',
            text: '${rows.length} linhas exportadas.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayFmt = DateFormat.yMMMd('pt_BR');
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar CSV')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Exporta uma linha por item vendido no período (inclui totais e troco da venda).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Data inicial'),
            subtitle: Text(dayFmt.format(_start)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _busy ? null : _pickStart,
          ),
          ListTile(
            title: const Text('Data final'),
            subtitle: Text(dayFmt.format(_end)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _busy ? null : _pickEnd,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : _export,
            icon: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            label: Text(_busy ? 'Gerando…' : 'Gerar e compartilhar CSV'),
          ),
        ],
      ),
    );
  }
}
