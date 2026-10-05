/// Motivos de movimentação de estoque (`stock_movements.reason`).
class StockMovementReason {
  /// Carga inicial / baseline criado na migração ou no cadastro.
  static const initial = 0;

  /// Baixa por venda.
  static const sale = 1;

  /// Devolução por edição ou exclusão de venda.
  static const saleRevert = 2;

  /// Ajuste manual (edição de produto ou ficha com valor absoluto).
  static const manualAdjust = 3;

  /// Fichas entregues como troco.
  static const changeDots = 4;

  /// Devolução de fichas de troco (edição/exclusão da venda).
  static const changeDotsRevert = 5;

  static String label(int reason) => switch (reason) {
        initial => 'Carga inicial',
        sale => 'Venda',
        saleRevert => 'Devolução (venda)',
        manualAdjust => 'Ajuste manual',
        changeDots => 'Troco em fichas',
        changeDotsRevert => 'Devolução (troco)',
        _ => 'Outro',
      };
}
