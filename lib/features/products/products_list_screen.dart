import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends ConsumerWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: StreamBuilder<List<ChurchProduct>>(
        stream: db.watchAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final list = snapshot.data;
          if (list == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (list.isEmpty) {
            return const Center(
              child: Text('Nenhum produto. Toque em + para cadastrar.'),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = list[i];
              final stock = p.trackStock ? '${p.stockQty} un.' : 'Sem controle';
              return ListTile(
                title: Text(p.name),
                subtitle: Text(
                  '${formatCents(p.priceCents)} · $stock${p.active ? '' : ' · Inativo'}',
                ),
                isThreeLine: true,
                onTap: () async {
                  await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ProductFormScreen(productId: p.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_products_list',
        onPressed: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
