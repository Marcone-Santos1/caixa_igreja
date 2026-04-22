/// Tipo de linha na venda (tabela `sale_lines.line_kind`).
abstract class SaleLineKind {
  static const int product = 0;
  static const int valorLivre = 1;
  static const int ficha = 2;
}
