import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../providers/database_provider.dart';
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
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final list = snapshot.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const Center(
              child: Text('Nenhum evento. Toque em + para cadastrar.'),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = list[i];
              final day = DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs);
              return ListTile(
                title: Text(e.title),
                subtitle: Text(
                  '${_dateFmt.format(day)}\n${e.notes.isEmpty ? '—' : e.notes}',
                ),
                isThreeLine: true,
                onTap: () => context.go('/event/${e.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EventFormScreen(eventId: e.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_events_list',
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const EventFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
