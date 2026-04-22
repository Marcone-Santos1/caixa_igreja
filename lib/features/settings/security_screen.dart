import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/pin_lock_provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _newPin = TextEditingController();
  final _confirm = TextEditingController();
  final _oldPin = TextEditingController();
  String? _msg;
  bool _busy = false;

  @override
  void dispose() {
    _newPin.dispose();
    _confirm.dispose();
    _oldPin.dispose();
    super.dispose();
  }

  Future<void> _saveNewPin() async {
    setState(() {
      _msg = null;
      _busy = true;
    });
    try {
      final a = _newPin.text.trim();
      final b = _confirm.text.trim();
      if (a.length < 4) {
        setState(() => _msg = 'Use pelo menos 4 dígitos.');
        return;
      }
      if (a != b) {
        setState(() => _msg = 'Confirmação não coincide.');
        return;
      }
      if (ref.read(hasPinConfiguredProvider)) {
        final old = _oldPin.text.trim();
        if (!ref.read(pinLockServiceProvider).verifyPin(old)) {
          setState(() => _msg = 'PIN atual incorreto.');
          return;
        }
      }
      await ref.read(pinLockServiceProvider).setPin(a);
      ref.read(pinSettingsRevisionProvider.notifier).state++;
      ref.read(appUnlockedProvider.notifier).state = true;
      if (mounted) {
        _newPin.clear();
        _confirm.clear();
        _oldPin.clear();
        setState(() => _msg = 'PIN guardado. Será pedido no próximo arranque.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removePin() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover PIN?'),
        content: const Text(
          'Qualquer pessoa com acesso ao dispositivo poderá abrir a app sem PIN.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (ref.read(hasPinConfiguredProvider)) {
      final old = _oldPin.text.trim();
      if (!ref.read(pinLockServiceProvider).verifyPin(old)) {
        setState(() => _msg = 'PIN atual incorreto.');
        return;
      }
    }
    setState(() => _busy = true);
    try {
      await ref.read(pinLockServiceProvider).clearPin();
      ref.read(pinSettingsRevisionProvider.notifier).state++;
      ref.read(appUnlockedProvider.notifier).state = true;
      if (mounted) setState(() => _msg = 'PIN desactivado.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPin = ref.watch(hasPinConfiguredProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Segurança'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'PIN opcional',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'No arranque da app, será pedido o PIN se estiver definido. O PIN '
            'não é guardado em texto claro.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 24),
          if (hasPin) ...[
            TextField(
              controller: _oldPin,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'PIN atual'),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _newPin,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: hasPin ? 'Novo PIN' : 'PIN',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Confirmar PIN'),
          ),
          if (_msg != null) ...[
            const SizedBox(height: 16),
            Text(
              _msg!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _saveNewPin,
            child: Text(_busy ? 'A guardar…' : (hasPin ? 'Alterar PIN' : 'Activar PIN')),
          ),
          if (hasPin) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _removePin,
              child: const Text('Desactivar PIN'),
            ),
          ],
        ],
      ),
    );
  }
}
