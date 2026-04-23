import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_theme.dart';
import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, required this.eventId, this.productId});

  final int eventId;
  final int? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  bool _trackStock = false;
  bool _active = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _description = TextEditingController();
    _price = TextEditingController();
    _stock = TextEditingController(text: '0');
    _load();
  }

  Future<void> _load() async {
    final id = widget.productId;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final db = ref.read(appDatabaseProvider);
    final p = await (db.select(db.products)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.eventId.equals(widget.eventId)))
        .getSingleOrNull();
    if (!mounted) return;
    if (p == null) {
      setState(() => _loading = false);
      return;
    }
    _name.text = p.name;
    _description.text = p.description;
    _price.text = (p.priceCents / 100).toStringAsFixed(2).replaceAll('.', ',');
    _stock.text = p.stockQty.toString();
    _trackStock = p.trackStock;
    _active = p.active;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final priceCents = parseMoneyToCents(_price.text);
    if (priceCents == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preço inválido')),
      );
      return;
    }
    var stock = int.tryParse(_stock.text.trim()) ?? 0;
    if (stock < 0) stock = 0;

    final db = ref.read(appDatabaseProvider);
    final id = widget.productId;
    if (id == null) {
      await db.into(db.products).insert(
            ProductsCompanion.insert(
              eventId: widget.eventId,
              name: _name.text.trim(),
              description: Value(_description.text.trim()),
              priceCents: priceCents,
              trackStock: Value(_trackStock),
              stockQty: Value(_trackStock ? stock : 0),
              active: Value(_active),
            ),
          );
    } else {
      await (db.update(db.products)
            ..where((t) => t.id.equals(id))
            ..where((t) => t.eventId.equals(widget.eventId)))
          .write(
            ProductsCompanion(
              name: Value(_name.text.trim()),
              description: Value(_description.text.trim()),
              priceCents: Value(priceCents),
              trackStock: Value(_trackStock),
              stockQty: Value(_trackStock ? stock : 0),
              active: Value(_active),
            ),
          );
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _confirmDelete() async {
    final id = widget.productId;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: const Text(
          'O produto será removido do catálogo deste evento. '
          'Não é possível excluir se já tiver sido vendido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final db = ref.read(appDatabaseProvider);
    final err = await db.deleteProduct(eventId: widget.eventId, productId: id);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isEdit = widget.productId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar produto' : 'Novo produto'),
        actions: [
          if (isEdit)
            IconButton(
              tooltip: 'Excluir produto',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: kCaixaScreenPadding.copyWith(bottom: 32),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nome',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(
                labelText: 'Preço (ex: 5,00)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Controlar estoque'),
              value: _trackStock,
              onChanged: (v) => setState(() => _trackStock = v),
            ),
            if (_trackStock)
              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(
                  labelText: 'Quantidade em estoque',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            SwitchListTile(
              title: const Text('Ativo no PDV'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
