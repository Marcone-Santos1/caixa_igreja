import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/dot_change.dart';
import '../../utils/money_format.dart';

class ChangeDotsScreen extends ConsumerStatefulWidget {
  const ChangeDotsScreen({
    super.key,
    required this.eventId,
    required this.saleId,
    required this.changeCents,
  });

  final int eventId;
  final int saleId;
  final int changeCents;

  @override
  ConsumerState<ChangeDotsScreen> createState() => _ChangeDotsScreenState();
}

class _ChangeDotsScreenState extends ConsumerState<ChangeDotsScreen> {
  final Map<int, TextEditingController> _qtyCtrls = {};

  @override
  void dispose() {
    for (final c in _qtyCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrlFor(int denomId) {
    return _qtyCtrls.putIfAbsent(
      denomId,
      () => TextEditingController(text: '0'),
    );
  }

  List<({int dotDenominationId, int qty})> _readAllocation(
    List<EventDotDenom> denoms,
  ) {
    final out = <({int dotDenominationId, int qty})>[];
    for (final d in denoms) {
      final raw = _ctrlFor(d.id).text.trim();
      final q = int.tryParse(raw) ?? 0;
      if (q > 0) out.add((dotDenominationId: d.id, qty: q));
    }
    return out;
  }

  int _sumCents(
    List<({int dotDenominationId, int qty})> alloc,
    List<EventDotDenom> denoms,
  ) {
    return allocationTotalCents(alloc, denoms);
  }

  void _applySuggestion(List<EventDotDenom> denoms) {
    final sug = suggestChangeAllocation(
      changeCents: widget.changeCents,
      denoms: denoms,
    );
    for (final d in denoms) {
      _ctrlFor(d.id).text = '0';
    }
    for (final s in sug) {
      _ctrlFor(s.dotDenominationId).text = '${s.qty}';
    }
    setState(() {});
  }

  Future<void> _confirm(List<EventDotDenom> denoms) async {
    final alloc = _readAllocation(denoms);
    final sum = _sumCents(alloc, denoms);
    if (sum != widget.changeCents) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'A soma das fichas (${formatCents(sum)}) deve ser igual ao troco '
            '(${formatCents(widget.changeCents)}).',
          ),
        ),
      );
      return;
    }
    final db = ref.read(appDatabaseProvider);
    try {
      await db.confirmChangeDots(
        saleId: widget.saleId,
        eventId: widget.eventId,
        changeCents: widget.changeCents,
        allocation: alloc,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Troco em fichas registrado')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Troco em fichas'),
      ),
      body: StreamBuilder<List<EventDotDenom>>(
        stream: db.watchDotDenominations(widget.eventId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          final denoms = snap.data;
          if (denoms == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final sum = _sumCents(_readAllocation(denoms), denoms);
          final remainder = widget.changeCents - sum;
          final sug = suggestChangeAllocation(
            changeCents: widget.changeCents,
            denoms: denoms,
          );
          final sugSum = allocationTotalCents(sug, denoms);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Troco a distribuir: ${formatCents(widget.changeCents)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Informe quantas fichas de cada tipo você entrega ao cliente. '
                'A soma deve fechar exatamente o troco (auditoria).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (denoms.isEmpty)
                const Text('Cadastre fichas no evento para usar esta tela.')
              else ...[
                if (sugSum < widget.changeCents)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Com o estoque atual não dá para cobrir todo o troco só com fichas '
                        '(faltam ${formatCents(widget.changeCents - sugSum)} com a sugestão). '
                        'Ajuste manualmente ou use cédulas/moedas e registre só o que entregar em fichas.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _applySuggestion(denoms),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Preencher sugestão (maior valor primeiro)'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Soma atual: ${formatCents(sum)} · '
                  'Falta: ${formatCents(remainder.clamp(0, 1 << 30))}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                for (final d in denoms) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(d.label),
                    subtitle: Text(
                      '${formatCents(d.valueCents)} cada · estoque ${d.stockQty}',
                    ),
                    trailing: SizedBox(
                      width: 72,
                      child: TextField(
                        controller: _ctrlFor(d.id),
                        decoration: const InputDecoration(
                          labelText: 'Qtd',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: denoms.isEmpty ? null : () => _confirm(denoms),
                child: const Text('Confirmar fichas do troco'),
              ),
            ],
          );
        },
      ),
    );
  }
}
