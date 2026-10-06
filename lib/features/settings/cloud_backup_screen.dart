import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/device_identity.dart';
import '../../providers/cloud_sync_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../services/cloud_backup_service.dart';
import '../events/event_cloud_sheet.dart';
import '../events/qr_scanner_dialog.dart';

/// Tela "Backup na nuvem" (RFC v2): ativação de 1 toque, pareamento por QR e
/// visão geral dos eventos sincronizados. As ações de cada evento ficam no
/// painel do evento (☁️ no hub ou toque na lista daqui).
class CloudBackupScreen extends ConsumerStatefulWidget {
  const CloudBackupScreen({super.key});

  @override
  ConsumerState<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends ConsumerState<CloudBackupScreen> {
  bool _working = false;

  String _fmtWhen(DateTime? dt) =>
      dt == null ? '—' : DateFormat('dd/MM HH:mm').format(dt.toLocal());

  Future<void> _activate() async {
    final controller = ref.read(cloudSyncControllerProvider.notifier);
    String? endpoint;
    final stored = ref.read(cloudSyncControllerProvider).endpoint;
    if (kDefaultCloudEndpoint.isEmpty && stored.isEmpty) {
      endpoint = await _askEndpoint();
      if (endpoint == null || endpoint.trim().isEmpty) return;
    } else if (kDefaultCloudEndpoint.isEmpty) {
      endpoint = stored;
    }
    setState(() => _working = true);
    try {
      await controller.activate(endpointOverride: endpoint);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Backup ativado! Use "Parear outro celular" nos demais aparelhos.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<String?> _askEndpoint() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Endereço do servidor'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://cantina-....workers.dev',
            helperText: 'Pedido só uma vez; o QR leva aos outros celulares.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanToPair() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerDialog()),
    );
    if (raw == null || !mounted) return;
    await _pairWith(raw);
  }

  Future<void> _pasteToPair() async {
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Colar código de pareamento'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'caixa://cloud/…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
    if (token == null || !mounted) return;
    await _pairWith(token);
  }

  Future<void> _pairWith(String token) async {
    setState(() => _working = true);
    try {
      final ok = await ref
          .read(cloudSyncControllerProvider.notifier)
          .pairWithToken(token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(ok
                ? 'Conectado! Os eventos da nuvem aparecem abaixo.'
                : 'Código inválido. Escaneie o QR do celular já configurado.')),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  /// Gera um CONVITE de uso único no servidor e mostra o QR (admin).
  Future<void> _showPairingQr() async {
    setState(() => _working = true);
    String? token;
    try {
      final invite =
          await ref.read(cloudSyncControllerProvider.notifier).createInvite();
      token = invite.encode();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
    if (token == null || !mounted) return;
    final qrToken = token;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Convidar outro celular'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: QrImageView(data: qrToken),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Convite de uso único (vale 48h). No outro celular: '
              'Ajustes → Backup na nuvem → "Conectar com QR".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: qrToken));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Convite copiado.')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copiar convite'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cloudSyncControllerProvider);
    final controller = ref.read(cloudSyncControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Backup na nuvem'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!state.configured)
            _ActivationCard(
              working: _working,
              onActivate: _activate,
              onScan: _scanToPair,
              onPaste: _pasteToPair,
            )
          else ...[
            _OverviewCard(state: state, fmtWhen: _fmtWhen),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        state.busy ? null : () => controller.refreshAll(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Verificar agora'),
                  ),
                ),
                if (state.isAdmin) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _working || state.busy ? null : _showPairingQr,
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Convidar celular'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _EventsCard(state: state, fmtWhen: _fmtWhen),
            const SizedBox(height: 16),
            _AdvancedCard(state: state),
          ],
          const SizedBox(height: 8),
          Text(
            'Cada evento é sincronizado separadamente: quem operar o caixa na '
            'semana seguinte abre o app e recebe o evento atualizado. Com '
            'novidades dos dois lados, o app pergunta — nada é sobrescrito em '
            'silêncio, e as versões anteriores ficam no histórico.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivationCard extends StatelessWidget {
  const _ActivationCard({
    required this.working,
    required this.onActivate,
    required this.onScan,
    required this.onPaste,
  });

  final bool working;
  final VoidCallback onActivate;
  final VoidCallback onScan;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.cloud_outlined,
                size: 44, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'Passagem de caixa entre celulares',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Os eventos ficam guardados na nuvem da igreja. Ative uma vez '
              'aqui e conecte os outros celulares com um QR.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: working ? null : onActivate,
              icon: working
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_done_outlined),
              label: const Text('Ativar backup na nuvem'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: working ? null : onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Conectar com QR de outro celular'),
            ),
            TextButton(
              onPressed: working ? null : onPaste,
              child: const Text('Colar código de pareamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.state, required this.fmtWhen});

  final CloudSyncState state;
  final String Function(DateTime?) fmtWhen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attention = state.anyAttention;
    return Card(
      child: ListTile(
        leading: Icon(
          attention
              ? Icons.warning_amber_outlined
              : state.busy
                  ? Icons.cloud_sync_outlined
                  : Icons.cloud_done_outlined,
          color: attention
              ? theme.colorScheme.error
              : state.busy
                  ? theme.colorScheme.primary
                  : Colors.green,
          size: 30,
        ),
        title: Text(
          attention
              ? 'Algum evento precisa de atenção'
              : state.busy
                  ? 'Sincronizando…'
                  : 'Backup ativo',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Igreja: ${state.churchCode} · Aparelho: ${DeviceIdentity.deviceName}\n'
          'Última verificação: ${fmtWhen(state.lastCheckedAt)}'
          '${state.globalMessage != null ? '\n${state.globalMessage}' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _EventsCard extends StatelessWidget {
  const _EventsCard({required this.state, required this.fmtWhen});

  final CloudSyncState state;
  final String Function(DateTime?) fmtWhen;

  (IconData, Color) _visual(BuildContext context, CloudEventStatus s) {
    final scheme = Theme.of(context).colorScheme;
    return switch (s.phase) {
      CloudEventPhase.upToDate => (Icons.cloud_done_outlined, Colors.green),
      CloudEventPhase.uploading ||
      CloudEventPhase.downloading =>
        (Icons.cloud_sync_outlined, scheme.primary),
      CloudEventPhase.pendingUpload ||
      CloudEventPhase.updateAvailable =>
        (Icons.cloud_outlined, scheme.primary),
      CloudEventPhase.cloudOnly =>
        (Icons.cloud_download_outlined, scheme.primary),
      CloudEventPhase.paused =>
        (Icons.pause_circle_outline, scheme.onSurfaceVariant),
      _ => (Icons.warning_amber_outlined, scheme.error),
    };
  }

  String _subtitle(CloudEventStatus s) {
    final remote = s.remote;
    final remoteTxt = remote == null || remote.isEmpty
        ? 'nunca enviado'
        : 'v${remote.version} · ${remote.deviceName ?? '?'} · ${fmtWhen(remote.uploadedAt)}';
    return switch (s.phase) {
      CloudEventPhase.cloudOnly => s.sharedWithMe
          ? 'Na nuvem: $remoteTxt — toque para baixar'
          : 'Backup privado de outro aparelho · $remoteTxt',
      CloudEventPhase.divergence => 'Divergência — toque para resolver',
      CloudEventPhase.paused => 'Sincronização pausada neste aparelho',
      CloudEventPhase.blockedSchema => 'Atualize o app para sincronizar',
      CloudEventPhase.error => s.message ?? 'Falha — toque para detalhes',
      _ => 'Nuvem: $remoteTxt',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events = state.events.values.toList()
      ..sort((a, b) => (b.eventDateMs ?? 0).compareTo(a.eventDateMs ?? 0));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eventos',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhum evento ainda. Crie um evento ou aguarde a primeira '
                  'verificação.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            for (final s in events)
              Builder(builder: (context) {
                final (icon, color) = _visual(context, s);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(icon, color: color),
                  title: Text(s.title),
                  subtitle: Text(_subtitle(s)),
                  onTap: () => showEventCloudSheet(context, s.eventId),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _AdvancedCard extends ConsumerWidget {
  const _AdvancedCard({required this.state});

  final CloudSyncState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(cloudSyncControllerProvider.notifier);
    return Card(
      child: ExpansionTile(
        title: const Text('Avançado'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Servidor: ${state.endpoint}\nCódigo da igreja: ${state.churchCode}'
              '\nEste celular: ${state.isAdmin ? 'administrador' : 'membro'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
          if (state.devices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Celulares da igreja',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            for (final d in state.devices)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  d.revoked
                      ? Icons.phonelink_erase
                      : d.isAdmin
                          ? Icons.admin_panel_settings_outlined
                          : Icons.phone_android,
                  size: 20,
                  color: d.revoked ? theme.colorScheme.error : null,
                ),
                title: Text(
                  '${d.name}${d.deviceId == DeviceIdentity.deviceId ? ' (este)' : ''}',
                ),
                subtitle: Text(
                  d.revoked
                      ? 'Acesso revogado'
                      : d.isAdmin
                          ? 'Administrador'
                          : 'Membro',
                ),
                trailing: state.isAdmin && d.deviceId != DeviceIdentity.deviceId
                    ? PopupMenuButton<String>(
                        onSelected: (action) {
                          switch (action) {
                            case 'revoke':
                              controller.setDeviceRevoked(d.deviceId, true);
                            case 'restore':
                              controller.setDeviceRevoked(d.deviceId, false);
                            case 'promote':
                              controller.setDeviceRole(d.deviceId, 'admin');
                            case 'demote':
                              controller.setDeviceRole(d.deviceId, 'member');
                          }
                        },
                        itemBuilder: (_) => [
                          if (!d.revoked)
                            const PopupMenuItem(
                              value: 'revoke',
                              child: Text('Revogar acesso'),
                            )
                          else
                            const PopupMenuItem(
                              value: 'restore',
                              child: Text('Restaurar acesso'),
                            ),
                          if (!d.isAdmin)
                            const PopupMenuItem(
                              value: 'promote',
                              child: Text('Tornar administrador'),
                            )
                          else
                            const PopupMenuItem(
                              value: 'demote',
                              child: Text('Tornar membro'),
                            ),
                        ],
                      )
                    : null,
              ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final controller =
                  TextEditingController(text: DeviceIdentity.deviceName);
              final name = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Nome deste aparelho'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration:
                        const InputDecoration(hintText: 'Celular do Marcone'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, controller.text),
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              );
              if (name != null && name.trim().isNotEmpty) {
                await DeviceIdentity.setDeviceName(
                    ref.read(sharedPreferencesProvider), name);
              }
            },
            icon: const Icon(Icons.phone_android),
            label: Text('Nome do aparelho: ${DeviceIdentity.deviceName}'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () async {
              final go = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Desconectar deste aparelho?'),
                  content: const Text(
                    'O backup na nuvem para de sincronizar NESTE celular. '
                    'Nada é apagado na nuvem nem nos outros aparelhos.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Desconectar'),
                    ),
                  ],
                ),
              );
              if (go == true) {
                await ref
                    .read(cloudSyncControllerProvider.notifier)
                    .disconnect();
              }
            },
            icon: const Icon(Icons.link_off),
            label: const Text('Desconectar deste aparelho'),
          ),
        ],
      ),
    );
  }
}
