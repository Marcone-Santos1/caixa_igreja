import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';
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
              return CaixaListRow(
                title: p.name,
                subtitle:
                    '${formatCents(p.priceCents)} · $stock${p.active ? '' : ' · Inativo'}',
                onTap: () async {
                  await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(
                        eventId: eventId,
                        productId: p.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'fab_products_list',
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ProductFormScreen(eventId: eventId),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
