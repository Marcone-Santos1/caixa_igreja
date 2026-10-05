import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/cloud_sync_provider.dart';
import '../events/event_cloud_sheet.dart';

/// Indicador compacto do backup na nuvem (☁️) de UM evento, para a AppBar do
/// hub. Tocar abre o painel da nuvem do evento; sem configuração, leva à
/// tela de ativação.
class CloudStatusIcon extends ConsumerWidget {
  const CloudStatusIcon({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cloudSyncControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    if (!state.configured) {
      return IconButton(
        tooltip: 'Ativar backup na nuvem',
        icon: Icon(Icons.cloud_off_outlined,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
        onPressed: () => context.push('/settings/cloud'),
      );
    }

    final status = state.forEvent(eventId);
    final (icon, color, tooltip) = switch (status?.phase) {
      CloudEventPhase.uploading ||
      CloudEventPhase.downloading =>
        (Icons.cloud_sync_outlined, scheme.primary, 'Sincronizando…'),
      CloudEventPhase.upToDate => (
          Icons.cloud_done_outlined,
          Colors.green,
          'Em dia (v${status!.lastSyncedVersion})'
        ),
      CloudEventPhase.divergence || CloudEventPhase.blockedSchema => (
          Icons.cloud_sync_outlined,
          scheme.error,
          'Precisa de atenção'
        ),
      CloudEventPhase.error => (
          Icons.cloud_off_outlined,
          scheme.error,
          'Falha no backup'
        ),
      CloudEventPhase.pendingUpload || CloudEventPhase.updateAvailable => (
          Icons.cloud_outlined,
          scheme.primary,
          'Sincronização pendente'
        ),
      CloudEventPhase.paused => (
          Icons.pause_circle_outline,
          scheme.onSurfaceVariant.withValues(alpha: 0.7),
          'Sincronização pausada'
        ),
      _ => (
          Icons.cloud_outlined,
          scheme.onSurfaceVariant,
          'Backup na nuvem'
        ),
    };

    final attention = status?.needsAttention ?? false;
    final pending = status?.phase == CloudEventPhase.pendingUpload ||
        status?.phase == CloudEventPhase.updateAvailable;

    return IconButton(
      tooltip: tooltip,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: color),
          if (attention || pending)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: attention ? scheme.error : scheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      onPressed: () => showEventCloudSheet(context, eventId),
    );
  }
}
