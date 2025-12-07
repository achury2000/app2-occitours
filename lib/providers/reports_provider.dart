import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/date_utils.dart';

class ReportsProvider with ChangeNotifier {
  bool _loading = false;
  Map<String, dynamic> _data = {};

  bool get loading => _loading;
  Map<String, dynamic> get data => Map.unmodifiable(_data);

  Future<void> generateReport({DateTime? from, DateTime? to, List<Map<String,dynamic>>? reservations}) async {
    _loading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 700));

    // Si se pasan reservas, calcular métricas a partir de ellas
    if (reservations != null) {
      // revenue total (exclude cancelled)
      double revenue = 0.0;
      final Map<String,int> serviceCounts = {};
      final int currentYear = DateTime.now().year;
      final List<Map<String,dynamic>> monthly = List.generate(12, (i) => {'month': i+1, 'value': 0.0});

      for (var r in reservations) {
        try {
          final status = (r['status'] ?? '').toString();
          if (status.toLowerCase() == 'cancelada') continue;
          final price = (r['price'] ?? 0) as num;
          final date = parseDateFlexible((r['date'] ?? '').toString()) ?? DateTime.now();
          revenue += price.toDouble();
          final svc = (r['service'] ?? '-').toString();
          serviceCounts[svc] = (serviceCounts[svc] ?? 0) + 1;
          if (date.year == currentYear) {
            monthly[date.month - 1]['value'] = monthly[date.month - 1]['value'] + price.toDouble();
          }
        } catch (_) { }
      }

      // topProducts derived from serviceCounts
      final top = serviceCounts.entries.map((e) => {'name': e.key, 'sales': e.value}).toList();
      top.sort((a,b) => (b['sales'] as int).compareTo(a['sales'] as int));

      // satisfaction / NPS
      double satisfactionSum = 0.0;
      int satisfactionCount = 0;
      int promoters = 0;
      int detractors = 0;
      for (var r in reservations) {
        try {
          final rating = r['rating'];
          if (rating != null) {
            final numRate = (rating as num).toDouble();
            satisfactionSum += numRate;
            satisfactionCount++;
            // Map 1-5 into NPS-like buckets: 5 -> promoter, 4 -> passive, <=3 detractor
            if (numRate >= 5) promoters++; else if (numRate >= 4) {/* passive */} else detractors++;
          }
        } catch (_) {}
      }
      final satisfactionAvg = satisfactionCount > 0 ? (satisfactionSum / satisfactionCount) : 0.0;
      final nps = satisfactionCount > 0 ? ((promoters - detractors) / satisfactionCount) * 100 : 0.0;

      // sales per day for last 7 days
      final now = DateTime.now();
      final List<Map<String,dynamic>> sales = List.generate(7, (i) {
        final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
        double daySum = 0.0;
        for (var r in reservations) {
          try {
            final status = (r['status'] ?? '').toString();
            if (status.toLowerCase() == 'cancelada') continue;
            final date = parseDateFlexible((r['date'] ?? '').toString());
            if (date != null && date.year == day.year && date.month == day.month && date.day == day.day) {
              daySum += ((r['price'] ?? 0) as num).toDouble();
            }
          } catch(_){}
        }
        return {'day': i+1, 'value': daySum};
      });

      _data = {
        'sales': sales,
        'topProducts': top,
        'revenue': revenue,
        'monthlyRevenue': monthly,
        'satisfactionAvg': double.parse(satisfactionAvg.toStringAsFixed(2)),
        'nps': double.parse(nps.toStringAsFixed(1)),
        'ratingCount': satisfactionCount
      };

      _loading = false;
      notifyListeners();
      return;
    }

    // Datos simulados de respaldo para los gráficos cuando no se pasan reservas
    _data = {
      'sales': List.generate(7, (i) => {'day': i+1, 'value': (1000*(i+1)).toDouble()}),
      'topProducts': [
        {'id':'p8','name':'Paquete Aventura - 3 días','sales':25},
        {'id':'p11','name':'Finca Premium - Fin de Semana','sales':10},
        {'id':'p1','name':'Ruta Cacao - Sopetrán','sales':18},
      ],
      'revenue': 1250000.0,
      'monthlyRevenue': List.generate(12, (m) => {'month': m+1, 'value': ((m + 1) * 250000).toDouble()}),
      'satisfactionAvg': 4.6,
      'nps': 45.0,
      'ratingCount': 128
    };

    _loading = false;
    notifyListeners();
  }
}
