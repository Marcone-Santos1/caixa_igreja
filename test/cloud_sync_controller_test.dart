import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:caixa_igreja/data/database.dart';
import 'package:caixa_igreja/data/event_cloud_aggregate.dart';
import 'package:caixa_igreja/data/sale_line_draft.dart';
import 'package:caixa_igreja/domain/payment_method.dart';
import 'package:caixa_igreja/providers/cloud_sync_provider.dart';
import 'package:caixa_igreja/providers/database_provider.dart';
import 'package:caixa_igreja/providers/shared_preferences_provider.dart';

/// Worker falso em memória (mesmo contrato HTTP do `cloud/worker`).
class _FakeWorker {
  late HttpServer _server;
  final Map<String, Map<int, Uint8List>> snapshots = {};
  final Map<String, Map<String, dynamic>> manifests = {};

  String get url => 'http://127.0.0.1:${_server.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_handle);
  }

  Future<void> stop() => _server.close(force: true);

  /// Pré-carrega um evento como se outro celular o tivesse enviado.
  void seed(String eventId, Uint8List gz,
      {String? title, int? dateMs, String deviceName = 'Celular do Diogo'}) {
    final version = (manifests[eventId]?['version'] as int? ?? 0) + 1;
    snapshots.putIfAbsent(eventId, () => {})[version] = gz;
    manifests[eventId] = {
      'eventId': eventId,
      'version': version,
      'sha256': sha256.convert(gz).toString(),
      'schemaVersion': kAppSchemaVersion,
      'formatVersion': kEventAggregateFormatVersion,
      'uploadedAt': DateTime.now().toUtc().toIso8601String(),
      'deviceId': 'outro-device',
      'deviceName': deviceName,
      'eventTitle': title ?? 'Evento',
      'eventDateMs': dateMs ?? 0,
      'baseVersion': version - 1,
      'summary': null,
      'ownerDeviceId': 'outro-device',
      'sharedWith': ['local'],
      'history': const [],
    };
  }

  Future<void> _handle(HttpRequest req) async {
    final path = req.uri.path;
    void json(Object data, [int status = 200]) {
      req.response.statusCode = status;
      req.response.headers.contentType = ContentType.json;
      req.response.write(jsonEncode(data));
    }

    try {
      if (req.method == 'GET' && path == '/v1/devices') {
        json({
          'devices': [
            {
              'deviceId': 'local',
              'name': 'Este aparelho',
              'role': 'admin',
              'joinedAt': DateTime.now().toUtc().toIso8601String(),
              'revoked': false,
            },
            {
              'deviceId': 'outro-device',
              'name': 'Celular do Diogo',
              'role': 'member',
              'joinedAt': DateTime.now().toUtc().toIso8601String(),
              'revoked': false,
            },
          ],
        });
      } else if (req.method == 'PUT' &&
          RegExp(r'^/v1/events/[^/]+/acl$').hasMatch(path)) {
        final id = path.split('/')[3];
        final manifest = manifests[id];
        if (manifest == null) {
          json({'error': 'Evento não encontrado'}, 404);
        } else {
          final builder = BytesBuilder(copy: false);
          await for (final chunk in req) {
            builder.add(chunk);
          }
          final body =
              jsonDecode(utf8.decode(builder.takeBytes())) as Map<String, dynamic>;
          manifest['sharedWith'] =
              (body['sharedWith'] as List).map((e) => e.toString()).toList();
          json({'ok': true, 'manifest': manifest});
        }
      } else if (req.method == 'GET' && path == '/v1/events') {
        json({'events': manifests.values.toList()});
      } else if (req.method == 'GET' &&
          RegExp(r'^/v1/events/[^/]+/manifest$').hasMatch(path)) {
        final id = path.split('/')[3];
        json(manifests[id] ?? {'eventId': id, 'version': 0});
      } else if (req.method == 'GET' &&
          RegExp(r'^/v1/events/[^/]+/snapshot/\d+$').hasMatch(path)) {
        final parts = path.split('/');
        final bytes = snapshots[parts[3]]?[int.parse(parts[5])];
        if (bytes == null) {
          json({'error': 'Snapshot não encontrado'}, 404);
        } else {
          req.response.headers.contentType =
              ContentType('application', 'gzip');
          req.response.add(bytes);
        }
      } else if (req.method == 'PUT' &&
          RegExp(r'^/v1/events/[^/]+/snapshot$').hasMatch(path)) {
        final id = path.split('/')[3];
        final expected = int.parse(req.uri.queryParameters['expected'] ?? '-1');
        final current = manifests[id]?['version'] as int? ?? 0;
        final builder = BytesBuilder(copy: false);
        await for (final chunk in req) {
          builder.add(chunk);
        }
        if (current != expected) {
          json({
            'error': 'conflict',
            'manifest': manifests[id] ?? {'eventId': id, 'version': 0},
          }, 409);
        } else {
          final gz = builder.takeBytes();
          final version = current + 1;
          snapshots.putIfAbsent(id, () => {})[version] = gz;
          final previous = manifests[id];
          manifests[id] = {
            'ownerDeviceId': previous?['ownerDeviceId'] ??
                (req.headers.value('x-device-id') ?? 'local'),
            'sharedWith': previous?['sharedWith'] ?? <String>[],
            'eventId': id,
            'version': version,
            'sha256': sha256.convert(gz).toString(),
            'schemaVersion':
                int.parse(req.headers.value('x-schema-version') ?? '0'),
            'formatVersion':
                int.parse(req.headers.value('x-format-version') ?? '0'),
            'uploadedAt': DateTime.now().toUtc().toIso8601String(),
            'deviceId': req.headers.value('x-device-id') ?? '',
            'deviceName': req.headers.value('x-device-name') ?? '',
            'eventTitle': req.headers.value('x-event-title') ?? '',
            'eventDateMs':
                int.parse(req.headers.value('x-event-date-ms') ?? '0'),
            'baseVersion': current,
            'summary': null,
            'history': const [],
          };
          json({'ok': true, 'manifest': manifests[id]!});
        }
      } else {
        json({'error': 'Rota não encontrada'}, 404);
      }
    } finally {
      await req.response.close();
    }
  }
}

Future<void> _waitUntil(bool Function() cond,
    {Duration timeout = const Duration(seconds: 10)}) async {
  final deadline = DateTime.now().add(timeout);
  while (!cond()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('timeout esperando condição');
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // flutter_test troca o HttpClient por um mock que responde 400 a tudo;
    // este teste fala com um servidor local real.
    HttpOverrides.global = null;
  });

  late _FakeWorker worker;
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    worker = _FakeWorker();
    await worker.start();
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({
      'cloud.endpoint': worker.url,
      'cloud.churchCode': 'igtest',
      'cloud.deviceToken': 'token-de-teste',
      'cloud.role': 'admin',
    });
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(db),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await worker.stop();
  });

  /// Monta o gzip de um agregado exportado de um "outro celular".
  Future<(String eventId, Uint8List gz)> buildRemoteEvent() async {
    final other = AppDatabase(NativeDatabase.memory());
    final eventId = other.generateUuid();
    await other.into(other.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Pastel Padroeira',
            dateEpochMs: 777,
          ),
        );
    final productId = await other.saveProduct(
      eventId: eventId,
      name: 'Pastel',
      priceCents: 800,
      trackStock: true,
      stockQty: 10,
      active: true,
    );
    await other.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 1600,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 2, unitPriceCents: 800),
      ],
    );
    final json = await other.exportEventAggregate(eventId);
    await other.close();
    return (eventId, Uint8List.fromList(gzip.encode(utf8.encode(jsonEncode(json)))));
  }

  test('evento que só existe na nuvem: aparece como cloudOnly e Baixar aplica',
      () async {
    final (eventId, gz) = await buildRemoteEvent();
    worker.seed(eventId, gz, title: 'Pastel Padroeira', dateMs: 777);

    final controller = container.read(cloudSyncControllerProvider.notifier);
    // Espera o refresh de abertura (microtask do construtor) assentar.
    await _waitUntil(() {
      final s = container.read(cloudSyncControllerProvider);
      return !s.busy && s.forEvent(eventId) != null;
    });
    var status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.cloudOnly);

    // O BUG era aqui: Baixar não baixava nada.
    await controller.downloadEvent(eventId);

    status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.upToDate);
    expect(status.lastSyncedVersion, 1);

    // O evento chegou de verdade no banco local, com vendas e estoque.
    final ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.title, 'Pastel Padroeira');
    final sales = await db.watchSalesForEvent(eventId).first;
    expect(sales, hasLength(1));
    final products = await db.watchAllProductsForEvent(eventId).first;
    expect(products.single.stockQty, 8);

    // E o refresh seguinte continua em dia (não vira divergência).
    await controller.refreshAll();
    status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.upToDate);
  });

  test('evento local novo sobe no refresh e fica em dia', () async {
    final controller = container.read(cloudSyncControllerProvider.notifier);
    // Espera o refresh de abertura TERMINAR (lastCheckedAt marcado), senão a
    // chamada explícita seguinte é descartada pelo guard de reentrância.
    await _waitUntil(() {
      final s = container.read(cloudSyncControllerProvider);
      return s.lastCheckedAt != null && !s.busy;
    });

    final eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Almoço Comunitário',
            dateEpochMs: 999,
          ),
        );
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Marmita',
      priceCents: 1500,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 1500,
      lines: [
        SaleLineDraft.product(
            productId: productId, qty: 1, unitPriceCents: 1500),
      ],
    );

    await controller.refreshAll(allowApply: false);
    var status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.upToDate);
    expect(status.lastSyncedVersion, 1);
    expect(worker.manifests[eventId]!['version'], 1);
    // Título vai em header HTTP (latin-1): acentos viram '?'.
    expect(worker.manifests[eventId]!['eventTitle'], 'Almo?o Comunit?rio');

    // Sem nada novo, o próximo refresh não gera versão nova.
    await controller.refreshAll(allowApply: false);
    expect(worker.manifests[eventId]!['version'], 1);

    // Uma venda nova gera v2 no próximo ciclo.
    await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.pix,
      amountReceivedCents: 1500,
      lines: [
        SaleLineDraft.product(
            productId: productId, qty: 1, unitPriceCents: 1500),
      ],
    );
    await controller.refreshAll(allowApply: false);
    expect(worker.manifests[eventId]!['version'], 2);
    status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.upToDate);
  });

  test('evento pausado não sobe nem baixa; retomar envia as pendências',
      () async {
    final controller = container.read(cloudSyncControllerProvider.notifier);
    await _waitUntil(() {
      final s = container.read(cloudSyncControllerProvider);
      return s.lastCheckedAt != null && !s.busy;
    });

    final eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Evento de teste local',
            dateEpochMs: 555,
          ),
        );

    // Pausa ANTES do primeiro envio: o refresh não deve criar versão nenhuma.
    await controller.setEventSyncPaused(eventId, true);
    await controller.refreshAll(allowApply: false);
    var status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.paused);
    expect(worker.manifests.containsKey(eventId), isFalse,
        reason: 'evento pausado não pode subir para a nuvem');

    // Escritas durante a pausa continuam locais.
    final productId = await db.saveProduct(
      eventId: eventId,
      name: 'Produto local',
      priceCents: 500,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    await db.completeSale(
      eventId: eventId,
      paymentMethod: PaymentMethod.dinheiro,
      amountReceivedCents: 500,
      lines: [
        SaleLineDraft.product(productId: productId, qty: 1, unitPriceCents: 500),
      ],
    );
    await controller.refreshAll(allowApply: false);
    expect(worker.manifests.containsKey(eventId), isFalse);

    // Baixar também é bloqueado enquanto pausado.
    await controller.downloadEvent(eventId);
    expect(container
        .read(cloudSyncControllerProvider)
        .forEvent(eventId)!
        .phase, CloudEventPhase.paused);

    // Retomar envia tudo que ficou pendente.
    await controller.setEventSyncPaused(eventId, false);
    status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.upToDate);
    expect(worker.manifests[eventId]!['version'], 1);
  });

  test('evento novo nasce privado; compartilhar amplia a lista de acesso',
      () async {
    final controller = container.read(cloudSyncControllerProvider.notifier);
    await _waitUntil(() {
      final s = container.read(cloudSyncControllerProvider);
      return s.lastCheckedAt != null && !s.busy;
    });

    final eventId = db.generateUuid();
    await db.into(db.events).insert(
          EventsCompanion.insert(
            id: eventId,
            title: 'Festa do Padroeiro',
            dateEpochMs: 123,
          ),
        );
    await controller.refreshAll(allowApply: false);

    // Subiu automaticamente (backup), mas PRIVADO: lista de acesso vazia.
    expect(worker.manifests[eventId]!['version'], 1);
    expect(worker.manifests[eventId]!['sharedWith'], isEmpty);
    expect(worker.manifests[eventId]!['ownerDeviceId'], 'local');

    // Compartilhar = ligar o celular do Diogo na lista.
    await controller.toggleEventShare(eventId, 'outro-device', true);
    expect(worker.manifests[eventId]!['sharedWith'], ['outro-device']);
    var status = container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.remote!.sharedWith, ['outro-device']);

    // Desligar remove da lista.
    await controller.toggleEventShare(eventId, 'outro-device', false);
    expect(worker.manifests[eventId]!['sharedWith'], isEmpty);
  });

  test('download não sobrescreve evento local com alterações pendentes',
      () async {
    final (eventId, gz) = await buildRemoteEvent();
    worker.seed(eventId, gz, title: 'Pastel Padroeira');
    // A nuvem avança para v2 (outro celular vendeu mais).
    worker.seed(eventId, gz, title: 'Pastel Padroeira');

    final controller = container.read(cloudSyncControllerProvider.notifier);
    // Espera o refresh de abertura TERMINAR (lastCheckedAt marcado), senão a
    // chamada explícita seguinte é descartada pelo guard de reentrância.
    await _waitUntil(() {
      final s = container.read(cloudSyncControllerProvider);
      return s.lastCheckedAt != null && !s.busy;
    });

    // Este aparelho tem o MESMO evento com dados próprios nunca enviados.
    await db.runWithSyncBypass(() async {
      await db.into(db.events).insert(
            EventsCompanion.insert(
              id: eventId,
              title: 'Pastel (local)',
              dateEpochMs: 777,
            ),
          );
    });
    await db.saveProduct(
      eventId: eventId,
      name: 'Produto local',
      priceCents: 100,
      trackStock: false,
      stockQty: 0,
      active: true,
    );
    // Simula que a v1 era a base conhecida, mas há alterações locais depois
    // dela (fingerprint divergente do armazenado).
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cloud.ev.$eventId.v', 1);
    await prefs.setString('cloud.ev.$eventId.fp', 'fp-antigo');

    await controller.downloadEvent(eventId);

    final status =
        container.read(cloudSyncControllerProvider).forEvent(eventId);
    expect(status!.phase, CloudEventPhase.divergence,
        reason: 'download nunca sobrescreve alterações locais em silêncio');
    final ev = await (db.select(db.events)..where((e) => e.id.equals(eventId)))
        .getSingle();
    expect(ev.title, 'Pastel (local)', reason: 'dados locais intactos');
  });
}
