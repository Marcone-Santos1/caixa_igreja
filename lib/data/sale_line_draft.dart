import '../domain/sale_line_kind.dart';

/// Linha de venda antes de persistir.
class SaleLineDraft {
  SaleLineDraft._({
    required this.kind,
    this.productId,
    this.dotDenominationId,
    this.freeLabel,
    required this.qty,
    this.unitPriceCents,
    this.lineTotalCents,
  });

  factory SaleLineDraft.product({
    required int productId,
    required int qty,
    required int unitPriceCents,
  }) {
    return SaleLineDraft._(
      kind: SaleLineKind.product,
      productId: productId,
      qty: qty,
      unitPriceCents: unitPriceCents,
    );
  }

  factory SaleLineDraft.valorLivre({
    required String freeLabel,
    required int lineTotalCents,
  }) {
    return SaleLineDraft._(
      kind: SaleLineKind.valorLivre,
      freeLabel: freeLabel,
      qty: 1,
      unitPriceCents: lineTotalCents,
      lineTotalCents: lineTotalCents,
    );
  }

  factory SaleLineDraft.ficha({
    required int dotDenominationId,
    required int qty,
    required int unitPriceCents,
  }) {
    return SaleLineDraft._(
      kind: SaleLineKind.ficha,
      dotDenominationId: dotDenominationId,
      qty: qty,
      unitPriceCents: unitPriceCents,
    );
  }

  final int kind;
  final int? productId;
  final int? dotDenominationId;
  final String? freeLabel;
  final int qty;
  final int? unitPriceCents;
  final int? lineTotalCents;

  int resolveLineTotalCents() {
    switch (kind) {
      case SaleLineKind.valorLivre:
        return lineTotalCents ?? 0;
      default:
        return qty * (unitPriceCents ?? 0);
    }
  }

  int resolveUnitPriceCents() {
    switch (kind) {
      case SaleLineKind.valorLivre:
        return lineTotalCents ?? 0;
      default:
        return unitPriceCents ?? 0;
    }
  }
}
