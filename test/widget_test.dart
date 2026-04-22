import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:caixa_igreja/main.dart';

void main() {
  testWidgets('App carrega na aba Eventos', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CaixaIgrejaApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Eventos'), findsWidgets);
  });
}
