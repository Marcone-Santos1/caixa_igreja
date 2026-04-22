import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/event_detail_provider.dart';
import 'event_form_screen.dart';

final _dateFmt = DateFormat.yMMMEd('pt_BR');

class EventHubScreen extends ConsumerWidget {
  const EventHubScreen({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(eventDetailProvider(eventId));
    void goBackToEvents() {
      context.go('/events');
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBackToEvents();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: goBackToEvents,
          ),
          title: const Text('Evento'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EventFormScreen(eventId: eventId),
                  ),
                );
                if (context.mounted) {
                  ref.invalidate(eventDetailProvider(eventId));
                }
              },
            ),
          ],
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (e) {
            if (e == null) {
              return const Center(child: Text('Evento não encontrado.'));
            }
            final day = DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs);
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  e.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _dateFmt.format(day),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (e.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(e.notes),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.push('/event/$eventId/sale'),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Nova venda'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/event/$eventId/fichas'),
                  icon: const Icon(Icons.toll_outlined),
                  label: const Text('Gerenciar fichas (dots)'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/event/$eventId/vendas'),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Registro de vendas'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
