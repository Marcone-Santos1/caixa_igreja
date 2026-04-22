import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de vendas')),
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
              return Card(
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
