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

