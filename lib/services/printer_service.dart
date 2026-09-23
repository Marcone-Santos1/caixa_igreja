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
