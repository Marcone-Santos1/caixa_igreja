import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';
import '../../app/ui_kit.dart';
import '../../utils/date_time_utils.dart';
import '../../data/database.dart';
import '../../data/database_seeder.dart';
import '../../providers/app_update_provider.dart';
import '../../providers/cloud_sync_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import 'event_cloud_sheet.dart';
import 'event_delete_flow.dart';
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
                const _AppUpdateBanner(),
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
              const _AppUpdateBanner(),
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
                              tooltip: 'Duplicar evento',
                              icon: const Icon(Icons.copy_outlined, size: 18),
                              onPressed: () =>
                                  _showDuplicateDialog(context, ref, e),
                            ),
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
                              onPressed: () =>
                                  confirmAndDeleteEvent(context, ref, e),
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

/// Diálogo de duplicação: novo título/data + copiar estoques.
Future<void> _showDuplicateDialog(
    BuildContext context, WidgetRef ref, ChurchEvent source) async {
  final titleCtrl = TextEditingController(text: source.title);
  var date = DateTime.now();
  var copyStock = true;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Duplicar evento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Copia produtos, combos, fichas e a configuração de PIX de '
              '"${source.title}". Vendas e sessões não vão junto.',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título do novo evento'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
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
                  firstDate: DateTime(date.year - 1),
                  lastDate: DateTime(date.year + 2),
                );
                if (picked != null) setState(() => date = picked);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Copiar estoques atuais'),
              subtitle: const Text('Desligado: tudo começa zerado'),
              value: copyStock,
              onChanged: (v) => setState(() => copyStock = v),
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
            child: const Text('Duplicar'),
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return;

  try {
    final newId = await ref.read(appDatabaseProvider).duplicateEvent(
          sourceEventId: source.id,
          title: titleCtrl.text.trim().isEmpty
              ? '${source.title} (cópia)'
              : titleCtrl.text.trim(),
          dateEpochMs: startOfLocalDayMs(date),
          copyStock: copyStock,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento duplicado! Abrindo…')),
      );
      context.go('/event/$newId');
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao duplicar: $e')));
    }
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
    final cloudOnly = state.homeBannerEvents;
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              showEventCloudSheet(context, s.eventId),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(
                                '${s.eventDateMs != null ? dateFmt.format(DateTime.fromMillisecondsSinceEpoch(s.eventDateMs!)) : ''}'
                                '${s.remote?.deviceName != null ? ' · ${s.remote!.deviceName}' : ''}'
                                '${s.remote?.salesCount != null ? ' · ${s.remote!.salesCount} vendas' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: state.busy
                            ? null
                            : () => ref
                                .read(cloudSyncControllerProvider.notifier)
                                .downloadEvent(s.eventId),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('Baixar'),
                      ),
                      IconButton(
                        tooltip: 'Dispensar (fica na tela da nuvem)',
                        icon: const Icon(Icons.close, size: 18),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                        onPressed: () => ref
                            .read(cloudSyncControllerProvider.notifier)
                            .dismissCloudEvent(s.eventId),
                      ),
                    ],
                  ),
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


/// Banner "atualização do app disponível" (atualizador via nossa nuvem).
class _AppUpdateBanner extends ConsumerWidget {
  const _AppUpdateBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateControllerProvider);
    if (!update.updateAvailable || update.manifest == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final m = update.manifest!;
    final downloading = update.phase == AppUpdatePhase.downloading;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 0,
        color: CaixaAppTheme.warmGold.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.system_update,
                      size: 20, color: CaixaAppTheme.warmGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Atualização ${m.versionName} disponível',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (downloading)
                    Text('${(update.progress * 100).round()}%',
                        style: theme.textTheme.labelLarge)
                  else
                    FilledButton.tonal(
                      onPressed: () => ref
                          .read(appUpdateControllerProvider.notifier)
                          .downloadAndInstall(),
                      child: const Text('Instalar'),
                    ),
                ],
              ),
              if ((m.notes ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(m.notes!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
              if (downloading)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(value: update.progress),
                ),
              if (update.message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(update.message!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
