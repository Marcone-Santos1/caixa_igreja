import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../data/database_backup.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _backupBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: kCaixaScreenPadding.copyWith(bottom: 32),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Segurança'),
                  subtitle: const Text('PIN no arranque da app'),
                  onTap: () => context.push('/settings/security'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Aparência'),
                  subtitle: const Text('Claro, escuro ou sistema'),
                  onTap: () => context.push('/settings/appearance'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Base de dados (SQLite)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exportar cria uma cópia do ficheiro local. Restaurar substitui '
                    'toda a base atual; em caso de erro ou dados inconsistentes, '
                    'feche e reabra a app.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _backupBusy
                        ? null
                        : () async {
                            setState(() => _backupBusy = true);
                            try {
                              final r = await exportDatabaseBackup();
                              if (!context.mounted) return;
                              if (r.userCancelled) return;
                              if (r.errorMessage != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(r.errorMessage!)),
                                );
                              } else if (r.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cópia da base guardada na pasta escolhida.',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _backupBusy = false);
                            }
                          },
                    icon: _backupBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_alt_outlined),
                    label: const Text('Exportar cópia da base'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _backupBusy
                        ? null
                        : () async {
                            final go = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Restaurar base?'),
                                content: const Text(
                                  'Todos os dados atuais serão substituídos pela '
                                  'cópia selecionada. Faça um backup antes, se precisar.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Continuar'),
                                  ),
                                ],
                              ),
                            );
                            if (go != true || !context.mounted) return;
                            setState(() => _backupBusy = true);
                            try {
                              final err = await restoreDatabaseBackup(ref);
                              if (!context.mounted) return;
                              if (err == null) return;
                              if (err.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Base restaurada. Se algo falhar, feche e reabra a app.',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _backupBusy = false);
                            }
                          },
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('Restaurar a partir de cópia…'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
