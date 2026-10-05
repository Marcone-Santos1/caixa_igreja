import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Identidade local do aparelho, usada pelas colunas de sincronização
/// (`updatedByDevice`, `stock_movements.deviceId`) e pelo backup na nuvem.
///
/// Carregada em `main()` antes de o banco ser aberto. Os valores padrão
/// valem em testes, onde não há SharedPreferences.
class DeviceIdentity {
  static String deviceId = 'local';
  static String deviceName = 'Este aparelho';

  static Future<void> ensureLoaded(SharedPreferences prefs) async {
    var id = prefs.getString('device.id');
    if (id == null || id.isEmpty) {
      id = const Uuid().v7();
      await prefs.setString('device.id', id);
    }
    deviceId = id;
    deviceName = prefs.getString('device.name') ?? deviceName;
  }

  static Future<void> setDeviceName(SharedPreferences prefs, String name) async {
    deviceName = name.trim().isEmpty ? 'Este aparelho' : name.trim();
    await prefs.setString('device.name', deviceName);
  }
}
