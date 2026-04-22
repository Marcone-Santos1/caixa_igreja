import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database.dart';
import '../../data/sale_line_draft.dart';
import '../../domain/payment_method.dart';
import '../../providers/database_provider.dart';
import '../../utils/money_format.dart';

class _FreeLine {
  _FreeLine({required this.label, required this.cents});
  final String label;
  final int cents;
}

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key, required this.eventId});

  final int eventId;

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  final Map<int, int> _productQty = {};
  final Map<int, int> _fichaQty = {};
  final List<_FreeLine> _freeLines = [];

  int _totalCents(
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
  ) {
    var t = 0;
    for (final p in products) {
      final q = _productQty[p.id] ?? 0;
      if (q > 0) t += q * p.priceCents;
    }
    for (final d in denoms) {
      final q = _fichaQty[d.id] ?? 0;
      if (q > 0) t += q * d.valueCents;
    }
    for (final f in _freeLines) {
      t += f.cents;
    }
    return t;
  }

  void _addProduct(ChurchProduct p) {
    setState(() {
      final q = _productQty[p.id] ?? 0;
      if (p.trackStock && q >= p.stockQty) return;
      _productQty[p.id] = q + 1;
    });
  }

  void _setProductQty(ChurchProduct p, int q) {
    setState(() {
      if (q <= 0) {
        _productQty.remove(p.id);
      } else {
        final cap = p.trackStock ? p.stockQty : q;
        _productQty[p.id] = q > cap ? cap : q;
      }
    });
  }

  void _addFicha(EventDotDenom d) {
    setState(() {
      final q = _fichaQty[d.id] ?? 0;
      if (q >= d.stockQty) return;
      _fichaQty[d.id] = q + 1;
    });
  }

  void _setFichaQty(EventDotDenom d, int q) {
    setState(() {
      if (q <= 0) {
        _fichaQty.remove(d.id);
      } else {
        _fichaQty[d.id] = q > d.stockQty ? d.stockQty : q;
      }
    });
  }

  Future<void> _addFreeLine() async {
    final labelCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Valor avulso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueCtrl,
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final cents = parseMoneyToCents(valueCtrl.text);
    if (cents == null || cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor inválido')),
      );
      return;
    }
    if (labelCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a descrição')),
      );
      return;
    }
    setState(() {
      _freeLines.add(_FreeLine(label: labelCtrl.text.trim(), cents: cents));
    });
  }

  List<SaleLineDraft> _buildDrafts(
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
  ) {
    final out = <SaleLineDraft>[];
    for (final p in products) {
      final q = _productQty[p.id] ?? 0;
      if (q > 0) {
        out.add(
          SaleLineDraft.product(
            productId: p.id,
            qty: q,
            unitPriceCents: p.priceCents,
          ),
        );
      }
    }
    for (final d in denoms) {
      final q = _fichaQty[d.id] ?? 0;
      if (q > 0) {
        out.add(
          SaleLineDraft.ficha(
            dotDenominationId: d.id,
            qty: q,
            unitPriceCents: d.valueCents,
          ),
        );
      }
    }
    for (final f in _freeLines) {
      out.add(
        SaleLineDraft.valorLivre(
          freeLabel: f.label,
          lineTotalCents: f.cents,
        ),
      );
    }
    return out;
  }

  Future<void> _checkout(
    int total,
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
  ) async {
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione itens à venda')),
      );
      return;
    }
    final drafts = _buildDrafts(products, denoms);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<_CheckoutResult>(
      context: context,
      builder: (ctx) => _SaleCheckoutDialog(totalCents: total),
    );
    if (result == null || !context.mounted) return;
    final db = ref.read(appDatabaseProvider);
    try {
      final saleId = await db.completeSale(
        eventId: widget.eventId,
        paymentMethod: result.paymentMethod,
        amountReceivedCents: result.amountReceivedCents,
        lines: drafts,
      );
      if (!context.mounted) return;
      final change = result.amountReceivedCents - total;
      if (result.paymentMethod == PaymentMethod.dinheiro && change > 0) {
        await router.push(
          '/event/${widget.eventId}/sale/$saleId/troco?change=$change',
        );
      }
      if (!context.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Venda registrada')),
      );
      if (!context.mounted) return;
      router.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Nova venda'),
      ),
      body: StreamBuilder<List<ChurchProduct>>(
        stream: db.watchActiveProducts(),
        builder: (context, prodSnap) {
          if (prodSnap.hasError) {
            return Center(child: Text('Erro: ${prodSnap.error}'));
          }
          final products = prodSnap.data;
          if (products == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<EventDotDenom>>(
            stream: db.watchDotDenominations(widget.eventId),
            builder: (context, dotSnap) {
              if (dotSnap.hasError) {
                return Center(child: Text('Erro: ${dotSnap.error}'));
              }
              final denoms = dotSnap.data;
              if (denoms == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final total = _totalCents(products, denoms);
              final hasCart = total > 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hasCart)
                    Material(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(
                          'Resumo · ${formatCents(total)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        children: [
                          for (final p in products)
                            if ((_productQty[p.id] ?? 0) > 0)
                              ListTile(
                                dense: true,
                                title: Text(p.name),
                                subtitle: Text(formatCents(p.priceCents)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _setProductQty(
                                        p,
                                        (_productQty[p.id] ?? 0) - 1,
                                      ),
                                    ),
                                    Text('${_productQty[p.id]}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _addProduct(p),
                                    ),
                                  ],
                                ),
                              ),
                          for (final d in denoms)
                            if ((_fichaQty[d.id] ?? 0) > 0)
                              ListTile(
                                dense: true,
                                title: Text('${d.label} (ficha)'),
                                subtitle: Text(formatCents(d.valueCents)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _setFichaQty(
                                        d,
                                        (_fichaQty[d.id] ?? 0) - 1,
                                      ),
                                    ),
                                    Text('${_fichaQty[d.id]}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _addFicha(d),
                                    ),
                                  ],
                                ),
                              ),
                          for (final f in _freeLines)
                            ListTile(
                              dense: true,
                              title: Text(f.label),
                              subtitle: Text(formatCents(f.cents)),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() => _freeLines.remove(f));
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Row(
                          children: [
                            Text(
                              'Produtos',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _addFreeLine,
                              icon: const Icon(Icons.attach_money),
                              label: const Text('Valor avulso'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (products.isEmpty)
                          const Text('Nenhum produto ativo.')
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, i) {
                              final p = products[i];
                              final disabled =
                                  p.trackStock && p.stockQty == 0;
                              final inCart = _productQty[p.id] ?? 0;
                              return Card(
                                child: InkWell(
                                  onTap: disabled ? null : () => _addProduct(p),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        const Spacer(),
                                        Text(formatCents(p.priceCents)),
                                        if (inCart > 0)
                                          Text('x$inCart',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        if (denoms.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Fichas (dots)',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.2,
                            ),
                            itemCount: denoms.length,
                            itemBuilder: (context, i) {
                              final d = denoms[i];
                              final disabled = d.stockQty == 0;
                              final inCart = _fichaQty[d.id] ?? 0;
                              return Card(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                child: InkWell(
                                  onTap: disabled ? null : () => _addFicha(d),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d.label,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                        const Spacer(),
                                        Text(formatCents(d.valueCents)),
                                        Text(
                                          'Estoque: ${d.stockQty}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                        if (inCart > 0)
                                          Text(
                                            'x$inCart',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: !hasCart
                                  ? null
                                  : () => setState(() {
                                        _productQty.clear();
                                        _fichaQty.clear();
                                        _freeLines.clear();
                                      }),
                              child: const Text('Limpar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: !hasCart
                                  ? null
                                  : () => _checkout(total, products, denoms),
                              child: Text('Pagar ${formatCents(total)}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CheckoutResult {
  _CheckoutResult({
    required this.paymentMethod,
    required this.amountReceivedCents,
  });
  final String paymentMethod;
  final int amountReceivedCents;
}

class _SaleCheckoutDialog extends StatefulWidget {
  const _SaleCheckoutDialog({required this.totalCents});

  final int totalCents;

  @override
  State<_SaleCheckoutDialog> createState() => _SaleCheckoutDialogState();
}

class _SaleCheckoutDialogState extends State<_SaleCheckoutDialog> {
  String _payment = PaymentMethod.dinheiro;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncReceivedField();
  }

  void _syncReceivedField() {
    final t = widget.totalCents;
    _controller.text =
        (t / 100).toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? get _received => parseMoneyToCents(_controller.text);

  @override
  Widget build(BuildContext context) {
    final isCash = _payment == PaymentMethod.dinheiro;
    final rec = _received ?? 0;
    final change = rec - widget.totalCents;

    return AlertDialog(
      title: const Text('Pagamento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ${formatCents(widget.totalCents)}'),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Forma de pagamento',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _payment,
                  items: PaymentMethod.all
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(PaymentMethod.label(c)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _payment = v;
                      _syncReceivedField();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: isCash
                    ? 'Valor recebido (dinheiro)'
                    : 'Valor pago (confirme)',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            if (isCash) ...[
              const SizedBox(height: 8),
              Text(
                _received == null
                    ? 'Informe o valor recebido'
                    : 'Troco: ${formatCents(change.clamp(0, 1 << 30))}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 8,
                children: [10, 20, 50, 100, 200].map((reais) {
                  return ActionChip(
                    label: Text('R\$ $reais'),
                              onPressed: () {
                                setState(() {
                                  _controller.text = reais
                                      .toStringAsFixed(2)
                                      .replaceAll('.', ',');
                                });
                              },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final r = _received;
            if (r == null || r < widget.totalCents) return;
            Navigator.pop(
              context,
              _CheckoutResult(
                paymentMethod: _payment,
                amountReceivedCents: r,
              ),
            );
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
