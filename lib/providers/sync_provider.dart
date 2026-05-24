import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final List<Map<String, dynamic>> discoveredServers; // List of discovered servers: [{'ip', 'port', 'eventTitle', 'eventId', 'lastSeen'}]
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

  Future<void> startServer(int eventId, String eventTitle) async {
    stopAll();
    try {
      final localIp = await _getLocalIp();
      if (localIp == null) {
        state = state.copyWith(error: 'Não foi possível detectar o IP local. Verifique sua rede.');
        return;
      }

      // Bind HTTP Server
      _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, state.serverPort);
      _httpServer!.listen(_handleHttpRequest, onError: (err) {
        developer.log('Erro no servidor HTTP: $err', name: 'SyncServer');
      });

      // Start UDP Broadcast for discovery
      _udpBroadcastSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
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
          _udpBroadcastSocket?.send(bytes, InternetAddress('255.255.255.255'), 4545);
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
      developer.log('Servidor iniciado em $localIp:${state.serverPort}', name: 'SyncServer');
    } catch (e) {
      state = state.copyWith(error: 'Falha ao iniciar o servidor: $e');
      stopAll();
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
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    final path = request.uri.path;
    developer.log('Server HTTP Request: ${request.method} $path', name: 'SyncServer');

    try {
      // WS Upgrade
      if (path.endsWith('/ws')) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          final ws = await WebSocketTransformer.upgrade(request);
          _serverWebSockets.add(ws);
          final clientIp = request.connectionInfo?.remoteAddress.address ?? 'Desconhecido';
          state = state.copyWith(connectedClients: [...state.connectedClients, clientIp]);
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
        request.response.write(jsonEncode({'status': 'ok', 'ip': state.serverIp}));
        await request.response.close();
        return;
      }

      if (uriSegments.length >= 3 && uriSegments[0] == 'events') {
        final eventId = int.tryParse(uriSegments[1]) ?? 0;
        final endpoint = uriSegments[2];

        if (request.method == 'GET') {
          request.response.headers.contentType = ContentType.json;

          if (endpoint == 'details') {
            final ev = await (_db.select(_db.events)..where((t) => t.id.equals(eventId))).getSingleOrNull();
            request.response.write(jsonEncode(ev?.toJson()));
          } else if (endpoint == 'products') {
            final list = await _db.watchAllProductsForEvent(eventId).first;
            request.response.write(jsonEncode(list.map((e) => e.toJson()).toList()));
          } else if (endpoint == 'denoms') {
            final list = await _db.watchDotDenominations(eventId).first;
            request.response.write(jsonEncode(list.map((e) => e.toJson()).toList()));
          } else if (endpoint == 'sales') {
            final list = await _db.watchSalesForEvent(eventId).first;
            request.response.write(jsonEncode(list.map((e) => e.toJson()).toList()));
          } else if (endpoint == 'lines') {
            final list = await _db.watchSaleLinesForEvent(eventId).first;
            request.response.write(jsonEncode(list.map((e) => e.toJson()).toList()));
          } else if (endpoint == 'change-allocations') {
            final list = await _db.watchChangeDotAllocationsForEvent(eventId).first;
            request.response.write(jsonEncode(list.map((e) => e.toJson()).toList()));
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
            final productId = l['productId'] as int?;
            final dotDenominationId = l['dotDenominationId'] as int?;
            final freeLabel = l['freeLabel'] as String?;
            final qty = l['qty'] as int;
            final unitPriceCents = l['unitPriceCents'] as int?;
            final lineTotalCents = l['lineTotalCents'] as int?;

            if (kind == SaleLineKind.product) {
              return SaleLineDraft.product(productId: productId!, qty: qty, unitPriceCents: unitPriceCents!);
            } else if (kind == SaleLineKind.ficha) {
              return SaleLineDraft.ficha(dotDenominationId: dotDenominationId!, qty: qty, unitPriceCents: unitPriceCents!);
            } else {
              return SaleLineDraft.valorLivre(freeLabel: freeLabel!, lineTotalCents: lineTotalCents!);
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
            request.response.write(jsonEncode({'success': true, 'saleId': saleId}));
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

  // --- CLIENT (TERMINAL) MODE ---

  Future<void> connectToHost(String ip, int port, int targetEventId) async {
    stopAll();
    developer.log('Conectando ao host $ip:$port', name: 'SyncClient');
    try {
      // Check status first
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse('http://$ip:$port/status'));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        state = state.copyWith(error: 'Conexão rejeitada pelo servidor (${response.statusCode})');
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
      state = state.copyWith(error: 'Não foi possível conectar ao IP $ip:$port: $e');
    }
  }

  void _connectClientWebSocket(String ip, int port, int eventId) {
    WebSocket.connect('ws://$ip:$port/events/$eventId/ws').then((ws) {
      _clientWebSocket = ws;
      ws.listen(
        (message) {
          if (message == 'refresh') {
            developer.log('Mensagem WebSocket recebida: refresh', name: 'SyncClient');
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
          developer.log('Erro no WebSocket do cliente: $err', name: 'SyncClient');
          if (state.mode == SyncMode.client) {
            state = state.copyWith(isConnected: false);
          }
        },
      );
    }).catchError((e) {
      developer.log('Erro ao abrir WebSocket: $e', name: 'SyncClient');
    });
  }

  void _stopClient() {
    _clientWebSocket?.close();
    _clientWebSocket = null;
  }

  Future<void> refreshAllClientCaches(int eventId) async {
    if (state.mode != SyncMode.client || !state.isConnected) return;
    await Future.wait([
      _pullClientList(eventId, 'products', (json) => ChurchProduct.fromJson(json)),
      _pullClientList(eventId, 'denoms', (json) => EventDotDenom.fromJson(json)),
      _pullClientList(eventId, 'sales', (json) => PosSale.fromJson(json)),
      _pullClientList(eventId, 'lines', (json) => PosSaleLine.fromJson(json)),
      _pullClientList(eventId, 'change-allocations', (json) => ChangeDotRow.fromJson(json), controllerKey: 'changeDotAllocations'),
    ]);
  }

  Future<void> _pullClientList(
    int eventId,
    String endpoint,
    dynamic Function(Map<String, dynamic>) fromJson, {
    String? controllerKey,
  }) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    final key = controllerKey ?? endpoint;
    final controller = _clientStreamControllers[key];

    if (ip == null || controller == null) return;

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse('http://$ip:$port/events/$eventId/$endpoint'));
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final content = await utf8.decoder.bind(response).join();
        final List list = jsonDecode(content);
        final parsedList = list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
        controller.add(parsedList);
      }
    } catch (e) {
      developer.log('Erro ao puxar dados do endpoint $endpoint: $e', name: 'SyncClient');
    }
  }

  Future<ChurchEvent?> fetchEventDetailsFromServer(int eventId) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) return null;

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('http://$ip:$port/events/$eventId/details'));
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final content = await utf8.decoder.bind(response).join();
        final data = jsonDecode(content);
        if (data == null) return null;
        return ChurchEvent.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      developer.log('Erro ao buscar detalhes do evento no servidor: $e', name: 'SyncClient');
    }
    return null;
  }

  Future<int> submitSaleToHost(int eventId, String paymentMethod, int amountReceivedCents, String? notes, bool changePending, String? customerName, List<SaleLineDraft> lines) async {
    final ip = state.serverIp;
    final port = state.serverPort;
    if (ip == null) throw StateError('Não conectado ao servidor host.');

    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://$ip:$port/events/$eventId/sales'));
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
      return data['saleId'] as int;
    } else {
      throw StateError(data['error'] as String? ?? 'Erro desconhecido ao enviar venda ao servidor.');
    }
  }

  // --- UDP DISCOVERY ---

  void _startUdpListener() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 4545).then((socket) {
      _udpListenerSocket = socket;
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            try {
              final payload = utf8.decode(datagram.data);
              final Map<String, dynamic> data = jsonDecode(payload);

              if (data['appName'] == 'CaixaIgreja' && data['ip'] != state.serverIp) {
                final discovered = [...state.discoveredServers];
                final ip = data['ip'] as String;
                final port = data['port'] as int;
                final eventId = data['eventId'] as int;
                final eventTitle = data['eventTitle'] as String;

                final index = discovered.indexWhere((s) => s['ip'] == ip && s['port'] == port);
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
    }).catchError((err) {
      developer.log('Erro ao iniciar UDP discovery listener: $err', name: 'SyncDiscovery');
    });
  }

  Future<String?> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}

// Client side stream providers targeting controllers
final syncClientStreamProvider = Provider.autoDispose.family<Stream<List<dynamic>>, (int eventId, String key)>((ref, arg) {
  final controller = _clientStreamControllers[arg.$2];
  if (controller == null) {
    return const Stream.empty();
  }
  // Immediately pull data to populate cache
  ref.read(syncProvider.notifier).refreshAllClientCaches(arg.$1);
  return controller.stream;
});
