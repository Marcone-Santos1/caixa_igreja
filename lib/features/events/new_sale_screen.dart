import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/app_theme.dart';
import '../../data/database.dart';
import '../../data/sale_line_draft.dart';
import '../../domain/payment_method.dart';
import '../../domain/sale_line_kind.dart';
import '../../providers/database_provider.dart';
import '../../providers/event_dashboard_provider.dart';
import '../../providers/printer_provider.dart';
import '../../providers/sales_draft_provider.dart';
import '../../services/printer_service.dart';
import '../../providers/sync_provider.dart';
import '../../providers/cash_session_provider.dart';
import '../../providers/event_detail_provider.dart';
import '../../utils/money_format.dart';
import '../../utils/pix_payload.dart';
import 'cash_session_dialogs.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key, required this.eventId, this.editSaleId});

  final String eventId;
  final String? editSaleId;

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  final Map<String, int> _productQty = {};
  final Map<String, int> _fichaQty = {};
  final List<FreeLineDraft> _freeLines = [];
  PosSale? _originalSale;
  bool _isLoadingEdit = false;
  String _selectedCategory = 'Todos';
  bool _isCartExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchVisible = false;

  bool get _isEditing => widget.editSaleId != null;

  @override
  void initState() {
    super.initState();
    if (widget.editSaleId != null) {
      _loadEditSale();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    HapticFeedback.lightImpact();
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
    HapticFeedback.selectionClick();
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
    HapticFeedback.lightImpact();
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
    HapticFeedback.selectionClick();
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

  Future<bool> _printSaleTicket({
    required String eventId,
    required _CheckoutResult result,
    required int totalCents,
    required List<SaleLineDraft> drafts,
    required List<ChurchProduct> products,
    required List<EventDotDenom> denoms,
  }) async {
    final autoPrint = ref.read(autoPrintEnabledProvider);
    final printVouchers = ref.read(printDeliveryVouchersEnabledProvider);
    if (!autoPrint && !printVouchers) return false;

    final printerService = ref.read(printerServiceProvider);
    final connected = await printerService.isConnected();
    if (!connected) return false;

    final db = ref.read(appDatabaseProvider);
    int orderSeq = 1;
    String headerTitle = 'CANTINA';
    try {
      final ev = await (db.select(db.events)..where((e) => e.id.equals(eventId))).getSingleOrNull();
      if (ev != null && ev.title.trim().isNotEmpty) {
        headerTitle = ev.title.trim();
      }
      final sales = await (db.select(db.sales)..where((s) => s.eventId.equals(eventId))).get();
      orderSeq = sales.length;
      if (orderSeq <= 0) orderSeq = 1;
    } catch (_) {}

    final orderNumber = orderSeq.toString().padLeft(3, '0');

    final items = <Map<String, dynamic>>[];
    for (final d in drafts) {
      String name = 'Item';
      if (d.kind == SaleLineKind.product && d.productId != null) {
        final p = products.firstWhere(
          (p) => p.id == d.productId,
          orElse: () => ChurchProduct(
            id: '',
            eventId: '',
            name: 'Produto',
            description: '',
            priceCents: 0,
            trackStock: false,
            stockQty: 0,
            active: true,
            isCombo: false,
            rowVersion: 1,
            updatedAtMs: 0,
          ),
        );
        name = p.name;
      } else if (d.kind == SaleLineKind.ficha && d.dotDenominationId != null) {
        final f = denoms.firstWhere(
          (f) => f.id == d.dotDenominationId,
          orElse: () => EventDotDenom(
            id: '',
            eventId: '',
            label: 'Ficha',
            valueCents: 0,
            stockQty: 0,
            rowVersion: 1,
            updatedAtMs: 0,
          ),
        );
        name = 'Ficha: ${f.label}';
      } else if (d.kind == SaleLineKind.valorLivre) {
        name = d.freeLabel ?? 'Valor avulso';
      }

      items.add({
        'name': name,
        'qty': d.qty,
        'subtotal': d.resolveLineTotalCents() / 100.0,
      });
    }

    bool printedAny = false;

    // 1. Imprime o comprovante geral da venda (se habilitado)
    if (autoPrint) {
      final changeCents = result.amountReceivedCents - totalCents;
      final ok = await printerService.printTicket(
        orderNumber: orderNumber,
        items: items,
        total: totalCents / 100.0,
        headerTitle: headerTitle,
        paymentMethod: PaymentMethod.label(result.paymentMethod),
        amountReceived: result.amountReceivedCents > 0
            ? result.amountReceivedCents / 100.0
            : null,
        change: changeCents > 0 ? changeCents / 100.0 : null,
        customerName: result.customerName,
        notes: result.notes,
      );
      if (ok) printedAny = true;
    }

    // 2. Imprime as fichas / canhotos de entrega no balcão (se habilitado)
    if (printVouchers) {
      final perUnit = ref.read(deliveryVouchersPerUnitProvider);
      final oneByOne = ref.read(deliveryVouchersOneByOneProvider);

      if (oneByOne) {
        // Modo "uma por vez": monta os bytes de cada ficha e exibe diálogo de confirmação
        final voucherBytesList = await printerService.buildDeliveryVoucherBytes(
          orderNumber: orderNumber,
          items: items,
          eventTitle: headerTitle,
          customerName: result.customerName,
          perUnit: perUnit,
        );

        if (voucherBytesList.isNotEmpty && mounted) {
          final done = await _showVoucherStepDialog(
            printerService: printerService,
            voucherBytesList: voucherBytesList,
          );
          if (done) printedAny = true;
        }
      } else {
        // Modo padrão: imprime tudo de uma vez
        final okVouchers = await printerService.printDeliveryVouchers(
          orderNumber: orderNumber,
          items: items,
          eventTitle: headerTitle,
          customerName: result.customerName,
          perUnit: perUnit,
        );
        if (okVouchers) printedAny = true;
      }
    }

    return printedAny;
  }

  /// Exibe um diálogo passo a passo para imprimir fichas uma por vez.
  /// O operador confirma cada impressão antes de avançar para a próxima.
  Future<bool> _showVoucherStepDialog({
    required PrinterService printerService,
    required List<Uint8List> voucherBytesList,
  }) async {
    int currentIndex = 0;
    final total = voucherBytesList.length;
    bool printedAtLeastOne = false;

    // Imprime a primeira ficha imediatamente
    await printerService.printVoucherBytes(voucherBytesList[currentIndex]);
    printedAtLeastOne = true;
    currentIndex++;

    while (currentIndex < total && mounted) {
      final ctx = context;
      // ignore: use_build_context_synchronously
      final shouldContinue = await showDialog<bool>(
        context: ctx,
        barrierDismissible: false,
        builder: (dlgCtx) => AlertDialog(
          icon: const Icon(Icons.confirmation_number_outlined, size: 32),
          title: Text('Ficha $currentIndex de $total impressa'),
          content: Text(
            currentIndex < total
                ? 'Destaque a ficha e toque em "Próxima" para imprimir a ficha ${currentIndex + 1}.'
                : 'Última ficha. Toque em "Concluir" para finalizar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dlgCtx).pop(false),
              child: const Text('Cancelar restantes'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dlgCtx).pop(true),
              icon: Icon(
                currentIndex < total
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
              ),
              label: Text(currentIndex < total ? 'Próxima →' : 'Concluir'),
            ),
          ],
        ),
      );

      if (shouldContinue != true) break;

      await printerService.printVoucherBytes(voucherBytesList[currentIndex]);
      printedAtLeastOne = true;
      currentIndex++;
    }

    return printedAtLeastOne;
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
    final result = await showModalBottomSheet<_CheckoutResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SaleCheckoutBottomSheet(
        eventId: widget.eventId,
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
          final activeSession = ref.read(activeCashSessionStreamProvider(widget.eventId)).value;
          await db.completeSale(
            eventId: widget.eventId,
            paymentMethod: result.paymentMethod,
            amountReceivedCents: result.amountReceivedCents,
            notes: result.notes,
            changePending: result.changePending,
            customerName: result.customerName,
            sessionId: activeSession?.id,
            lines: drafts,
          );
        }
      }

      // Auto-impressão do ticket na impressora térmica se conectada
      bool ticketPrinted = false;
      try {
        ticketPrinted = await _printSaleTicket(
          eventId: widget.eventId,
          result: result,
          totalCents: total,
          drafts: drafts,
          products: products,
          denoms: denoms,
        );
      } catch (_) {}

      if (!context.mounted) return;
      
      final change = result.amountReceivedCents - total;

      if (!mounted) return;
      
      if (change > 0 && result.paymentMethod == PaymentMethod.dinheiro) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(result.changePending ? 'Venda Finalizada (Troco Pendente)' : 'Venda Finalizada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result.changePending 
                      ? 'Devendo troco de:\n\n${formatCents(change)}\n\nPara: ${result.customerName ?? 'Não informado'}'
                      : 'Troco a devolver:\n\n${formatCents(change)}',
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                    fontSize: result.changePending ? 20 : null,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (ticketPrinted) ...[
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                      SizedBox(width: 6),
                      Text(
                        'Ticket impresso na impressora',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
          SnackBar(
            content: Text(
              ticketPrinted
                  ? 'Venda registrada • Ticket impresso!'
                  : 'Venda registrada',
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: draftsState.drafts.length + 1,
        itemBuilder: (context, index) {
          if (index == draftsState.drafts.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ActionChip(
                avatar: const Icon(Icons.add, size: 18, color: CaixaAppTheme.marianBlue),
                label: Text(
                  'Nova Comanda',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CaixaAppTheme.marianBlue,
                  ),
                ),
                backgroundColor: CaixaAppTheme.marianBlue.withValues(alpha: 0.08),
                side: BorderSide(color: CaixaAppTheme.marianBlue.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => notifier.addDraft(),
              ),
            );
          }

          final d = draftsState.drafts[index];
          final isActive = d.id == activeId;
          final total = d.totalCents(products, denoms);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: isActive
                  ? CaixaAppTheme.marianBlue
                  : (isDark ? Colors.white10 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(20),
              elevation: isActive ? 2 : 0,
              child: InkWell(
                onTap: () => notifier.selectDraft(d.id),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (total > 0) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? CaixaAppTheme.warmGold : Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        total > 0 ? '${d.name} (${formatCents(total)})' : d.name,
                        style: GoogleFonts.outfit(
                          color: isActive ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (draftsState.drafts.length > 1) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (d.isEmpty) {
                              notifier.removeDraft(d.id);
                            } else {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Descartar comanda?'),
                                  content: Text('Deseja realmente descartar a comanda "${d.name}"?'),
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
                                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Descartar'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 15,
                            color: isActive ? Colors.white70 : Colors.grey.shade600,
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

  Widget _buildCategorySelector(List<ChurchProduct> products, List<EventDotDenom> denoms) {
    final categories = <String>['Todos'];

    final hasPasteis = products.any((p) => p.name.toLowerCase().contains('pastel'));
    if (hasPasteis) categories.add('Pastéis');

    final hasBebidas = products.any((p) {
      final name = p.name.toLowerCase();
      return name.contains('refrigerante') ||
          name.contains('suco') ||
          name.contains('água') ||
          name.contains('agua') ||
          name.contains('chá') ||
          name.contains('cha') ||
          name.contains('cerveja') ||
          name.contains('bebida');
    });
    if (hasBebidas) categories.add('Bebidas');

    final hasCombos = products.any((p) => p.isCombo);
    if (hasCombos) categories.add('Combos');

    if (denoms.isNotEmpty) categories.add('Fichas');

    if (categories.length <= 1) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                cat,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : CaixaAppTheme.marianBlue)
                      : (isDark ? Colors.white70 : Colors.grey.shade800),
                ),
              ),
              selected: isSelected,
              selectedColor: isDark
                  ? CaixaAppTheme.marianBlue.withValues(alpha: 0.3)
                  : CaixaAppTheme.marianBlue.withValues(alpha: 0.12),
              backgroundColor: isDark ? Colors.white10 : Colors.white,
              checkmarkColor: isDark ? Colors.white : CaixaAppTheme.marianBlue,
              side: BorderSide(
                color: isSelected
                    ? CaixaAppTheme.marianBlue
                    : (isDark ? Colors.white12 : Colors.grey.shade300),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (_) {
                setState(() => _selectedCategory = cat);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(ChurchProduct p, int inCart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOutOfStock = p.trackStock && p.stockQty == 0;
    final isLowStock = p.trackStock && p.stockQty > 0 && p.stockQty <= 5;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: inCart > 0
              ? CaixaAppTheme.marianBlue
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: inCart > 0 ? 1.5 : 1,
        ),
      ),
      color: isOutOfStock
          ? (isDark ? Colors.black26 : Colors.grey.shade100)
          : (inCart > 0
              ? CaixaAppTheme.marianBlue.withValues(alpha: isDark ? 0.15 : 0.04)
              : (isDark ? Colors.grey.shade900 : Colors.white)),
      child: InkWell(
        onTap: isOutOfStock ? null : () => _addProduct(p),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags superiores (Combo, Estoque)
              Row(
                children: [
                  if (p.isCombo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: CaixaAppTheme.warmGold.withValues(alpha: 0.18),
                        border: Border.all(color: CaixaAppTheme.warmGold.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'COMBO',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF8B5E00),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (isOutOfStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ESGOTADO',
                        style: GoogleFonts.inter(
                          color: Colors.red.shade700,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isLowStock)
                    Text(
                      'Resta ${p.stockQty}',
                      style: GoogleFonts.inter(
                        color: Colors.orange.shade800,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const Spacer(),
                  if (inCart > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: CaixaAppTheme.marianBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'x$inCart',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Nome do produto
              Expanded(
                child: Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isOutOfStock
                        ? Colors.grey
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Rodapé do card: Preço e Ações
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formatCents(p.priceCents),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? Colors.grey : CaixaAppTheme.marianBlue,
                    ),
                  ),
                  if (inCart > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _setProductQty(p, inCart - 1),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '$inCart',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        InkWell(
                          onTap: () => _addProduct(p),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: CaixaAppTheme.marianBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? Colors.grey.withValues(alpha: 0.2)
                            : CaixaAppTheme.marianBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 18,
                        color: isOutOfStock ? Colors.grey : CaixaAppTheme.marianBlue,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFichaCard(EventDotDenom d, int inCart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOutOfStock = d.stockQty == 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: inCart > 0
              ? CaixaAppTheme.warmGold
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: inCart > 0 ? 1.5 : 1,
        ),
      ),
      color: inCart > 0
          ? CaixaAppTheme.warmGold.withValues(alpha: isDark ? 0.15 : 0.05)
          : (isDark ? Colors.grey.shade900 : Colors.white),
      child: InkWell(
        onTap: isOutOfStock ? null : () => _addFicha(d),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars, size: 18, color: CaixaAppTheme.warmGold),
                  const SizedBox(width: 4),
                  Text(
                    'FICHA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: CaixaAppTheme.warmGold,
                    ),
                  ),
                  const Spacer(),
                  if (inCart > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: CaixaAppTheme.warmGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'x$inCart',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Estoque: ${d.stockQty}',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    formatCents(d.valueCents),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CaixaAppTheme.warmGold,
                    ),
                  ),
                  if (inCart > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _setFichaQty(d, inCart - 1),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '$inCart',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        InkWell(
                          onTap: () => _addFicha(d),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: CaixaAppTheme.warmGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CaixaAppTheme.warmGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: CaixaAppTheme.warmGold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemsSummary(
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
    SalesDraft? draft,
  ) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          for (final p in products)
            if (((_isEditing ? _productQty[p.id] : draft?.productQty[p.id]) ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            formatCents(p.priceCents * ((_isEditing ? _productQty[p.id] : draft?.productQty[p.id]) ?? 0)),
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => _setProductQty(
                        p,
                        ((_isEditing ? _productQty[p.id] : draft?.productQty[p.id]) ?? 0) - 1,
                      ),
                    ),
                    Text(
                      '${_isEditing ? _productQty[p.id] : draft?.productQty[p.id]}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => _addProduct(p),
                    ),
                  ],
                ),
              ),

          for (final d in denoms)
            if (((_isEditing ? _fichaQty[d.id] : draft?.fichaQty[d.id]) ?? 0) > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${d.label} (Ficha)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            formatCents(d.valueCents * ((_isEditing ? _fichaQty[d.id] : draft?.fichaQty[d.id]) ?? 0)),
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => _setFichaQty(
                        d,
                        ((_isEditing ? _fichaQty[d.id] : draft?.fichaQty[d.id]) ?? 0) - 1,
                      ),
                    ),
                    Text(
                      '${_isEditing ? _fichaQty[d.id] : draft?.fichaQty[d.id]}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => _addFicha(d),
                    ),
                  ],
                ),
              ),

          for (final f in (_isEditing ? _freeLines : draft?.freeLines ?? const []))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${f.label} (${formatCents(f.cents)})',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () {
                      if (_isEditing) {
                        setState(() => _freeLines.remove(f));
                      } else {
                        ref.read(vendaDraftsProvider(widget.eventId).notifier).removeFreeLine(f);
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomCartBar(
    int total,
    List<ChurchProduct> products,
    List<EventDotDenom> denoms,
    SalesDraft? draft,
  ) {
    final hasCart = total > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int totalItemCount = 0;
    if (_isEditing) {
      totalItemCount = _productQty.values.fold<int>(0, (a, b) => a + b) +
          _fichaQty.values.fold<int>(0, (a, b) => a + b) +
          _freeLines.length;
    } else if (draft != null) {
      totalItemCount = draft.productQty.values.fold<int>(0, (a, b) => a + b) +
          draft.fichaQty.values.fold<int>(0, (a, b) => a + b) +
          draft.freeLines.length;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header sanfonado do resumo de itens
            if (hasCart) ...[
              InkWell(
                onTap: () => setState(() => _isCartExpanded = !_isCartExpanded),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: CaixaAppTheme.marianBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$totalItemCount itens',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: CaixaAppTheme.marianBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCartExpanded ? 'Ocultar detalhes' : 'Ver comanda completa',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatCents(total),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CaixaAppTheme.marianBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isCartExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),

              if (_isCartExpanded) ...[
                const Divider(height: 1),
                _buildCartItemsSummary(products, denoms, draft),
                const Divider(height: 1),
              ],
            ],

            // Botões de Ação
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  if (hasCart)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton.outlined(
                        tooltip: 'Limpar comanda',
                        icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                        onPressed: () {
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
                      ),
                    ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: !hasCart ? null : () => _checkout(total, products, denoms),
                        icon: const Icon(Icons.payment, size: 20),
                        label: Text(
                          hasCart ? 'COBRAR ${formatCents(total)}' : 'SELECIONE ITENS',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: CaixaAppTheme.marianBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: hasCart ? 2 : 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draftsState = _isEditing ? null : ref.watch(vendaDraftsProvider(widget.eventId));
    final draft = draftsState?.activeDraft;
    final activeProductsAsync = ref.watch(eventActiveProductsStreamProvider(widget.eventId));
    final denomsAsync = ref.watch(eventDenomsStreamProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.editSaleId != null ? 'Editar comanda #${widget.editSaleId}' : 'Caixa Cantina',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Toque para adicionar à comanda',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final activeSessionAsync = ref.watch(activeCashSessionStreamProvider(widget.eventId));
              final activeSession = activeSessionAsync.value;
              final isOpen = activeSession != null;
              return IconButton(
                tooltip: isOpen
                    ? 'Caixa Aberto: ${activeSession.title} (Troco: ${formatCents(activeSession.initialCashFloatCents)})'
                    : 'Caixa Fechado (Toque para abrir)',
                icon: Badge(
                  backgroundColor: isOpen ? Colors.green : Colors.grey,
                  smallSize: 8,
                  child: Icon(
                    Icons.point_of_sale_rounded,
                    color: isOpen ? Colors.green : Colors.grey.shade600,
                  ),
                ),
                onPressed: () async {
                  if (isOpen) {
                    final eventAsync = ref.read(eventDetailProvider(widget.eventId));
                    final eventTitle = eventAsync.value?.title ?? 'Evento';
                    await CloseCashSessionDialog.show(
                      context: context,
                      session: activeSession,
                      eventTitle: eventTitle,
                    );
                  } else {
                    await OpenCashSessionDialog.show(context, widget.eventId);
                  }
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isConnectedAsync = ref.watch(printerConnectedProvider);
              final isConnected = isConnectedAsync.value ?? false;
              return IconButton(
                tooltip: isConnected ? 'Impressora conectada' : 'Impressora desconectada',
                icon: Badge(
                  backgroundColor: isConnected ? Colors.green : Colors.orange,
                  smallSize: 8,
                  child: Icon(
                    Icons.print_outlined,
                    color: isConnected ? Colors.green : Colors.grey.shade600,
                  ),
                ),
                onPressed: () => context.push('/settings/printer'),
              );
            },
          ),
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
            tooltip: _isSearchVisible ? 'Fechar busca' : 'Buscar produto',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_outlined),
            tooltip: 'Adicionar valor avulso',
            onPressed: _addFreeLine,
          ),
        ],
      ),
      body: _isLoadingEdit
          ? const Center(child: CircularProgressIndicator())
          : activeProductsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro: $err')),
              data: (products) => denomsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Erro: $err')),
                data: (denoms) {
                  final total = _totalCents(products, denoms);

                  // Filtragem de produtos por busca e categoria
                  final filteredProducts = products.where((p) {
                    if (_searchQuery.isNotEmpty && !p.name.toLowerCase().contains(_searchQuery)) {
                      return false;
                    }
                    if (_selectedCategory == 'Todos') return true;
                    if (_selectedCategory == 'Combos') return p.isCombo;
                    if (_selectedCategory == 'Pastéis') {
                      return p.name.toLowerCase().contains('pastel');
                    }
                    if (_selectedCategory == 'Bebidas') {
                      final name = p.name.toLowerCase();
                      return name.contains('refrigerante') ||
                          name.contains('suco') ||
                          name.contains('água') ||
                          name.contains('agua') ||
                          name.contains('chá') ||
                          name.contains('cha') ||
                          name.contains('cerveja') ||
                          name.contains('bebida');
                    }
                    if (_selectedCategory == 'Fichas') return false;
                    return true;
                  }).toList();

                  final showFichas = (_selectedCategory == 'Todos' || _selectedCategory == 'Fichas') &&
                      _searchQuery.isEmpty &&
                      denoms.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Abas de comanda (se não estiver em modo de edição)
                      if (!_isEditing && draftsState != null)
                        _buildDraftTabs(context, ref, draftsState, products, denoms),

                      // Barra de busca rápida colapsável
                      if (_isSearchVisible)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Buscar pastéis, bebidas, combos...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              isDense: true,
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade900
                                  : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() => _searchQuery = val.trim().toLowerCase());
                            },
                          ),
                        ),

                      // Filtro de Categorias (Chips)
                      _buildCategorySelector(products, denoms),

                      // Área Principal com Grid de Produtos e Fichas
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            if (filteredProducts.isNotEmpty) ...[
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                sliver: SliverToBoxAdapter(
                                  child: Row(
                                    children: [
                                      Text(
                                        _selectedCategory == 'Todos' ? 'Produtos' : _selectedCategory,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${filteredProducts.length} itens',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 0.98,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final p = filteredProducts[index];
                                      final inCart = _isEditing
                                          ? (_productQty[p.id] ?? 0)
                                          : (draft?.productQty[p.id] ?? 0);
                                      return _buildProductCard(p, inCart);
                                    },
                                    childCount: filteredProducts.length,
                                  ),
                                ),
                              ),
                            ],

                            // Fichas (Dots)
                            if (showFichas) ...[
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                                sliver: SliverToBoxAdapter(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.stars, size: 18, color: CaixaAppTheme.warmGold),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Fichas (Dots)',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverGrid(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 0.98,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final d = denoms[index];
                                      final inCart = _isEditing
                                          ? (_fichaQty[d.id] ?? 0)
                                          : (draft?.fichaQty[d.id] ?? 0);
                                      return _buildFichaCard(d, inCart);
                                    },
                                    childCount: denoms.length,
                                  ),
                                ),
                              ),
                            ],

                            if (filteredProducts.isEmpty && !showFichas)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nenhum item encontrado nesta categoria.',
                                        style: GoogleFonts.inter(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Margem inferior de respiro
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),
                          ],
                        ),
                      ),

                      // Barra Inferior de Checkout (Sticky Cart Bar)
                      _buildBottomCartBar(total, products, denoms, draft),
                    ],
                  );
                },
              ),
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

class _SaleCheckoutBottomSheet extends ConsumerStatefulWidget {
  const _SaleCheckoutBottomSheet({
    required this.eventId,
    required this.totalCents,
    required this.denominations,
    this.originalSale,
  });

  final String eventId;
  final int totalCents;
  final List<EventDotDenom> denominations;
  final PosSale? originalSale;

  @override
  ConsumerState<_SaleCheckoutBottomSheet> createState() => _SaleCheckoutBottomSheetState();
}

class _SaleCheckoutBottomSheetState extends ConsumerState<_SaleCheckoutBottomSheet> {
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
    if (_payment == PaymentMethod.fiado) {
      // Fiado: o campo vira a ENTRADA opcional paga na hora.
      _controller.text = '0,00';
      return;
    }
    final t = widget.totalCents;
    _controller.text = (t / 100).toStringAsFixed(2).replaceAll('.', ',');
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
    return parts.join('  •  ');
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final event = eventAsync.valueOrNull;

    final isCash = _payment == PaymentMethod.dinheiro;
    final isFiado = _payment == PaymentMethod.fiado;
    final rec = _received ?? 0;
    final change = rec - widget.totalCents;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : CaixaAppTheme.ivoryCanvas,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header & Total Banner (Stitch Marian Blue gradient)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [CaixaAppTheme.marianBlue, Color(0xFF0C2B54)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: CaixaAppTheme.marianBlue.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: CaixaAppTheme.warmGold,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL DA COMANDA',
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatCents(widget.totalCents),
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white70),
                              tooltip: 'Fechar',
                            ),
                          ],
                        ),
                      ),

                      // Sugestão de Fichas (se houver denominações)
                      if (widget.denominations.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: CaixaAppTheme.warmGold.withValues(alpha: 0.12),
                            border: Border.all(
                              color: CaixaAppTheme.warmGold.withValues(alpha: 0.4),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars, color: CaixaAppTheme.warmGold, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sugestão de Fichas (Dots)',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? CaixaAppTheme.warmGold : const Color(0xFF7A4E00),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _buildFichasSuggestion(widget.totalCents),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Forma de Pagamento (Grid 2x2 no estilo Stitch)
                      Text(
                        'FORMA DE PAGAMENTO',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final methods = [
                            {'id': PaymentMethod.dinheiro, 'label': 'Dinheiro', 'icon': Icons.payments_outlined},
                            {'id': PaymentMethod.pix, 'label': 'PIX', 'icon': Icons.qr_code_2_rounded},
                            {'id': PaymentMethod.cartaoDebito, 'label': 'Débito', 'icon': Icons.credit_card_outlined},
                            {'id': PaymentMethod.cartaoCredito, 'label': 'Crédito', 'icon': Icons.credit_score_outlined},
                            {'id': PaymentMethod.fiado, 'label': 'Fiado', 'icon': Icons.handshake_outlined},
                          ];

                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.3,
                            children: methods.map((m) {
                              final isSelected = _payment == m['id'];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _payment = m['id'] as String;
                                    _syncReceivedField();
                                  });
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? CaixaAppTheme.marianBlue.withValues(alpha: 0.08)
                                        : (isDark ? Colors.grey.shade900 : Colors.white),
                                    border: Border.all(
                                      color: isSelected
                                          ? CaixaAppTheme.marianBlue
                                          : (isDark ? Colors.white12 : Colors.grey.shade300),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        m['icon'] as IconData,
                                        size: 22,
                                        color: isSelected
                                            ? CaixaAppTheme.marianBlue
                                            : Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          m['label'] as String,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? CaixaAppTheme.marianBlue
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: CaixaAppTheme.marianBlue,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Painel de QR Code PIX Dinâmico (se a forma for PIX)
                      if (_payment == PaymentMethod.pix) ...[
                        _buildPixSection(context, event, isDark),
                        const SizedBox(height: 16),
                      ],

                      // Campo de Valor Recebido (oculto se PIX)
                      if (_payment != PaymentMethod.pix) ...[
                        TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: isFiado
                                ? 'Entrada paga agora (opcional)'
                                : isCash
                                    ? 'Valor recebido em dinheiro'
                                    : 'Valor cobrado',
                            prefixText: 'R\$ ',
                            prefixStyle: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],

                      // Atalhos de Dinheiro e Cálculo de Troco
                      if (isCash) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            ActionChip(
                              label: Text(
                                'Exato',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: CaixaAppTheme.marianBlue,
                                ),
                              ),
                              backgroundColor: CaixaAppTheme.marianBlue.withValues(alpha: 0.1),
                              side: BorderSide(color: CaixaAppTheme.marianBlue.withValues(alpha: 0.3)),
                              onPressed: () {
                                setState(() {
                                  _syncReceivedField();
                                });
                              },
                            ),
                            ...[10, 20, 50, 100, 200].map((reais) {
                              return ActionChip(
                                label: Text(
                                  'R\$ $reais',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller.text = reais.toStringAsFixed(2).replaceAll('.', ',');
                                  });
                                },
                              );
                            }),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Assistente de Troco
                        if (_received != null && _received! >= widget.totalCents) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.price_check, color: Colors.green, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Troco a devolver:',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                      Text(
                                        formatCents(change),
                                        style: GoogleFonts.outfit(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (_received != null && _received! < widget.totalCents) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Faltam ${formatCents(widget.totalCents - _received!)}',
                                  style: GoogleFonts.inter(
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Troco Pendente
                        if (_received != null && change > 0) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade900 : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _changePending
                                    ? CaixaAppTheme.warmGold
                                    : (isDark ? Colors.white12 : Colors.grey.shade200),
                              ),
                            ),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: Text(
                                    'Troco pendente',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    'Marque se o cliente buscar o troco depois',
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                  value: _changePending,
                                  activeTrackColor: CaixaAppTheme.warmGold,
                                  onChanged: (v) => setState(() => _changePending = v),
                                ),
                                if (_changePending)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                    child: TextField(
                                      controller: _customerNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Nome do cliente *',
                                        hintText: 'Ex: Dona Maria',
                                        filled: true,
                                        fillColor: isDark ? Colors.black26 : CaixaAppTheme.ivoryCanvas,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      textCapitalization: TextCapitalization.words,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],

                      // Fiado: nome do cliente obrigatório + saldo devedor atual
                      if (isFiado) ...[
                        const SizedBox(height: 12),
                        _buildFiadoSection(context, isDark),
                      ],

                      const SizedBox(height: 12),

                      // Campo de Observações
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Observações (opcional)',
                          prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade900 : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 20),

                      // Botão Confirmar Pagamento
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () {
                            final r = _received;
                            if (_payment == PaymentMethod.fiado) {
                              final entrada = r ?? 0;
                              if (entrada < 0 || entrada >= widget.totalCents) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('A entrada do fiado deve ser menor que o total (ou zero)')),
                                );
                                return;
                              }
                              if (_customerNameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Venda fiada exige o nome do cliente')),
                                );
                                return;
                              }
                              Navigator.pop(
                                context,
                                _CheckoutResult(
                                  paymentMethod: _payment,
                                  amountReceivedCents: entrada,
                                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                                  customerName: _customerNameController.text.trim(),
                                ),
                              );
                              return;
                            }
                            if (r == null || r < widget.totalCents) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Valor recebido é menor que o total da venda')),
                              );
                              return;
                            }

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
                                customerName: _customerNameController.text.trim().isEmpty
                                    ? null
                                    : _customerNameController.text.trim(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(
                            'CONFIRMAR PAGAMENTO',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: CaixaAppTheme.marianBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiadoSection(BuildContext context, bool isDark) {
    final db = ref.read(appDatabaseProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CaixaAppTheme.warmGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_outlined,
                  color: CaixaAppTheme.warmGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Venda fiada — fica em aberto no nome do cliente',
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customerNameController,
            decoration: InputDecoration(
              labelText: 'Nome do cliente *',
              hintText: 'Ex: João da Silva',
              filled: true,
              fillColor: isDark ? Colors.black26 : CaixaAppTheme.ivoryCanvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          FutureBuilder<List<String>>(
            future: db.customerNameSuggestions(_customerNameController.text),
            builder: (context, snap) {
              final suggestions = (snap.data ?? const <String>[])
                  .where((n) =>
                      n.toLowerCase() !=
                      _customerNameController.text.trim().toLowerCase())
                  .take(4)
                  .toList();
              if (suggestions.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: suggestions
                      .map((n) => ActionChip(
                            label: Text(n,
                                style: GoogleFonts.inter(fontSize: 12)),
                            onPressed: () => setState(
                                () => _customerNameController.text = n),
                          ))
                      .toList(),
                ),
              );
            },
          ),
          FutureBuilder<int>(
            future: _customerNameController.text.trim().isEmpty
                ? Future.value(0)
                : db.customerFiadoOpenCents(_customerNameController.text),
            builder: (context, snap) {
              final open = snap.data ?? 0;
              if (open <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_customerNameController.text.trim()} já deve ${formatCents(open)} em fiados.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPixSection(BuildContext context, ChurchEvent? event, bool isDark) {
    final key = event?.pixKey?.trim();
    if (key == null || key.isEmpty) {
      return _buildEmptyPixCard(context, event, isDark);
    }
    return _buildPixCard(context, event, key, isDark);
  }

  Widget _buildPixCard(BuildContext context, ChurchEvent? event, String key, bool isDark) {
    final merchantName = (event?.pixMerchantName != null && event!.pixMerchantName!.trim().isNotEmpty)
        ? event.pixMerchantName!.trim()
        : (event?.title.trim().isNotEmpty == true ? event!.title.trim() : 'CANTINA');
    final merchantCity = (event?.pixMerchantCity != null && event!.pixMerchantCity!.trim().isNotEmpty)
        ? event.pixMerchantCity!.trim()
        : 'CIDADE';

    final payload = PixPayload(
      pixKey: key,
      merchantName: merchantName,
      merchantCity: merchantCity,
      amount: widget.totalCents / 100.0,
      description: 'Venda',
    );
    final pixCode = payload.generateCode();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CaixaAppTheme.marianBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CaixaAppTheme.marianBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded, color: CaixaAppTheme.marianBlue, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pague com PIX',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: CaixaAppTheme.marianBlue,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Editar chave PIX',
                onPressed: () => _showEditPixKeyDialog(context, event),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: pixCode,
              version: QrVersions.auto,
              size: 160,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aponte o celular do cliente para o QR Code',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Chave: $key • $merchantName',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: pixCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Código PIX Copia e Cola copiado!'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copiar Código PIX'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPixCard(BuildContext context, ChurchEvent? event, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CaixaAppTheme.warmGold.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2_rounded, size: 36, color: CaixaAppTheme.warmGold),
          const SizedBox(height: 8),
          Text(
            'Chave PIX não cadastrada',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cadastre a chave PIX deste evento para gerar o QR Code automático com o valor da venda.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _showEditPixKeyDialog(context, event),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Cadastrar Chave PIX'),
            style: FilledButton.styleFrom(
              backgroundColor: CaixaAppTheme.marianBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPixKeyDialog(BuildContext context, ChurchEvent? event) async {
    final keyCtrl = TextEditingController(text: event?.pixKey ?? '');
    final nameCtrl = TextEditingController(text: event?.pixMerchantName ?? '');
    final cityCtrl = TextEditingController(text: event?.pixMerchantCity ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.qr_code_2_rounded, color: CaixaAppTheme.marianBlue),
            const SizedBox(width: 8),
            Text(
              'Chave PIX do Evento',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Chave PIX',
                  hintText: 'CNPJ, CPF, Celular, E-mail ou Aleatória',
                  prefixIcon: Icon(Icons.key_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome do Recebedor / Paróquia',
                  hintText: 'Ex: Paroquia N Sra Aparecida',
                  prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cidade do Recebedor',
                  hintText: 'Ex: Sao Paulo',
                  prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (keyCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: CaixaAppTheme.marianBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (saved == true && event != null) {
      final db = ref.read(appDatabaseProvider);
      await (db.update(db.events)..where((e) => e.id.equals(event.id))).write(
        EventsCompanion(
          pixKey: Value(keyCtrl.text.trim()),
          pixMerchantName: Value(nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim()),
          pixMerchantCity: Value(cityCtrl.text.trim().isEmpty ? null : cityCtrl.text.trim()),
        ),
      );
    }
  }
}

