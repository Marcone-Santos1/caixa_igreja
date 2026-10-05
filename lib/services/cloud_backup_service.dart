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
    this.baseVersion,
    this.summary,
    this.history = const [],
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
  final int? baseVersion;
  final Map<String, dynamic>? summary;
  final List<CloudEventManifest> history;

  bool get isEmpty => version <= 0;

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
      baseVersion: (json['baseVersion'] as num?)?.toInt(),
      summary: json['summary'] as Map<String, dynamic>?,
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

/// Configuração de acesso (gerada pelo app ao ativar; compartilhada por QR).
class CloudBackupConfig {
  const CloudBackupConfig({
    required this.endpoint,
    required this.churchCode,
    required this.secret,
  });

  final String endpoint;
  final String churchCode;
  final String secret;

  bool get isComplete =>
      endpoint.trim().isNotEmpty &&
      churchCode.trim().isNotEmpty &&
      secret.trim().isNotEmpty;

  /// Token de pareamento (vai no QR e pode ser colado como texto).
  String toPairingToken() {
    final payload = jsonEncode({
      'v': 1,
      'e': endpoint.trim(),
      'c': churchCode.trim(),
      's': secret.trim(),
    });
    return '$kCloudTokenPrefix${base64Url.encode(utf8.encode(payload))}';
  }

  static CloudBackupConfig? fromPairingToken(String token) {
    try {
      var clean = token.trim();
      if (clean.startsWith(kCloudTokenPrefix)) {
        clean = clean.substring(kCloudTokenPrefix.length);
      }
      final map =
          jsonDecode(utf8.decode(base64Url.decode(clean))) as Map<String, dynamic>;
      final config = CloudBackupConfig(
        endpoint: map['e'] as String? ?? '',
        churchCode: map['c'] as String? ?? '',
        secret: map['s'] as String? ?? '',
      );
      return config.isComplete ? config : null;
    } catch (_) {
      return null;
    }
  }

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
    request.headers.set('x-church-secret', config.secret.trim());
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
    throw CloudBackupException(message);
  }

  /// Também serve de "registro": o primeiro request de um código novo
  /// reivindica o espaço da igreja no servidor.
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
