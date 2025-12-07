// parte lucho
// Utilidades de fecha: parseo flexible para CSV y datos externos
import 'package:intl/intl.dart';

DateTime? parseDateFlexible(dynamic input) {
  if (input == null) return null;
  final s = input.toString().trim();
  if (s.isEmpty) return null;

  // Try ISO/standard parse first
  try {
    final d = DateTime.tryParse(s);
    if (d != null) return d;
  } catch (_) {}

  // Try common date formats
  final formats = [
    'dd/MM/yyyy HH:mm:ss',
    'dd/MM/yyyy HH:mm',
    'dd/MM/yyyy',
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd',
    'MM/dd/yyyy',
    'MM/dd/yyyy HH:mm',
  ];

  for (final fmt in formats) {
    try {
      final f = DateFormat(fmt);
      return f.parseLoose(s);
    } catch (_) {}
  }

  // As a last attempt, try parsing only the leading date portion
  try {
    final firstToken = s.split(' ').first;
    final d = DateTime.tryParse(firstToken);
    if (d != null) return d;
  } catch (_) {}

  return null;
}
