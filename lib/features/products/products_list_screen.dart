import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/ui_kit.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';
import '../../providers/event_dashboard_provider.dart';
import '../../providers/sync_provider.dart';
import 'combo_form_screen.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final isClient = syncState.mode == SyncMode.client && syncState.isConnected;
    final productsAsync = ref.watch(eventProductsStreamProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Produtos do evento')),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (list) {
          if (list.isEmpty) {
            return const CaixaEmptyHint(
              icon: Icons.inventory_2_outlined,
              message: 'Nenhum produto',
              detail: 'Toque em + para cadastrar.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 2),
            itemBuilder: (context, i) {
              final p = list[i];
              final stock = p.trackStock ? '${p.stockQty} un.' : 'Sem controle';
              final title = p.isCombo ? '📦 ${p.name} (COMBO)' : p.name;
              return CaixaListRow(
                title: title,
                subtitle:
                    '${formatCents(p.priceCents)} · $stock${p.active ? '' : ' · Inativo'}',
                onTap: () async {
                  if (p.isCombo) {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => ComboFormScreen(
                          eventId: eventId,
                          comboProductId: p.id,
                        ),
                      ),
                    );
                  } else {
                    await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => ProductFormScreen(
                          eventId: eventId,
                          productId: p.id,
                        ),
                      ),
                    );
                  }
                },
                trailing: IconButton(
                  tooltip: 'Excluir',
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Excluir produto?'),
                        content: Text('Remover "${p.name}" deste evento?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(ctx).colorScheme.error,
                              foregroundColor:
                                  Theme.of(ctx).colorScheme.onError,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true || !context.mounted) return;
                    
                    try {
                      if (isClient) {
                        await ref.read(syncProvider.notifier).deleteProductOnHost(eventId, p.id);
                        // Re-sync: puxa os dados atualizados do host imediatamente
                        await ref.read(syncProvider.notifier).refreshAllClientCaches(eventId);
                      } else {
                        final err = await ref
                            .read(appDatabaseProvider)
                            .deleteProduct(eventId: eventId, productId: p.id);
                        if (err != null) throw StateError(err);
                        // Se for o host, avisa os clientes conectados
                        if (ref.read(syncProvider).mode == SyncMode.server) {
                          ref.read(syncProvider.notifier).broadcastRefresh();
                        }
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Produto excluído com sucesso')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao excluir: $e')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: PopupMenuButton<int>(
        tooltip: 'Adicionar',
        onSelected: (val) async {
          if (val == 0) {
            await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => ProductFormScreen(eventId: eventId)),
            );
          } else {
            await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => ComboFormScreen(eventId: eventId)),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 0,
            child: Row(children: [Icon(Icons.fastfood, size: 20), SizedBox(width: 12), Text('Novo Produto')]),
          ),
          const PopupMenuItem(
            value: 1,
            child: Row(children: [Icon(Icons.layers, size: 20), SizedBox(width: 12), Text('Novo Combo')]),
          ),
        ],
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: kElevationToShadow[3],
          ),
          child: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}
