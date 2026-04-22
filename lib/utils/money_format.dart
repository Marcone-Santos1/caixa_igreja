import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

String formatCents(int cents) =>
    _currency.format(cents / 100.0);

/// Aceita "10", "10,5", "10,50", "1.234,56" (milhar com ponto).
int? parseMoneyToCents(String input) {
  var s = input.trim();
  if (s.isEmpty) return null;
  s = s.replaceAll(r'R$', '').replaceAll(' ', '').trim();
  if (s.isEmpty) return null;

  final comma = s.lastIndexOf(',');
  final dot = s.lastIndexOf('.');

  String normalized;
  if (comma >= 0 && dot >= 0) {
    if (comma > dot) {
      normalized = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      normalized = s.replaceAll(',', '');
    }
  } else if (comma >= 0) {
    normalized = s.replaceAll(',', '.');
  } else {
    normalized = s;
  }

  final value = double.tryParse(normalized);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}
