import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show ShareParams, SharePlus, XFile;
import 'package:csv/csv.dart';

import '../../app/app_theme.dart';
import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../domain/payment_method.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  int? _eventId;
  bool _busy = false;

  String _safeFileSlug(String title) {
    var s = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s-]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    if (s.isEmpty) s = 'evento';
    if (s.length > 40) s = s.substring(0, 40);
    return s;
  }

  Future<void> _export(ChurchEvent event) async {
    setState(() => _busy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final rows = await db.exportSaleLinesForEvent(event.id);

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
      final bytes = utf8.encode('\ufeff$csvString');

      final slug = _safeFileSlug(event.title);
      final subject = 'Vendas — ${event.title}';

      if (kIsWeb) {
        if (mounted) {
          await SharePlus.instance.share(
            ShareParams(
              text: csvString,
              subject: subject,
            ),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/vendas_evento_${event.id}_$slug.csv');
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            subject: subject,
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
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exportar CSV')),
      body: StreamBuilder<List<ChurchEvent>>(
        stream: db.watchAllEvents(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Erro: ${snap.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snap.data!;
          if (events.isEmpty) {
            return const CaixaEmptyHint(
              icon: Icons.event_busy_outlined,
              message: 'Nenhum evento cadastrado',
              detail: 'Cadastre um evento para poder exportar as vendas.',
            );
          }

          final selectedId = _eventId ?? events.first.id;
          final selectedEvent =
              events.firstWhere((e) => e.id == selectedId, orElse: () => events.first);

          return ListView(
            padding: kCaixaScreenPadding.copyWith(bottom: 32),
            children: [
              Text(
                'Exporta todas as linhas de venda de um evento (itens, totais e troco).',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Evento',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        isExpanded: true,
                        value: selectedId,
                        items: [
                          for (final e in events)
                            DropdownMenuItem(
                              value: e.id,
                              child: Text(
                                '${e.title} · ${dayFmt.format(DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs))}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (v) {
                                if (v != null) {
                                  setState(() => _eventId = v);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _export(selectedEvent),
                icon: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share_rounded),
                label: Text(_busy ? 'Gerando…' : 'Gerar e compartilhar CSV'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
