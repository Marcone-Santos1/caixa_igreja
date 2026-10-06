import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/cloud_backup_service.dart';
import 'cloud_sync_provider.dart';

/// Atualizador embutido ("mini Play Store" via nossa nuvem):
/// ao abrir o app, compara a versão instalada com `_app/latest.json` no
/// Worker; havendo versão nova, mostra o banner e baixa/abre o instalador.
/// Publicação: `./cloud/publish_app.sh` (ver docs/distribuicao_app.md).
enum AppUpdatePhase { idle, checking, available, downloading, error }

class AppUpdateState {
  const AppUpdateState({
    this.phase = AppUpdatePhase.idle,
    this.manifest,
    this.installedVersionCode,
    this.installedVersionName = '',
    this.progress = 0,
    this.message,
    this.lastCheckedAt,
  });

  final AppUpdatePhase phase;
  final AppUpdateManifest? manifest;
  final int? installedVersionCode;
  final String installedVersionName;

  /// 0..1 durante o download.
  final double progress;
  final String? message;
  final DateTime? lastCheckedAt;

  bool get updateAvailable =>
      phase == AppUpdatePhase.available || phase == AppUpdatePhase.downloading;

  AppUpdateState copyWith({
    AppUpdatePhase? phase,
    AppUpdateManifest? manifest,
    int? installedVersionCode,
    String? installedVersionName,
    double? progress,
    String? message,
    bool clearMessage = false,
    DateTime? lastCheckedAt,
  }) {
    return AppUpdateState(
      phase: phase ?? this.phase,
      manifest: manifest ?? this.manifest,
      installedVersionCode: installedVersionCode ?? this.installedVersionCode,
      installedVersionName: installedVersionName ?? this.installedVersionName,
      progress: progress ?? this.progress,
      message: clearMessage ? null : (message ?? this.message),
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

final appUpdateControllerProvider =
    StateNotifierProvider<AppUpdateController, AppUpdateState>((ref) {
  return AppUpdateController(ref);
});

class AppUpdateController extends StateNotifier<AppUpdateState> {
  AppUpdateController(this._ref) : super(const AppUpdateState()) {
    // Verificação na abertura (silenciosa; sem config/rede, não incomoda).
    Future<void>.microtask(() {
      if (mounted) checkNow(silent: true);
    });
  }

  final Ref _ref;
  bool _busy = false;

  CloudBackupService? _service() {
    final config =
        _ref.read(cloudSyncControllerProvider.notifier).currentConfig();
    return config == null ? null : CloudBackupService(config);
  }

  Future<void> checkNow({bool silent = false}) async {
    if (_busy || !mounted) return;
    final service = _service();
    if (service == null) {
      if (!silent) {
        state = state.copyWith(
            message: 'Configure o backup na nuvem para receber atualizações.');
      }
      return;
    }
    _busy = true;
    if (!silent) state = state.copyWith(phase: AppUpdatePhase.checking);
    try {
      int installed;
      String installedName;
      try {
        final info = await PackageInfo.fromPlatform();
        installed = int.tryParse(info.buildNumber) ?? 0;
        installedName = info.version;
      } catch (_) {
        // Testes/plataformas sem o plugin: sem como comparar, não avisa.
        _busy = false;
        return;
      }
      final manifest = await service.getAppLatest();
      if (!mounted) return;
      final hasUpdate =
          !manifest.isEmpty && manifest.versionCode > installed;
      state = state.copyWith(
        phase: hasUpdate ? AppUpdatePhase.available : AppUpdatePhase.idle,
        manifest: hasUpdate ? manifest : state.manifest,
        installedVersionCode: installed,
        installedVersionName: installedName,
        lastCheckedAt: DateTime.now(),
        message: hasUpdate || silent ? null : 'O app já está na versão mais nova.',
        clearMessage: hasUpdate,
      );
    } catch (e) {
      developer.log('Erro ao buscar atualização: $e', name: 'AppUpdate');
      if (mounted && !silent) {
        state = state.copyWith(
            phase: AppUpdatePhase.error, message: 'Falha ao verificar: $e');
      } else if (mounted) {
        state = state.copyWith(phase: AppUpdatePhase.idle);
      }
    } finally {
      _busy = false;
    }
  }

  /// Baixa o APK e abre o instalador do Android (o usuário confirma lá).
  Future<void> downloadAndInstall() async {
    final manifest = state.manifest;
    final service = _service();
    if (manifest == null || service == null || _busy) return;
    _busy = true;
    state = state.copyWith(phase: AppUpdatePhase.downloading, progress: 0);
    try {
      final dir = await getTemporaryDirectory();
      final target =
          File(p.join(dir.path, 'cantina-${manifest.versionCode}.apk'));
      await service.downloadApk(
        manifest.versionCode,
        target,
        expectedSha256: manifest.sha256,
        onProgress: (received, total) {
          if (!mounted || total <= 0) return;
          state = state.copyWith(progress: received / total);
        },
      );
      if (!mounted) return;
      state = state.copyWith(phase: AppUpdatePhase.available, progress: 1);
      final result = await OpenFilex.open(target.path);
      if (result.type != ResultType.done && mounted) {
        state = state.copyWith(
          phase: AppUpdatePhase.error,
          message:
              'Não consegui abrir o instalador (${result.message}). Permita '
              '"instalar apps desconhecidos" para o Cantina Padroeira e tente de novo.',
        );
      }
    } catch (e) {
      developer.log('Erro ao baixar atualização: $e', name: 'AppUpdate');
      if (mounted) {
        state = state.copyWith(
            phase: AppUpdatePhase.available, message: 'Falha no download: $e');
      }
    } finally {
      _busy = false;
    }
  }
}
