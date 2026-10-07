import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/device_identity.dart';
import '../../providers/cloud_sync_provider.dart';
import '../../providers/database_provider.dart';
import 'event_delete_dialog.dart';

/// Fluxo único de exclusão de evento, ciente da nuvem:
/// - evento não sincronizado → confirmação simples (tombstone local);
/// - dono/admin → "Excluir para todos" ou "Remover só deste aparelho";
/// - membro → só "Remover deste aparelho" (sair do evento, sem propagar).
/// O servidor também bloqueia exclusão-para-todos vinda de membro (403).
Future<bool> confirmAndDeleteEvent(
  BuildContext context,
  WidgetRef ref,
  ChurchEvent event,
) async {
  final cloud = ref.read(cloudSyncControllerProvider);
  final status = cloud.forEvent(event.id);
  final remote = status?.remote;
  final synced =
      cloud.configured && remote != null && !remote.isEmpty;

  if (!synced) {
    final sure =
        await confirmDeleteEventDialog(context, eventTitle: event.title);
    if (!sure || !context.mounted) return false;
    await ref.read(appDatabaseProvider).deleteEventCascade(event.id);
    return true;
  }

  final isOwner = remote.ownerDeviceId == DeviceIdentity.deviceId;
  final canDeleteForAll = isOwner || cloud.isAdmin;

  final action = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Excluir "${event.title}"?'),
      content: Text(
        canDeleteForAll
            ? 'Este evento está sincronizado na nuvem. Escolha o alcance: '
                'excluir para TODOS os celulares (dá para restaurar pelo '
                'histórico depois) ou remover apenas deste aparelho.'
            : 'Este evento é compartilhado. Só o dono ou um administrador '
                'pode excluí-lo para todos — você pode removê-lo apenas '
                'deste aparelho (os outros celulares não são afetados).',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(ctx, 'local'),
          child: const Text('Remover deste aparelho'),
        ),
        if (canDeleteForAll)
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, 'all'),
            child: const Text('Excluir para todos'),
          ),
      ],
    ),
  );
  if (action == null || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  try {
    if (action == 'all') {
      await ref.read(appDatabaseProvider).deleteEventCascade(event.id);
      messenger.showSnackBar(const SnackBar(
          content: Text(
              'Evento excluído para todos. Restauração: Backup na nuvem → Eventos excluídos.')));
    } else {
      await ref
          .read(cloudSyncControllerProvider.notifier)
          .leaveEventLocally(event.id);
      messenger.showSnackBar(const SnackBar(
          content:
              Text('Evento removido deste aparelho. Os demais não mudam.')));
    }
    return true;
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('$e')));
    return false;
  }
}
