import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/event_detail_provider.dart';
import '../../providers/sync_provider.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  bool _showManualInput = false;

  @override
  void initState() {
    super.initState();
    final syncState = ref.read(syncProvider);
    _ipController.text = syncState.serverIp ?? '';
    _portController.text = syncState.serverPort.toString();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final scheme = Theme.of(context).colorScheme;

    final event = eventAsync.valueOrNull;
    String? connectionToken;
    if (event != null && syncState.serverIp != null) {
      final payload = {
        'ip': syncState.serverIp,
        'port': syncState.serverPort,
        'eventId': event.id,
        'eventTitle': event.title,
        'eventDate': event.dateEpochMs,
        'eventNotes': event.notes,
      };
      connectionToken = base64Encode(utf8.encode(jsonEncode(payload)));
    }

    final eventTitle = eventAsync.maybeWhen(
      data: (e) => e?.title ?? 'Evento #${widget.eventId}',
      orElse: () => 'Evento #${widget.eventId}',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Sincronização Local'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Header info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wifi_off_outlined, color: scheme.primary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Conexão Multi-dispositivos',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Permite que outros celulares se conectem a este aparelho para registrar vendas simultâneas em tempo real usando a mesma rede Wi-Fi, mesmo sem internet.',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Device Mode Selection Header
          Text(
            'Escolha o modo deste aparelho',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // 1. STANDALONE CARD
          _buildModeCard(
            context: context,
            title: 'Caixa Autônomo (Padrão)',
            description: 'Salva todas as vendas e dados localmente apenas neste celular. Funciona de forma independente.',
            icon: Icons.phone_android_outlined,
            isSelected: syncState.mode == SyncMode.standalone,
            onTap: () {
              ref.read(syncProvider.notifier).stopAll();
            },
          ),
          const SizedBox(height: 10),

          // 2. SERVER (HOST) CARD
          _buildModeCard(
            context: context,
            title: 'Caixa Central (Servidor / Host)',
            description: 'Transforma este celular no banco de dados master. Aceita conexões e recebe as vendas dos outros caixas.',
            icon: Icons.dns_outlined,
            isSelected: syncState.mode == SyncMode.server,
            onTap: () {
              ref.read(syncProvider.notifier).startServer(widget.eventId, eventTitle);
            },
            extraContent: syncState.mode == SyncMode.server
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Servidor Ativo e Transmitindo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('IP do Servidor: ${syncState.serverIp}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                          Text('Porta: ${syncState.serverPort}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                          const Divider(),
                          Text(
                            'Terminais Conectados: ${syncState.connectedClients.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          if (syncState.connectedClients.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            ...syncState.connectedClients.map((clientIp) => Padding(
                                  padding: const EdgeInsets.only(left: 10, top: 2),
                                  child: Text('• $clientIp', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
                                )),
                          ],
                          if (connectionToken != null) ...[
                            const Divider(),
                            const Text(
                              'Conectar novos caixas',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Peça para o outro aparelho ler o QR code abaixo ou colar o token de conexão.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: QrImageView(
                                  data: 'caixa://connect/$connectionToken',
                                  version: QrVersions.auto,
                                  size: 160.0,
                                ),
                              ),
                            ),
                            Center(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: 'caixa://connect/$connectionToken'));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Token de conexão copiado!')),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded, size: 16),
                                label: const Text('Copiar token de conexão', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 10),

          // 3. CLIENT (TERMINAL) CARD
          _buildModeCard(
            context: context,
            title: 'Terminal de Vendas (Cliente / Terminal)',
            description: 'Conecta-se à Caixa Central via rede local. Ideal para operadores adicionais.',
            icon: Icons.point_of_sale_outlined,
            isSelected: syncState.mode == SyncMode.client,
            onTap: () {
              // Set mode to client but don't connect automatically
              ref.read(syncProvider.notifier).setClientMode();
            },
            extraContent: syncState.mode == SyncMode.client
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (syncState.isConnected) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.cloud_done_outlined, color: Colors.green),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Conectado ao Caixa Central', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                                      Text('IP: ${syncState.serverIp}:${syncState.serverPort}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(syncProvider.notifier).setClientMode();
                                  },
                                  child: const Text('Desconectar', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          'Servidores Disponíveis na Rede (Busca Automática)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: scheme.primary, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        if (syncState.discoveredServers.isEmpty && !syncState.isConnected)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                                SizedBox(width: 12),
                                Text('Procurando servidores automaticamente...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          )
                        else
                          ...syncState.discoveredServers.map((server) {
                            final sIp = server['ip'] as String;
                            final sPort = server['port'] as int;
                            final sTitle = server['eventTitle'] as String;
                            final sEventId = server['eventId'] as String;
                            final isCurrent = syncState.isConnected && syncState.serverIp == sIp;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: scheme.outlineVariant),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.dns_outlined, color: isCurrent ? Colors.green : scheme.primary),
                                title: Text(sTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text('$sIp:$sPort', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                                trailing: isCurrent
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : ElevatedButton(
                                        onPressed: () {
                                          ref.read(syncProvider.notifier).connectToHost(sIp, sPort, sEventId);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                        ),
                                        child: const Text('Conectar', style: TextStyle(fontSize: 12)),
                                      ),
                              ),
                            );
                          }),

                        const Divider(height: 24),
                        // Expandable manual fallback
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showManualInput = !_showManualInput;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Conexão Manual (Fallback)',
                                style: TextStyle(fontWeight: FontWeight.bold, color: scheme.onSurfaceVariant, fontSize: 12),
                              ),
                              Icon(_showManualInput ? Icons.expand_less : Icons.expand_more, size: 20),
                            ],
                          ),
                        ),
                        if (_showManualInput) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _ipController,
                                  decoration: const InputDecoration(
                                    labelText: 'IP do Servidor',
                                    hintText: 'ex: 192.168.1.50',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: _portController,
                                  decoration: const InputDecoration(
                                    labelText: 'Porta',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  final ip = _ipController.text.trim();
                                  final port = int.tryParse(_portController.text.trim()) ?? 8080;
                                  if (ip.isNotEmpty) {
                                    ref.read(syncProvider.notifier).connectToHost(ip, port, widget.eventId);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  )
                : null,
          ),

          // Error block display
          if (syncState.error != null) ...[
            const SizedBox(height: 16),
            Card(
              color: scheme.errorContainer,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: scheme.error, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: scheme.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        syncState.error!,
                        style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Widget? extraContent,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: isSelected ? scheme.primaryContainer.withValues(alpha: 0.15) : null,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? scheme.primary : scheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: isSelected ? scheme.primary : scheme.onSurfaceVariant, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? scheme.primary : null,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.radio_button_checked, color: scheme.primary)
                  else
                    Icon(Icons.radio_button_off, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
                ],
              ),
              ?extraContent,
            ],
          ),
        ),
      ),
    );
  }
}
