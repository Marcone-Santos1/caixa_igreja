import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_theme.dart';
import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../domain/payment_method.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';

final _dateTimeFmt = DateFormat.yMd('pt_BR').add_Hm();

class EventSalesRegisterScreen extends ConsumerWidget {
  const EventSalesRegisterScreen({super.key, required this.eventId});

  final int eventId;

  Future<void> _deleteSale(BuildContext context, WidgetRef ref, int saleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir venda'),
        content: const Text(
          'Tem certeza que deseja excluir esta venda?\n\n'
          'Os produtos e fichas retornarão ao estoque.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final db = ref.read(appDatabaseProvider);
        await db.deleteSale(saleId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Venda excluída')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  Future<void> _resolvePendingChange(BuildContext context, WidgetRef ref, PosSale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolver Pendência'),
        content: Text('Confirmar que o troco de ${formatCents(sale.amountReceivedCents - sale.totalCents)} foi entregue para ${sale.customerName ?? 'o cliente'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final db = ref.read(appDatabaseProvider);
        final newNotes = sale.notes == null || sale.notes!.isEmpty 
            ? 'Troco entregue para ${sale.customerName ?? 'o cliente'}.' 
            : '${sale.notes}\n[Troco entregue para ${sale.customerName ?? 'o cliente'}]';
            
        await db.updateSaleDetails(
          saleId: sale.id,
          paymentMethod: sale.paymentMethod,
          amountReceivedCents: sale.amountReceivedCents,
          notes: newNotes,
          changePending: false,
          customerName: sale.customerName,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pendência resolvida!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  Future<void> _shareSalesSummary(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final sales = await (db.select(db.sales)..where((s) => s.eventId.equals(eventId))).get();
    
    if (sales.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há vendas para exportar.')));
      }
      return;
    }

    final event = await (db.select(db.events)..where((e) => e.id.equals(eventId))).getSingle();

    int totalAmount = 0;
    Map<String, int> totalByMethod = {};
    List<PosSale> pendingChanges = [];

    for (final s in sales) {
      totalAmount += s.totalCents;
      totalByMethod[s.paymentMethod] = (totalByMethod[s.paymentMethod] ?? 0) + s.totalCents;
      if (s.changePending) {
        pendingChanges.add(s);
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 *Resumo de Vendas: ${event.title}*');
    buffer.writeln('📅 Data: ${_dateTimeFmt.format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('💰 *Total Arrecadado*: ${formatCents(totalAmount)}');
    buffer.writeln('');
    buffer.writeln('💳 *Por Forma de Pagamento*:');
    totalByMethod.forEach((method, amount) {
      buffer.writeln('• ${PaymentMethod.label(method)}: ${formatCents(amount)}');
    });
    buffer.writeln('');
    buffer.writeln('🧾 *Total de Vendas*: ${sales.length}');

    if (pendingChanges.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('⚠️ *TROCOS PENDENTES*:');
      for (final s in pendingChanges) {
        final change = s.amountReceivedCents - s.totalCents;
        buffer.writeln('• ${s.customerName ?? 'Não informado'}: ${formatCents(change)} (Venda #${s.id})');
      }
    }

    buffer.writeln('');
    buffer.writeln('📋 *LISTA DE VENDAS*:');
    for (final s in sales) {
      final when = DateTime.fromMillisecondsSinceEpoch(s.soldAtMs);
      final timeStr = DateFormat.Hm('pt_BR').format(when);
      final payStr = PaymentMethod.label(s.paymentMethod);
      buffer.writeln('• #${s.id} às $timeStr - ${formatCents(s.totalCents)} ($payStr)');
      
      try {
        final lines = await db.saleLinesForSale(s.id);
        if (lines.isNotEmpty) {
          final itemsStr = lines.map((l) => '${l.qty}x ${l.itemLabel}').join(', ');
          buffer.writeln('  ↳ $itemsStr');
        }
      } catch (_) {}
      
      if (s.notes != null && s.notes!.isNotEmpty) {
        buffer.writeln('  📝 Obs: ${s.notes!.replaceAll('\n', ' ')}');
      }
    }

    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de vendas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Exportar Resumo',
            onPressed: () => _shareSalesSummary(context, ref),
          ),
        ],
      ),
      body: StreamBuilder<List<PosSale>>(
        stream: db.watchSalesForEvent(eventId),
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
          final list = snap.data!;
          if (list.isEmpty) {
            return const CaixaEmptyHint(
              icon: Icons.receipt_long_outlined,
              message: 'Nenhuma venda neste evento',
            );
          }
          return ListView.separated(
            padding: kCaixaScreenPadding.copyWith(top: 8, bottom: 24),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final s = list[i];
              final when = DateTime.fromMillisecondsSinceEpoch(s.soldAtMs);
              final change = s.amountReceivedCents - s.totalCents;
              final pay = PaymentMethod.label(s.paymentMethod);
              final isPending = s.changePending;
              final isResolved = !isPending && s.customerName != null;
              
              return Card(
                color: isPending 
                    ? Colors.orange.withValues(alpha: 0.15) 
                    : isResolved 
                        ? Colors.green.withValues(alpha: 0.15) 
                        : null,
                child: ExpansionTile(
                  key: ValueKey(s.id),
                  leading: CircleAvatar(
                    radius: 18,
                    child: Text(
                      '${s.id}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  title: Text(
                    _dateTimeFmt.format(when),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Text(
                    '$pay · Total ${formatCents(s.totalCents)}'
                    '${change != 0 ? ' · Troco ${formatCents(change)}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                  FutureBuilder<List<EventSaleLineRow>>(
                    future: db.saleLinesForSale(s.id),
                    builder: (context, lineSnap) {
                      if (lineSnap.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      if (lineSnap.hasError) {
                        return Text('Erro: ${lineSnap.error}');
                      }
                      final lines = lineSnap.data!;
                      if (lines.isEmpty) {
                        return const Text('Sem itens.');
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (s.notes != null && s.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.notes, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(s.notes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic))),
                                ],
                              ),
                            ),
                          if (s.changePending)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Troco pendente (${formatCents(s.amountReceivedCents - s.totalCents)}) para: ${s.customerName ?? 'Não informado'}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            'Itens',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          ...lines.map(
                            (l) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      l.itemLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${l.qty}× ${formatCents(l.unitPriceCents)}',
                                      textAlign: TextAlign.end,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 88,
                                    child: Text(
                                      formatCents(l.lineTotalCents),
                                      textAlign: TextAlign.end,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recebido',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(formatCents(s.amountReceivedCents)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              if (s.changePending)
                                TextButton.icon(
                                  onPressed: () => _resolvePendingChange(context, ref, s),
                                  icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                  label: const Text('Baixar troco', style: TextStyle(color: Colors.green)),
                                ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => context.push('/event/${s.eventId}/edit_sale/${s.id}'),
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Editar'),
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteSale(context, ref, s.id),
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                label: const Text('Excluir', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
