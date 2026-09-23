import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/printer_service.dart';
import 'shared_preferences_provider.dart';

/// Provider global da instância de PrinterService.
final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterService();
});

/// Provider de preferência para imprimir o ticket automaticamente ao finalizar cada venda.
final autoPrintEnabledProvider =
    StateNotifierProvider<AutoPrintNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AutoPrintNotifier(prefs);
});

class AutoPrintNotifier extends StateNotifier<bool> {
  AutoPrintNotifier(this._prefs)
      : super(_prefs.getBool(_kAutoPrintKey) ?? true);

  static const _kAutoPrintKey = 'printer_auto_print_enabled';
  final SharedPreferences _prefs;

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _prefs.setBool(_kAutoPrintKey, enabled);
  }
}

/// Provider que verifica o status de conexão atual da impressora térmica Bluetooth.
final printerConnectedProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(printerServiceProvider);
  return await service.isConnected();
});

/// Provider de preferência para emitir fichas / canhotos de balcão (Cozinha/Bar).
final printDeliveryVouchersEnabledProvider =
    StateNotifierProvider<DeliveryVouchersNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DeliveryVouchersNotifier(prefs);
});

class DeliveryVouchersNotifier extends StateNotifier<bool> {
  DeliveryVouchersNotifier(this._prefs)
      : super(_prefs.getBool(_kKey) ?? true);

  static const _kKey = 'printer_delivery_vouchers_enabled';
  final SharedPreferences _prefs;

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _prefs.setBool(_kKey, enabled);
  }
}

/// Provider para escolher o formato de fichas:
/// - true: 1 ficha para cada unidade comprada (ex: 2x Pastel = 2 fichas individuais)
/// - false: 1 ficha agrupada por produto (ex: 1 ficha com "2x Pastel")
final deliveryVouchersPerUnitProvider =
    StateNotifierProvider<DeliveryVouchersPerUnitNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DeliveryVouchersPerUnitNotifier(prefs);
});

class DeliveryVouchersPerUnitNotifier extends StateNotifier<bool> {
  DeliveryVouchersPerUnitNotifier(this._prefs)
      : super(_prefs.getBool(_kKey) ?? true);

  static const _kKey = 'printer_vouchers_per_unit';
  final SharedPreferences _prefs;

  Future<void> toggle(bool perUnit) async {
    state = perUnit;
    await _prefs.setBool(_kKey, perUnit);
  }
}


