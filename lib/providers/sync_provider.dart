import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:drift/drift.dart' show Value, InsertMode;
import '../data/database.dart';
import '../data/sale_line_draft.dart';
import '../domain/sale_line_kind.dart';
import 'database_provider.dart';

enum SyncMode { standalone, server, client }

class SyncState {
  final SyncMode mode;
  final String? serverIp;
  final int serverPort;
  final bool isConnected;
  final List<Map<String, dynamic>>
  discoveredServers; // List of discovered servers: [{'ip', 'port', 'eventTitle', 'eventId', 'lastSeen'}]
  final List<String> connectedClients; // List of client IPs on server
  final String? error;

  SyncState({
    this.mode = SyncMode.standalone,
    this.serverIp,
    this.serverPort = 8080,
    this.isConnected = false,
    this.discoveredServers = const [],
    this.connectedClients = const [],
    this.error,
  });

  SyncState copyWith({
    SyncMode? mode,
    String? serverIp,
    int? serverPort,
    bool? isConnected,
    List<Map<String, dynamic>>? discoveredServers,
    List<String>? connectedClients,
    String? error,
  }) {
    return SyncState(
      mode: mode ?? this.mode,
      serverIp: serverIp ?? this.serverIp,
      serverPort: serverPort ?? this.serverPort,
      isConnected: isConnected ?? this.isConnected,
      discoveredServers: discoveredServers ?? this.discoveredServers,
      connectedClients: connectedClients ?? this.connectedClients,
      error: error,
    );
  }
}

// Global stream controllers to notify caches in Client mode
final Map<String, StreamController<List<dynamic>>> _clientStreamControllers = {
  'products': StreamController<List<dynamic>>.broadcast(),
  'denoms': StreamController<List<dynamic>>.broadcast(),
  'sales': StreamController<List<dynamic>>.broadcast(),
  'lines': StreamController<List<dynamic>>.broadcast(),
  'changeDotAllocations': StreamController<List<dynamic>>.broadcast(),
};

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncNotifier(db);
});

class SyncNotifier extends StateNotifier<SyncState> {
  final AppDatabase _db;
  HttpServer? _httpServer;
  RawDatagramSocket? _udpBroadcastSocket;
  RawDatagramSocket? _udpListenerSocket;
  Timer? _broadcastTimer;
  WebSocket? _clientWebSocket;
  final List<WebSocket> _serverWebSockets = [];
  Timer? _discoveredCleanupTimer;

  SyncNotifier(this._db) : super(SyncState()) {
    // Start discovery listener by default to find servers
    _startUdpListener();
    _startDiscoveredCleanupTimer();
  }

  @override
  void dispose() {
    stopAll();
    _udpListenerSocket?.close();
    _discoveredCleanupTimer?.cancel();
    super.dispose();
  }

  void _startDiscoveredCleanupTimer() {
    _discoveredCleanupTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      final filtered = state.discoveredServers.where((s) {
        final lastSeen = s['lastSeen'] as DateTime;
        return now.difference(lastSeen).inSeconds < 10;
      }).toList();
      if (filtered.length != state.discoveredServers.length) {
        state = state.copyWith(discoveredServers: filtered);
      }
    });
  }

  void stopAll() {
    _stopServer();
    _stopClient();
    state = SyncState(discoveredServers: state.discoveredServers);
  }

  void setClientMode() {
    stopAll();
    state = state.copyWith(
      mode: SyncMode.client,
      isConnected: false,
      error: null,
    );
  }

  // --- SERVER (HOST) MODE ---

  Future<void> startServer(String eventId, String eventTitle) async {
    stopAll();
    try {
      String? localIp = await _getLocalIp();
      if (localIp == null) {
        developer.log('IP local não detectado. Usando fallback 127.0.0.1.', name: 'SyncServer');
        localIp = '127.0.0.1';
      }

      // Bind HTTP Server
      _httpServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        state.serverPort,
      );
      _httpServer!.listen(
        _handleHttpRequest,
        onError: (err) {
          developer.log('Erro no servidor HTTP: $err', name: 'SyncServer');
        },
      );

      // Start UDP Broadcast for discovery
      _udpBroadcastSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      _udpBroadcastSocket!.broadcastEnabled = true;

      final broadcastPayload = jsonEncode({
        'ip': localIp,
        'port': state.serverPort,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'appName': 'CaixaIgreja',
      });
      final bytes = utf8.encode(broadcastPayload);

      _broadcastTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        try {
          _udpBroadcastSocket?.send(
            bytes,
            InternetAddress('255.255.255.255'),
            4545,
          );
        } catch (e) {
          developer.log('Erro ao enviar UDP broadcast: $e', name: 'SyncServer');
        }
      });

      state = state.copyWith(
        mode: SyncMode.server,
        serverIp: localIp,
        isConnected: true,
        error: null,
      );
      developer.log(
        'Servidor iniciado em $localIp:${state.serverPort}',
        name: 'SyncServer',
      );
    } catch (e, stack) {
      developer.log('Erro ao iniciar o servidor: $e', name: 'SyncServer', error: e, stackTrace: stack);
      stopAll();
      state = state.copyWith(error: 'Falha ao iniciar o servidor: $e');
    }
  }

  void _stopServer() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;

    _udpBroadcastSocket?.close();
    _udpBroadcastSocket = null;

    for (final ws in _serverWebSockets) {
      ws.close();
    }
    _serverWebSockets.clear();

    _httpServer?.close(force: true);
    _httpServer = null;
  }

  Future<void> _handleHttpRequest(HttpRequest request) async {
    // Enable CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, POST, OPTIONS',
    );
    request.response.headers.add(
      'Access-Control-Allow-Headers',
      'Content-Type',
    );

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    developer.log(
      'Server HTTP Request: ${request.method} $path',
      name: 'SyncServer',
    );

    try {
      // WS Upgrade
      if (path.endsWith('/ws')) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final ws = await WebSocketTransformer.upgrade(request);
          _serverWebSockets.add(ws);
          final clientIp =
              request.connectionInfo?.remoteAddress.address ?? 'Desconhecido';
          state = state.copyWith(
            connectedClients: [...state.connectedClients, clientIp],
          );
          ws.listen(
            (data) {},
            onDone: () {
              _serverWebSockets.remove(ws);
              final list = [...state.connectedClients]..remove(clientIp);
              state = state.copyWith(connectedClients: list);
            },
            onError: (err) {
              _serverWebSockets.remove(ws);
              final list = [...state.connectedClients]..remove(clientIp);
              state = state.copyWith(connectedClients: list);
            },
          );
          return;
        }
      }

      final uriSegments = request.uri.pathSegments;
      if (uriSegments.isEmpty) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      if (uriSegments[0] == 'status') {
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({'status': 'ok', 'ip': state.serverIp}),
        );
        await request.response.close();
        return;
      }

      if (uriSegments.length >= 3 && uriSegments[0] == 'events') {
        final eventId = uriSegments[1];
        final endpoint = uriSegments[2];

        if (request.method == 'GET') {
          request.response.headers.contentType = ContentType.json;

          if (endpoint == 'details') {
            final ev = await (_db.select(
              _db.events,
            )..where((t) => t.id.equals(eventId))).getSingleOrNull();
            request.response.write(jsonEncode(ev?.toJson()));
          } else if (endpoint == 'products') {
            final list = await _db.watchAllProductsForEvent(eventId).first;
            request.response.write(
              jsonEncode(list.map((e) => e.toJson()).toList()),
            );
          } else if (endpoint == 'denoms') {
            final list = await _db.watchDotDenominations(eventId).first;
            request.response.write(
              jsonEncode(list.map((e) => e.toJson()).toList()),
            );
          } else if (endpoint == 'sales') {
            final list = await _db.watchSalesForEvent(eventId).first;
            request.response.write(
              jsonEncode(list.map((e) => e.toJson()).toList()),
            );
          } else if (endpoint == 'lines') {
            final list = await _db.watchSaleLinesForEvent(eventId).first;
            request.response.write(
              jsonEncode(list.map((e) => e.toJson()).toList()),
            );
          } else if (endpoint == 'change-allocations') {
            final list = await _db
                .watchChangeDotAllocationsForEvent(eventId)
                .first;
            request.response.write(
              jsonEncode(list.map((e) => e.toJson()).toList()),
            );
          } else if (endpoint == 'combo-items') {
            final list = await _db.getComboItemsForEvent(eventId);
            request.response.write(
              jsonEncode(list.map((e) => e.toJson()).toList()),
            );
          } else {
            request.response.statusCode = HttpStatus.notFound;
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'sales') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);

          final paymentMethod = body['paymentMethod'] as String;
          final amountReceivedCents = body['amountReceivedCents'] as int;
          final notes = body['notes'] as String?;
          final changePending = body['changePending'] as bool? ?? false;
          final customerName = body['customerName'] as String?;
          final linesJson = body['lines'] as List;

          final drafts = linesJson.map((l) {
            final kind = l['kind'] as int;
            final productId = l['productId'] as String?;
            final dotDenominationId = l['dotDenominationId'] as String?;
            final freeLabel = l['freeLabel'] as String?;
            final qty = l['qty'] as int;
            final unitPriceCents = l['unitPriceCents'] as int?;
            final lineTotalCents = l['lineTotalCents'] as int?;

            if (kind == SaleLineKind.product) {
              return SaleLineDraft.product(
                productId: productId!,
                qty: qty,
                unitPriceCents: unitPriceCents!,
              );
            } else if (kind == SaleLineKind.ficha) {
              return SaleLineDraft.ficha(
                dotDenominationId: dotDenominationId!,
                qty: qty,
                unitPriceCents: unitPriceCents!,
              );
            } else {
              return SaleLineDraft.valorLivre(
                freeLabel: freeLabel!,
                lineTotalCents: lineTotalCents!,
              );
            }
          }).toList();

          try {
            final saleId = await _db.completeSale(
              eventId: eventId,
              paymentMethod: paymentMethod,
              amountReceivedCents: amountReceivedCents,
              notes: notes,
              changePending: changePending,
              customerName: customerName,
              lines: drafts,
            );

            // Broadcast refresh to WebSocket clients
            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(
              jsonEncode({'success': true, 'saleId': saleId}),
            );
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(
              jsonEncode({'success': false, 'error': e.toString()}),
            );
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'products') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);

          final id = body['id'] as String?;
          final name = body['name'] as String;
          final priceCents = body['priceCents'] as int;
          final description = body['description'] as String? ?? '';
          final trackStock = body['trackStock'] as bool? ?? false;
          final stockQty = body['stockQty'] as int? ?? 0;
          final active = body['active'] as bool? ?? true;
          final isCombo = body['isCombo'] as bool? ?? false;

          try {
            if (isCombo) {
              final itemsList = body['items'] as List;
              final items = itemsList.map((i) {
                final childId = i['childProductId'] as String;
                final qty = i['qty'] as int;
                return (childProductId: childId, qty: qty);
              }).toList();

              if (id == null) {
                await _db.createCombo(
                  eventId: eventId,
                  name: name,
                  priceCents: priceCents,
                  description: description,
                  active: active,
                  items: items,
                );
              } else {
                await _db.updateCombo(
                  comboProductId: id,
                  name: name,
                  priceCents: priceCents,
                  description: description,
                  active: active,
                  items: items,
                );
              }
            } else {
              if (id == null) {
                final idToUse = _db.generateUuid();
                await _db.into(_db.products).insert(ProductsCompanion.insert(
                  id: idToUse,
                  eventId: eventId,
                  name: name,
                  priceCents: priceCents,
                  description: Value(description),
                  trackStock: Value(trackStock),
                  stockQty: Value(stockQty),
                  active: Value(active),
                  isCombo: const Value(false),
                ));
              } else {
                await (_db.update(_db.products)..where((t) => t.id.equals(id))).write(ProductsCompanion(
                  name: Value(name),
                  priceCents: Value(priceCents),
                  description: Value(description),
                  trackStock: Value(trackStock),
                  stockQty: Value(stockQty),
                  active: Value(active),
                ));
              }
            }

            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'delete-product') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);
          final productId = body['productId'] as String;

          try {
            final err = await _db.deleteProduct(eventId: eventId, productId: productId);
            if (err != null) throw StateError(err);

            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'denoms') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);

          final id = body['id'] as String?;
          final label = body['label'] as String;
          final valueCents = body['valueCents'] as int;
          final stockQty = body['stockQty'] as int? ?? 0;

          try {
            if (id == null) {
              final idToUse = _db.generateUuid();
              await _db.into(_db.eventDotDenominations).insert(EventDotDenominationsCompanion.insert(
                id: idToUse,
                eventId: eventId,
                label: label,
                valueCents: valueCents,
                stockQty: Value(stockQty),
              ));
            } else {
              await (_db.update(_db.eventDotDenominations)..where((t) => t.id.equals(id))).write(EventDotDenominationsCompanion(
                label: Value(label),
                valueCents: Value(valueCents),
                stockQty: Value(stockQty),
              ));
            }

            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'delete-denom') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);
          final denomId = body['denomId'] as String;

          try {
            final err = await _db.deleteDotDenomination(eventId: eventId, dotDenominationId: denomId);
            if (err != null) throw StateError(err);

            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'edit-sale') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);

          final saleId = body['saleId'] as String;
          final paymentMethod = body['paymentMethod'] as String;
          final amountReceivedCents = body['amountReceivedCents'] as int;
          final notes = body['notes'] as String?;
          final changePending = body['changePending'] as bool? ?? false;
          final customerName = body['customerName'] as String?;
          final linesJson = body['lines'] as List;

          final drafts = linesJson.map((l) {
            final kind = l['kind'] as int;
            final productId = l['productId'] as String?;
            final dotDenominationId = l['dotDenominationId'] as String?;
            final freeLabel = l['freeLabel'] as String?;
            final qty = l['qty'] as int;
            final unitPriceCents = l['unitPriceCents'] as int?;
            final lineTotalCents = l['lineTotalCents'] as int?;

            if (kind == SaleLineKind.product) {
              return SaleLineDraft.product(
                productId: productId!,
                qty: qty,
                unitPriceCents: unitPriceCents!,
              );
            } else if (kind == SaleLineKind.ficha) {
              return SaleLineDraft.ficha(
                dotDenominationId: dotDenominationId!,
                qty: qty,
                unitPriceCents: unitPriceCents!,
              );
            } else {
              return SaleLineDraft.valorLivre(
                freeLabel: freeLabel!,
                lineTotalCents: lineTotalCents!,
              );
            }
          }).toList();

          try {
            await _db.updateSaleWithLines(
              saleId: saleId,
              eventId: eventId,
              paymentMethod: paymentMethod,
              amountReceivedCents: amountReceivedCents,
              notes: notes,
              changePending: changePending,
              customerName: customerName,
              lines: drafts,
            );

            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'delete-sale') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);
          final saleId = body['saleId'] as String;

          try {
            await _db.deleteSale(saleId);

            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
          }
          await request.response.close();
          return;
        }

        if (request.method == 'POST' && endpoint == 'resolve-change') {
          final content = await utf8.decoder.bind(request).join();
          final Map<String, dynamic> body = jsonDecode(content);

          final saleId = body['saleId'] as String;
          final paymentMethod = body['paymentMethod'] as String;
          final amountReceivedCents = body['amountReceivedCents'] as int;
          final notes = body['notes'] as String?;
          final changePending = body['changePending'] as bool? ?? false;
          final customerName = body['customerName'] as String?;

          try {
            await _db.updateSaleDetails(
              saleId: saleId,
              paymentMethod: paymentMethod,
              amountReceivedCents: amountReceivedCents,
              notes: notes,
              changePending: changePending,
              customerName: customerName,
            );

            _broadcastServerRefresh();

            request.response.headers.contentType = ContentType.json;
            request.response.write(jsonEncode({'success': true}));
          } catch (e) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.write(jsonEncode({'success': false, 'error': e.toString()}));
          }
          await request.response.close();
          return;
        }
      }

      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    } catch (e) {
      developer.log('Erro ao processar request HTTP: $e', name: 'SyncServer');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.write(jsonEncode({'error': e.toString()}));
        await request.response.close();
      } catch (_) {}
    }
  }

  void _broadcastServerRefresh() {
    for (final ws in _serverWebSockets) {
      try {
        ws.add('refresh');
      } catch (_) {}
    }
  }

  /// Método público para o lado servidor notificar os clientes de uma mudança.
  void broadcastRefresh() => _broadcastServerRefresh();

  // --- CLIENT (TERMINAL) MODE ---

  Future<void> connectToHost(String ip, int port, String targetEventId) async {
    stopAll();
    developer.log('Conectando ao host $ip:$port', name: 'SyncClient');
    try {
      // Check status first
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse('http://$ip:$port/status'));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        state = state.copyWith(
          error: 'Conexão rejeitada pelo servidor (${response.statusCode})',
        );
        return;
      }

      state = state.copyWith(
        mode: SyncMode.client,
        serverIp: ip,
        serverPort: port,
        isConnected: true,
        error: null,
      );

      // Connect WebSocket for notifications
      _connectClientWebSocket(ip, port, targetEventId);

      // Trigger initial pull of all entities
      refreshAllClientCaches(targetEventId);
    } catch (e) {
      state = state.copyWith(
        error: 'Não foi possível conectar ao IP $ip:$port: $e',
      );
    }
  }

  void _connectClientWebSocket(String ip, int port, String eventId) {
    WebSocket.connect('ws://$ip:$port/events/$eventId/ws')
        .then((ws) {
          _clientWebSocket = ws;
          ws.listen(
            (message) {
              if (message == 'refresh') {
                developer.log(
                  'Mensagem WebSocket recebida: refresh',
                  name: 'SyncClient',
                );
                refreshAllClientCaches(eventId);
              }
            },
            onDone: () {
              developer.log('Conexão WebSocket finalizada', name: 'SyncClient');
              if (state.mode == SyncMode.client) {
                state = state.copyWith(isConnected: false);
              }
            },
            onError: (err) {
              developer.log(
                'Erro no WebSocket do cliente: $err',
                name: 'SyncClient',
              );
              if (state.mode == SyncMode.client) {
                state = state.copyWith(isConnected: false);
              }
            },
          );
        })
        .catchError((e) {
          developer.log('Erro ao abrir WebSocket: $e', name: 'SyncClient');
        });
  }

  void _stopClient() {
    _clientWebSocket?.close();
    _clientWebSocket = null;
  }

  Future<List<T>> _pullDataListFromServer<T>(
    String ip,
    int port,
    String eventId,
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 4);
    final request = await client.getUrl(
      Uri.parse('http://$ip:$port/events/$eventId/$endpoint'),
    );
    final response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      final content = await utf8.decoder.bind(response).join();
      final List list = jsonDecode(content);
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw StateError('Falha ao obter $endpoint (${response.statusCode})');
    }
  }

  Future<void> refreshAllClientCaches(String eventId) async {
    if (state.mode != SyncMode.client || !state.isConnected) return;

    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) return;

    try {
      // 1. Obter detalhes do evento
      final event = await fetchEventDetailsFromServer(eventId);
      if (event == null) throw StateError('Detalhes do evento não encontrados no servidor.');

      // 2. Obter denominações (Fichas)
      final denoms = await _pullDataListFromServer<EventDotDenom>(
        ip, port, eventId, 'denoms', (json) => EventDotDenom.fromJson(json),
      );

      // 3. Obter produtos
      final productsList = await _pullDataListFromServer<ChurchProduct>(
        ip, port, eventId, 'products', (json) => ChurchProduct.fromJson(json),
      );

      // 4. Obter itens de combo
      final comboItems = await _pullDataListFromServer<ProductComboItem>(
        ip, port, eventId, 'combo-items', (json) => ProductComboItem.fromJson(json),
      );

      // 5. Obter vendas
      final salesList = await _pullDataListFromServer<PosSale>(
        ip, port, eventId, 'sales', (json) => PosSale.fromJson(json),
      );

      // 6. Obter linhas de vendas
      final saleLinesList = await _pullDataListFromServer<PosSaleLine>(
        ip, port, eventId, 'lines', (json) => PosSaleLine.fromJson(json),
      );

      // 7. Obter alocações de troco
      final changeAllocations = await _pullDataListFromServer<ChangeDotRow>(
        ip, port, eventId, 'change-allocations', (json) => ChangeDotRow.fromJson(json),
      );

      // 8. Gravar os dados atômicos no banco de dados local do cliente
      await _db.syncEventData(
        eventId: eventId,
        event: event,
        denoms: denoms,
        productsList: productsList,
        comboItems: comboItems,
        salesList: salesList,
        saleLinesList: saleLinesList,
        changeAllocationsList: changeAllocations,
      );

      // 9. Atualizar os controllers antigos por compatibilidade temporária
      _clientStreamControllers['products']?.add(productsList);
      _clientStreamControllers['denoms']?.add(denoms);
      _clientStreamControllers['sales']?.add(salesList);
      _clientStreamControllers['lines']?.add(saleLinesList);
      _clientStreamControllers['changeDotAllocations']?.add(changeAllocations);

      developer.log(
        'Sincronização completa realizada no SQLite local para o evento $eventId',
        name: 'SyncClient',
      );
    } catch (e) {
      developer.log(
        'Erro ao realizar a sincronização completa com o Host: $e',
        name: 'SyncClient',
        error: e,
      );
    }
  }

  Future<ChurchEvent?> fetchEventDetailsFromServer(String eventId) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) return null;

    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('http://$ip:$port/events/$eventId/details'),
      );
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final content = await utf8.decoder.bind(response).join();
        final data = jsonDecode(content);
        if (data == null) return null;
        return ChurchEvent.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log(
        'Erro ao buscar detalhes do evento no servidor: $e',
        name: 'SyncClient',
      );
    }
    return null;
  }

  Future<String> submitSaleToHost(
    String eventId,
    String paymentMethod,
    int amountReceivedCents,
    String? notes,
    bool changePending,
    String? customerName,
    List<SaleLineDraft> lines,
  ) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/sales'),
    );
    request.headers.contentType = ContentType.json;

    final linesJson = lines.map((l) {
      return {
        'kind': l.kind,
        'productId': l.productId,
        'dotDenominationId': l.dotDenominationId,
        'freeLabel': l.freeLabel,
        'qty': l.qty,
        'unitPriceCents': l.unitPriceCents,
        'lineTotalCents': l.lineTotalCents,
      };
    }).toList();

    final body = {
      'paymentMethod': paymentMethod,
      'amountReceivedCents': amountReceivedCents,
      'notes': notes,
      'changePending': changePending,
      'customerName': customerName,
      'lines': linesJson,
    };

    request.write(jsonEncode(body));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode == HttpStatus.ok && data['success'] == true) {
      return data['saleId'] as String;
    } else {
      throw StateError(
        data['error'] as String? ??
            'Erro desconhecido ao enviar venda ao servidor.',
      );
    }
  }

  // --- UDP DISCOVERY ---

  void _startUdpListener() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 4545)
        .then((socket) {
          _udpListenerSocket = socket;
          socket.listen((event) {
            if (event == RawSocketEvent.read) {
              final datagram = socket.receive();
              if (datagram != null) {
                try {
                  final payload = utf8.decode(datagram.data);
                  final Map<String, dynamic> data = jsonDecode(payload);

                  if (data['appName'] == 'CaixaIgreja' &&
                      data['ip'] != state.serverIp) {
                    final discovered = [...state.discoveredServers];
                    final ip = data['ip'] as String;
                    final port = data['port'] as int;
                    final eventId = data['eventId'] as String;
                    final eventTitle = data['eventTitle'] as String;

                    final index = discovered.indexWhere(
                      (s) => s['ip'] == ip && s['port'] == port,
                    );
                    final newServer = {
                      'ip': ip,
                      'port': port,
                      'eventId': eventId,
                      'eventTitle': eventTitle,
                      'lastSeen': DateTime.now(),
                    };

                    if (index != -1) {
                      discovered[index] = newServer;
                    } else {
                      discovered.add(newServer);
                    }
                    state = state.copyWith(discoveredServers: discovered);
                  }
                } catch (_) {}
              }
            }
          });
        })
        .catchError((err) {
          developer.log(
            'Erro ao iniciar UDP discovery listener: $err',
            name: 'SyncDiscovery',
          );
        });
  }

  Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      developer.log('Interfaces de rede encontradas: ${interfaces.map((i) => "${i.name}: ${i.addresses.map((a) => a.address).toList()}").toList()}', name: 'SyncNotifier');
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (e, stack) {
      developer.log('Erro ao obter interfaces de rede: $e', name: 'SyncNotifier', error: e, stackTrace: stack);
    }
    return null;
  }

  Map<String, dynamic>? parseSyncToken(String token) {
    try {
      String cleanToken = token.trim();
      const prefix = 'caixa://connect/';
      if (cleanToken.startsWith(prefix)) {
        cleanToken = cleanToken.substring(prefix.length);
      }
      final decoded = utf8.decode(base64Decode(cleanToken));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error parsing sync token: $e', name: 'SyncNotifier');
      return null;
    }
  }

  Future<void> importEventAndConnect(String token) async {
    final payload = parseSyncToken(token);
    if (payload == null) {
      throw const FormatException('Token de conexão inválido ou corrompido.');
    }

    final ip = payload['ip'] as String?;
    final port = payload['port'] as int?;
    final eventId = payload['eventId'] as String?;
    final title = payload['eventTitle'] as String?;
    final dateMs = payload['eventDate'] as int?;
    final notes = payload['eventNotes'] as String? ?? '';

    if (ip == null || port == null || eventId == null || title == null || dateMs == null) {
      throw const FormatException('Informações incompletas no token.');
    }

    // Insert or update the event locally
    final companion = EventsCompanion(
      id: Value(eventId),
      title: Value(title),
      notes: Value(notes),
      dateEpochMs: Value(dateMs),
    );

    await _db.into(_db.events).insert(companion, mode: InsertMode.insertOrReplace);

    // Now connect to host
    await connectToHost(ip, port, eventId);
  }

  Future<void> submitProductToHost({
    required String eventId,
    String? productId,
    required String name,
    required int priceCents,
    required String description,
    required bool trackStock,
    required int stockQty,
    required bool active,
    required bool isCombo,
    required List<Map<String, dynamic>> items,
  }) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/products'),
    );
    request.headers.contentType = ContentType.json;

    final body = {
      'id': productId,
      'name': name,
      'priceCents': priceCents,
      'description': description,
      'trackStock': trackStock,
      'stockQty': stockQty,
      'active': active,
      'isCombo': isCombo,
      'items': items,
    };

    request.write(jsonEncode(body));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode != HttpStatus.ok || data['success'] != true) {
      throw StateError(
        data['error'] as String? ?? 'Erro ao salvar produto no servidor.',
      );
    }
  }

  Future<void> deleteProductOnHost(String eventId, String productId) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/delete-product'),
    );
    request.headers.contentType = ContentType.json;

    request.write(jsonEncode({'productId': productId}));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode != HttpStatus.ok || data['success'] != true) {
      throw StateError(
        data['error'] as String? ?? 'Erro ao excluir produto no servidor.',
      );
    }
  }

  Future<void> submitDenomToHost({
    required String eventId,
    String? denomId,
    required String label,
    required int valueCents,
    required int stockQty,
  }) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/denoms'),
    );
    request.headers.contentType = ContentType.json;

    final body = {
      'id': denomId,
      'label': label,
      'valueCents': valueCents,
      'stockQty': stockQty,
    };

    request.write(jsonEncode(body));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode != HttpStatus.ok || data['success'] != true) {
      throw StateError(
        data['error'] as String? ?? 'Erro ao salvar ficha no servidor.',
      );
    }
  }

  Future<void> deleteDenomOnHost(String eventId, String denomId) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/delete-denom'),
    );
    request.headers.contentType = ContentType.json;

    request.write(jsonEncode({'denomId': denomId}));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode != HttpStatus.ok || data['success'] != true) {
      throw StateError(
        data['error'] as String? ?? 'Erro ao excluir ficha no servidor.',
      );
    }
  }

  Future<void> submitEditSaleToHost({
    required String eventId,
    required String saleId,
    required String paymentMethod,
    required int amountReceivedCents,
    String? notes,
    required bool changePending,
    String? customerName,
    required List<SaleLineDraft> lines,
  }) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/edit-sale'),
    );
    request.headers.contentType = ContentType.json;

    final linesJson = lines.map((l) {
      return {
        'kind': l.kind,
        'productId': l.productId,
        'dotDenominationId': l.dotDenominationId,
        'freeLabel': l.freeLabel,
        'qty': l.qty,
        'unitPriceCents': l.unitPriceCents,
        'lineTotalCents': l.lineTotalCents,
      };
    }).toList();

    final body = {
      'saleId': saleId,
      'paymentMethod': paymentMethod,
      'amountReceivedCents': amountReceivedCents,
      'notes': notes,
      'changePending': changePending,
      'customerName': customerName,
      'lines': linesJson,
    };

    request.write(jsonEncode(body));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode != HttpStatus.ok || data['success'] != true) {
      throw StateError(
        data['error'] as String? ?? 'Erro ao editar venda no servidor.',
      );
    }
  }

  Future<void> deleteSaleOnHost(String eventId, String saleId) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/delete-sale'),
    );
    request.headers.contentType = ContentType.json;

    request.write(jsonEncode({'saleId': saleId}));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode != HttpStatus.ok || data['success'] != true) {
      throw StateError(
        data['error'] as String? ?? 'Erro ao excluir venda no servidor.',
      );
    }
  }

  Future<void> resolveChangeOnHost({
    required String eventId,
    required String saleId,
    required String paymentMethod,
    required int amountReceivedCents,
    String? notes,
    required bool changePending,
    String? customerName,
  }) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('http://$ip:$port/events/$eventId/resolve-change'),
    );
    request.headers.contentType = ContentType.json;

    final body = {
      'saleId': saleId,
      'paymentMethod': paymentMethod,
      'amountReceivedCents': amountReceivedCents,
      'notes': notes,
      'changePending': changePending,
      'customerName': customerName,
    };

    request.write(jsonEncode(body));
    final response = await request.close();
    final responseContent = await utf8.decoder.bind(response).join();
    final Map<String, dynamic> data = jsonDecode(responseContent);

    if (response.statusCode != HttpStatus.ok || data['success'] != true) {
      throw StateError(
        data['error'] as String? ?? 'Erro ao resolver troco no servidor.',
      );
    }
  }
}

// Client side stream providers targeting controllers
final syncClientStreamProvider = Provider.autoDispose
    .family<Stream<List<dynamic>>, (String eventId, String key)>((ref, arg) {
      final controller = _clientStreamControllers[arg.$2];
      if (controller == null) {
        return const Stream.empty();
      }
      // Immediately pull data to populate cache
      ref.read(syncProvider.notifier).refreshAllClientCaches(arg.$1);
      return controller.stream;
    });
