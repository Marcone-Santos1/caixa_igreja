import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';
import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../data/database_seeder.dart';
import '../../providers/cloud_sync_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import 'event_cloud_sheet.dart';
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
        title: Row(
          children: [
                      Image.asset(
              'assets/icon/app_icon.png',
              height: 34,
              width: 34,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              'Cantina Padroeira',
              style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
            return Column(
              children: [
                const _CloudEventsBanner(),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CaixaEmptyHint(
                      icon: Icons.event_available_outlined,
                      message: 'Nenhum evento ainda',
                      detail:
                          'Toque em + para cadastrar o primeiro ou carregue dados de demonstração para testar.',
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        final seeder = DatabaseSeeder(ref.read(appDatabaseProvider));
                        final res = await seeder.seedAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Dados de exemplo carregados (${res.eventsCount} eventos).',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.dataset_outlined),
                      label: const Text('Carregar dados de exemplo (Seeder)'),
                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              const _CloudEventsBanner(),
              Expanded(
                child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final e = list[i];
              final day = DateTime.fromMillisecondsSinceEpoch(e.dateEpochMs);
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                  ),
                ),
                color: isDark ? Colors.grey.shade900 : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.go('/event/${e.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: CaixaAppTheme.warmGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.event, size: 14, color: CaixaAppTheme.warmGold),
                                  const SizedBox(width: 4),
                                  Text(
                                    _dateFmt.format(day),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF7A4E00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Editar evento',
                              icon: const Icon(Icons.edit_outlined, size: 18),
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
                                size: 18,
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
                        const SizedBox(height: 8),
                        Text(
                          e.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (e.notes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            e.notes,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => context.go('/event/${e.id}'),
                              icon: const Icon(Icons.point_of_sale_outlined, size: 18),
                              label: const Text('Abrir Caixa / PDV'),
                              style: TextButton.styleFrom(
                                foregroundColor: CaixaAppTheme.marianBlue,
                                textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
                ),
              ),
            ],
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

/// Banner "eventos disponíveis na nuvem": aparece quando existem eventos na
/// nuvem da igreja que ainda não estão neste celular (ex.: o caixa da semana
/// passada foi operado em outro aparelho).
class _CloudEventsBanner extends ConsumerWidget {
  const _CloudEventsBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudSyncControllerProvider);
    final cloudOnly = state.cloudOnlyEvents;
    if (!state.configured || cloudOnly.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd/MM');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_download_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    cloudOnly.length == 1
                        ? '1 evento na nuvem para baixar'
                        : '${cloudOnly.length} eventos na nuvem para baixar',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              for (final s in cloudOnly.take(3))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(s.title),
                  subtitle: Text(
                    '${s.eventDateMs != null ? dateFmt.format(DateTime.fromMillisecondsSinceEpoch(s.eventDateMs!)) : ''}'
                    '${s.remote?.deviceName != null ? ' · ${s.remote!.deviceName}' : ''}'
                    '${s.remote?.salesCount != null ? ' · ${s.remote!.salesCount} vendas' : ''}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: state.busy
                        ? null
                        : () => ref
                            .read(cloudSyncControllerProvider.notifier)
                            .downloadEvent(s.eventId),
                    child: const Text('Baixar'),
                  ),
                  onTap: () => showEventCloudSheet(context, s.eventId),
                ),
              if (cloudOnly.length > 3)
                TextButton(
                  onPressed: () => context.push('/settings/cloud'),
                  child: Text('Ver todos (${cloudOnly.length})'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
