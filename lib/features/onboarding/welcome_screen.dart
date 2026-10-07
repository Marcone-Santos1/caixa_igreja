import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/app_theme.dart';
import '../../providers/cloud_sync_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../events/qr_scanner_dialog.dart';
import 'church_setup.dart';

const kOnboardingDoneKey = 'onboarding.done';

/// Primeira abertura do app: cadastrar a igreja (vira administrador),
/// entrar com convite, recuperar administrador, ou seguir sem nuvem.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _busy = false;

  Future<void> _finish() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(kOnboardingDoneKey, true);
    if (mounted) context.go('/events');
  }

  Future<void> _run(Future<bool> Function() flow) async {
    setState(() => _busy = true);
    try {
      final ok = await flow();
      if (ok) await _finish();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _joinWithInvite() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerDialog()),
    );
    if (raw == null || !mounted) return false;
    final ok = await ref
        .read(cloudSyncControllerProvider.notifier)
        .pairWithToken(raw);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Convite inválido. Peça um novo no celular administrador.')));
    }
    return ok;
  }

  Future<bool> _joinWithPastedInvite() async {
    final ctrl = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Colar convite'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'caixa://cloud/…'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Entrar')),
        ],
      ),
    );
    if (token == null || !mounted) return false;
    final ok = await ref
        .read(cloudSyncControllerProvider.notifier)
        .pairWithToken(token);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Convite inválido ou expirado.')));
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/icon/app_icon.png',
                      height: 84, fit: BoxFit.contain),
                  const SizedBox(height: 16),
                  Text(
                    'Cantina Padroeira',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Caixa da cantina com passagem entre celulares pela nuvem. '
                    'Como você quer começar?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _busy
                        ? null
                        : () =>
                            _run(() => showCreateChurchFlow(context, ref)),
                    icon: const Icon(Icons.church_outlined),
                    label: const Text('Cadastrar minha igreja'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: CaixaAppTheme.marianBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _run(_joinWithInvite),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Entrar com convite (QR)'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => _run(_joinWithPastedInvite),
                    child: const Text('Colar convite'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () =>
                            _run(() => showRecoverAdminFlow(context, ref)),
                    child: const Text(
                        'Perdi o acesso — tenho o código de recuperação'),
                  ),
                  const Divider(height: 32),
                  TextButton.icon(
                    onPressed: _busy ? null : _finish,
                    icon: const Icon(Icons.wifi_off_outlined, size: 18),
                    label: const Text('Usar sem nuvem por enquanto'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Dá para ativar depois em Ajustes → Backup na nuvem.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
