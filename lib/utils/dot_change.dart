import '../data/database.dart';

/// Alocação sugerida: quantas fichas de cada denominação (troco exato, greedy maior valor primeiro).
List<({int dotDenominationId, int qty})> suggestChangeAllocation({
  required int changeCents,
  required List<EventDotDenom> denoms,
}) {
  if (changeCents <= 0) return [];
  final sorted = [...denoms]..sort((a, b) => b.valueCents.compareTo(a.valueCents));
  var remaining = changeCents;
  final out = <({int dotDenominationId, int qty})>[];
  for (final d in sorted) {
    if (remaining <= 0 || d.valueCents <= 0) continue;
    final maxByChange = remaining ~/ d.valueCents;
    final take = maxByChange < d.stockQty ? maxByChange : d.stockQty;
    if (take > 0) {
      out.add((dotDenominationId: d.id, qty: take));
      remaining -= take * d.valueCents;
    }
  }
  return out;
}

int allocationTotalCents(
  List<({int dotDenominationId, int qty})> alloc,
  List<EventDotDenom> denoms,
) {
  final byId = {for (final d in denoms) d.id: d};
  var t = 0;
  for (final a in alloc) {
    final d = byId[a.dotDenominationId];
    if (d == null) continue;
    t += a.qty * d.valueCents;
  }
  return t;
}
