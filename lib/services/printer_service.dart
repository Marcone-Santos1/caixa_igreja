import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

/// Serviço responsável pela comunicação e impressão térmica via Bluetooth padrão ESC/POS (58mm).
class PrinterService {
  PrinterService({BlueThermalPrinter? printer})
      : _printer = printer ?? BlueThermalPrinter.instance;

  final BlueThermalPrinter _printer;

  /// Retorna a lista de dispositivos Bluetooth previamente pareados no dispositivo.
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      final devices = await _printer.getBondedDevices();
      return devices;
    } catch (e) {
      return [];
    }
  }

  /// Conecta a um dispositivo Bluetooth pareado.
  Future<bool> connect(BluetoothDevice device) async {
    try {
      final isAlreadyConnected = await _printer.isConnected ?? false;
      if (isAlreadyConnected) {
        await _printer.disconnect();
      }
      await _printer.connect(device);
      return await _printer.isConnected ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Desconecta da impressora Bluetooth conectada.
  Future<bool> disconnect() async {
    try {
      await _printer.disconnect();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se a impressora está conectada no momento.
  Future<bool> isConnected() async {
    try {
      return await _printer.isConnected ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Imprime o ticket de pedido no formato padrão 58mm (CANTINA).
  ///
  /// [orderNumber]: Senha ou número do pedido.
  /// [items]: Lista com itens vendidos (chaves aceitas: 'name'/'nome', 'qty'/'quantidade', 'subtotal'/'price').
  /// [total]: Valor total do pedido em reais.
  /// [headerTitle]: Título do cabeçalho (ex: Nome do Evento ou CANTINA).
  /// [paymentMethod]: Forma de pagamento (ex: Dinheiro, PIX, Cartão).
  /// [amountReceived]: Valor em reais entregue pelo cliente.
  /// [change]: Troco a ser devolvido ao cliente.
  /// [customerName]: Nome do cliente (se informado).
  /// [notes]: Observações do pedido.
  Future<bool> printTicket({
    String? orderNumber,
    required List<Map<String, dynamic>> items,
    required double total,
    String? headerTitle,
    String? paymentMethod,
    double? amountReceived,
    double? change,
    String? customerName,
    String? notes,
    String? terminalTag,
  }) async {
    final connected = await isConnected();
    if (!connected) {
      throw StateError('Impressora não conectada via Bluetooth.');
    }

    // Carrega perfil padrão e gerador ESC/POS para papel 58mm
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);

    // 1. Cabeçalho
    final title = (headerTitle != null && headerTitle.trim().isNotEmpty)
        ? headerTitle.trim()
        : 'CANTINA';
    bytes.addAll(
      generator.text(
        _removeAccents(title),
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        dateStr,
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    if (terminalTag != null && terminalTag.trim().isNotEmpty) {
      bytes.addAll(
        generator.text(
          '[ ${_removeAccents(terminalTag.trim().toUpperCase())} ]',
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      );
    }
    bytes.addAll(generator.hr());

    // Cliente (se informado)
    if (customerName != null && customerName.trim().isNotEmpty) {
      bytes.addAll(
        generator.text(
          _removeAccents('Cliente: ${customerName.trim()}'),
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      );
      bytes.addAll(generator.hr());
    }

    // 3. Cabeçalho de Itens
    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'QTD ITEM',
          width: 8,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'SUBTOTAL',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]),
    );
    bytes.addAll(generator.hr(ch: '-'));

    // 4. Lista de Itens
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    for (final item in items) {
      final rawName = (item['name'] ?? item['nome'] ?? item['title'] ?? 'Item')
          .toString();
      final cleanName = _removeAccents(rawName);

      final qty = (item['qty'] ?? item['quantidade'] ?? 1).toString();
      final subtotalNum = (item['subtotal'] ?? item['price'] ?? item['valor'] ?? 0.0);
      final double subtotal = subtotalNum is num ? subtotalNum.toDouble() : 0.0;
      final subtotalStr = currencyFmt.format(subtotal).replaceAll('R\$', 'R\$ ');

      bytes.addAll(
        generator.row([
          PosColumn(
            text: '${qty}x $cleanName',
            width: 8,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: _removeAccents(subtotalStr),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }
    bytes.addAll(generator.hr());

    // 5. Total
    final totalFormatted = currencyFmt.format(total).replaceAll('R\$', 'R\$ ');
    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 6,
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: _removeAccents(totalFormatted),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      ]),
    );

    // 6. Informações de Pagamento e Troco
    if (paymentMethod != null && paymentMethod.trim().isNotEmpty) {
      bytes.addAll(
        generator.row([
          PosColumn(
            text: 'PAGAMENTO',
            width: 6,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: _removeAccents(paymentMethod.trim()),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }
    if (amountReceived != null && amountReceived > 0) {
      final recFormatted = currencyFmt.format(amountReceived).replaceAll('R\$', 'R\$ ');
      bytes.addAll(
        generator.row([
          PosColumn(
            text: 'VALOR PAGO',
            width: 6,
          ),
          PosColumn(
            text: _removeAccents(recFormatted),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }
    if (change != null && change > 0) {
      final changeFormatted = currencyFmt.format(change).replaceAll('R\$', 'R\$ ');
      bytes.addAll(
        generator.row([
          PosColumn(
            text: 'TROCO',
            width: 6,
            styles: const PosStyles(bold: true),
          ),
          PosColumn(
            text: _removeAccents(changeFormatted),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );
    }
    if (notes != null && notes.trim().isNotEmpty) {
      bytes.addAll(generator.hr(ch: '-'));
      bytes.addAll(
        generator.text(
          _removeAccents('Obs: ${notes.trim()}'),
          styles: const PosStyles(align: PosAlign.left),
        ),
      );
    }
    bytes.addAll(generator.hr());

    // 6. Rodapé
    bytes.addAll(
      generator.text(
        _removeAccents('Deus abencoe!'),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
      ),
    );

    // 7. Avanço suave apenas para passar da serrilha manual
    bytes.addAll(generator.feed(1));

    // Envio direto dos bytes ESC/POS brutos à impressora
    await _printer.writeBytes(Uint8List.fromList(bytes));
    return true;
  }

  /// Imprime canhotos / fichas individuais de retirada no balcão (Cozinha e Bar).
  ///
  /// [orderNumber]: Senha ou número do pedido.
  /// [items]: Lista com itens vendidos (chaves: 'name'/'nome', 'qty'/'quantidade').
  /// [eventTitle]: Nome do evento / comunidade.
  /// [customerName]: Nome do cliente (se informado).
  /// [perUnit]: Se true, imprime 1 ficha para cada unidade comprada (ex: 2x Pastel = 2 fichas de 1x).
  ///            Se false, imprime 1 ficha agrupada por produto (ex: 1 ficha de 2x Pastel).
  Future<bool> printDeliveryVouchers({
    required String orderNumber,
    required List<Map<String, dynamic>> items,
    String? eventTitle,
    String? customerName,
    bool perUnit = true,
  }) async {
    final connected = await isConnected();
    if (!connected) {
      throw StateError('Impressora não conectada via Bluetooth.');
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);
    final title = (eventTitle != null && eventTitle.trim().isNotEmpty)
        ? eventTitle.trim().toUpperCase()
        : 'CANTINA';

    final vouchersToPrint = <Map<String, dynamic>>[];
    for (final item in items) {
      final rawName = (item['name'] ?? item['nome'] ?? item['title'] ?? 'Item').toString();
      final cleanName = _removeAccents(rawName);
      final rawQty = item['qty'] ?? item['quantidade'] ?? 1;
      final int qty = (rawQty is num) ? rawQty.toInt() : (int.tryParse(rawQty.toString()) ?? 1);

      if (perUnit && qty > 1) {
        for (int i = 0; i < qty; i++) {
          vouchersToPrint.add({
            'name': cleanName,
            'qty': 1,
            'unitIndex': i + 1,
            'unitTotal': qty,
          });
        }
      } else {
        vouchersToPrint.add({
          'name': cleanName,
          'qty': qty,
        });
      }
    }

    if (vouchersToPrint.isEmpty) return false;

    for (int idx = 0; idx < vouchersToPrint.length; idx++) {
      final v = vouchersToPrint[idx];
      final itemName = v['name'] as String;
      final itemQty = v['qty'] as int;
      final unitIndex = v['unitIndex'] as int?;
      final unitTotal = v['unitTotal'] as int?;

      // Cabeçalho do Canhoto
      bytes.addAll(generator.hr());
      bytes.addAll(
        generator.text(
          'FICHA DE RETIRADA',
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
          ),
        ),
      );
      bytes.addAll(
        generator.text(
          'PEDIDO #$orderNumber',
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      );
      bytes.addAll(generator.hr(ch: '-'));

      // Nome do Item em destaque
      final itemLabel = '${itemQty}x $itemName';
      bytes.addAll(
        generator.text(
          itemLabel,
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      );

      if (unitIndex != null && unitTotal != null) {
        bytes.addAll(
          generator.text(
            '(Unidade $unitIndex de $unitTotal)',
            styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
            ),
          ),
        );
      }

      bytes.addAll(generator.hr(ch: '-'));

      if (customerName != null && customerName.trim().isNotEmpty) {
        bytes.addAll(
          generator.text(
            _removeAccents('Cliente: ${customerName.trim()}'),
            styles: const PosStyles(align: PosAlign.center),
          ),
        );
      }

      bytes.addAll(
        generator.text(
          dateStr,
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
      bytes.addAll(
        generator.text(
          _removeAccents(title),
          styles: const PosStyles(align: PosAlign.center),
        ),
      );

      // Linha pontilhada de destaque
      bytes.addAll(generator.feed(1));
      bytes.addAll(
        generator.text(
          '- - - - - - - - - - - - - - - -',
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
      bytes.addAll(generator.feed(1));
    }

    await _printer.writeBytes(Uint8List.fromList(bytes));
    return true;
  }

  /// Imprime o relatório de fechamento / resumo de vendas na impressora térmica 58mm.
  Future<bool> printSummaryReport({
    required String eventTitle,
    required double totalRevenue,
    required int totalSalesCount,
    required Map<String, double> revenueByPaymentMethod,
    List<Map<String, dynamic>> pendingChanges = const [],
  }) async {
    final connected = await isConnected();
    if (!connected) {
      throw StateError('Impressora não conectada via Bluetooth.');
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm:ss').format(now);
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // 1. Cabeçalho
    bytes.addAll(
      generator.text(
        _removeAccents(eventTitle.toUpperCase()),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'RESUMO DE VENDAS',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(
      generator.text(
        dateStr,
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr());

    // 2. Total Geral e Contagem
    final totalFormatted = currencyFmt.format(totalRevenue).replaceAll('R\$', 'R\$ ');
    bytes.addAll(
      generator.row([
        PosColumn(
          text: 'TOTAL',
          width: 5,
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
        PosColumn(
          text: _removeAccents(totalFormatted),
          width: 7,
          styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size2),
        ),
      ]),
    );
    bytes.addAll(
      generator.text(
        'Comandas emitidas: $totalSalesCount',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr(ch: '-'));

    // 3. Por Forma de Pagamento
    bytes.addAll(
      generator.text(
        'POR FORMA DE PAGAMENTO:',
        styles: const PosStyles(bold: true),
      ),
    );
    revenueByPaymentMethod.forEach((method, val) {
      if (val > 0) {
        final valStr = currencyFmt.format(val).replaceAll('R\$', 'R\$ ');
        bytes.addAll(
          generator.row([
            PosColumn(
              text: _removeAccents(method),
              width: 6,
            ),
            PosColumn(
              text: _removeAccents(valStr),
              width: 6,
              styles: const PosStyles(align: PosAlign.right, bold: true),
            ),
          ]),
        );
      }
    });

    // 4. Trocos Pendentes (se houver)
    if (pendingChanges.isNotEmpty) {
      bytes.addAll(generator.hr(ch: '-'));
      bytes.addAll(
        generator.text(
          'TROCOS PENDENTES:',
          styles: const PosStyles(bold: true),
        ),
      );
      for (final p in pendingChanges) {
        final name = (p['customerName'] ?? 'Cliente').toString();
        final changeVal = (p['change'] ?? 0.0) as double;
        final changeStr = currencyFmt.format(changeVal).replaceAll('R\$', 'R\$ ');
        bytes.addAll(
          generator.row([
            PosColumn(
              text: _removeAccents(name),
              width: 7,
            ),
            PosColumn(
              text: _removeAccents(changeStr),
              width: 5,
              styles: const PosStyles(align: PosAlign.right, bold: true),
            ),
          ]),
        );
      }
    }

    // 5. Rodapé
    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.text(
        _removeAccents('Comunidade N. Sra Aparecida'),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.feed(1));

    await _printer.writeBytes(Uint8List.fromList(bytes));
    return true;
  }

  /// Imprime o comprovante oficial de Fechamento de Caixa / Sessão na impressora térmica 58mm.
  Future<bool> printSessionClosingReceipt({
    required String eventTitle,
    required String sessionTitle,
    required DateTime openedAt,
    required DateTime closedAt,
    required double initialCashFloat,
    required double cashRevenue,
    required double cashChangeGiven,
    required double expectedInDrawer,
    double? countedInDrawer,
    required double totalRevenue,
    required int totalSalesCount,
    required Map<String, double> revenueByPaymentMethod,
    List<Map<String, dynamic>> pendingChanges = const [],
    String? closedBy,
    String? closedNotes,
  }) async {
    final connected = await isConnected();
    if (!connected) {
      throw StateError('Impressora não conectada via Bluetooth.');
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String fmt(double val) => currencyFmt.format(val).replaceAll('R\$', 'R\$ ');

    // 1. Cabeçalho
    bytes.addAll(
      generator.text(
        _removeAccents(eventTitle.toUpperCase()),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'FECHAMENTO DE CAIXA',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(
      generator.text(
        _removeAccents(sessionTitle),
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    bytes.addAll(generator.hr());

    // 2. Horários e Operador
    bytes.addAll(generator.text('Abertura: ${dateFmt.format(openedAt)}'));
    bytes.addAll(generator.text('Fechamento: ${dateFmt.format(closedAt)}'));
    if (closedBy != null && closedBy.isNotEmpty) {
      bytes.addAll(generator.text('Operador: ${_removeAccents(closedBy)}'));
    }
    bytes.addAll(generator.hr(ch: '-'));

    // 3. Faturamento Geral
    bytes.addAll(
      generator.row([
        PosColumn(text: 'TOTAL VENDAS', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: _removeAccents(fmt(totalRevenue)),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]),
    );
    bytes.addAll(generator.text('Comandas: $totalSalesCount'));
    bytes.addAll(generator.hr(ch: '-'));

    // 4. Detalhamento por Forma de Pagamento
    bytes.addAll(generator.text('RECEBIMENTOS:', styles: const PosStyles(bold: true)));
    revenueByPaymentMethod.forEach((method, val) {
      if (val > 0) {
        bytes.addAll(
          generator.row([
            PosColumn(text: _removeAccents(method), width: 6),
            PosColumn(
              text: _removeAccents(fmt(val)),
              width: 6,
              styles: const PosStyles(align: PosAlign.right, bold: true),
            ),
          ]),
        );
      }
    });
    bytes.addAll(generator.hr(ch: '-'));

    // 5. Conferência de Gaveta (Dinheiro)
    bytes.addAll(generator.text('CONFERENCIA DE GAVETA:', styles: const PosStyles(bold: true)));
    bytes.addAll(
      generator.row([
        PosColumn(text: '(+) Fundo Inicial', width: 7),
        PosColumn(text: _removeAccents(fmt(initialCashFloat)), width: 5, styles: const PosStyles(align: PosAlign.right)),
      ]),
    );
    bytes.addAll(
      generator.row([
        PosColumn(text: '(+) Vendas Dinheiro', width: 7),
        PosColumn(text: _removeAccents(fmt(cashRevenue)), width: 5, styles: const PosStyles(align: PosAlign.right)),
      ]),
    );
    if (cashChangeGiven > 0) {
      bytes.addAll(
        generator.row([
          PosColumn(text: '(-) Troco em Dinheiro', width: 7),
          PosColumn(text: _removeAccents(fmt(cashChangeGiven)), width: 5, styles: const PosStyles(align: PosAlign.right)),
        ]),
      );
    }
    bytes.addAll(
      generator.row([
        PosColumn(text: '(=) ESPERADO', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: _removeAccents(fmt(expectedInDrawer)),
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]),
    );

    if (countedInDrawer != null) {
      final diff = countedInDrawer - expectedInDrawer;
      bytes.addAll(
        generator.row([
          PosColumn(text: '(=) CONTADO', width: 6, styles: const PosStyles(bold: true)),
          PosColumn(
            text: _removeAccents(fmt(countedInDrawer)),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );
      final diffLabel = diff.abs() < 0.01
          ? 'DIFERENCA: OK (R\$ 0,00)'
          : (diff > 0 ? 'SOBRA: +${fmt(diff)}' : 'FALTA: ${fmt(diff)}');
      bytes.addAll(generator.text(diffLabel, styles: const PosStyles(align: PosAlign.center, bold: true)));
    }

    // 6. Trocos pendentes
    if (pendingChanges.isNotEmpty) {
      bytes.addAll(generator.hr(ch: '-'));
      bytes.addAll(generator.text('TROCOS PENDENTES:', styles: const PosStyles(bold: true)));
      for (final p in pendingChanges) {
        final name = (p['customerName'] ?? 'Cliente').toString();
        final changeVal = (p['change'] ?? 0.0) as double;
        bytes.addAll(
          generator.row([
            PosColumn(text: _removeAccents(name), width: 7),
            PosColumn(text: _removeAccents(fmt(changeVal)), width: 5, styles: const PosStyles(align: PosAlign.right)),
          ]),
        );
      }
    }

    if (closedNotes != null && closedNotes.isNotEmpty) {
      bytes.addAll(generator.hr(ch: '-'));
      bytes.addAll(generator.text('Obs: ${_removeAccents(closedNotes)}'));
    }

    // 7. Canhoto de Assinaturas
    bytes.addAll(generator.hr());
    bytes.addAll(generator.feed(1));
    bytes.addAll(generator.text('________________________________', styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(generator.text('Operador de Caixa', styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(generator.feed(1));
    bytes.addAll(generator.text('________________________________', styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(generator.text('Coordenador / Pastoral', styles: const PosStyles(align: PosAlign.center)));
    bytes.addAll(generator.feed(2));

    await _printer.writeBytes(Uint8List.fromList(bytes));
    return true;
  }

  /// Remove caracteres acentuados e caracteres especiais incompatíveis
  /// com a tabela de caracteres padrão (CodePage 437/ASCII) de mini impressoras chinesas de 58mm.
  String _removeAccents(String text) {
    const withAccents =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÌÍÎÏìíîïÙÚÛÜùúûüÇçÑñÝýÿ';
    const withoutAccents =
        'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeIIIIiiiiUUUUuuuuCcNnYyy';

    var result = text;
    for (var i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }

  /// Visível apenas para validação em testes automatizados.
  String removeAccentsForTesting(String text) => _removeAccents(text);
}
