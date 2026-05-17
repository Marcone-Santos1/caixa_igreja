import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';
import 'combo_form_screen.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos do evento')),
      body: StreamBuilder<List<ChurchProduct>>(
        stream: db.watchAllProductsForEvent(eventId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          final list = snapshot.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
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
                    final err = await ref
                        .read(appDatabaseProvider)
                        .deleteProduct(eventId: eventId, productId: p.id);
                    if (!context.mounted) return;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
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
