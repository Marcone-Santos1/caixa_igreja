import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/device_identity.dart';
import '../../providers/cloud_sync_provider.dart';

/// Painel da nuvem de UM evento (aberto pelo ☁️ no hub do evento):
/// estado, enviar agora, baixar, divergência guiada, histórico e desfazer.
Future<void> showEventCloudSheet(BuildContext context, String eventId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (context, scrollController) =>
          _EventCloudSheet(eventId: eventId, scrollController: scrollController),
    ),
  );
}

class _EventCloudSheet extends ConsumerWidget {
  const _EventCloudSheet({required this.eventId, required this.scrollController});

  final String eventId;
  final ScrollController scrollController;

  String _fmtWhen(DateTime? dt) =>
      dt == null ? '—' : DateFormat('dd/MM HH:mm').format(dt.toLocal());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudSyncControllerProvider);
    final controller = ref.read(cloudSyncControllerProvider.notifier);
    final theme = Theme.of(context);
    final status = state.forEvent(eventId);

    if (!state.configured) {
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Text('Backup na nuvem',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
              'O backup na nuvem ainda não foi ativado neste aparelho.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings/cloud');
            },
            icon: const Icon(Icons.cloud_outlined),
            label: const Text('Ativar backup na nuvem'),
          ),
        ],
      );
    }

    final remote = status?.remote;
    final history = remote?.history ?? const [];
    final applied = status?.lastApplied;
    final paused = status?.phase == CloudEventPhase.paused;
    final isLocal = status?.existsLocally ?? false;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                status?.title ?? 'Evento',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (state.busy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _phaseLabel(status),
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: _phaseColor(context, status)),
        ),
        if (status?.message != null) ...[
          const SizedBox(height: 6),
          Text(status!.message!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
        const SizedBox(height: 6),
        Text(
          'Neste aparelho: v${status?.lastSyncedVersion ?? 0} · '
          'Na nuvem: ${remote == null || remote.isEmpty ? '—' : 'v${remote.version} (${remote.deviceName ?? '?'} · ${_fmtWhen(remote.uploadedAt)})'}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        if (isLocal)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sincronizar este evento'),
            subtitle: Text(
              paused
                  ? 'Pausado neste aparelho: não envia nem baixa. '
                      'Não afeta os outros celulares.'
                  : 'Enviado e atualizado automaticamente.',
            ),
            value: !paused,
            onChanged: state.busy
                ? null
                : (v) => controller.setEventSyncPaused(eventId, !v),
          ),
        if (!paused && status?.phase == CloudEventPhase.divergence) ...[
          Card(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Este aparelho e a nuvem têm novidades diferentes',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Nada foi perdido: escolha qual lado passa a valer. O outro '
                    'fica guardado (no histórico da nuvem ou em cópia local).',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: state.busy
                        ? null
                        : () => controller.resolveKeepLocal(eventId),
                    icon: const Icon(Icons.upload_outlined),
                    label: const Text('Manter o deste aparelho'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: state.busy
                        ? null
                        : () => controller.resolveUseRemote(eventId),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Usar o da nuvem (arquivar o local)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (!paused) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.busy
                      ? null
                      : () => controller.uploadEventNow(eventId),
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Enviar agora'),
                ),
              ),
              if (status?.phase == CloudEventPhase.updateAvailable ||
                  status?.phase == CloudEventPhase.cloudOnly) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: state.busy
                        ? null
                        : () => controller.downloadEvent(eventId),
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: const Text('Baixar'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
        ],

        // ─── Quem recebe (RFC v3) ───────────────────────────────────────
        if (isLocal && !paused && remote != null && !remote.isEmpty)
          _SharingSection(
            eventId: eventId,
            state: state,
            controller: controller,
          ),

        if (applied != null)
          Card(
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.history_outlined),
              title: Text(
                  'Atualizado para a v${applied.version} (${applied.deviceName ?? 'outro aparelho'})'),
              subtitle: Text(_fmtWhen(applied.at)),
              trailing: TextButton(
                onPressed:
                    state.busy ? null : () => controller.undoLastApplied(eventId),
                child: const Text('Desfazer'),
              ),
            ),
          ),

        if (history.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Histórico de versões',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          for (final entry in history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                entry.version == status?.lastSyncedVersion
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 20,
              ),
              title: Text(
                'v${entry.version} · ${entry.deviceName ?? '?'}'
                '${entry.salesCount != null ? ' · ${entry.salesCount} vendas' : ''}',
              ),
              subtitle: Text(_fmtWhen(entry.uploadedAt)),
              trailing: entry.version == status?.lastSyncedVersion
                  ? null
                  : TextButton(
                      onPressed: state.busy
                          ? null
                          : () async {
                              final go = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title:
                                      Text('Restaurar a v${entry.version}?'),
                                  content: const Text(
                                    'O estado atual do evento é arquivado e a '
                                    'versão restaurada vira a nova versão da '
                                    'nuvem no próximo envio.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Restaurar'),
                                    ),
                                  ],
                                ),
                              );
                              if (go == true) {
                                await controller.restoreEventVersion(
                                    eventId, entry.version);
                              }
                            },
                      child: const Text('Restaurar'),
                    ),
            ),
        ],
      ],
    );
  }

  String _phaseLabel(CloudEventStatus? status) {
    return switch (status?.phase) {
      null => 'Ainda não verificado',
      CloudEventPhase.upToDate => 'Em dia ✓',
      CloudEventPhase.pendingUpload => 'Alterações pendentes de envio',
      CloudEventPhase.uploading => 'Enviando…',
      CloudEventPhase.downloading => 'Baixando…',
      CloudEventPhase.updateAvailable => 'Nova versão disponível na nuvem',
      CloudEventPhase.divergence => 'Divergência — precisa da sua escolha',
      CloudEventPhase.blockedSchema => 'Atualize o app para sincronizar',
      CloudEventPhase.cloudOnly => 'Disponível na nuvem para baixar',
      CloudEventPhase.paused => 'Sincronização pausada neste aparelho',
      CloudEventPhase.error => 'Falha na última tentativa',
    };
  }

  Color _phaseColor(BuildContext context, CloudEventStatus? status) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status?.phase) {
      CloudEventPhase.upToDate => Colors.green,
      CloudEventPhase.divergence ||
      CloudEventPhase.blockedSchema ||
      CloudEventPhase.error =>
        scheme.error,
      _ => scheme.onSurfaceVariant,
    };
  }
}

/// "Quem recebe": lista de celulares da igreja com interruptor por evento.
/// Dono e administradores gerenciam; os demais veem o estado.
class _SharingSection extends StatelessWidget {
  const _SharingSection({
    required this.eventId,
    required this.state,
    required this.controller,
  });

  final String eventId;
  final CloudSyncState state;
  final CloudSyncController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = state.forEvent(eventId);
    final remote = status?.remote;
    if (remote == null) return const SizedBox.shrink();

    final canManage =
        remote.isOwner(DeviceIdentity.deviceId) || state.isAdmin;
    final others = state.devices
        .where((d) => !d.revoked && d.deviceId != remote.ownerDeviceId)
        .toList();
    final ownerName = state.devices
        .where((d) => d.deviceId == remote.ownerDeviceId)
        .map((d) => d.name)
        .firstOrNull;
    final sharedCount = remote.sharedWith.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              sharedCount == 0 ? Icons.lock_outline : Icons.group_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text('Quem recebe este evento',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          sharedCount == 0
              ? 'Privado: backup na nuvem só deste evento para '
                  '${ownerName ?? 'o dono'}. Ligue os celulares que devem receber.'
              : 'Dono: ${ownerName ?? '?'}. Celulares desligados param de '
                  'receber novas versões (o que já baixaram permanece lá).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (others.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Nenhum outro celular na igreja ainda. Convide em '
              'Ajustes → Backup na nuvem.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        for (final d in others)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              '${d.name}${d.deviceId == DeviceIdentity.deviceId ? ' (este)' : ''}',
            ),
            value: remote.sharedWith.contains(d.deviceId),
            onChanged: canManage && !state.busy
                ? (v) => controller.toggleEventShare(eventId, d.deviceId, v)
                : null,
          ),
        if (!canManage)
          Text(
            'Só o dono do evento ou um administrador altera esta lista.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
