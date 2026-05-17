import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';
import 'package:drift/drift.dart' hide Column;

class ComboFormScreen extends ConsumerStatefulWidget {
  final int eventId;
  final int? comboProductId;

  const ComboFormScreen({super.key, required this.eventId, this.comboProductId});

  @override
  ConsumerState<ComboFormScreen> createState() => _ComboFormScreenState();
}

class _ComboFormScreenState extends ConsumerState<ComboFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _active = true;
  bool _isLoading = true;

  // Map of productId -> quantity in combo
  final Map<int, int> _comboItems = {};
  List<ChurchProduct> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(appDatabaseProvider);
    
    // Carrega apenas produtos (exclui combos) para o usuário poder montar o combo
    final products = await (db.select(db.products)
          ..where((t) => t.eventId.equals(widget.eventId))
          ..where((t) => t.isCombo.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    
    if (widget.comboProductId != null) {
      final p = await (db.select(db.products)..where((t) => t.id.equals(widget.comboProductId!))).getSingleOrNull();
      if (p != null) {
        _nameCtrl.text = p.name;
        _descCtrl.text = p.description;
        _priceCtrl.text = (p.priceCents / 100).toStringAsFixed(2).replaceAll('.', ',');
        _active = p.active;

        final items = await db.getComboItems(p.id);
        for (final item in items) {
          _comboItems[item.childProductId] = item.qty;
        }
      }
    }

    if (mounted) {
      setState(() {
        _availableProducts = products;
        _isLoading = false;
      });
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_comboItems.isEmpty || _comboItems.values.every((q) => q <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um produto ao combo')),
      );
      return;
    }

    final valStr = _priceCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    final priceCents = int.tryParse(valStr) ?? 0;

    final db = ref.read(appDatabaseProvider);
    final itemsList = _comboItems.entries
        .where((e) => e.value > 0)
        .map((e) => (childProductId: e.key, qty: e.value))
        .toList();

    if (widget.comboProductId == null) {
      await db.createCombo(
        eventId: widget.eventId,
        name: _nameCtrl.text.trim(),
        priceCents: priceCents,
        description: _descCtrl.text.trim(),
        active: _active,
        items: itemsList,
      );
    } else {
      await db.updateCombo(
        comboProductId: widget.comboProductId!,
        name: _nameCtrl.text.trim(),
        priceCents: priceCents,
        description: _descCtrl.text.trim(),
        active: _active,
        items: itemsList,
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comboProductId == null ? 'Novo Combo' : 'Editar Combo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome do Combo *', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Preço Fixo do Combo (R\$) *', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição / Observação (Opcional)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Combo Ativo'),
              subtitle: const Text('Aparece na tela de vendas'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 32),
            const Text('Produtos Inclusos no Combo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_availableProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhum produto cadastrado no evento ainda.'),
              ),
            ..._availableProducts.map((p) {
              final qty = _comboItems[p.id] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(formatCents(p.priceCents), style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: qty > 0 ? () => setState(() => _comboItems[p.id] = qty - 1) : null,
                          ),
                          Text(qty.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() => _comboItems[p.id] = qty + 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
