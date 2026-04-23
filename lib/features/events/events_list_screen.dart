import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import 'event_delete_dialog.dart';
import 'event_form_screen.dart';

final _dateFmt = DateFormat.yMMMEd('pt_BR');

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: StreamBuilder<List<ChurchEvent>>(
        stream: db.watchAllEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          final list = snapshot.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const CaixaEmptyHint(
              icon: Icons.event_available_outlined,
              message: 'Nenhum evento ainda',
              detail: 'Toque em + para cadastrar o primeiro.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, i) {
              final e = list[i];
              final day = DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs);
              return CaixaListRow(
                title: e.title,
                subtitle:
                    '${_dateFmt.format(day)}\n${e.notes.isEmpty ? '—' : e.notes}',
                isThreeLine: true,
                onTap: () => context.go('/event/${e.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => EventFormScreen(eventId: e.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Excluir',
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () async {
                        final sure = await confirmDeleteEventDialog(
                          context,
                          eventTitle: e.title,
                        );
                        if (!sure || !context.mounted) return;
                        await ref
                            .read(appDatabaseProvider)
                            .deleteEventCascade(e.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'fab_events_list',
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const EventFormScreen()),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
