import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../data/database_backup.dart';
import '../data/device_identity.dart';
import '../data/event_cloud_aggregate.dart';
import '../services/cloud_backup_service.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';
import 'sync_provider.dart';

/// Sincronização pela nuvem POR EVENTO (RFC v2).
///
/// Cada evento tem a própria cadeia de versões. `dirty` não é uma flag
/// mantida à mão: é derivado comparando a impressão digital atual do evento
/// (`eventCloudFingerprint`, baseada nos `rowVersion` do schema v9) com a do
/// último envio. Fast-forward aplica automático; divergência é guiada.
enum CloudEventPhase {
  /// Local e nuvem na mesma versão, nada pendente.
  upToDate,

  /// Há alterações locais aguardando envio.
  pendingUpload,

  uploading,
  downloading,

  /// A nuvem tem versão mais nova; será aplicada no próximo gatilho de
  /// abertura (não substituímos dados no meio do uso).
  updateAvailable,

  /// Os dois lados têm novidades: o usuário escolhe (nada é sobrescrito
  /// em silêncio).
  divergence,

  /// A nuvem exige um app mais novo.
  blockedSchema,

  /// Evento existe só na nuvem: disponível para baixar.
  cloudOnly,

  /// Sincronização pausada NESTE aparelho (opção por evento): não envia nem
  /// baixa até ser retomada. Não afeta os outros celulares.
  paused,

  error,
}

/// Registro de uma aplicação automática (para "Desfazer").
class AppliedCloudUpdate {
  const AppliedCloudUpdate({
    required this.eventId,
    required this.version,
    required this.deviceName,
    required this.at,
    required this.backupPath,
    required this.previousVersion,
    required this.previousFingerprint,
  });

  final String eventId;
  final int version;
  final String? deviceName;
  final DateTime at;

  /// Agregado local arquivado antes de aplicar ('' quando o evento não
  /// existia localmente).
  final String backupPath;
  final int previousVersion;
  final String? previousFingerprint;
}

/// Estado da nuvem de UM evento.
class CloudEventStatus {
  const CloudEventStatus({
    required this.eventId,
    required this.title,
    required this.phase,
    this.eventDateMs,
    this.existsLocally = true,
    this.remote,
    this.lastSyncedVersion = 0,
    this.dirty = false,
    this.message,
    this.lastApplied,
  });

  final String eventId;
  final String title;
  final CloudEventPhase phase;
  final int? eventDateMs;
  final bool existsLocally;
  final CloudEventManifest? remote;
  final int lastSyncedVersion;
  final bool dirty;
  final String? message;
  final AppliedCloudUpdate? lastApplied;

  bool get needsAttention =>
      phase == CloudEventPhase.divergence ||
      phase == CloudEventPhase.blockedSchema ||
      phase == CloudEventPhase.error;

  /// O evento foi COMPARTILHADO com este aparelho (ou é dele)?
  /// Administradores enxergam todos os eventos da igreja, inclusive backups
  /// privados dos outros celulares — esses não devem virar aviso na home.
  bool get sharedWithMe {
    final r = remote;
    if (r == null) return existsLocally;
    return r.ownerDeviceId == DeviceIdentity.deviceId ||
        r.sharedWith.contains(DeviceIdentity.deviceId);
  }

  CloudEventStatus copyWith({
    CloudEventPhase? phase,
    CloudEventManifest? remote,
    int? lastSyncedVersion,
    bool? dirty,
    String? message,
    AppliedCloudUpdate? lastApplied,
    bool clearLastApplied = false,
  }) {
    return CloudEventStatus(
      eventId: eventId,
      title: title,
      phase: phase ?? this.phase,
      eventDateMs: eventDateMs,
      existsLocally: existsLocally,
      remote: remote ?? this.remote,
      lastSyncedVersion: lastSyncedVersion ?? this.lastSyncedVersion,
      dirty: dirty ?? this.dirty,
      message: message ?? this.message,
      lastApplied:
          clearLastApplied ? null : (lastApplied ?? this.lastApplied),
    );
  }
}

class CloudSyncState {
  const CloudSyncState({
    this.endpoint = '',
    this.churchCode = '',
    this.credentialConfigured = false,
    this.role = 'member',
    this.busy = false,
    this.lastCheckedAt,
    this.globalMessage,
    this.events = const {},
    this.devices = const [],
    this.accessRevoked = false,
    this.dismissedEventIds = const {},
  });

  final String endpoint;
  final String churchCode;
  final bool credentialConfigured;

  /// Papel deste celular na igreja: 'admin' (convida, revoga, gerencia tudo)
  /// ou 'member'.
  final String role;
  final bool busy;
  final DateTime? lastCheckedAt;
  final String? globalMessage;

  /// Por eventId (eventos locais e os que só existem na nuvem).
  final Map<String, CloudEventStatus> events;

  /// Celulares da igreja (para "Quem recebe" e administração).
  final List<CloudDeviceInfo> devices;

  /// Este celular foi revogado no servidor (precisa de novo convite).
  final bool accessRevoked;

  /// Eventos da nuvem dispensados do banner da home (continuam na tela da
  /// nuvem).
  final Set<String> dismissedEventIds;

  bool get configured =>
      endpoint.isNotEmpty && churchCode.isNotEmpty && credentialConfigured;

  bool get isAdmin => role == 'admin';

  CloudEventStatus? forEvent(String eventId) => events[eventId];

  List<CloudEventStatus> get cloudOnlyEvents => events.values
      .where((e) => e.phase == CloudEventPhase.cloudOnly)
      .toList()
    ..sort((a, b) => (b.eventDateMs ?? 0).compareTo(a.eventDateMs ?? 0));

  /// O que o banner da home mostra: eventos da nuvem COMPARTILHADOS com este
  /// aparelho e não dispensados. O resto fica só na tela Backup na nuvem.
  List<CloudEventStatus> get homeBannerEvents => cloudOnlyEvents
      .where((e) => e.sharedWithMe && !dismissedEventIds.contains(e.eventId))
      .toList();

  bool get anyAttention =>
      accessRevoked || events.values.any((e) => e.needsAttention);

  CloudSyncState copyWith({
    String? endpoint,
    String? churchCode,
    bool? credentialConfigured,
    String? role,
    bool? busy,
    DateTime? lastCheckedAt,
    String? globalMessage,
    bool clearGlobalMessage = false,
    Map<String, CloudEventStatus>? events,
    List<CloudDeviceInfo>? devices,
    bool? accessRevoked,
    Set<String>? dismissedEventIds,
  }) {
    return CloudSyncState(
      endpoint: endpoint ?? this.endpoint,
      churchCode: churchCode ?? this.churchCode,
      credentialConfigured: credentialConfigured ?? this.credentialConfigured,
      role: role ?? this.role,
      busy: busy ?? this.busy,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      globalMessage:
          clearGlobalMessage ? null : (globalMessage ?? this.globalMessage),
      events: events ?? this.events,
      devices: devices ?? this.devices,
      accessRevoked: accessRevoked ?? this.accessRevoked,
      dismissedEventIds: dismissedEventIds ?? this.dismissedEventIds,
    );
  }
}

final cloudSyncControllerProvider =
    StateNotifierProvider<CloudSyncController, CloudSyncState>((ref) {
  final controller = CloudSyncController(ref);
  ref.listen<AppDatabase>(appDatabaseProvider, (prev, next) {
    controller.attachDatabase(next);
  });
  controller.attachDatabase(ref.read(appDatabaseProvider));
  // O StateNotifierProvider descarta o controller sozinho (dispose).
  return controller;
});

class CloudSyncController extends StateNotifier<CloudSyncState>
    with WidgetsBindingObserver {
  CloudSyncController(this._ref) : super(const CloudSyncState()) {
    _loadPersisted();
    WidgetsBinding.instance.addObserver(this);
    // Gatilho de abertura do app (sem Timer aqui: testes de widget checam
    // timers pendentes — o polling só liga quando a nuvem está configurada,
    // ao fim do primeiro ciclo). Sem configuração, refreshAll retorna logo.
    Future<void>.microtask(() {
      if (mounted) refreshAll();
    });
  }

  static const _kEndpoint = 'cloud.endpoint';
  static const _kChurchCode = 'cloud.churchCode';
  static const _kDeviceToken = 'cloud.deviceToken';
  static const _kRole = 'cloud.role';

  /// Chave do modelo antigo (segredo único da igreja, v2). Se existir sem
  /// deviceToken, a config é de uma versão anterior e precisa de novo
  /// pareamento.
  static const _kLegacySecret = 'cloud.secret';

  /// Espera após a última escrita antes do envio automático. Curto: o
  /// snapshot por evento tem poucos KB e o usuário espera ver a sincronização
  /// acontecer, não "daqui a 3 minutos".
  static const uploadDebounce = Duration(seconds: 20);

  /// Verificação periódica em primeiro plano: é o que faz o OUTRO celular
  /// receber novidades sem precisar fechar e reabrir o app.
  static const pollInterval = Duration(seconds: 60);

  final Ref _ref;
  StreamSubscription<void>? _dbSub;
  Timer? _debounce;
  Timer? _poll;
  bool _busy = false;

  /// Alguém pediu refresh durante um ciclo: roda de novo ao terminar, em vez
  /// de descartar silenciosamente (era a sensação de "travado").
  bool _refreshQueued = false;

  /// Houve escrita local desde o último ciclo? Sem escrita, eventos já em dia
  /// nem recalculam o fingerprint — o polling fica barato.
  bool _writesSinceRefresh = true;

  /// Ligado enquanto aplicamos um agregado remoto, para as escritas
  /// resultantes não dispararem o debounce de envio.
  bool _applying = false;

  final Map<String, AppliedCloudUpdate> _lastApplied = {};

  // ─── Configuração ──────────────────────────────────────────────────────

  void _loadPersisted() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final dismissed =
        (prefs.getStringList('cloud.dismissed') ?? const []).toSet();
    final hasToken = (prefs.getString(_kDeviceToken) ?? '').isNotEmpty;
    final hasLegacy = (prefs.getString(_kLegacySecret) ?? '').isNotEmpty;
    state = state.copyWith(
      endpoint: prefs.getString(_kEndpoint) ?? kDefaultCloudEndpoint,
      churchCode: prefs.getString(_kChurchCode) ?? '',
      credentialConfigured: hasToken,
      role: prefs.getString(_kRole) ?? 'member',
      dismissedEventIds: dismissed,
      globalMessage: !hasToken && hasLegacy
          ? 'O modelo de acesso mudou (credencial por celular). Ative de novo ou peça um convite.'
          : null,
    );
  }

  CloudBackupConfig? currentConfig() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final config = CloudBackupConfig(
      endpoint: prefs.getString(_kEndpoint) ?? kDefaultCloudEndpoint,
      churchCode: prefs.getString(_kChurchCode) ?? '',
      deviceId: DeviceIdentity.deviceId,
      deviceToken: prefs.getString(_kDeviceToken) ?? '',
    );
    return config.isComplete ? config : null;
  }

  CloudBackupService? _service() {
    final config = currentConfig();
    return config == null ? null : CloudBackupService(config);
  }

  /// "Ativar backup na nuvem" (1º celular): cria a igreja no servidor e este
  /// celular vira o administrador, com credencial própria.
  Future<void> activate({String? endpointOverride}) async {
    final endpoint = (endpointOverride?.trim().isNotEmpty ?? false)
        ? endpointOverride!.trim()
        : kDefaultCloudEndpoint;
    if (endpoint.isEmpty) {
      throw CloudBackupException(
          'Informe o endereço do servidor (ou gere o app com CLOUD_SYNC_ENDPOINT).');
    }
    final rng = Random.secure();
    String randomCode() =>
        'ig${List.generate(10, (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'[rng.nextInt(36)]).join()}';

    // Colisão de código é improvável; ainda assim, tenta de novo num 409.
    CloudBackupException? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      final code = randomCode();
      try {
        final result = await CloudBackupService.register(
          endpoint: endpoint,
          churchCode: code,
          deviceId: DeviceIdentity.deviceId,
          deviceName: DeviceIdentity.deviceName,
        );
        await _saveCredential(
          endpoint: endpoint,
          churchCode: code,
          deviceToken: result.deviceToken,
          role: result.role,
        );
        unawaited(refreshAll());
        return;
      } on CloudBackupException catch (e) {
        lastError = e;
        if (!e.message.contains('já está em uso')) rethrow;
      }
    }
    throw lastError ?? CloudBackupException('Não foi possível ativar.');
  }

  /// Pareia este celular trocando o convite (QR/texto) por credencial própria.
  Future<bool> pairWithToken(String token) async {
    final invite = CloudInviteToken.decode(token);
    if (invite == null) return false;
    final result = await CloudBackupService.join(
      invite: invite,
      deviceId: DeviceIdentity.deviceId,
      deviceName: DeviceIdentity.deviceName,
    );
    await _saveCredential(
      endpoint: invite.endpoint,
      churchCode: invite.churchCode,
      deviceToken: result.deviceToken,
      role: result.role,
    );
    unawaited(refreshAll());
    return true;
  }

  /// Gera um convite de uso único para parear outro celular (admin).
  Future<CloudInviteToken> createInvite() async {
    final service = _service();
    if (service == null) {
      throw CloudBackupException('Backup na nuvem não configurado.');
    }
    return service.createInvite();
  }

  Future<void> _saveCredential({
    required String endpoint,
    required String churchCode,
    required String deviceToken,
    required String role,
  }) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(_kEndpoint, endpoint);
    await prefs.setString(_kChurchCode, churchCode);
    await prefs.setString(_kDeviceToken, deviceToken);
    await prefs.setString(_kRole, role);
    await prefs.remove(_kLegacySecret);
    if (mounted) {
      state = state.copyWith(
        endpoint: endpoint,
        churchCode: churchCode,
        credentialConfigured: true,
        role: role,
        accessRevoked: false,
        clearGlobalMessage: true,
      );
    }
  }

  /// Desliga o backup neste aparelho (não apaga nada na nuvem).
  Future<void> disconnect() async {
    final prefs = _ref.read(sharedPreferencesProvider);
    for (final key in prefs.getKeys().where((k) => k.startsWith('cloud.'))) {
      await prefs.remove(key);
    }
    _lastApplied.clear();
    if (mounted) {
      state = CloudSyncState(endpoint: kDefaultCloudEndpoint);
    }
  }

  // ─── Estado por evento persistido ──────────────────────────────────────

  /// Sincronização pausada para este evento NESTE aparelho?
  bool isEventSyncPaused(String eventId) =>
      _ref.read(sharedPreferencesProvider).getBool('cloud.ev.$eventId.paused') ??
      false;

  /// Pausa/retoma a sincronização de um evento neste aparelho. Ao retomar,
  /// o próximo ciclo envia pendências ou sinaliza divergência normalmente.
  Future<void> setEventSyncPaused(String eventId, bool paused) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    if (paused) {
      await prefs.setBool('cloud.ev.$eventId.paused', true);
      final current = state.forEvent(eventId);
      if (current != null) {
        _setEventStatus(
          eventId,
          current.copyWith(
            phase: CloudEventPhase.paused,
            message: 'Sincronização pausada neste aparelho.',
          ),
        );
      }
    } else {
      await prefs.remove('cloud.ev.$eventId.paused');
      await refreshAll(allowApply: false, onlyEventId: eventId);
    }
  }

  int _storedVersion(String eventId) =>
      _ref.read(sharedPreferencesProvider).getInt('cloud.ev.$eventId.v') ?? 0;

  String? _storedFingerprint(String eventId) =>
      _ref.read(sharedPreferencesProvider).getString('cloud.ev.$eventId.fp');

  Future<void> _storeSynced(String eventId, int version, String? fp) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setInt('cloud.ev.$eventId.v', version);
    if (fp != null) {
      await prefs.setString('cloud.ev.$eventId.fp', fp);
    } else {
      await prefs.remove('cloud.ev.$eventId.fp');
    }
  }

  // ─── Ciclo de vida / gatilhos ──────────────────────────────────────────

  void attachDatabase(AppDatabase db) {
    _dbSub?.cancel();
    _dbSub = db.tableUpdates().listen((_) => _onLocalWrite());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dbSub?.cancel();
    _debounce?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  /// Liga o polling de primeiro plano (só quando configurado — assim testes
  /// de widget sem nuvem não criam timer nenhum).
  void _ensurePolling() {
    if (_poll != null || !state.configured) return;
    _poll = Timer.periodic(pollInterval, (_) {
      if (mounted) refreshAll();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _ensurePolling();
      refreshAll();
    } else if (state == AppLifecycleState.paused) {
      // Em segundo plano não gastamos bateria/rede com polling.
      _poll?.cancel();
      _poll = null;
      // Saindo do app: tenta enviar o que estiver pendente.
      refreshAll(allowApply: false);
    }
  }

  bool get _isWifiClientMode =>
      _ref.read(syncProvider).mode == SyncMode.client;

  void _onLocalWrite() {
    if (_applying) return;
    _writesSinceRefresh = true;
    if (!state.configured || _isWifiClientMode) return;
    _debounce?.cancel();
    _debounce = Timer(uploadDebounce, () {
      if (mounted) refreshAll(allowApply: false);
    });
  }

  /// Gatilho do fechamento de sessão de caixa: envia o evento já.
  void onCashSessionClosed(String eventId) {
    _debounce?.cancel();
    refreshAll(allowApply: false, onlyEventId: eventId);
  }

  // ─── Ciclo principal ───────────────────────────────────────────────────

  /// Verifica a nuvem e decide por evento: fast-forward, envio ou
  /// divergência. [allowApply] falso adia o download (não substituímos dados
  /// no meio do uso); [onlyEventId] restringe a um evento.
  Future<void> refreshAll({bool allowApply = true, String? onlyEventId}) async {
    final service = _service();
    if (service == null || !mounted) return;
    if (_busy) {
      // Ciclo em andamento: enfileira mais um em vez de ignorar o pedido.
      _refreshQueued = true;
      return;
    }
    if (_isWifiClientMode) {
      state = state.copyWith(
        globalMessage:
            'Este aparelho está como terminal Wi-Fi; o backup na nuvem é feito pelo caixa central.',
      );
      return;
    }

    _busy = true;
    final hadWrites = _writesSinceRefresh;
    _writesSinceRefresh = false;
    state = state.copyWith(busy: true, clearGlobalMessage: true);
    final db = _ref.read(appDatabaseProvider);
    try {
      final remoteList = await service.listEvents();
      final devices = await service.listDevices();
      if (mounted) {
        state = state.copyWith(devices: devices, accessRevoked: false);
      }
      final remoteById = {for (final m in remoteList) m.eventId: m};
      final localEvents = await db.select(db.events).get();
      final localById = {for (final e in localEvents) e.id: e};

      final ids = <String>{...localById.keys, ...remoteById.keys};
      if (onlyEventId != null) {
        ids.removeWhere((id) => id != onlyEventId);
      }

      final statuses = Map<String, CloudEventStatus>.from(state.events);
      for (final id in ids) {
        statuses[id] = await _evaluateEvent(
          service,
          db,
          eventId: id,
          local: localById[id],
          remote: remoteById[id],
          allowApply: allowApply,
          hadWrites: hadWrites,
          previous: state.forEvent(id),
        );
        if (!mounted) return;
        state = state.copyWith(events: Map.of(statuses));
      }
      // Remove da lista eventos que sumiram dos dois lados.
      statuses.removeWhere((id, _) =>
          onlyEventId == null &&
          !localById.containsKey(id) &&
          !remoteById.containsKey(id));
      if (mounted) {
        state = state.copyWith(
          events: statuses,
          lastCheckedAt: DateTime.now(),
        );
      }
    } on CloudAccessDeniedException catch (e) {
      developer.log('Acesso negado na nuvem: $e', name: 'CloudSync');
      if (mounted) {
        state = state.copyWith(
          accessRevoked: true,
          globalMessage: e.message,
        );
      }
    } catch (e) {
      developer.log('Erro na sincronização com a nuvem: $e', name: 'CloudSync');
      if (mounted) {
        state = state.copyWith(globalMessage: _friendlyError(e));
      }
    } finally {
      _busy = false;
      if (mounted) {
        state = state.copyWith(busy: false);
        _ensurePolling();
        if (_refreshQueued) {
          _refreshQueued = false;
          // Alguém pediu durante o ciclo: atende agora.
          unawaited(refreshAll(allowApply: allowApply));
        }
      }
    }
  }

  /// Tira um evento da nuvem do banner da home (continua na tela da nuvem).
  Future<void> dismissCloudEvent(String eventId) async {
    final dismissed = {...state.dismissedEventIds, eventId};
    await _ref
        .read(sharedPreferencesProvider)
        .setStringList('cloud.dismissed', dismissed.toList());
    if (mounted) state = state.copyWith(dismissedEventIds: dismissed);
  }

  // ─── Compartilhamento e administração (RFC v3) ─────────────────────────

  /// Define a lista de celulares que recebem um evento (dono ou admin).
  Future<void> setEventSharedWith(
      String eventId, List<String> sharedWith) async {
    final service = _service();
    final current = state.forEvent(eventId);
    if (service == null || current == null) return;
    try {
      final manifest = await service.updateEventAcl(eventId, sharedWith);
      _setEventStatus(
        eventId,
        current.copyWith(
          remote: manifest,
          message: sharedWith.isEmpty
              ? 'Evento privado: backup só deste aparelho.'
              : 'Compartilhado com ${sharedWith.length} celular(es).',
        ),
      );
    } on CloudBackupException catch (e) {
      _setEventStatus(
        eventId,
        current.copyWith(message: _friendlyError(e)),
      );
    }
  }

  /// Liga/desliga um celular na lista de um evento.
  Future<void> toggleEventShare(
      String eventId, String deviceId, bool enabled) async {
    final current = state.forEvent(eventId)?.remote;
    if (current == null) return;
    final set = {...current.sharedWith};
    if (enabled) {
      set.add(deviceId);
    } else {
      set.remove(deviceId);
    }
    await setEventSharedWith(eventId, set.toList());
  }

  /// Revoga (ou reativa) um celular da igreja inteira (admin).
  Future<void> setDeviceRevoked(String deviceId, bool revoked) async {
    final service = _service();
    if (service == null) return;
    try {
      await service.updateDevice(deviceId, revoked: revoked);
      final devices = await service.listDevices();
      if (mounted) state = state.copyWith(devices: devices);
    } on CloudBackupException catch (e) {
      if (mounted) state = state.copyWith(globalMessage: _friendlyError(e));
    }
  }

  /// Promove/rebaixa um celular (admin). Promover um segundo administrador
  /// cobre o caso do celular principal quebrar.
  Future<void> setDeviceRole(String deviceId, String role) async {
    final service = _service();
    if (service == null) return;
    try {
      await service.updateDevice(deviceId, role: role);
      final devices = await service.listDevices();
      if (mounted) state = state.copyWith(devices: devices);
    } on CloudBackupException catch (e) {
      if (mounted) state = state.copyWith(globalMessage: _friendlyError(e));
    }
  }

  Future<CloudEventStatus> _evaluateEvent(
    CloudBackupService service,
    AppDatabase db, {
    required String eventId,
    required ChurchEvent? local,
    required CloudEventManifest? remote,
    required bool allowApply,
    bool hadWrites = true,
    CloudEventStatus? previous,
  }) async {
    final title = local?.title ?? remote?.eventTitle ?? 'Evento';
    final dateMs = local?.dateEpochMs ?? remote?.eventDateMs;
    final storedV = _storedVersion(eventId);
    final applied = _lastApplied[eventId];

    CloudEventStatus status(CloudEventPhase phase,
        {bool dirty = false, String? message}) {
      return CloudEventStatus(
        eventId: eventId,
        title: title,
        eventDateMs: dateMs,
        existsLocally: local != null,
        remote: remote,
        lastSyncedVersion: storedV,
        dirty: dirty,
        phase: phase,
        message: message,
        lastApplied: applied,
      );
    }

    if (local == null) {
      return status(CloudEventPhase.cloudOnly);
    }

    if (isEventSyncPaused(eventId)) {
      return status(CloudEventPhase.paused,
          message: 'Sincronização pausada neste aparelho.');
    }

    // Atalho do polling: sem escrita local desde o último ciclo e com a nuvem
    // na mesma versão, o evento continua em dia — sem recalcular fingerprint.
    final remoteVersionNow = remote?.version ?? 0;
    if (!hadWrites &&
        previous?.phase == CloudEventPhase.upToDate &&
        remoteVersionNow == storedV &&
        previous?.lastSyncedVersion == storedV) {
      return previous!.copyWith(remote: remote);
    }

    final fp = await db.eventCloudFingerprint(eventId);
    final dirty = fp != _storedFingerprint(eventId);
    final remoteV = remote?.version ?? 0;

    if (remote != null &&
        remoteV > storedV &&
        (remote.schemaVersion > kAppSchemaVersion ||
            remote.formatVersion > kEventAggregateFormatVersion)) {
      return status(CloudEventPhase.blockedSchema,
          dirty: dirty,
          message:
              'A versão na nuvem foi enviada por um app mais novo. Atualize o app.');
    }

    if (remoteV == storedV) {
      if (!dirty) return status(CloudEventPhase.upToDate);
      // Alterações locais e nuvem na base esperada: envia.
      return _uploadEvent(service, db, status, eventId, expected: remoteV);
    }

    if (remoteV > storedV) {
      if (dirty) return status(CloudEventPhase.divergence, dirty: true);
      if (!allowApply) {
        return status(CloudEventPhase.updateAvailable,
            message:
                'Nova versão (v$remoteV) disponível; será aplicada na próxima abertura.');
      }
      return _applyRemoteEvent(service, db, status, eventId, remote!);
    }

    // remoteV < storedV: a nuvem retrocedeu (limpa/recriada).
    return status(CloudEventPhase.divergence,
        dirty: dirty,
        message:
            'A nuvem está numa versão anterior (v$remoteV) à que este aparelho conhecia (v$storedV).');
  }

  // ─── Envio ─────────────────────────────────────────────────────────────

  Future<CloudEventStatus> _uploadEvent(
    CloudBackupService service,
    AppDatabase db,
    CloudEventStatus Function(CloudEventPhase, {bool dirty, String? message})
        status,
    String eventId, {
    required int expected,
  }) async {
    if (mounted) {
      state = state.copyWith(events: {
        ...state.events,
        eventId: status(CloudEventPhase.uploading, dirty: true),
      });
    }
    try {
      // Fingerprint ANTES do export: se alguém vender no meio, o próximo
      // ciclo detecta dirty de novo (nunca o contrário).
      final fp = await db.eventCloudFingerprint(eventId);
      final json = await db.exportEventAggregate(eventId);
      if (json == null) {
        return status(CloudEventPhase.error, message: 'Evento não encontrado.');
      }
      final event = ChurchEvent.fromJson(json['event'] as Map<String, dynamic>);
      final gz = Uint8List.fromList(gzip.encode(utf8.encode(jsonEncode(json))));
      final salesList = (json['sales'] as List?) ?? const [];
      final liveSales = salesList
          .whereType<Map<String, dynamic>>()
          .where((s) => s['deletedAtMs'] == null)
          .toList();
      int? lastSaleAt;
      for (final s in liveSales) {
        final at = (s['soldAtMs'] as num?)?.toInt() ?? 0;
        if (lastSaleAt == null || at > lastSaleAt) lastSaleAt = at;
      }

      final manifest = await service.uploadEventSnapshot(
        eventId: eventId,
        gzipBytes: gz,
        expectedVersion: expected,
        schemaVersion: kAppSchemaVersion,
        formatVersion: kEventAggregateFormatVersion,
        deviceId: DeviceIdentity.deviceId,
        deviceName: DeviceIdentity.deviceName,
        eventTitle: event.title,
        eventDateMs: event.dateEpochMs,
        summary: {
          'sales': liveSales.length,
          if (lastSaleAt != null)
            'lastSaleAt': DateTime.fromMillisecondsSinceEpoch(lastSaleAt)
                .toUtc()
                .toIso8601String(),
        },
      );
      await _storeSynced(eventId, manifest.version, fp);
      return CloudEventStatus(
        eventId: eventId,
        title: event.title,
        eventDateMs: event.dateEpochMs,
        existsLocally: true,
        remote: manifest,
        lastSyncedVersion: manifest.version,
        phase: CloudEventPhase.upToDate,
        message: 'Enviado como v${manifest.version}.',
        lastApplied: _lastApplied[eventId],
      );
    } on CloudConflictException catch (e) {
      return status(CloudEventPhase.divergence, dirty: true)
          .copyWith(remote: e.current);
    } catch (e) {
      developer.log('Erro ao enviar evento $eventId: $e', name: 'CloudSync');
      return status(CloudEventPhase.error,
          dirty: true, message: _friendlyError(e));
    }
  }

  // ─── Download / aplicação ──────────────────────────────────────────────

  Future<CloudEventStatus> _applyRemoteEvent(
    CloudBackupService service,
    AppDatabase db,
    CloudEventStatus Function(CloudEventPhase, {bool dirty, String? message})
        status,
    String eventId,
    CloudEventManifest manifest,
  ) async {
    if (mounted) {
      state = state.copyWith(events: {
        ...state.events,
        eventId: status(CloudEventPhase.downloading),
      });
    }
    try {
      final bytes = await service.downloadEventSnapshot(
        eventId,
        manifest.version,
        expectedSha256: manifest.sha256,
      );
      final jsonMap = jsonDecode(utf8.decode(gzip.decode(bytes)))
          as Map<String, dynamic>;

      // Arquiva o agregado local antes de substituir (base do "Desfazer").
      final prevVersion = _storedVersion(eventId);
      final prevFp = _storedFingerprint(eventId);
      var backupPath = '';
      final localJson = await db.exportEventAggregate(eventId);
      if (localJson != null) {
        backupPath = await _archiveAggregate(eventId, prevVersion, localJson);
      }

      _applying = true;
      try {
        await db.applyEventAggregate(jsonMap);
      } finally {
        Future<void>.delayed(
            const Duration(milliseconds: 500), () => _applying = false);
      }

      final newFp = await db.eventCloudFingerprint(eventId);
      await _storeSynced(eventId, manifest.version, newFp);
      final applied = AppliedCloudUpdate(
        eventId: eventId,
        version: manifest.version,
        deviceName: manifest.deviceName,
        at: DateTime.now(),
        backupPath: backupPath,
        previousVersion: prevVersion,
        previousFingerprint: prevFp,
      );
      _lastApplied[eventId] = applied;
      return CloudEventStatus(
        eventId: eventId,
        title: manifest.eventTitle?.isNotEmpty == true
            ? manifest.eventTitle!
            : 'Evento',
        eventDateMs: manifest.eventDateMs,
        existsLocally: true,
        remote: manifest,
        lastSyncedVersion: manifest.version,
        phase: CloudEventPhase.upToDate,
        message:
            'Atualizado para a v${manifest.version} (${manifest.deviceName ?? 'outro aparelho'}).',
        lastApplied: applied,
      );
    } catch (e) {
      developer.log('Erro ao aplicar evento $eventId: $e', name: 'CloudSync');
      return status(CloudEventPhase.error, message: _friendlyError(e));
    }
  }

  Future<String> _archiveAggregate(
      String eventId, int version, Map<String, dynamic> json) async {
    final dir = await backupsDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final shortId = eventId.length > 8 ? eventId.substring(0, 8) : eventId;
    final path = p.join(dir.path, 'evento-$shortId-prev$version-$stamp.json.gz');
    await File(path)
        .writeAsBytes(gzip.encode(utf8.encode(jsonEncode(json))), flush: true);
    return path;
  }

  // ─── Ações do usuário ──────────────────────────────────────────────────

  /// "Enviar agora" de um evento (ignora o debounce).
  Future<void> uploadEventNow(String eventId) async {
    _debounce?.cancel();
    await refreshAll(allowApply: false, onlyEventId: eventId);
  }

  /// Baixa um evento da nuvem: tanto o que só existe lá (banner "Baixar")
  /// quanto a atualização adiada de um evento local. Eventos da nuvem NÃO
  /// são baixados automaticamente no refresh — o download é sempre uma ação
  /// explícita do usuário (sincronização seletiva por evento).
  Future<void> downloadEvent(String eventId) async {
    final service = _service();
    if (service == null || _busy) return;
    if (isEventSyncPaused(eventId)) return;
    final db = _ref.read(appDatabaseProvider);
    _busy = true;
    state = state.copyWith(busy: true);
    try {
      final manifest = await service.getEventManifest(eventId);
      final base = state.forEvent(eventId) ??
          CloudEventStatus(
            eventId: eventId,
            title: manifest.eventTitle?.isNotEmpty == true
                ? manifest.eventTitle!
                : 'Evento',
            eventDateMs: manifest.eventDateMs,
            existsLocally: false,
            remote: manifest,
            phase: CloudEventPhase.cloudOnly,
          );
      final builder = _statusBuilder(base.copyWith(remote: manifest));

      if (manifest.isEmpty) {
        _setEventStatus(
            eventId,
            builder(CloudEventPhase.error,
                message: 'Este evento não está mais na nuvem.'));
        return;
      }
      if (manifest.schemaVersion > kAppSchemaVersion ||
          manifest.formatVersion > kEventAggregateFormatVersion) {
        _setEventStatus(
            eventId,
            builder(CloudEventPhase.blockedSchema,
                message:
                    'A versão na nuvem foi enviada por um app mais novo. Atualize o app.'));
        return;
      }

      // Guarda: evento local com alterações pendentes nunca é sobrescrito
      // por um download — cai no fluxo de divergência.
      final localEvent = await (db.select(db.events)
            ..where((e) => e.id.equals(eventId)))
          .getSingleOrNull();
      if (localEvent != null) {
        final fp = await db.eventCloudFingerprint(eventId);
        final dirty = fp != _storedFingerprint(eventId);
        if (dirty) {
          _setEventStatus(
              eventId, builder(CloudEventPhase.divergence, dirty: true));
          return;
        }
      }

      final result =
          await _applyRemoteEvent(service, db, builder, eventId, manifest);
      _setEventStatus(eventId, result);
    } catch (e) {
      developer.log('Erro ao baixar evento $eventId: $e', name: 'CloudSync');
      if (mounted) {
        state = state.copyWith(globalMessage: _friendlyError(e));
      }
    } finally {
      _busy = false;
      if (mounted) state = state.copyWith(busy: false);
    }
  }

  void _setEventStatus(String eventId, CloudEventStatus status) {
    if (!mounted) return;
    state = state.copyWith(events: {...state.events, eventId: status});
  }

  /// Divergência → "manter o deste aparelho": envia por cima da versão da
  /// nuvem (que permanece no histórico).
  Future<void> resolveKeepLocal(String eventId) async {
    final service = _service();
    final current = state.forEvent(eventId);
    final remote = current?.remote;
    if (service == null || remote == null || _busy) return;
    final db = _ref.read(appDatabaseProvider);
    _busy = true;
    state = state.copyWith(busy: true);
    try {
      final result = await _uploadEvent(
        service,
        db,
        _statusBuilder(current!),
        eventId,
        expected: remote.version,
      );
      if (mounted) {
        state = state.copyWith(events: {...state.events, eventId: result});
      }
    } finally {
      _busy = false;
      if (mounted) state = state.copyWith(busy: false);
    }
  }

  /// Divergência → "usar o da nuvem": arquiva o agregado local e aplica.
  Future<void> resolveUseRemote(String eventId) async {
    final service = _service();
    final current = state.forEvent(eventId);
    final remote = current?.remote;
    if (service == null || remote == null || _busy) return;
    final db = _ref.read(appDatabaseProvider);
    _busy = true;
    state = state.copyWith(busy: true);
    try {
      final result = await _applyRemoteEvent(
          service, db, _statusBuilder(current!), eventId, remote);
      if (mounted) {
        state = state.copyWith(events: {...state.events, eventId: result});
      }
    } finally {
      _busy = false;
      if (mounted) state = state.copyWith(busy: false);
    }
  }

  /// Restaura uma versão antiga do histórico do evento. O estado local atual
  /// é arquivado; a versão restaurada fica pendente e vira a nova versão da
  /// nuvem no próximo envio (o histórico não é reescrito).
  Future<void> restoreEventVersion(String eventId, int version) async {
    final service = _service();
    final current = state.forEvent(eventId);
    if (service == null || current == null || _busy) return;
    final db = _ref.read(appDatabaseProvider);
    _busy = true;
    state = state.copyWith(busy: true);
    try {
      final entry = current.remote?.history
          .where((h) => h.version == version)
          .firstOrNull;
      final bytes = await service.downloadEventSnapshot(eventId, version,
          expectedSha256: entry?.sha256);
      final jsonMap = jsonDecode(utf8.decode(gzip.decode(bytes)))
          as Map<String, dynamic>;
      final localJson = await db.exportEventAggregate(eventId);
      if (localJson != null) {
        await _archiveAggregate(eventId, _storedVersion(eventId), localJson);
      }
      _applying = true;
      try {
        await db.applyEventAggregate(jsonMap);
      } finally {
        Future<void>.delayed(
            const Duration(milliseconds: 500), () => _applying = false);
      }
      // Não atualiza versão/fingerprint: o estado fica "pendente de envio"
      // e sobe como a nova versão atual no próximo ciclo.
      if (mounted) {
        state = state.copyWith(events: {
          ...state.events,
          eventId: current.copyWith(
            phase: CloudEventPhase.pendingUpload,
            dirty: true,
            message:
                'v$version restaurada; será enviada como a nova versão atual.',
          ),
        });
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(events: {
          ...state.events,
          eventId: current.copyWith(
            phase: CloudEventPhase.error,
            message: _friendlyError(e),
          ),
        });
      }
    } finally {
      _busy = false;
      if (mounted) state = state.copyWith(busy: false);
    }
  }

  /// Desfaz a última atualização aplicada neste evento.
  Future<void> undoLastApplied(String eventId) async {
    final applied = _lastApplied[eventId];
    final current = state.forEvent(eventId);
    if (applied == null || current == null || _busy) return;
    final db = _ref.read(appDatabaseProvider);
    _busy = true;
    state = state.copyWith(busy: true);
    try {
      if (applied.backupPath.isEmpty || !File(applied.backupPath).existsSync()) {
        throw CloudBackupException('A cópia de segurança não foi encontrada.');
      }
      final jsonMap = jsonDecode(utf8.decode(
              gzip.decode(await File(applied.backupPath).readAsBytes())))
          as Map<String, dynamic>;
      _applying = true;
      try {
        await db.applyEventAggregate(jsonMap);
      } finally {
        Future<void>.delayed(
            const Duration(milliseconds: 500), () => _applying = false);
      }
      await _storeSynced(
          eventId, applied.previousVersion, applied.previousFingerprint);
      _lastApplied.remove(eventId);
      if (mounted) {
        state = state.copyWith(events: {
          ...state.events,
          eventId: current.copyWith(
            phase: CloudEventPhase.pendingUpload,
            dirty: true,
            clearLastApplied: true,
            message: 'Atualização desfeita; o evento voltou ao estado anterior.',
          ),
        });
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(events: {
          ...state.events,
          eventId: current.copyWith(
            phase: CloudEventPhase.error,
            message: _friendlyError(e),
          ),
        });
      }
    } finally {
      _busy = false;
      if (mounted) state = state.copyWith(busy: false);
    }
  }

  // ─── Auxiliares ────────────────────────────────────────────────────────

  CloudEventStatus Function(CloudEventPhase, {bool dirty, String? message})
      _statusBuilder(CloudEventStatus base) {
    return (CloudEventPhase phase, {bool dirty = false, String? message}) =>
        base.copyWith(phase: phase, dirty: dirty, message: message);
  }

  String _friendlyError(Object e) {
    if (e is SocketException || e is TimeoutException) {
      return 'Sem conexão com o servidor. Tento de novo no próximo gatilho.';
    }
    if (e is CloudBackupException) return e.message;
    return 'Falha na sincronização: $e';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
