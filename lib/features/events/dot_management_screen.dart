import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';

class DotManagementScreen extends ConsumerWidget {
  const DotManagementScreen({super.key, required this.eventId});

  final int eventId;

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    EventDotDenom? existing,
  }) async {
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final valueCtrl = TextEditingController(
      text: existing == null
          ? ''
          : (existing.valueCents / 100).toStringAsFixed(2).replaceAll('.', ','),
    );
    final stockCtrl = TextEditingController(
      text: (existing?.stockQty ?? 0).toString(),
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Nova ficha' : 'Editar ficha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome (ex: Ficha R\$5)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueCtrl,
                decoration: const InputDecoration(
                  labelText: 'Valor unitário',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(
                  labelText: 'Quantidade em estoque',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final vc = parseMoneyToCents(valueCtrl.text);
    if (vc == null || vc <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido')),
      );
      return;
    }
    final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
    if (stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estoque inválido')),
      );
      return;
    }
    if (labelCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome')),
      );
      return;
    }

    final db = ref.read(appDatabaseProvider);
    if (existing == null) {
      await db.into(db.eventDotDenominations).insert(
            EventDotDenominationsCompanion.insert(
              eventId: eventId,
              label: labelCtrl.text.trim(),
              valueCents: vc,
              stockQty: Value(stock),
            ),
          );
    } else {
      await (db.update(db.eventDotDenominations)
            ..where((t) => t.id.equals(existing.id)))
          .write(
        EventDotDenominationsCompanion(
          label: Value(labelCtrl.text.trim()),
          valueCents: Value(vc),
          stockQty: Value(stock),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Fichas do evento'),
      ),
      body: StreamBuilder<List<EventDotDenom>>(
        stream: db.watchDotDenominations(eventId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          final list = snap.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return Center(
              child: Text(
                'Nenhuma ficha cadastrada.\nToque em + para criar denominações (ex: R\$ 5, R\$ 10).',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = list[i];
              return ListTile(
                title: Text(d.label),
                subtitle: Text(
                  '${formatCents(d.valueCents)} · Estoque: ${d.stockQty}',
                ),
                onTap: () => _openForm(context, ref, existing: d),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dot_management',
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
