import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/device_identity.dart';
import '../../providers/cloud_sync_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../services/cloud_backup_service.dart';

/// Fluxos de cadastro/recuperação da igreja, compartilhados entre o
/// onboarding (primeira abertura) e a tela Backup na nuvem.

/// Cadastra a igreja: nome da igreja + nome do aparelho → este celular vira
/// o administrador e recebe o CÓDIGO DE RECUPERAÇÃO (mostrado uma vez).
/// Retorna true se concluiu.
Future<bool> showCreateChurchFlow(BuildContext context, WidgetRef ref) async {
  final churchCtrl = TextEditingController();
  final deviceCtrl = TextEditingController(text: DeviceIdentity.deviceName);
  final endpointCtrl = TextEditingController();
  final needsEndpoint = kDefaultCloudEndpoint.isEmpty &&
      ref.read(cloudSyncControllerProvider).endpoint.isEmpty;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cadastrar igreja'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: churchCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome da igreja/cantina *',
                hintText: 'Ex: Paróquia N. Sra. Aparecida',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deviceCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome deste aparelho *',
                hintText: 'Ex: Celular do Marcone',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            if (needsEndpoint) ...[
              const SizedBox(height: 12),
              TextField(
                controller: endpointCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Endereço do servidor',
                  hintText: 'https://cantina-....workers.dev',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Cadastrar'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;

  final churchName = churchCtrl.text.trim();
  if (churchName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome à igreja/cantina.')));
    return false;
  }

  try {
    await DeviceIdentity.setDeviceName(
        ref.read(sharedPreferencesProvider), deviceCtrl.text);
    final recoveryCode =
        await ref.read(cloudSyncControllerProvider.notifier).activate(
              churchName: churchName,
              endpointOverride:
                  needsEndpoint ? endpointCtrl.text.trim() : null,
            );
    if (context.mounted && recoveryCode != null && recoveryCode.isNotEmpty) {
      await showRecoveryCodeDialog(context, recoveryCode, isNew: true);
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    return false;
  }
}

/// Mostra o código de recuperação UMA vez, com cópia e confirmação.
Future<void> showRecoveryCodeDialog(BuildContext context, String code,
    {bool isNew = false}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Código de recuperação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isNew
                ? 'Se este celular quebrar ou for perdido, este código '
                    'recupera o posto de administrador em outro aparelho. '
                    'Ele NÃO aparece de novo — guarde agora (papel, Drive…).'
                : 'O código anterior foi invalidado. Guarde este novo '
                    '(ele não aparece de novo).',
            style: Theme.of(ctx).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado.')));
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copiar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Guardei o código'),
        ),
      ],
    ),
  );
}

/// Pergunta o nome deste aparelho (antes de entrar com convite): é o nome
/// que os outros celulares veem. Retorna false se cancelado.
Future<bool> askDeviceName(BuildContext context, WidgetRef ref) async {
  final ctrl = TextEditingController(
    text: DeviceIdentity.deviceName == 'Este aparelho'
        ? ''
        : DeviceIdentity.deviceName,
  );
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nome deste aparelho'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Ex: Celular do Diogo',
          helperText: 'É assim que os outros celulares vão te ver.',
        ),
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuar')),
      ],
    ),
  );
  if (ok != true) return false;
  if (ctrl.text.trim().isNotEmpty) {
    await DeviceIdentity.setDeviceName(
        ref.read(sharedPreferencesProvider), ctrl.text);
  }
  return true;
}

/// "Perdi o acesso": recupera o posto de administrador neste aparelho com o
/// código da igreja + código de recuperação. Retorna true se concluiu.
Future<bool> showRecoverAdminFlow(BuildContext context, WidgetRef ref) async {
  final codeCtrl = TextEditingController();
  final recoveryCtrl = TextEditingController();
  final endpointCtrl = TextEditingController();
  final needsEndpoint = kDefaultCloudEndpoint.isEmpty &&
      ref.read(cloudSyncControllerProvider).endpoint.isEmpty;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Recuperar administrador'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Use o código de recuperação gerado no cadastro da igreja. '
              'Ele é de uso único: depois, gere um novo em Avançado.',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Código da igreja *',
                hintText: 'ig…  (está em Avançado no outro aparelho)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: recoveryCtrl,
              decoration: const InputDecoration(
                labelText: 'Código de recuperação *',
                hintText: 'XXXX-XXXX-XXXX-XXXX',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            if (needsEndpoint) ...[
              const SizedBox(height: 12),
              TextField(
                controller: endpointCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Endereço do servidor',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Recuperar'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return false;

  try {
    await ref.read(cloudSyncControllerProvider.notifier).recoverAdmin(
          churchCode: codeCtrl.text,
          recoveryCode: recoveryCtrl.text,
          endpointOverride: needsEndpoint ? endpointCtrl.text.trim() : null,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Administrador recuperado! Gere um novo código de recuperação em Avançado.')));
    }
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    return false;
  }
}
