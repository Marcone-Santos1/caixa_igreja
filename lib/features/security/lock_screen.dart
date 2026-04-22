import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../providers/pin_lock_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _pinController.text;
    final ok = ref.read(pinLockServiceProvider).verifyPin(pin);
    if (!ok) {
      setState(() {
        _error = 'PIN incorreto';
        _pinController.clear();
      });
      return;
    }
    ref.read(appUnlockedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: kCaixaScreenPadding.copyWith(top: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline_rounded, size: 56, color: scheme.primary),
              const SizedBox(height: 20),
              Text(
                'Caixa Igreja',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Introduza o PIN para continuar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 8,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'PIN',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                child: const Text('Desbloquear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
