import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';
import '../../data/database.dart';
import '../../data/sale_line_draft.dart';
import '../../domain/payment_method.dart';
import '../../domain/sale_line_kind.dart';
import '../../providers/database_provider.dart';
import '../../providers/sales_draft_provider.dart';
import '../../providers/sync_provider.dart';
import '../../utils/money_format.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key, required this.eventId, this.editSaleId});

  final int eventId;
  final int? editSaleId;

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  final Map<int, int> _productQty = {};
  final Map<int, int> _fichaQty = {};
  final List<FreeLineDraft> _freeLines = [];
  PosSale? _originalSale;
  bool _isLoadingEdit = false;

  bool get _isEditing => widget.editSaleId != null;

  @override
  void initState() {
    super.initState();
    if (widget.editSaleId != null) {
      _loadEditSale();
    }
  }

  Future<void> _loadEditSale() async {
    setState(() => _isLoadingEdit = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final sale = await (db.select(db.sales)..where((s) => s.id.equals(widget.editSaleId!))).getSingleOrNull();
      if (sale != null) {
        _originalSale = sale;
        final lines = await (db.select(db.saleLines)..where((l) => l.saleId.equals(sale.id))).get();
        for (final l in lines) {
          if (l.lineKind == SaleLineKind.product && l.productId != null) {
            _productQty[l.productId!] = (_productQty[l.productId!] ?? 0) + l.qty;
          } else if (l.lineKind == SaleLineKind.ficha && l.dotDenominationId != null) {
            _fichaQty[l.dotDenominationId!] = (_fichaQty[l.dotDenominationId!] ?? 0) + l.qty;
          } else if (l.lineKind == SaleLineKind.valorLivre) {
            _freeLines.add(FreeLineDraft(label: l.freeLabel ?? 'Valor', cents: l.lineTotalCents));
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingEdit = false);
      }
    }
  }

  int _totalCents(
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
  ) {
    if (_isEditing) {
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
    } else {
      final draft = ref.watch(vendaDraftsProvider(widget.eventId)).activeDraft;
      return draft.totalCents(products, denoms);
    }
  }

  void _addProduct(ChurchProduct p) {
    if (_isEditing) {
      setState(() {
        final q = _productQty[p.id] ?? 0;
        if (p.trackStock && q >= p.stockQty) return;
        _productQty[p.id] = q + 1;
      });
    } else {
      final draft = ref.read(vendaDraftsProvider(widget.eventId)).activeDraft;
      final q = draft.productQty[p.id] ?? 0;
      if (p.trackStock && q >= p.stockQty) return;
      ref.read(vendaDraftsProvider(widget.eventId).notifier).updateProductQty(p.id, q + 1);
    }
  }

  void _setProductQty(ChurchProduct p, int q) {
    if (_isEditing) {
      setState(() {
        if (q <= 0) {
          _productQty.remove(p.id);
        } else {
          final cap = p.trackStock ? p.stockQty : q;
          _productQty[p.id] = q > cap ? cap : q;
        }
      });
    } else {
      if (q <= 0) {
        ref.read(vendaDraftsProvider(widget.eventId).notifier).updateProductQty(p.id, 0);
      } else {
        final cap = p.trackStock ? p.stockQty : q;
        final targetQty = q > cap ? cap : q;
        ref.read(vendaDraftsProvider(widget.eventId).notifier).updateProductQty(p.id, targetQty);
      }
    }
  }

  void _addFicha(EventDotDenom d) {
    if (_isEditing) {
      setState(() {
        final q = _fichaQty[d.id] ?? 0;
        if (q >= d.stockQty) return;
        _fichaQty[d.id] = q + 1;
      });
    } else {
      final draft = ref.read(vendaDraftsProvider(widget.eventId)).activeDraft;
      final q = draft.fichaQty[d.id] ?? 0;
      if (q >= d.stockQty) return;
      ref.read(vendaDraftsProvider(widget.eventId).notifier).updateFichaQty(d.id, q + 1);
    }
  }

  void _setFichaQty(EventDotDenom d, int q) {
    if (_isEditing) {
      setState(() {
        if (q <= 0) {
          _fichaQty.remove(d.id);
        } else {
          _fichaQty[d.id] = q > d.stockQty ? d.stockQty : q;
        }
      });
    } else {
      if (q <= 0) {
        ref.read(vendaDraftsProvider(widget.eventId).notifier).updateFichaQty(d.id, 0);
      } else {
        final targetQty = q > d.stockQty ? d.stockQty : q;
        ref.read(vendaDraftsProvider(widget.eventId).notifier).updateFichaQty(d.id, targetQty);
      }
    }
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
    if (_isEditing) {
      setState(() {
        _freeLines.add(FreeLineDraft(label: labelCtrl.text.trim(), cents: cents));
      });
    } else {
      ref.read(vendaDraftsProvider(widget.eventId).notifier).addFreeLine(labelCtrl.text.trim(), cents);
    }
  }

  List<SaleLineDraft> _buildDrafts(
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
  ) {
    final out = <SaleLineDraft>[];
    if (_isEditing) {
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
    } else {
      final draft = ref.read(vendaDraftsProvider(widget.eventId)).activeDraft;
      for (final p in products) {
        final q = draft.productQty[p.id] ?? 0;
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
        final q = draft.fichaQty[d.id] ?? 0;
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
      for (final f in draft.freeLines) {
        out.add(
          SaleLineDraft.valorLivre(
            freeLabel: f.label,
            lineTotalCents: f.cents,
          ),
        );
      }
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
      builder: (ctx) => _SaleCheckoutDialog(
        totalCents: total,
        denominations: denoms,
        originalSale: _originalSale,
      ),
    );
    if (result == null || !context.mounted) return;
    final db = ref.read(appDatabaseProvider);
    try {
      final syncState = ref.read(syncProvider);
      final isSyncClient = syncState.mode == SyncMode.client && syncState.isConnected;

      if (isSyncClient) {
        await ref.read(syncProvider.notifier).submitSaleToHost(
          widget.eventId,
          result.paymentMethod,
          result.amountReceivedCents,
          result.notes,
          result.changePending,
          result.customerName,
          drafts,
        );
      } else {
        if (_isEditing) {
          await db.updateSaleWithLines(
            saleId: widget.editSaleId!,
            eventId: widget.eventId,
            paymentMethod: result.paymentMethod,
            amountReceivedCents: result.amountReceivedCents,
            notes: result.notes,
            changePending: result.changePending,
            customerName: result.customerName,
            lines: drafts,
          );
        } else {
          await db.completeSale(
            eventId: widget.eventId,
            paymentMethod: result.paymentMethod,
            amountReceivedCents: result.amountReceivedCents,
            notes: result.notes,
            changePending: result.changePending,
            customerName: result.customerName,
            lines: drafts,
          );
        }
      }
      if (!context.mounted) return;
      
      final change = result.amountReceivedCents - total;

      if (!mounted) return;
      
      if (change > 0 && result.paymentMethod == PaymentMethod.dinheiro) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(result.changePending ? 'Venda Finalizada (Troco Pendente)' : 'Venda Finalizada'),
            content: Text(
              result.changePending 
                  ? 'Devendo troco de:\n\n${formatCents(change)}\n\nPara: ${result.customerName ?? 'Não informado'}'
                  : 'Troco a devolver:\n\n${formatCents(change)}',
              style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                fontSize: result.changePending ? 20 : null,
              ),
              textAlign: TextAlign.center,
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Venda registrada')),
        );
      }

      if (!context.mounted) return;

      if (_isEditing) {
        router.pop();
      } else {
        final draftsState = ref.read(vendaDraftsProvider(widget.eventId));
        final activeDraftId = draftsState.activeDraftId;
        final otherDraftsNotEmpty = draftsState.drafts.any((d) => d.id != activeDraftId && !d.isEmpty);

        ref.read(vendaDraftsProvider(widget.eventId).notifier).removeDraft(activeDraftId);

        if (!otherDraftsNotEmpty) {
          router.pop();
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Widget _buildDraftTabs(
    BuildContext context,
    WidgetRef ref,
    EventSalesDraftState draftsState,
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
  ) {
    final notifier = ref.read(vendaDraftsProvider(widget.eventId).notifier);
    final activeId = draftsState.activeDraftId;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: draftsState.drafts.length + 1,
        itemBuilder: (context, index) {
          if (index == draftsState.drafts.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton.filledTonal(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => notifier.addDraft(),
                tooltip: 'Nova aba de venda',
              ),
            );
          }

          final d = draftsState.drafts[index];
          final isActive = d.id == activeId;
          final total = d.totalCents(products, denoms);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              elevation: isActive ? 2 : 0,
              child: InkWell(
                onTap: () => notifier.selectDraft(d.id),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (total > 0) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? colorScheme.onPrimary : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        total > 0 ? '${d.name} (${formatCents(total)})' : d.name,
                        style: TextStyle(
                          color: isActive
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      if (draftsState.drafts.length > 1) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            if (d.isEmpty) {
                              notifier.removeDraft(d.id);
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Descartar venda?'),
                                  content: Text('Deseja realmente descartar a aba "${d.name}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        notifier.removeDraft(d.id);
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Descartar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: isActive
                                ? colorScheme.onPrimary.withValues(alpha: 0.8)
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final draftsState = _isEditing ? null : ref.watch(vendaDraftsProvider(widget.eventId));
    final draft = draftsState?.activeDraft;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.editSaleId != null ? 'Editar venda #${widget.editSaleId}' : 'Nova venda'),
      ),
      body: _isLoadingEdit 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<ChurchProduct>>(
        stream: db.watchActiveProductsForEvent(widget.eventId),
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
                  if (!_isEditing && draftsState != null)
                    _buildDraftTabs(context, ref, draftsState, products, denoms),
                  if (hasCart)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Card(
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            'Resumo · ${formatCents(total)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          children: [
                          for (final p in products)
                            if (((_isEditing ? _productQty[p.id] : draft?.productQty[p.id]) ?? 0) > 0)
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
                                        ((_isEditing ? _productQty[p.id] : draft?.productQty[p.id]) ?? 0) - 1,
                                      ),
                                    ),
                                    Text('${_isEditing ? _productQty[p.id] : draft?.productQty[p.id]}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _addProduct(p),
                                    ),
                                  ],
                                ),
                              ),
                          for (final d in denoms)
                            if (((_isEditing ? _fichaQty[d.id] : draft?.fichaQty[d.id]) ?? 0) > 0)
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
                                        ((_isEditing ? _fichaQty[d.id] : draft?.fichaQty[d.id]) ?? 0) - 1,
                                      ),
                                    ),
                                    Text('${_isEditing ? _fichaQty[d.id] : draft?.fichaQty[d.id]}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _addFicha(d),
                                    ),
                                  ],
                                ),
                              ),
                          for (final f in (_isEditing ? _freeLines : draft?.freeLines ?? const []))
                            ListTile(
                              dense: true,
                              title: Text(f.label),
                              subtitle: Text(formatCents(f.cents)),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  if (_isEditing) {
                                    setState(() => _freeLines.remove(f));
                                  } else {
                                    ref.read(vendaDraftsProvider(widget.eventId).notifier).removeFreeLine(f);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      padding: kCaixaScreenPadding.copyWith(
                        top: 4,
                        bottom: 8,
                      ),
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
                              final inCart = _isEditing ? (_productQty[p.id] ?? 0) : (draft?.productQty[p.id] ?? 0);
                              
                              Widget cardContent = Padding(
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
                                    if (p.isCombo)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('COMBO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                              );

                              if (disabled) {
                                cardContent = Opacity(
                                  opacity: 0.5,
                                  child: cardContent,
                                );
                              }

                              return Card(
                                color: disabled
                                    ? Colors.red.withValues(alpha: 0.2)
                                    : null,
                                child: InkWell(
                                  onTap: disabled ? null : () => _addProduct(p),
                                  child: cardContent,
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
                              final inCart = _isEditing ? (_fichaQty[d.id] ?? 0) : (draft?.fichaQty[d.id] ?? 0);
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
                      padding: kCaixaScreenPadding.copyWith(
                        top: 8,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: !hasCart
                                  ? null
                                  : () {
                                      if (_isEditing) {
                                        setState(() {
                                          _productQty.clear();
                                          _fichaQty.clear();
                                          _freeLines.clear();
                                        });
                                      } else {
                                        ref.read(vendaDraftsProvider(widget.eventId).notifier).clearDraft(draft!.id);
                                      }
                                    },
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
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
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
    this.notes,
    this.changePending = false,
    this.customerName,
  });
  final String paymentMethod;
  final int amountReceivedCents;
  final String? notes;
  final bool changePending;
  final String? customerName;
}

class _SaleCheckoutDialog extends StatefulWidget {
  const _SaleCheckoutDialog({
    required this.totalCents,
    required this.denominations,
    this.originalSale,
  });

  final int totalCents;
  final List<EventDotDenom> denominations;
  final PosSale? originalSale;

  @override
  State<_SaleCheckoutDialog> createState() => _SaleCheckoutDialogState();
}

class _SaleCheckoutDialogState extends State<_SaleCheckoutDialog> {
  String _payment = PaymentMethod.dinheiro;
  final _controller = TextEditingController();
  final _notesController = TextEditingController();
  bool _changePending = false;
  final _customerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.originalSale != null) {
      final s = widget.originalSale!;
      _payment = s.paymentMethod;
      _notesController.text = s.notes ?? '';
      _changePending = s.changePending;
      _customerNameController.text = s.customerName ?? '';
      _controller.text = (s.amountReceivedCents / 100).toStringAsFixed(2).replaceAll('.', ',');
    } else {
      _syncReceivedField();
    }
  }

  void _syncReceivedField() {
    final t = widget.totalCents;
    _controller.text =
        (t / 100).toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  int? get _received => parseMoneyToCents(_controller.text);

  String _buildFichasSuggestion(int totalCents) {
    if (widget.denominations.isEmpty || totalCents <= 0) return '';
    final sorted = List<EventDotDenom>.from(widget.denominations)
      ..sort((a, b) => b.valueCents.compareTo(a.valueCents));
    var remaining = totalCents;
    final Map<int, int> toGive = {};
    for (final d in sorted) {
      if (d.valueCents <= 0) continue;
      final qty = remaining ~/ d.valueCents;
      if (qty > 0) {
        toGive[d.valueCents] = qty;
        remaining -= (qty * d.valueCents);
      }
    }
    if (toGive.isEmpty) return '';
    final parts = toGive.entries.map((e) => '${e.value}x ${formatCents(e.key)}');
    return 'Sugestão de Fichas (Dots):\n${parts.join('  |  ')}';
  }

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
            if (widget.denominations.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _buildFichasSuggestion(widget.totalCents),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
              const SizedBox(height: 12),
            ],
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
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observação (Opcional)',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
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
              if (_received != null && change > 0) ...[
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Troco pendente'),
                  subtitle: const Text('Marque se ficar devendo o troco'),
                  value: _changePending,
                  onChanged: (v) => setState(() => _changePending = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_changePending) ...[
                  TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do cliente',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
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
            
            if (_changePending && _customerNameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informe o nome do cliente para o troco pendente')),
              );
              return;
            }
            
            Navigator.pop(
              context,
              _CheckoutResult(
                paymentMethod: _payment,
                amountReceivedCents: r,
                notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                changePending: _changePending,
                customerName: _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim(),
              ),
            );
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
