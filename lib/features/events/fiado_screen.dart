import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../domain/payment_method.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../utils/money_format.dart';

/// Tela de fiados: com [eventId], os fiados daquele evento; sem, a visão
/// geral por cliente (todos os eventos).
class FiadoScreen extends ConsumerWidget {
  const FiadoScreen({super.key, this.eventId});

  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(eventId != null ? 'Fiados do evento' : 'Fiados'),
      ),
      body: eventId != null
          ? _EventFiadoList(eventId: eventId!)
          : _GlobalFiadoList(db: db),
    );
  }
}

class _EventFiadoList extends ConsumerWidget {
  const _EventFiadoList({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<FiadoSaleInfo>>(
      stream: db.watchFiadoSales(eventId: eventId),
      builder: (context, snap) {
        final list = snap.data;
        if (list == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (list.isEmpty) {
          return const Center(
            child: CaixaEmptyHint(
              icon: Icons.handshake_outlined,
              message: 'Nenhum fiado neste evento',
              detail:
                  'Vendas fiadas (método "Fiado" no checkout) aparecem aqui '
                  'para receber depois.',
            ),
          );
        }
        final open = list.where((f) => !f.isSettled).toList();
        final settled = list.where((f) => f.isSettled).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (open.isNotEmpty) ...[
              _sectionHeader(context, 'Em aberto',
                  formatCents(open.fold(0, (a, f) => a + f.openCents))),
              for (final f in open) _FiadoSaleTile(info: f),
            ],
            if (settled.isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionHeader(context, 'Quitados', null),
              for (final f in settled) _FiadoSaleTile(info: f),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String? total) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (total != null)
            Text(total,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                )),
        ],
      ),
    );
  }
}

class _GlobalFiadoList extends StatelessWidget {
  const _GlobalFiadoList({required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<FiadoCustomerBalance>>(
      stream: db.watchFiadoBalancesByCustomer(),
      builder: (context, snap) {
        final balances = snap.data;
        if (balances == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (balances.isEmpty) {
          return const Center(
            child: CaixaEmptyHint(
              icon: Icons.handshake_outlined,
              message: 'Ninguém devendo 🎉',
              detail: 'Fiados em aberto de todos os eventos aparecem aqui, '
                  'agrupados por pessoa.',
            ),
          );
        }
        final totalOpen = balances.fold<int>(0, (a, b) => a + b.openCents);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.handshake_outlined,
                    color: theme.colorScheme.error, size: 30),
                title: const Text('Total em aberto'),
                subtitle:
                    Text('${balances.length} pessoa(s) com fiado pendente'),
                trailing: Text(
                  formatCents(totalOpen),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final b in balances)
              Card(
                child: ExpansionTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(b.customerName),
                  subtitle: Text(
                    '${b.openSaleCount} venda(s) · última em '
                    '${DateFormat('dd/MM').format(DateTime.fromMillisecondsSinceEpoch(b.lastSaleAtMs))}',
                  ),
                  trailing: Text(
                    formatCents(b.openCents),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  children: [
                    _CustomerSales(db: db, customerName: b.customerName),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CustomerSales extends StatelessWidget {
  const _CustomerSales({required this.db, required this.customerName});

  final AppDatabase db;
  final String customerName;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FiadoSaleInfo>>(
      stream: db.watchFiadoSales(onlyOpen: true),
      builder: (context, snap) {
        final sales = (snap.data ?? const <FiadoSaleInfo>[])
            .where((f) =>
                (f.sale.customerName ?? '').trim().toLowerCase() ==
                customerName.trim().toLowerCase())
            .toList();
        return Column(
          children: [for (final f in sales) _FiadoSaleTile(info: f)],
        );
      },
    );
  }
}

class _FiadoSaleTile extends ConsumerWidget {
  const _FiadoSaleTile({required this.info});

  final FiadoSaleInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sale = info.sale;
    final when = DateFormat('dd/MM HH:mm')
        .format(DateTime.fromMillisecondsSinceEpoch(sale.soldAtMs));
    return ListTile(
      dense: true,
      leading: Icon(
        info.isSettled ? Icons.check_circle_outline : Icons.schedule,
        color: info.isSettled ? Colors.green : theme.colorScheme.error,
      ),
      title: Text(
        '${sale.customerName ?? 'Sem nome'} · ${formatCents(sale.totalCents)}',
      ),
      subtitle: Text(
        info.isSettled
            ? '$when · quitado'
            : '$when · recebido ${formatCents(info.paidCents)} · '
                'deve ${formatCents(info.openCents)}',
      ),
      trailing: info.isSettled
          ? null
          : FilledButton.tonal(
              onPressed: () => showReceiveFiadoDialog(context, ref, info),
              child: const Text('Receber'),
            ),
      onTap: () => _showHistory(context, ref),
    );
  }

  Future<void> _showHistory(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final payments = await db.fiadoPaymentsForSale(info.sale.id);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        shrinkWrap: true,
        children: [
          Text(
            'Lançamentos — ${info.sale.customerName ?? 'Sem nome'}',
            style: Theme.of(ctx)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            const Text('Nenhum recebimento ainda.')
          else
            for (final p in payments)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attach_money, size: 20),
                title: Text(
                    '${formatCents(p.amountCents)} · ${PaymentMethod.label(p.method)}'),
                subtitle: Text(
                  '${DateFormat('dd/MM HH:mm').format(DateTime.fromMillisecondsSinceEpoch(p.paidAtMs))}'
                  '${p.sessionId == null ? ' · fora de caixa' : ''}'
                  '${(p.notes ?? '').isNotEmpty ? ' · ${p.notes}' : ''}',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final go = await showDialog<bool>(
                      context: ctx,
                      builder: (c) => AlertDialog(
                        title: const Text('Estornar lançamento?'),
                        content: Text(
                            'O recebimento de ${formatCents(p.amountCents)} volta a ficar em aberto.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancelar')),
                          FilledButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Estornar')),
                        ],
                      ),
                    );
                    if (go == true) {
                      await db.undoFiadoPayment(p.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Estornar'),
                ),
              ),
        ],
      ),
    );
  }
}

/// Diálogo "Receber fiado": valor (pré-preenchido com o saldo), método e
/// observação. No modo terminal Wi-Fi o lançamento vai via host.
Future<void> showReceiveFiadoDialog(
    BuildContext context, WidgetRef ref, FiadoSaleInfo info) async {
  final amountController = TextEditingController(
    text: (info.openCents / 100).toStringAsFixed(2).replaceAll('.', ','),
  );
  final notesController = TextEditingController();
  var method = PaymentMethod.dinheiro;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Receber de ${info.sale.customerName ?? 'Sem nome'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saldo devedor: ${formatCents(info.openCents)}',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Valor recebido',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: method,
              decoration: const InputDecoration(labelText: 'Método'),
              items: PaymentMethod.settlementMethods
                  .map((m) => DropdownMenuItem(
                      value: m, child: Text(PaymentMethod.label(m))))
                  .toList(),
              onChanged: (v) =>
                  setState(() => method = v ?? PaymentMethod.dinheiro),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration:
                  const InputDecoration(labelText: 'Observação (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Receber'),
          ),
        ],
      ),
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final amount = parseMoneyToCents(amountController.text) ?? 0;
  final notes =
      notesController.text.trim().isEmpty ? null : notesController.text.trim();
  final messenger = ScaffoldMessenger.of(context);
  try {
    final syncState = ref.read(syncProvider);
    if (syncState.mode == SyncMode.client && syncState.isConnected) {
      await ref.read(syncProvider.notifier).submitFiadoPaymentToHost(
            eventId: info.sale.eventId,
            saleId: info.sale.id,
            amountCents: amount,
            method: method,
            notes: notes,
          );
    } else {
      await ref.read(appDatabaseProvider).registerFiadoPayment(
            saleId: info.sale.id,
            amountCents: amount,
            method: method,
            notes: notes,
          );
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            'Recebido ${formatCents(amount)} de ${info.sale.customerName ?? 'cliente'}.'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('$e')));
  }
}
