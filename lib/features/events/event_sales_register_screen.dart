import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/app_theme.dart';
import '../../app/ui_kit.dart';
import '../../data/database.dart';
import '../../domain/payment_method.dart';
import '../../domain/sale_line_kind.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/event_dashboard_provider.dart';
import '../../providers/printer_provider.dart';
import '../../utils/money_format.dart';

final _dateTimeFmt = DateFormat.yMd('pt_BR').add_Hm();

class EventSalesRegisterScreen extends ConsumerWidget {
  const EventSalesRegisterScreen({super.key, required this.eventId});

  final String eventId;

  Future<void> _reprintSaleTicket(
    BuildContext context,
    WidgetRef ref,
    PosSale sale,
    List<EventSaleLineRow> lines,
  ) async {
    final printerService = ref.read(printerServiceProvider);
    final connected = await printerService.isConnected();
    if (!connected) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conecte a impressora em Configurações > Impressora antes de imprimir.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      final db = ref.read(appDatabaseProvider);
      String headerTitle = 'CANTINA';
      try {
        final ev = await (db.select(db.events)..where((e) => e.id.equals(sale.eventId))).getSingleOrNull();
        if (ev != null && ev.title.trim().isNotEmpty) {
          headerTitle = ev.title.trim();
        }
      } catch (_) {}

      final items = lines.map((l) => {
        'name': l.itemLabel,
        'qty': l.qty,
        'subtotal': l.lineTotalCents / 100.0,
      }).toList();

      final change = sale.amountReceivedCents - sale.totalCents;
      final orderNumber = sale.id.length > 4 ? sale.id.substring(0, 4).toUpperCase() : sale.id;

      await printerService.printTicket(
        orderNumber: orderNumber,
        items: items,
        total: sale.totalCents / 100.0,
        headerTitle: headerTitle,
        paymentMethod: PaymentMethod.label(sale.paymentMethod),
        amountReceived: sale.amountReceivedCents > 0 ? sale.amountReceivedCents / 100.0 : null,
        change: change > 0 ? change / 100.0 : null,
        customerName: sale.customerName,
        notes: sale.notes,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket enviado para a impressora!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao imprimir ticket: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteSale(BuildContext context, WidgetRef ref, String saleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir venda'),
        content: const Text(
          'Tem certeza que deseja excluir esta venda?\n\n'
          'Os produtos e fichas retornarão ao estoque.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final db = ref.read(appDatabaseProvider);
        await db.deleteSale(saleId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Venda excluída')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  Future<void> _resolvePendingChange(BuildContext context, WidgetRef ref, PosSale sale) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolver Pendência'),
        content: Text('Confirmar que o troco de ${formatCents(sale.amountReceivedCents - sale.totalCents)} foi entregue para ${sale.customerName ?? 'o cliente'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final db = ref.read(appDatabaseProvider);
        final newNotes = sale.notes == null || sale.notes!.isEmpty 
            ? 'Troco entregue para ${sale.customerName ?? 'o cliente'}.' 
            : '${sale.notes}\n[Troco entregue para ${sale.customerName ?? 'o cliente'}]';
            
        await db.updateSaleDetails(
          saleId: sale.id,
          paymentMethod: sale.paymentMethod,
          amountReceivedCents: sale.amountReceivedCents,
          notes: newNotes,
          changePending: false,
          customerName: sale.customerName,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pendência resolvida!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  Future<void> _shareSalesSummary(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final sales = await (db.select(db.sales)..where((s) => s.eventId.equals(eventId))).get();
    
    if (sales.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há vendas para exportar.')));
      }
      return;
    }

    final event = await (db.select(db.events)..where((e) => e.id.equals(eventId))).getSingle();

    int totalAmount = 0;
    Map<String, int> totalByMethod = {};
    List<PosSale> pendingChanges = [];

    for (final s in sales) {
      totalAmount += s.totalCents;
      totalByMethod[s.paymentMethod] = (totalByMethod[s.paymentMethod] ?? 0) + s.totalCents;
      if (s.changePending) {
        pendingChanges.add(s);
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('📊 *Resumo de Vendas: ${event.title}*');
    buffer.writeln('📅 Data: ${_dateTimeFmt.format(DateTime.now())}');
    buffer.writeln('');
    buffer.writeln('💰 *Total Arrecadado*: ${formatCents(totalAmount)}');
    buffer.writeln('');
    buffer.writeln('💳 *Por Forma de Pagamento*:');
    totalByMethod.forEach((method, amount) {
      buffer.writeln('• ${PaymentMethod.label(method)}: ${formatCents(amount)}');
    });
    buffer.writeln('');
    buffer.writeln('🧾 *Total de Vendas*: ${sales.length}');

    if (pendingChanges.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('⚠️ *TROCOS PENDENTES*:');
      for (final s in pendingChanges) {
        final change = s.amountReceivedCents - s.totalCents;
        buffer.writeln('• ${s.customerName ?? 'Não informado'}: ${formatCents(change)} (Venda #${s.id})');
      }
    }

    buffer.writeln('');
    buffer.writeln('📋 *LISTA DE VENDAS*:');
    for (final s in sales) {
      final when = DateTime.fromMillisecondsSinceEpoch(s.soldAtMs);
      final timeStr = DateFormat.Hm('pt_BR').format(when);
      final payStr = PaymentMethod.label(s.paymentMethod);
      buffer.writeln('• #${s.id} às $timeStr - ${formatCents(s.totalCents)} ($payStr)');
      
      try {
        final lines = await db.saleLinesForSale(s.id);
        if (lines.isNotEmpty) {
          final itemsStr = lines.map((l) => '${l.qty}x ${l.itemLabel}').join(', ');
          buffer.writeln('  ↳ $itemsStr');
        }
      } catch (_) {}
      
      if (s.notes != null && s.notes!.isNotEmpty) {
        buffer.writeln('  📝 Obs: ${s.notes!.replaceAll('\n', ' ')}');
      }
    }

    await SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  Future<void> _printSalesSummary(BuildContext context, WidgetRef ref) async {
    final printerService = ref.read(printerServiceProvider);
    final connected = await printerService.isConnected();
    if (!connected) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Conecte a impressora em Configurações > Impressora antes de imprimir.'),
            action: SnackBarAction(
              label: 'Conectar',
              onPressed: () => context.push('/printer'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final sales = await (db.select(db.sales)..where((s) => s.eventId.equals(eventId))).get();
    if (sales.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não há vendas para imprimir.')),
        );
      }
      return;
    }

    final event = await (db.select(db.events)..where((e) => e.id.equals(eventId))).getSingle();

    int totalAmount = 0;
    final Map<String, double> totalByMethod = {};
    final List<Map<String, dynamic>> pendingChanges = [];

    for (final s in sales) {
      totalAmount += s.totalCents;
      final label = PaymentMethod.label(s.paymentMethod);
      totalByMethod[label] = (totalByMethod[label] ?? 0.0) + (s.totalCents / 100.0);
      if (s.changePending) {
        final change = (s.amountReceivedCents - s.totalCents) / 100.0;
        pendingChanges.add({
          'customerName': s.customerName ?? 'Cliente #${s.id}',
          'change': change,
        });
      }
    }

    try {
      await printerService.printSummaryReport(
        eventTitle: event.title,
        totalRevenue: totalAmount / 100.0,
        totalSalesCount: sales.length,
        revenueByPaymentMethod: totalByMethod,
        pendingChanges: pendingChanges,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resumo de vendas impresso com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao imprimir resumo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final isClient = syncState.mode == SyncMode.client && syncState.isConnected;

    final salesAsync = ref.watch(eventSalesStreamProvider(eventId));
    final linesAsync = ref.watch(eventSaleLinesStreamProvider(eventId));
    final productsAsync = ref.watch(eventProductsStreamProvider(eventId));
    final denomsAsync = ref.watch(eventDenomsStreamProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de vendas',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Imprimir Resumo',
            onPressed: () => _printSalesSummary(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar Resumo',
            onPressed: () => _shareSalesSummary(context, ref),
          ),
        ],
      ),
      body: salesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err', style: TextStyle(color: Theme.of(context).colorScheme.error))),
        data: (list) {
          if (list.isEmpty) {
            return const CaixaEmptyHint(
              icon: Icons.receipt_long_outlined,
              message: 'Nenhuma venda neste evento',
            );
          }
          return linesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Erro: $err')),
            data: (linesList) => productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro: $err')),
              data: (productsList) => denomsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Erro: $err')),
                data: (denomsList) {
                  return ListView.separated(
                    padding: kCaixaScreenPadding.copyWith(top: 8, bottom: 24),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final s = list[i];
                      final when = DateTime.fromMillisecondsSinceEpoch(s.soldAtMs);
                      final change = s.amountReceivedCents - s.totalCents;
                      final pay = PaymentMethod.label(s.paymentMethod);
                      final isPending = s.changePending;
                      final isResolved = !isPending && s.customerName != null;

                      // Filter and map lines synchronously
                      final saleLines = linesList.where((l) => l.saleId == s.id).toList();
                      final lines = saleLines.map((l) {
                        String label = 'Item';
                        if (l.lineKind == SaleLineKind.valorLivre) {
                          label = 'Valor: ${l.freeLabel ?? ''}';
                        } else if (l.lineKind == SaleLineKind.ficha) {
                          final denom = denomsList.firstWhere((d) => d.id == l.dotDenominationId, orElse: () => EventDotDenom(id: '', eventId: '', label: 'Ficha', valueCents: 0, stockQty: 0));
                          label = 'Ficha: ${denom.label}';
                        } else if (l.lineKind == SaleLineKind.product) {
                          final prod = productsList.firstWhere((p) => p.id == l.productId, orElse: () => ChurchProduct(id: '', eventId: '', name: 'Produto', description: '', priceCents: 0, trackStock: false, stockQty: 0, active: true, isCombo: false));
                          label = prod.name;
                        }
                        return EventSaleLineRow(
                          itemLabel: label,
                          qty: l.qty,
                          unitPriceCents: l.unitPriceCents,
                          lineTotalCents: l.lineTotalCents,
                        );
                      }).toList();

                      final cardBg = isPending
                          ? CaixaAppTheme.warmGold.withValues(alpha: 0.12)
                          : isResolved
                              ? Colors.green.withValues(alpha: 0.08)
                              : Theme.of(context).colorScheme.surface;

                      final borderColor = isPending
                          ? CaixaAppTheme.warmGold.withValues(alpha: 0.6)
                          : isResolved
                              ? Colors.green.withValues(alpha: 0.4)
                              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5);

                      return Card(
                        color: cardBg,
                        elevation: isPending ? 1 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: borderColor, width: isPending ? 1.5 : 1.0),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          key: ValueKey(s.id),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            side: BorderSide.none,
                          ),
                          collapsedShape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            side: BorderSide.none,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: CaixaAppTheme.marianBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CaixaAppTheme.marianBlue.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              s.id.length > 6 ? s.id.substring(0, 6) : s.id,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: CaixaAppTheme.marianBlue,
                              ),
                            ),
                          ),
                          title: Text(
                            _dateTimeFmt.format(when),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '$pay · Total ${formatCents(s.totalCents)}'
                            '${change != 0 ? ' · Troco ${formatCents(change)}' : ''}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (s.notes != null && s.notes!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.notes, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            s.notes!,
                                            style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (s.changePending)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: CaixaAppTheme.warmGold.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: CaixaAppTheme.warmGold.withValues(alpha: 0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, size: 18, color: CaixaAppTheme.warmGold),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Troco pendente (${formatCents(s.amountReceivedCents - s.totalCents)}) para: ${s.customerName ?? 'Não informado'}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.brown.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  'ITENS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (lines.isEmpty)
                                  Text('Sem itens.', style: GoogleFonts.inter(fontSize: 13))
                                else
                                  ...lines.map(
                                    (l) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              l.itemLabel,
                                              style: GoogleFonts.inter(fontSize: 13),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${l.qty}× ${formatCents(l.unitPriceCents)}',
                                              textAlign: TextAlign.end,
                                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 88,
                                            child: Text(
                                              formatCents(l.lineTotalCents),
                                              textAlign: TextAlign.end,
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recebido',
                                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      formatCents(s.amountReceivedCents),
                                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _reprintSaleTicket(context, ref, s, lines),
                                      icon: const Icon(Icons.print_outlined, size: 16),
                                      label: Text('Imprimir', style: GoogleFonts.inter(fontSize: 13)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    if (isClient)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          'Edições permitidas apenas no Caixa Central',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      )
                                    else
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          if (s.changePending)
                                            FilledButton.icon(
                                              onPressed: () => _resolvePendingChange(context, ref, s),
                                              icon: const Icon(Icons.check_circle_outline, size: 16),
                                              label: Text('Baixar troco', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.green.shade700,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                visualDensity: VisualDensity.compact,
                                              ),
                                            ),
                                          IconButton.outlined(
                                            onPressed: () => context.push('/event/${s.eventId}/edit_sale/${s.id}'),
                                            icon: const Icon(Icons.edit_outlined, size: 16),
                                            tooltip: 'Editar Venda',
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          IconButton.outlined(
                                            onPressed: () => _deleteSale(context, ref, s.id),
                                            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                            tooltip: 'Excluir Venda',
                                            visualDensity: VisualDensity.compact,
                                            style: IconButton.styleFrom(
                                              side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
