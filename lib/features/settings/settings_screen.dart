import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../data/database_backup.dart';
import '../../data/database_seeder.dart';
import '../../providers/database_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _backupBusy = false;
  bool _seederBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: kCaixaScreenPadding.copyWith(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 110,
                  width: 110,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  'Comunidade Nossa Senhora Aparecida',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cantina e PDV',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.print_outlined),
                  title: const Text('Impressora Térmica'),
                  subtitle: const Text('Bluetooth 58mm (ESC/POS)'),
                  onTap: () => context.push('/settings/printer'),
                ),
                const Divider(height: 1),
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
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dados de Teste e Demonstração',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Popule o banco com eventos simulados (Festa Junina com histórico '
                    'de vendas e fichas, Bazar Beneficente e Almoço Comunitário pronto '
                    'para iniciar vendas no caixa), facilitando testes do sistema.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: (_backupBusy || _seederBusy) ? null : _handleSeedData,
                    icon: _seederBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.dataset_outlined),
                    label: const Text('Popular dados de teste (Seeder)'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: (_backupBusy || _seederBusy) ? null : _handleClearAllData,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                      ),
                    ),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Limpar todos os dados'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSeedData() async {
    final mode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Popular dados de teste'),
        content: const Text(
          'Deseja limpar os dados atuais antes de gerar os exemplos ou '
          'apenas adicionar os eventos de demonstração aos dados já existentes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancelar'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, 'append'),
            child: const Text('Apenas adicionar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'clean_and_seed'),
            child: const Text('Limpar e popular'),
          ),
        ],
      ),
    );

    if (mode == null || mode == 'cancel' || !mounted) return;

    setState(() => _seederBusy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final seeder = DatabaseSeeder(db);
      final clearExisting = mode == 'clean_and_seed';
      final res = await seeder.seedAll(clearExisting: clearExisting);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dados carregados: ${res.eventsCount} eventos, '
            '${res.productsCount} produtos e ${res.salesCount} vendas.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao popular dados: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _seederBusy = false);
    }
  }

  Future<void> _handleClearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar todos os dados?'),
        content: const Text(
          'Esta ação excluirá permanentemente todos os eventos, produtos, '
          'fichas e vendas gravados no dispositivo. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim, apagar tudo'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _seederBusy = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final seeder = DatabaseSeeder(db);
      await seeder.clearAll();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os dados foram excluídos com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao limpar dados: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _seederBusy = false);
    }
  }
}

