import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../utils/money_format.dart';

const kExpenseCategories = [
  'Insumos',
  'Gás',
  'Embalagem',
  'Transporte',
  'Outros',
];

/// Custos/despesas do evento: Lucro = faturamento − custos.
/// Em modo terminal Wi-Fi a tela é somente leitura (edita no caixa central).
class EventExpensesScreen extends ConsumerWidget {
  const EventExpensesScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final syncState = ref.watch(syncProvider);
    final readOnly =
        syncState.mode == SyncMode.client && syncState.isConnected;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Custos do evento'),
      ),
      floatingActionButton: readOnly
          ? null
          : FloatingActionButton(
              heroTag: 'fab_expenses',
              onPressed: () => _showExpenseSheet(context, ref),
              child: const Icon(Icons.add),
            ),
      body: StreamBuilder<List<EventExpense>>(
        stream: db.watchEventExpenses(eventId),
        builder: (context, snap) {
          final expenses = snap.data;
          if (expenses == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final total = expenses.fold<int>(0, (a, x) => a + x.amountCents);
          return Column(
            children: [
              if (readOnly)
                Container(
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Modo terminal: os custos são editados no Caixa Central.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: Icon(Icons.shopping_cart_outlined,
                      color: theme.colorScheme.error),
                  title: const Text('Total de custos'),
                  subtitle: Text('${expenses.length} lançamento(s)'),
                  trailing: Text(
                    formatCents(total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(
                        child: CaixaEmptyHint(
                          icon: Icons.shopping_cart_outlined,
                          message: 'Nenhum custo lançado',
                          detail:
                              'Registre as compras do evento (insumos, gás, '
                              'embalagem…) para ver o LUCRO nos relatórios.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: expenses.length,
                        itemBuilder: (context, i) {
                          final x = expenses[i];
                          return Card(
                            child: ListTile(
                              dense: true,
                              title: Text(x.description),
                              subtitle: Text(
                                '${x.category} · '
                                '${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(x.paidAtMs))}'
                                '${(x.notes ?? '').isNotEmpty ? ' · ${x.notes}' : ''}',
                              ),
                              trailing: Text(
                                formatCents(x.amountCents),
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              onTap: readOnly
                                  ? null
                                  : () =>
                                      _showExpenseSheet(context, ref, x),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showExpenseSheet(BuildContext context, WidgetRef ref,
      [EventExpense? existing]) async {
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final valueCtrl = TextEditingController(
      text: existing != null
          ? (existing.amountCents / 100).toStringAsFixed(2).replaceAll('.', ',')
          : '',
    );
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    var category = existing?.category ?? kExpenseCategories.first;
    var date = existing != null
        ? DateTime.fromMillisecondsSinceEpoch(existing.paidAtMs)
        : DateTime.now();

    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? 'Novo custo' : 'Editar custo',
                style: Theme.of(ctx)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                autofocus: existing == null,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Ex: 20kg de carne moída',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor *',
                  prefixText: 'R\$ ',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: [
                  for (final c in kExpenseCategories)
                    ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                    ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.event),
                title: Text(DateFormat('dd/MM/yyyy').format(date)),
                trailing: const Icon(Icons.edit_calendar_outlined, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: date,
                    firstDate: DateTime(date.year - 2),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => date = picked);
                },
              ),
              TextField(
                controller: notesCtrl,
                decoration:
                    const InputDecoration(labelText: 'Observação (opcional)'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, 'save'),
                child: const Text('Salvar'),
              ),
              if (existing != null)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, 'delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(ctx).colorScheme.error,
                  ),
                  child: const Text('Excluir lançamento'),
                ),
            ],
          ),
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    final db = ref.read(appDatabaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (action == 'delete' && existing != null) {
        await db.deleteEventExpense(existing.id);
        messenger.showSnackBar(
            const SnackBar(content: Text('Lançamento excluído.')));
        return;
      }
      await db.saveEventExpense(
        id: existing?.id,
        eventId: eventId,
        description: descCtrl.text,
        amountCents: parseMoneyToCents(valueCtrl.text) ?? 0,
        category: category,
        paidAtMs: date.millisecondsSinceEpoch,
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
