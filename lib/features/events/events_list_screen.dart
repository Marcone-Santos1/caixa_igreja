import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import 'event_delete_dialog.dart';
import 'event_form_screen.dart';
import 'qr_scanner_dialog.dart';

final _dateFmt = DateFormat.yMMMEd('pt_BR');

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  void _showImportAndSyncDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Conectar a Caixa Central'),
            content: isLoading
                ? const SizedBox(
                    height: 120,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Conectando e importando dados...', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Escaneie o QR Code ou cole o token de conexão gerado pelo dispositivo Caixa Central:',
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final scanned = await Navigator.push<String>(
                            ctx,
                            MaterialPageRoute(builder: (_) => const QrScannerDialog()),
                          );
                          if (scanned != null && scanned.isNotEmpty) {
                            setState(() {
                              controller.text = scanned;
                            });
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Escanear QR Code'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'ou cole o token manualmente abaixo:',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'caixa://connect/...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
            actions: isLoading
                ? []
                : [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final token = controller.text.trim();
                        if (token.isEmpty) return;

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          await ref.read(syncProvider.notifier).importEventAndConnect(token);
                          if (ctx.mounted) {
                            Navigator.pop(ctx); // Close dialog

                            final payload = ref.read(syncProvider.notifier).parseSyncToken(token);
                            if (payload != null) {
                              final eventId = payload['eventId'] as String;
                              context.go('/event/$eventId');
                            }
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Falha ao conectar: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Conectar'),
                    ),
                  ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        actions: [
          IconButton(
            tooltip: 'Conectar a Caixa Central',
            icon: const Icon(Icons.sync_alt_rounded),
            onPressed: () => _showImportAndSyncDialog(context, ref),
          ),
        ],
      ),
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
