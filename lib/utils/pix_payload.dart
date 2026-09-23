/// Utilitário puro em Dart para geração de Payload / BR Code do PIX (EMVCo).
/// Funciona 100% offline sem necessidade de conexões externas.
class PixPayload {
  PixPayload({
    required this.pixKey,
    required this.merchantName,
    required this.merchantCity,
    this.amount,
    this.txId = '***',
    this.description,
  });

  final String pixKey;
  final String merchantName;
  final String merchantCity;
  final double? amount;
  final String txId;
  final String? description;

  /// IDs de campos EMV padrão Banco Central
  static const _idPayloadFormatIndicator = '00';
  static const _idMerchantAccountInformation = '26';
  static const _idMerchantCategoryCode = '52';
  static const _idTransactionCurrency = '53';
  static const _idTransactionAmount = '54';
  static const _idCountryCode = '58';
  static const _idMerchantName = '59';
  static const _idMerchantCity = '60';
  static const _idAdditionalDataField = '62';
  static const _idCrc16 = '63';

  /// Monta o campo TLV (Tag, Length, Value)
  static String _formatTlv(String id, String value) {
    final len = value.length.toString().padLeft(2, '0');
    return '$id$len$value';
  }

  /// Remove acentos e caracteres especiais para compatibilidade com o padrão EMV
  static String _sanitize(String text, int maxLength) {
    var s = text
        .replaceAll(RegExp(r'[áàãâä]', caseSensitive: false), 'a')
        .replaceAll(RegExp(r'[éèêë]', caseSensitive: false), 'e')
        .replaceAll(RegExp(r'[íìîï]', caseSensitive: false), 'i')
        .replaceAll(RegExp(r'[óòõôö]', caseSensitive: false), 'o')
        .replaceAll(RegExp(r'[úùûü]', caseSensitive: false), 'u')
        .replaceAll(RegExp(r'[ç]', caseSensitive: false), 'c')
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), '')
        .trim();
    if (s.length > maxLength) {
      s = s.substring(0, maxLength);
    }
    return s;
  }

  /// Gera a string final do BR Code PIX (Copia e Cola e QR Code)
  String generateCode() {
    final cleanKey = pixKey.trim();
    var cleanName = _sanitize(merchantName.trim(), 25);
    if (cleanName.isEmpty) cleanName = 'IGREJA';

    var cleanCity = _sanitize(merchantCity.trim(), 15);
    if (cleanCity.isEmpty) cleanCity = 'CIDADE';

    var cleanTxId = _sanitize(txId.trim(), 25);
    if (cleanTxId.isEmpty) cleanTxId = '***';

    final sb = StringBuffer();

    // 00: Payload Format Indicator
    sb.write(_formatTlv(_idPayloadFormatIndicator, '01'));

    // 26: Merchant Account Information (GUI + Chave + Descrição opcional)
    final accountInfoSb = StringBuffer();
    accountInfoSb.write(_formatTlv('00', 'br.gov.bcb.pix'));
    accountInfoSb.write(_formatTlv('01', cleanKey));
    if (description != null && description!.trim().isNotEmpty) {
      accountInfoSb.write(_formatTlv('02', _sanitize(description!.trim(), 40)));
    }
    sb.write(_formatTlv(_idMerchantAccountInformation, accountInfoSb.toString()));

    // 52: Merchant Category Code (0000 padrão)
    sb.write(_formatTlv(_idMerchantCategoryCode, '0000'));

    // 53: Transaction Currency (986 = BRL)
    sb.write(_formatTlv(_idTransactionCurrency, '986'));

    // 54: Transaction Amount (opcional, formatado com 2 decimais)
    if (amount != null && amount! > 0) {
      final amountStr = amount!.toStringAsFixed(2);
      sb.write(_formatTlv(_idTransactionAmount, amountStr));
    }

    // 58: Country Code
    sb.write(_formatTlv(_idCountryCode, 'BR'));

    // 59: Merchant Name
    sb.write(_formatTlv(_idMerchantName, cleanName));

    // 60: Merchant City
    sb.write(_formatTlv(_idMerchantCity, cleanCity));

    // 62: Additional Data Field (TXID)
    final additionalData = _formatTlv('05', cleanTxId);
    sb.write(_formatTlv(_idAdditionalDataField, additionalData));

    // 63: CRC16 (Calculado sobre toda a string incluindo '6304')
    sb.write('$_idCrc16' '04');
    final payloadWithoutCrc = sb.toString();
    final crc = calculateCrc16(payloadWithoutCrc);
    final crcHex = crc.toRadixString(16).toUpperCase().padLeft(4, '0');

    return '$payloadWithoutCrc$crcHex';
  }

  /// Cálculo do CRC16-CCITT (polinômio 0x1021, valor inicial 0xFFFF)
  static int calculateCrc16(String str) {
    int crc = 0xFFFF;
    const polynomial = 0x1021;

    final bytes = str.codeUnits;
    for (final b in bytes) {
      for (int i = 0; i < 8; i++) {
        final bit = ((b >> (7 - i)) & 1) == 1;
        final c15 = ((crc >> 15) & 1) == 1;
        crc <<= 1;
        if (c15 ^ bit) {
          crc ^= polynomial;
        }
      }
    }

    return crc & 0xFFFF;
  }
}
