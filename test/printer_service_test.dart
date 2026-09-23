import 'package:caixa_igreja/services/printer_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('blue_thermal_printer');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isConnected':
          return false;
        case 'getBondedDevices':
          return [];
        case 'connect':
          return true;
        case 'disconnect':
          return true;
        case 'writeBytes':
          return true;
        default:
          return null;
      }
    });
  });

  group('PrinterService Unit Tests', () {
    test('removeAccents remove acentos e cedilhas corretamente', () {
      final service = PrinterService();

      expect(service.removeAccentsForTesting('Coração'), 'Coracao');
      expect(service.removeAccentsForTesting('Pastel de Maçã & Café'), 'Pastel de Maca & Cafe');
      expect(service.removeAccentsForTesting('Pão de Açúcar com Açúcar'), 'Pao de Acucar com Acucar');
      expect(service.removeAccentsForTesting('Espetinho de Almôndega'), 'Espetinho de Almondega');
      expect(service.removeAccentsForTesting('ÁGUA, CHÁ & QUENTÃO'), 'AGUA, CHA & QUENTAO');
    });

    test('printTicket lança StateError se impressora não estiver conectada', () async {
      final service = PrinterService();
      expect(
        () => service.printTicket(
          orderNumber: '001',
          items: [
            {'name': 'Pastel de Carne', 'qty': 2, 'subtotal': 20.0},
            {'name': 'Refrigerante', 'qty': 1, 'subtotal': 6.0},
          ],
          total: 26.0,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('getBondedDevices retorna lista vazia quando mock não tem dispositivos', () async {
      final service = PrinterService();
      final devices = await service.getBondedDevices();
      expect(devices, isEmpty);
    });
  });
}
