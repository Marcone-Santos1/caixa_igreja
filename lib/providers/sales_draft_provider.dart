import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';

class FreeLineDraft {
  final String label;
  final int cents;
  FreeLineDraft({required this.label, required this.cents});
}

class SalesDraft {
  final String id;
  final String name;
  final Map<int, int> productQty; // productId -> qty
  final Map<int, int> fichaQty; // denomId -> qty
  final List<FreeLineDraft> freeLines;

  SalesDraft({
    required this.id,
    required this.name,
    Map<int, int>? productQty,
    Map<int, int>? fichaQty,
    List<FreeLineDraft>? freeLines,
  })  : productQty = productQty ?? {},
        fichaQty = fichaQty ?? {},
        freeLines = freeLines ?? [];

  bool get isEmpty =>
      productQty.isEmpty && fichaQty.isEmpty && freeLines.isEmpty;

  int totalCents(List<ChurchProduct> products, List<EventDotDenom> denoms) {
    var t = 0;
    for (final p in products) {
      final q = productQty[p.id] ?? 0;
      if (q > 0) t += q * p.priceCents;
    }
    for (final d in denoms) {
      final q = fichaQty[d.id] ?? 0;
      if (q > 0) t += q * d.valueCents;
    }
    for (final f in freeLines) {
      t += f.cents;
    }
    return t;
  }

  SalesDraft copyWith({
    String? name,
    Map<int, int>? productQty,
    Map<int, int>? fichaQty,
    List<FreeLineDraft>? freeLines,
  }) {
    return SalesDraft(
      id: id,
      name: name ?? this.name,
      productQty: productQty ?? Map.from(this.productQty),
      fichaQty: fichaQty ?? Map.from(this.fichaQty),
      freeLines: freeLines ?? List.from(this.freeLines),
    );
  }
}

class EventSalesDraftState {
  final List<SalesDraft> drafts;
  final String activeDraftId;

  EventSalesDraftState({
    required this.drafts,
    required this.activeDraftId,
  });

  SalesDraft get activeDraft =>
      drafts.firstWhere((d) => d.id == activeDraftId, orElse: () => drafts.first);
}

class EventSalesDraftNotifier extends StateNotifier<EventSalesDraftState> {
  EventSalesDraftNotifier(this.eventId)
      : super(EventSalesDraftState(
          drafts: [],
          activeDraftId: '',
        )) {
    final id = 'draft_${DateTime.now().millisecondsSinceEpoch}';
    state = EventSalesDraftState(
      drafts: [SalesDraft(id: id, name: 'Venda 1')],
      activeDraftId: id,
    );
  }

  final int eventId;

  void addDraft() {
    final numbers = state.drafts.map((d) {
      final match = RegExp(r'Venda (\d+)').firstMatch(d.name);
      return match != null ? int.parse(match.group(1)!) : 0;
    }).toList();
    final nextNum = numbers.isEmpty ? 1 : (numbers.reduce(max) + 1);

    final id = 'draft_${DateTime.now().millisecondsSinceEpoch}_$nextNum';
    final newDraft = SalesDraft(id: id, name: 'Venda $nextNum');

    state = EventSalesDraftState(
      drafts: [...state.drafts, newDraft],
      activeDraftId: id,
    );
  }

  void selectDraft(String id) {
    state = EventSalesDraftState(
      drafts: state.drafts,
      activeDraftId: id,
    );
  }

  void removeDraft(String id) {
    if (state.drafts.length <= 1) {
      clearDraft(id);
      return;
    }

    final newDrafts = state.drafts.where((d) => d.id != id).toList();
    String newActiveId = state.activeDraftId;
    if (state.activeDraftId == id) {
      final index = state.drafts.indexWhere((d) => d.id == id);
      if (index > 0) {
        newActiveId = state.drafts[index - 1].id;
      } else {
        newActiveId = state.drafts[1].id;
      }
    }

    state = EventSalesDraftState(
      drafts: newDrafts,
      activeDraftId: newActiveId,
    );
  }

  void clearDraft(String id) {
    state = EventSalesDraftState(
      drafts: state.drafts.map((d) {
        if (d.id == id) {
          return SalesDraft(id: d.id, name: d.name);
        }
        return d;
      }).toList(),
      activeDraftId: state.activeDraftId,
    );
  }

  void updateProductQty(int productId, int qty) {
    state = EventSalesDraftState(
      drafts: state.drafts.map((d) {
        if (d.id == state.activeDraftId) {
          final newProductQty = Map<int, int>.from(d.productQty);
          if (qty <= 0) {
            newProductQty.remove(productId);
          } else {
            newProductQty[productId] = qty;
          }
          return d.copyWith(productQty: newProductQty);
        }
        return d;
      }).toList(),
      activeDraftId: state.activeDraftId,
    );
  }

  void updateFichaQty(int denomId, int qty) {
    state = EventSalesDraftState(
      drafts: state.drafts.map((d) {
        if (d.id == state.activeDraftId) {
          final newFichaQty = Map<int, int>.from(d.fichaQty);
          if (qty <= 0) {
            newFichaQty.remove(denomId);
          } else {
            newFichaQty[denomId] = qty;
          }
          return d.copyWith(fichaQty: newFichaQty);
        }
        return d;
      }).toList(),
      activeDraftId: state.activeDraftId,
    );
  }

  void addFreeLine(String label, int cents) {
    state = EventSalesDraftState(
      drafts: state.drafts.map((d) {
        if (d.id == state.activeDraftId) {
          final newFreeLines = List<FreeLineDraft>.from(d.freeLines)
            ..add(FreeLineDraft(label: label, cents: cents));
          return d.copyWith(freeLines: newFreeLines);
        }
        return d;
      }).toList(),
      activeDraftId: state.activeDraftId,
    );
  }

  void removeFreeLine(FreeLineDraft freeLine) {
    state = EventSalesDraftState(
      drafts: state.drafts.map((d) {
        if (d.id == state.activeDraftId) {
          final newFreeLines = List<FreeLineDraft>.from(d.freeLines)
            ..remove(freeLine);
          return d.copyWith(freeLines: newFreeLines);
        }
        return d;
      }).toList(),
      activeDraftId: state.activeDraftId,
    );
  }
}

final vendaDraftsProvider = StateNotifierProvider.family<
    EventSalesDraftNotifier, EventSalesDraftState, int>((ref, eventId) {
  return EventSalesDraftNotifier(eventId);
});
