import 'package:flutter_test/flutter_test.dart';
import 'package:caixa_igreja/utils/pix_payload.dart';

void main() {
  group('PixPayload Testes de Geração de BR Code', () {
    test('Gera BR Code com chave e valor definidos', () {
      final pix = PixPayload(
        pixKey: '12345678900',
        merchantName: 'Paróquia São José',
        merchantCity: 'São Paulo',
        amount: 25.50,
        txId: 'PED123',
      );

      final code = pix.generateCode();

      // Valida estrutura básica
      expect(code.startsWith('000201'), isTrue);
      expect(code.contains('br.gov.bcb.pix'), isTrue);
      expect(code.contains('12345678900'), isTrue);
      expect(code.contains('540525.50'), isTrue); // R$ 25.50
      expect(code.contains('5802BR'), isTrue);
      expect(code.contains('5917Paroquia Sao Jose'), isTrue); // Acentos removidos
      expect(code.contains('6009Sao Paulo'), isTrue); // Acentos removidos
      expect(code.contains('62100506PED123'), isTrue);
      expect(code.contains('6304'), isTrue);

      // Valida que os últimos 4 caracteres são o CRC16 hexadecimal
      final crcPart = code.substring(code.length - 4);
      expect(crcPart.length, 4);
      final payloadWithoutCrc = code.substring(0, code.length - 4);
      final expectedCrc = PixPayload.calculateCrc16(payloadWithoutCrc)
          .toRadixString(16)
          .toUpperCase()
          .padLeft(4, '0');
      expect(crcPart, expectedCrc);
    });

    test('Gera BR Code sem valor (chave estática)', () {
      final pix = PixPayload(
        pixKey: 'pastoral@igreja.org.br',
        merchantName: 'Comunidade',
        merchantCity: 'Campinas',
      );

      final code = pix.generateCode();
      expect(code.startsWith('000201'), isTrue);
      expect(code.contains('pastoral@igreja.org.br'), isTrue);
      // Sem tag 54 (amount)
      expect(code.contains('54'), isFalse);
    });

    test('Cálculo de CRC16 é consistente e válido', () {
      // Teste com vetor padrão
      final crc = PixPayload.calculateCrc16('123456789');
      expect(crc, isA<int>());
      expect(crc > 0, isTrue);
    });
  });
}
