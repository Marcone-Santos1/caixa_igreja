abstract class PaymentMethod {
  static const String dinheiro = 'dinheiro';
  static const String pix = 'pix';
  static const String cartaoCredito = 'cartao_credito';
  static const String cartaoDebito = 'cartao_debito';
  static const String transferencia = 'transferencia';
  static const String outros = 'outros';

  static const List<String> all = [
    dinheiro,
    pix,
    cartaoCredito,
    cartaoDebito,
    transferencia,
    outros,
  ];

  static String label(String code) {
    switch (code) {
      case dinheiro:
        return 'Dinheiro';
      case pix:
        return 'PIX';
      case cartaoCredito:
        return 'Cartão crédito';
      case cartaoDebito:
        return 'Cartão débito';
      case transferencia:
        return 'Transferência';
      case outros:
      default:
        return 'Outros';
    }
  }
}
