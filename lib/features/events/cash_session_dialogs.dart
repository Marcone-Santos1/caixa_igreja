import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../app/app_theme.dart';
import '../../data/database.dart';
import '../../domain/payment_method.dart';
import '../../providers/database_provider.dart';
import '../../providers/printer_provider.dart';
import '../../utils/money_format.dart';

/// Diálogo para Abertura de Caixa / Sessão
class OpenCashSessionDialog extends ConsumerStatefulWidget {
  const OpenCashSessionDialog({super.key, required this.eventId});

  final String eventId;

  static Future<bool?> show(BuildContext context, String eventId) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OpenCashSessionDialog(eventId: eventId),
    );
  }

  @override
  ConsumerState<OpenCashSessionDialog> createState() => _OpenCashSessionDialogState();
}

class _OpenCashSessionDialogState extends ConsumerState<OpenCashSessionDialog> {
  final _titleController = TextEditingController();
  final _floatController = TextEditingController(text: '0,00');
  final _operatorController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    _titleController.text = 'Sessão $dateStr';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _floatController.dispose();
    _operatorController.dispose();
    super.dispose();
  }

  int _parseCents(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  Future<void> _submit(int floatCents) async {
    final title = _titleController.text.trim().isEmpty ? 'Sessão de Vendas' : _titleController.text.trim();
    final openedBy = _operatorController.text.trim().isEmpty ? null : _operatorController.text.trim();

    setState(() => _isSubmitting = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.openCashSession(
        eventId: widget.eventId,
        title: title,
        initialCashFloatCents: floatCents,
        openedBy: openedBy,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir caixa: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CaixaAppTheme.marianBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.point_of_sale_rounded, color: CaixaAppTheme.marianBlue),
          ),
          const SizedBox(width: 12),
          Text(
            'Abrir Caixa do Dia',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informe a identificação da sessão e o troco inicial colocado na gaveta.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Identificação da Sessão',
                hintText: 'Ex: Domingo 23/09',
                prefixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _floatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Fundo de Troco Inicial (Dinheiro)',
                prefixText: 'R\$ ',
                prefixIcon: Icon(Icons.attach_money, size: 20),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                // Formatação simples de centavos
                final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                final cents = int.tryParse(digits) ?? 0;
                final formatted = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
                if (formatted != val) {
                  _floatController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _operatorController,
              decoration: const InputDecoration(
                labelText: 'Operador Responsável (Opcional)',
                prefixIcon: Icon(Icons.person_outline, size: 20),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : () => _submit(_parseCents(_floatController.text)),
          style: FilledButton.styleFrom(
            backgroundColor: CaixaAppTheme.marianBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Confirmar Abertura'),
        ),
      ],
    );
  }
}

/// Diálogo para Fechamento de Caixa / Sessão com Conferência Contábil e Impressão Térmica
class CloseCashSessionDialog extends ConsumerStatefulWidget {
  const CloseCashSessionDialog({
    super.key,
    required this.session,
    required this.sales,
    required this.eventTitle,
  });

  final CashSession session;
  final List<PosSale> sales;
  final String eventTitle;

  static Future<bool?> show({
    required BuildContext context,
    required CashSession session,
    required List<PosSale> sales,
    required String eventTitle,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CloseCashSessionDialog(
        session: session,
        sales: sales,
        eventTitle: eventTitle,
      ),
    );
  }

  @override
  ConsumerState<CloseCashSessionDialog> createState() => _CloseCashSessionDialogState();
}

class _CloseCashSessionDialogState extends ConsumerState<CloseCashSessionDialog> {
  final _countedController = TextEditingController();
  final _notesController = TextEditingController();
  final _closedByController = TextEditingController();
  bool _isSubmitting = false;

  int _countedCents = 0;
  bool _hasTypedCount = false;

  @override
  void initState() {
    super.initState();
    _closedByController.text = widget.session.closedBy ?? '';
  }

  @override
  void dispose() {
    _countedController.dispose();
    _notesController.dispose();
    _closedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final sales = widget.sales;

    // Cálculos Contábeis
    var totalRevenueCents = 0;
    var cashRevenueCents = 0;
    var cashChangeGivenCents = 0;
    final methodTotalsCents = <String, int>{};
    final pendingChangesList = <Map<String, dynamic>>[];

    for (final sale in sales) {
      totalRevenueCents += sale.totalCents;
      final m = sale.paymentMethod;
      methodTotalsCents[m] = (methodTotalsCents[m] ?? 0) + sale.totalCents;

      if (m == PaymentMethod.dinheiro) {
        cashRevenueCents += sale.totalCents;
        final ch = sale.amountReceivedCents - sale.totalCents;
        if (ch > 0 && !sale.changePending) {
          cashChangeGivenCents += ch;
        }
      }

      if (sale.changePending) {
        pendingChangesList.add({
          'customerName': sale.customerName ?? 'Cliente',
          'change': (sale.amountReceivedCents - sale.totalCents) / 100.0,
        });
      }
    }

    final initialFloatCents = s.initialCashFloatCents;
    final expectedDrawerCents = initialFloatCents + cashRevenueCents - cashChangeGivenCents;
    final diffCents = _hasTypedCount ? _countedCents - expectedDrawerCents : null;

    final openDate = DateTime.fromMillisecondsSinceEpoch(s.openedAtMs);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_clock_rounded, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fechamento de Caixa',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  s.title,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Aberto em: ${dateFmt.format(openDate)}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),

              // Quadro de Faturamento Total
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CaixaAppTheme.marianBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CaixaAppTheme.marianBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Faturamento Total (${sales.length} vendas)', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(formatCents(totalRevenueCents), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: CaixaAppTheme.marianBlue)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Meios de pagamento
              ...methodTotalsCents.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('• ${e.key}', style: GoogleFonts.inter(fontSize: 13)),
                        Text(formatCents(e.value), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
              const Divider(height: 20),

              // CONFERÊNCIA DE GAVETA (DINHEIRO)
              Text('CONFERÊNCIA DE GAVETA (DINHEIRO)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: CaixaAppTheme.marianBlue)),
              const SizedBox(height: 8),
              _drawerRow('(+) Fundo Inicial de Troco', formatCents(initialFloatCents)),
              _drawerRow('(+) Vendas em Dinheiro', formatCents(cashRevenueCents)),
              if (cashChangeGivenCents > 0)
                _drawerRow('(-) Trocos Pagos em Dinheiro', formatCents(cashChangeGivenCents)),
              const Divider(height: 16),
              _drawerRow(
                '(=) Esperado em Gaveta',
                formatCents(expectedDrawerCents),
                isBold: true,
                color: CaixaAppTheme.marianBlue,
              ),
              const SizedBox(height: 12),

              // Campo de contagem real
              TextField(
                controller: _countedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dinheiro Contado na Gaveta',
                  prefixText: 'R\$ ',
                  prefixIcon: Icon(Icons.money_rounded, size: 20),
                  border: OutlineInputBorder(),
                  hintText: '0,00',
                ),
                onChanged: (val) {
                  final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                  final cents = int.tryParse(digits) ?? 0;
                  setState(() {
                    _hasTypedCount = true;
                    _countedCents = cents;
                  });
                  final formatted = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
                  if (formatted != val) {
                    _countedController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),

              // Feedback de Diferença
              if (diffCents != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: diffCents == 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : (diffCents > 0 ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    diffCents == 0
                        ? '✓ Caixa conferido exato (sem sobra ou falta)'
                        : (diffCents > 0
                            ? '▲ Sobra de caixa: +${formatCents(diffCents)}'
                            : '▼ Falta de caixa: ${formatCents(diffCents)}'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: diffCents == 0 ? Colors.green.shade800 : (diffCents > 0 ? Colors.blue.shade900 : Colors.red.shade900),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              TextField(
                controller: _closedByController,
                decoration: const InputDecoration(
                  labelText: 'Operador de Fechamento',
                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (Opcional)',
                  prefixIcon: Icon(Icons.notes_rounded, size: 20),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _isSubmitting
              ? null
              : () => _finishAndPrint(
                    totalRevenueCents: totalRevenueCents,
                    cashRevenueCents: cashRevenueCents,
                    cashChangeGivenCents: cashChangeGivenCents,
                    expectedDrawerCents: expectedDrawerCents,
                    methodTotalsCents: methodTotalsCents,
                    pendingChangesList: pendingChangesList,
                  ),
          icon: const Icon(Icons.print_outlined, size: 18),
          label: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Fechar e Imprimir'),
          style: FilledButton.styleFrom(
            backgroundColor: CaixaAppTheme.marianBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _drawerRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishAndPrint({
    required int totalRevenueCents,
    required int cashRevenueCents,
    required int cashChangeGivenCents,
    required int expectedDrawerCents,
    required Map<String, int> methodTotalsCents,
    required List<Map<String, dynamic>> pendingChangesList,
  }) async {
    setState(() => _isSubmitting = true);
    final db = ref.read(appDatabaseProvider);
    final printerService = ref.read(printerServiceProvider);

    final closedNotes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final closedBy = _closedByController.text.trim().isEmpty ? null : _closedByController.text.trim();
    final countedDrawer = _hasTypedCount ? _countedCents : expectedDrawerCents;

    try {
      // 1. Fechar sessão no banco
      await db.closeCashSession(
        sessionId: widget.session.id,
        closedCashDrawerCents: countedDrawer,
        closedNotes: closedNotes,
        closedBy: closedBy,
      );

      // 2. Tentar imprimir comprovante
      final isPrinterReady = await printerService.isConnected();
      if (isPrinterReady) {
        final revenueByMethod = <String, double>{};
        methodTotalsCents.forEach((k, v) => revenueByMethod[k] = v / 100.0);

        await printerService.printSessionClosingReceipt(
          eventTitle: widget.eventTitle,
          sessionTitle: widget.session.title,
          openedAt: DateTime.fromMillisecondsSinceEpoch(widget.session.openedAtMs),
          closedAt: DateTime.now(),
          initialCashFloat: widget.session.initialCashFloatCents / 100.0,
          cashRevenue: cashRevenueCents / 100.0,
          cashChangeGiven: cashChangeGivenCents / 100.0,
          expectedInDrawer: expectedDrawerCents / 100.0,
          countedInDrawer: _hasTypedCount ? _countedCents / 100.0 : null,
          totalRevenue: totalRevenueCents / 100.0,
          totalSalesCount: widget.sales.length,
          revenueByPaymentMethod: revenueByMethod,
          pendingChanges: pendingChangesList,
          closedBy: closedBy,
          closedNotes: closedNotes,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPrinterReady ? 'Caixa fechado e comprovante impresso!' : 'Caixa fechado com sucesso! (Impressora desconectada)'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fechar caixa: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
