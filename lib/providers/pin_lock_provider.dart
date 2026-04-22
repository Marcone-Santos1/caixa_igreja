import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_preferences_provider.dart';

const _kPinDigestKey = 'pin_sha256';

String hashPinForStorage(String pin) {
  final bytes = utf8.encode(pin.trim());
  return sha256.convert(bytes).toString();
}

/// Incrementar após gravar ou limpar o PIN para forçar leitura nova das prefs.
final pinSettingsRevisionProvider = StateProvider<int>((ref) => 0);

final pinDigestProvider = Provider<String?>((ref) {
  ref.watch(pinSettingsRevisionProvider);
  final raw = ref.watch(sharedPreferencesProvider).getString(_kPinDigestKey);
  if (raw == null || raw.isEmpty) return null;
  return raw;
});

final hasPinConfiguredProvider = Provider<bool>((ref) {
  final d = ref.watch(pinDigestProvider);
  return d != null && d.isNotEmpty;
});

/// Após desbloquear com PIN correto fica `true` até encerrar a app.
final appUnlockedProvider = StateProvider<bool>((ref) => false);

final needsAppLockProvider = Provider<bool>((ref) {
  return ref.watch(hasPinConfiguredProvider) && !ref.watch(appUnlockedProvider);
});

class PinLockService {
  PinLockService(this._prefs);

  final SharedPreferences _prefs;

  Future<void> setPin(String pin) async {
    await _prefs.setString(_kPinDigestKey, hashPinForStorage(pin));
  }

  Future<void> clearPin() async {
    await _prefs.remove(_kPinDigestKey);
  }

  bool verifyPin(String pin) {
    final stored = _prefs.getString(_kPinDigestKey);
    if (stored == null || stored.isEmpty) return true;
    return stored == hashPinForStorage(pin);
  }
}

final pinLockServiceProvider = Provider<PinLockService>((ref) {
  return PinLockService(ref.watch(sharedPreferencesProvider));
});
