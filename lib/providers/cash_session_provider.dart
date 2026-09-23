import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'database_provider.dart';

/// Stream da sessão de caixa atualmente aberta para o evento (ou null se fechado).
final activeCashSessionStreamProvider =
    StreamProvider.family<CashSession?, String>((ref, eventId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchActiveSession(eventId);
});

/// Stream de todas as sessões do evento (abertas e fechadas).
final eventCashSessionsStreamProvider =
    StreamProvider.family<List<CashSession>, String>((ref, eventId) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchSessions(eventId);
});

/// Filtro da sessão atualmente selecionada para visualização no Dashboard e no Registro.
/// `null` significa "Todas as sessões (Acumulado Geral)".
final selectedSessionFilterProvider =
    StateProvider.family<String?, String>((ref, eventId) => null);
