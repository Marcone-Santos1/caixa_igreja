import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Endpoint padrão embutido no build (tarefa única do desenvolvedor):
/// `flutter build apk --dart-define=CLOUD_SYNC_ENDPOINT=https://...workers.dev`
/// Vazio ⇒ o app pede o endereço uma vez ao ativar (e o QR o propaga).
const kDefaultCloudEndpoint = String.fromEnvironment('CLOUD_SYNC_ENDPOINT');

/// Prefixo do token de pareamento (QR ou texto colado).
const kCloudTokenPrefix = 'caixa://cloud/';

/// Manifest de UM evento na nuvem (espelha o JSON do Worker).
class CloudEventManifest {
  const CloudEventManifest({
    required this.eventId,
    required this.version,
    this.sha256,
    this.sizeBytes,
    this.schemaVersion = 0,
    this.formatVersion = 0,
    this.uploadedAt,
    this.deviceId,
    this.deviceName,
    this.eventTitle,
    this.eventDateMs,
    this.eventDeleted = false,
    this.baseVersion,
    this.summary,
    this.history = const [],
    this.ownerDeviceId,
    this.sharedWith = const [],
  });

  final String eventId;
  final int version;
  final String? sha256;
  final int? sizeBytes;
  final int schemaVersion;
  final int formatVersion;
  final DateTime? uploadedAt;
  final String? deviceId;
  final String? deviceName;
  final String? eventTitle;
  final int? eventDateMs;

  /// O evento está EXCLUÍDO (tombstone sincronizado). Não deve virar card de
  /// baixar nem aparecer nas listas normais.
  final bool eventDeleted;
  final int? baseVersion;
  final Map<String, dynamic>? summary;
  final List<CloudEventManifest> history;

  /// Dono do evento (quem o enviou primeiro) e lista de acesso (RFC v3).
  final String? ownerDeviceId;
  final List<String> sharedWith;

  bool get isEmpty => version <= 0;

  bool isOwner(String deviceId) => ownerDeviceId == deviceId;

  int? get salesCount => (summary?['sales'] as num?)?.toInt();

  factory CloudEventManifest.fromJson(Map<String, dynamic> json) {
    return CloudEventManifest(
      eventId: json['eventId'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      sha256: json['sha256'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 0,
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 0,
      uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? ''),
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      eventTitle: json['eventTitle'] as String?,
      eventDateMs: (json['eventDateMs'] as num?)?.toInt(),
      eventDeleted: json['eventDeleted'] == true,
      baseVersion: (json['baseVersion'] as num?)?.toInt(),
      summary: json['summary'] as Map<String, dynamic>?,
      ownerDeviceId: json['ownerDeviceId'] as String?,
      sharedWith: (json['sharedWith'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      history: (json['history'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CloudEventManifest.fromJson)
          .toList(),
    );
  }
}

/// Outro celular enviou uma versão deste evento no meio do caminho (409).
class CloudConflictException implements Exception {
  CloudConflictException(this.current);
  final CloudEventManifest current;

  @override
  String toString() =>
      'Conflito de versão: o evento está na v${current.version} na nuvem';
}

class CloudBackupException implements Exception {
  CloudBackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// 401/403 do servidor: credencial inválida ou celular revogado/sem acesso.
class CloudAccessDeniedException extends CloudBackupException {
  CloudAccessDeniedException(super.message);
}

/// Celular registrado na igreja (lista de "conectados").
class CloudDeviceInfo {
  const CloudDeviceInfo({
    required this.deviceId,
    required this.name,
    required this.role,
    this.joinedAt,
    this.revoked = false,
  });

  final String deviceId;
  final String name;
  final String role;
  final DateTime? joinedAt;
  final bool revoked;

  bool get isAdmin => role == 'admin';

  factory CloudDeviceInfo.fromJson(Map<String, dynamic> json) {
    return CloudDeviceInfo(
      deviceId: json['deviceId'] as String? ?? '',
      name: json['name'] as String? ?? 'Celular',
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? ''),
      revoked: json['revoked'] == true,
    );
  }
}

/// Convite de pareamento (RFC v3): o QR carrega um convite de uso único que o
/// Worker troca por uma credencial própria do celular — nunca um segredo
/// compartilhado.
class CloudInviteToken {
  const CloudInviteToken({
    required this.endpoint,
    required this.churchCode,
    required this.inviteId,
    required this.inviteSecret,
  });

  final String endpoint;
  final String churchCode;
  final String inviteId;
  final String inviteSecret;

  String encode() {
    final payload = jsonEncode({
      'v': 3,
      'e': endpoint.trim(),
      'c': churchCode.trim(),
      'i': inviteId,
      's': inviteSecret,
    });
    return '$kCloudTokenPrefix${base64Url.encode(utf8.encode(payload))}';
  }

  static CloudInviteToken? decode(String token) {
    try {
      var clean = token.trim();
      if (clean.startsWith(kCloudTokenPrefix)) {
        clean = clean.substring(kCloudTokenPrefix.length);
      }
      final map =
          jsonDecode(utf8.decode(base64Url.decode(clean))) as Map<String, dynamic>;
      if ((map['v'] as num?)?.toInt() != 3) return null;
      final invite = CloudInviteToken(
        endpoint: map['e'] as String? ?? '',
        churchCode: map['c'] as String? ?? '',
        inviteId: map['i'] as String? ?? '',
        inviteSecret: map['s'] as String? ?? '',
      );
      if (invite.endpoint.isEmpty ||
          invite.churchCode.isEmpty ||
          invite.inviteId.isEmpty ||
          invite.inviteSecret.isEmpty) {
        return null;
      }
      return invite;
    } catch (_) {
      return null;
    }
  }
}

/// Resultado do cadastro/convite/recuperação: credencial + contexto.
class CloudBootstrapResult {
  const CloudBootstrapResult({
    required this.deviceToken,
    required this.role,
    this.churchName = '',
    this.recoveryCode,
  });

  final String deviceToken;
  final String role;
  final String churchName;

  /// Presente só no cadastro/regeneração — mostrar UMA vez para guardar.
  final String? recoveryCode;
}

/// Configuração de acesso deste celular: credencial própria (deviceToken),
/// obtida no registro (1º celular) ou na troca de um convite.
class CloudBackupConfig {
  const CloudBackupConfig({
    required this.endpoint,
    required this.churchCode,
    required this.deviceId,
    required this.deviceToken,
  });

  final String endpoint;
  final String churchCode;
  final String deviceId;
  final String deviceToken;

  bool get isComplete =>
      endpoint.trim().isNotEmpty &&
      churchCode.trim().isNotEmpty &&
      deviceId.trim().isNotEmpty &&
      deviceToken.trim().isNotEmpty;

  Uri _uri(String path) {
    var base = endpoint.trim();
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    if (!base.startsWith('http')) base = 'https://$base';
    return Uri.parse('$base$path');
  }
}

/// Cliente HTTP do Worker (por evento). Sem estado: a orquestração fica no
/// `CloudSyncController`.
class CloudBackupService {
  CloudBackupService(this.config);

  final CloudBackupConfig config;

  static const _timeout = Duration(seconds: 30);
  static const _transferTimeout = Duration(minutes: 2);

  Future<HttpClientRequest> _request(String method, String path,
      {Duration? timeout}) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    final request = await client
        .openUrl(method, config._uri(path))
        .timeout(timeout ?? _timeout);
    request.headers.set('x-church-code', config.churchCode.trim());
    request.headers.set('x-device-id', config.deviceId.trim());
    request.headers.set('x-device-token', config.deviceToken.trim());
    return request;
  }

  Never _fail(int status, String body) {
    String message;
    try {
      message = (jsonDecode(body) as Map<String, dynamic>)['error'] as String? ??
          'Erro HTTP $status';
    } catch (_) {
      message = 'Erro HTTP $status';
    }
    if (status == HttpStatus.forbidden || status == HttpStatus.unauthorized) {
      throw CloudAccessDeniedException(message);
    }
    throw CloudBackupException(message);
  }

  Future<Map<String, dynamic>> _json(HttpClientRequest request,
      {Duration? timeout}) async {
    final response = await request.close().timeout(timeout ?? _timeout);
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) _fail(response.statusCode, body);
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// Registra a igreja (com NOME) + este celular como administrador.
  /// Retorna o deviceToken e o código de recuperação (mostrado uma vez).
  static Future<CloudBootstrapResult> register({
    required String endpoint,
    required String churchCode,
    required String churchName,
    required String deviceId,
    required String deviceName,
  }) async {
    final bootstrap = CloudBackupConfig(
      endpoint: endpoint,
      churchCode: churchCode,
      deviceId: deviceId,
      deviceToken: '-',
    );
    return _bootstrapCall(bootstrap, '/v1/register', {
      'deviceName': deviceName,
      'churchName': churchName,
    });
  }

  /// Troca um convite pela credencial deste celular.
  static Future<CloudBootstrapResult> join({
    required CloudInviteToken invite,
    required String deviceId,
    required String deviceName,
  }) async {
    final bootstrap = CloudBackupConfig(
      endpoint: invite.endpoint,
      churchCode: invite.churchCode,
      deviceId: deviceId,
      deviceToken: '-',
    );
    return _bootstrapCall(bootstrap, '/v1/join', {
      'inviteId': invite.inviteId,
      'inviteSecret': invite.inviteSecret,
      'deviceName': deviceName,
    });
  }

  /// Recupera o posto de ADMINISTRADOR num aparelho novo via código de
  /// recuperação (uso único — o servidor o consome).
  static Future<CloudBootstrapResult> recoverAdmin({
    required String endpoint,
    required String churchCode,
    required String recoveryCode,
    required String deviceId,
    required String deviceName,
  }) async {
    final bootstrap = CloudBackupConfig(
      endpoint: endpoint,
      churchCode: churchCode,
      deviceId: deviceId,
      deviceToken: '-',
    );
    return _bootstrapCall(bootstrap, '/v1/recover', {
      'recoveryCode': recoveryCode.trim().toUpperCase(),
      'deviceName': deviceName,
    });
  }

  static Future<CloudBootstrapResult> _bootstrapCall(
      CloudBackupConfig config, String path, Map<String, dynamic> body) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    final request =
        await client.openUrl('POST', config._uri(path)).timeout(_timeout);
    request.headers.contentType = ContentType.json;
    request.headers.set('x-church-code', config.churchCode.trim());
    request.headers.set('x-device-id', config.deviceId.trim());
    request.write(jsonEncode(body));
    final response = await request.close().timeout(_timeout);
    final responseBody = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) {
      String message;
      try {
        message = (jsonDecode(responseBody) as Map<String, dynamic>)['error']
                as String? ??
            'Erro HTTP ${response.statusCode}';
      } catch (_) {
        message = 'Erro HTTP ${response.statusCode}';
      }
      throw CloudBackupException(message);
    }
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    return CloudBootstrapResult(
      deviceToken: data['deviceToken'] as String? ?? '',
      role: data['role'] as String? ?? 'member',
      churchName: data['churchName'] as String? ?? '',
      recoveryCode: data['recoveryCode'] as String?,
    );
  }

  /// Informações da igreja (nome, se há código de recuperação ativo).
  Future<({String name, bool hasRecoveryCode})> getChurchInfo() async {
    final data = await _json(await _request('GET', '/v1/church'));
    return (
      name: data['name'] as String? ?? '',
      hasRecoveryCode: data['hasRecoveryCode'] == true,
    );
  }

  /// Renomeia a igreja (apenas administradores).
  Future<void> renameChurch(String name) async {
    final request = await _request('PUT', '/v1/church');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'name': name.trim()}));
    await _json(request);
  }

  /// Gera um NOVO código de recuperação (invalida o anterior; admin).
  Future<String> regenerateRecoveryCode() async {
    final request = await _request('POST', '/v1/church/recovery-code');
    request.headers.contentType = ContentType.json;
    request.write('{}');
    final data = await _json(request);
    return data['recoveryCode'] as String? ?? '';
  }

  /// Cria um convite de pareamento (apenas celulares administradores).
  Future<CloudInviteToken> createInvite() async {
    final request = await _request('POST', '/v1/invites');
    request.headers.contentType = ContentType.json;
    request.write('{}');
    final data = await _json(request);
    return CloudInviteToken(
      endpoint: config.endpoint,
      churchCode: config.churchCode,
      inviteId: data['inviteId'] as String? ?? '',
      inviteSecret: data['inviteSecret'] as String? ?? '',
    );
  }

  /// Lista os celulares da igreja (para "Quem recebe" e administração).
  Future<List<CloudDeviceInfo>> listDevices() async {
    final data = await _json(await _request('GET', '/v1/devices'));
    return (data['devices'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CloudDeviceInfo.fromJson)
        .toList();
  }

  /// Atualiza um celular: qualquer aparelho renomeia A SI MESMO; revogar e
  /// mudar papel continuam exclusivos do administrador.
  Future<void> updateDevice(String deviceId,
      {bool? revoked, String? role, String? name}) async {
    final request = await _request('PUT', '/v1/devices/$deviceId');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({
      'revoked': ?revoked,
      'role': ?role,
      'name': ?name,
    }));
    await _json(request);
  }

  /// Atualiza a lista de acesso de um evento (dono ou administrador).
  Future<CloudEventManifest> updateEventAcl(
      String eventId, List<String> sharedWith) async {
    final request = await _request('PUT', '/v1/events/$eventId/acl');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'sharedWith': sharedWith}));
    final data = await _json(request);
    return CloudEventManifest.fromJson(
        data['manifest'] as Map<String, dynamic>);
  }

  Future<List<CloudEventManifest>> listEvents() async {
    final request = await _request('GET', '/v1/events');
    final response = await request.close().timeout(_timeout);
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) _fail(response.statusCode, body);
    final data = jsonDecode(body) as Map<String, dynamic>;
    return (data['events'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CloudEventManifest.fromJson)
        .toList();
  }

  Future<CloudEventManifest> getEventManifest(String eventId) async {
    final request = await _request('GET', '/v1/events/$eventId/manifest');
    final response = await request.close().timeout(_timeout);
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) _fail(response.statusCode, body);
    return CloudEventManifest.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  /// Baixa o snapshot gzip e confere o sha256, se informado.
  Future<Uint8List> downloadEventSnapshot(String eventId, int version,
      {String? expectedSha256}) async {
    final request = await _request(
        'GET', '/v1/events/$eventId/snapshot/$version',
        timeout: _transferTimeout);
    final response = await request.close().timeout(_transferTimeout);
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    if (response.statusCode != HttpStatus.ok) {
      _fail(response.statusCode, utf8.decode(bytes, allowMalformed: true));
    }
    if (expectedSha256 != null && expectedSha256.isNotEmpty) {
      final actual = sha256.convert(bytes).toString();
      if (actual != expectedSha256.toLowerCase()) {
        throw CloudBackupException(
          'Download corrompido: sha256 não confere. Tente novamente.',
        );
      }
    }
    return bytes;
  }

  /// Envia o snapshot do evento esperando que a nuvem esteja em
  /// [expectedVersion]. Lança [CloudConflictException] num 409.
  Future<CloudEventManifest> uploadEventSnapshot({
    required String eventId,
    required Uint8List gzipBytes,
    required int expectedVersion,
    required int schemaVersion,
    required int formatVersion,
    required String deviceId,
    required String deviceName,
    String? eventTitle,
    int? eventDateMs,
    bool eventDeleted = false,
    Map<String, dynamic>? summary,
  }) async {
    final digest = sha256.convert(gzipBytes).toString();
    final request = await _request(
      'PUT',
      '/v1/events/$eventId/snapshot?expected=$expectedVersion',
      timeout: _transferTimeout,
    );
    request.headers.contentType = ContentType('application', 'gzip');
    request.headers.set('x-snapshot-sha256', digest);
    request.headers.set('x-schema-version', '$schemaVersion');
    request.headers.set('x-format-version', '$formatVersion');
    request.headers.set('x-device-id', deviceId);
    request.headers.set('x-device-name', _asciiSafe(deviceName));
    if (eventTitle != null) {
      request.headers.set('x-event-title', _asciiSafe(eventTitle));
    }
    if (eventDateMs != null) {
      request.headers.set('x-event-date-ms', '$eventDateMs');
    }
    request.headers.set('x-event-deleted', '$eventDeleted');
    if (summary != null) {
      request.headers.set('x-summary', jsonEncode(summary));
    }
    request.contentLength = gzipBytes.length;
    request.add(gzipBytes);
    final response = await request.close().timeout(_transferTimeout);
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode == HttpStatus.conflict) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      throw CloudConflictException(
        CloudEventManifest.fromJson(
            data['manifest'] as Map<String, dynamic>? ??
                {'eventId': eventId, 'version': 0}),
      );
    }
    if (response.statusCode != HttpStatus.ok) _fail(response.statusCode, body);
    final data = jsonDecode(body) as Map<String, dynamic>;
    return CloudEventManifest.fromJson(data['manifest'] as Map<String, dynamic>);
  }

  /// Headers HTTP não aceitam caracteres fora de latin-1; títulos e nomes de
  /// aparelho podem ter emoji/acentos.
  static String _asciiSafe(String value) {
    return String.fromCharCodes(
      value.codeUnits.map((c) => c >= 32 && c < 127 ? c : 0x3F /* ? */),
    );
  }
}

/// Manifest da versão mais nova do app publicada na nuvem
/// (`cloud/publish_app.sh`).
class AppUpdateManifest {
  const AppUpdateManifest({
    required this.versionCode,
    required this.versionName,
    this.sha256,
    this.sizeBytes,
    this.notes,
    this.uploadedAt,
  });

  final int versionCode;
  final String versionName;
  final String? sha256;
  final int? sizeBytes;
  final String? notes;
  final DateTime? uploadedAt;

  bool get isEmpty => versionCode <= 0;

  factory AppUpdateManifest.fromJson(Map<String, dynamic> json) {
    return AppUpdateManifest(
      versionCode: (json['versionCode'] as num?)?.toInt() ?? 0,
      versionName: json['versionName'] as String? ?? '',
      sha256: json['sha256'] as String?,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      uploadedAt: DateTime.tryParse(json['uploadedAt'] as String? ?? ''),
    );
  }
}

/// Atualização do app via nuvem (extensão do cliente do Worker).
extension AppUpdateApi on CloudBackupService {
  Future<AppUpdateManifest> getAppLatest() async {
    final request = await _request('GET', '/v1/app/latest');
    final response = await request.close().timeout(CloudBackupService._timeout);
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode != HttpStatus.ok) _fail(response.statusCode, body);
    return AppUpdateManifest.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }

  /// Baixa o APK para [target], com progresso e conferência de sha256.
  Future<void> downloadApk(
    int versionCode,
    File target, {
    String? expectedSha256,
    void Function(int received, int total)? onProgress,
  }) async {
    final request = await _request('GET', '/v1/app/apk/$versionCode',
        timeout: const Duration(minutes: 10));
    final response =
        await request.close().timeout(const Duration(minutes: 10));
    if (response.statusCode != HttpStatus.ok) {
      final body = await utf8.decoder.bind(response).join();
      _fail(response.statusCode, body);
    }
    final total = response.contentLength;
    if (await target.exists()) await target.delete();
    final sink = target.openWrite();
    var received = 0;
    try {
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
    } finally {
      await sink.close();
    }
    if (expectedSha256 != null && expectedSha256.isNotEmpty) {
      final digest =
          (await sha256.bind(target.openRead()).first).toString();
      if (digest != expectedSha256.toLowerCase()) {
        await target.delete();
        throw CloudBackupException(
            'Download corrompido (sha256 não confere). Tente novamente.');
      }
    }
  }
}
