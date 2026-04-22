import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_mode_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Aparência'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          Text(
            'Tema da interface',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          ListTile(
            leading: const Icon(Icons.brightness_auto_outlined),
            title: const Text('Sistema'),
            subtitle: const Text('Segue o modo claro/escuro do dispositivo'),
            trailing: mode == ThemeMode.system
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
          ListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text('Claro'),
            trailing: mode == ThemeMode.light
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Escuro'),
            trailing: mode == ThemeMode.dark
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () =>
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}
