import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import '../providers/reports_provider.dart';
import '../providers/reservations_provider.dart';
import '../services/api_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  static const routeName = '/admin/analytics';
  @override
  _AdminAnalyticsScreenState createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  late ReportsProvider _reportsProv;
  late ReservationsProvider _reservationsProv;
  bool _inited = false;
  String _selectedPeriod = 'Último mes';
  String _selectedLocation = 'Todas';
  int _totalUsers = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _reportsProv = Provider.of<ReportsProvider>(context);
      _reservationsProv = Provider.of<ReservationsProvider>(context);
      // carga inicial - programar después del build para evitar notifyListeners durante el build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUsers();
        _applyFiltersAndRegenerate();
      });
      // escuchar cambios
      _reservationsProv.addListener(_onReservationsChanged);
      _inited = true;
    }
  }

  Future<void> _loadUsers() async {
    try {
      final apiService = ApiService();
      final users = await apiService.getUsers();
      if (mounted) setState(() => _totalUsers = users.length);
    } catch (e) {
      if (mounted) setState(() => _totalUsers = 0);
    }
  }

  @override
  void dispose() {
    try {
      _reservationsProv.removeListener(_onReservationsChanged);
    } catch (_) {}
    super.dispose();
  }

  void _onReservationsChanged() {
    // programar regeneración después del frame actual para evitar llamar notifyListeners durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyFiltersAndRegenerate();
    });
  }

  void _applyFiltersAndRegenerate() {
    // calcular rango de fechas desde el periodo seleccionado
    DateTime now = DateTime.now();
    DateTime? from;
    if (_selectedPeriod == 'Último mes') {
      from = DateTime(now.year, now.month - 1, now.day);
    } else if (_selectedPeriod == 'Últimos 3 meses') {
      from = DateTime(now.year, now.month - 3, now.day);
    } else if (_selectedPeriod == 'Año en curso') {
      from = DateTime(now.year, 1, 1);
    }

    // filtrar reservaciones por fecha y (opcionalmente) por ubicación
    final all = _reservationsProv.reservations;
    final filtered = all.where((r) {
      try {
        final d = DateTime.parse((r['date'] ?? '').toString());
        if (from != null && d.isBefore(from)) return false;
        if (_selectedLocation != 'Todas') {
          final loc = (r['location'] ?? '').toString();
          if (loc.isEmpty) return false;
          if (loc.toLowerCase() != _selectedLocation.toLowerCase())
            return false;
        }
        return true;
      } catch (_) {
        return false;
      }
    }).toList();

    _reportsProv.generateReport(reservations: filtered);
  }

  Widget _statCard(String title, String value, {Color? color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
          padding: EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.black))
          ])),
    );
  }

  Widget _monthlyChart(List<dynamic> monthly) {
    if (monthly.isEmpty)
      return Container(height: 140, child: Center(child: Text('No hay datos')));
    final bars = monthly
        .map((m) => BarChartGroupData(x: (m['month'] as int), barRods: [
              BarChartRodData(
                  toY: (m['value'] as num).toDouble(), color: Colors.green)
            ]))
        .toList();
    final maxY = (monthly
            .map((m) => (m['value'] as num).toDouble())
            .reduce((a, b) => a > b ? a : b)) *
        1.1;
    return SizedBox(
        height: 200,
        child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY <= 0 ? 1000 : maxY,
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          final labels = [
                            '',
                            'Ene',
                            'Feb',
                            'Mar',
                            'Abr',
                            'May',
                            'Jun',
                            'Jul',
                            'Ago',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dic'
                          ];
                          return Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(labels[idx]));
                        })),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: true))),
            barGroups: bars)));
  }

  Widget _pieChart(List<dynamic> top) {
    if (top.isEmpty)
      return Container(height: 120, child: Center(child: Text('No hay datos')));
    final sections = <PieChartSectionData>[];
    final total = top.fold<int>(0, (s, e) => s + (e['sales'] as int));
    for (int i = 0; i < top.length && i < 6; i++) {
      final item = top[i];
      final value = (item['sales'] as int).toDouble();
      final perc = total > 0 ? (value / total) : 0.0;
      sections.add(PieChartSectionData(
          value: value,
          title: '${(perc * 100).toStringAsFixed(0)}%',
          color: Colors.primaries[i % Colors.primaries.length].shade400,
          radius: 40));
    }
    return SizedBox(
        height: 180,
        child: PieChart(PieChartData(
            sections: sections, sectionsSpace: 2, centerSpaceRadius: 30)));
  }

  Future<void> _exportCsv() async {
    // Construir CSV a partir de reservaciones
    final reservations = _reservationsProv.reservations;
    final sb = StringBuffer();
    sb.writeln(
        'id,service,date,time,price,status,clientId,guideId,rating,comment');
    for (var r in reservations) {
      final line = [
        r['id'],
        '"${(r['service'] ?? '').toString().replaceAll('"', '""')}"',
        r['date'] ?? '',
        r['time'] ?? '',
        r['price'] ?? '',
        r['status'] ?? '',
        r['clientId'] ?? '',
        r['guideId'] ?? '',
        r['rating'] ?? '',
        '"${(r['comment'] ?? '').toString().replaceAll('"', '""')}"'
      ].join(',');
      sb.writeln(line);
    }
    final csv = sb.toString();
    await Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('CSV copiado al portapapeles')));
  }

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<ReportsProvider>(context);
    final data = reports.data;
    final totalUsers = _totalUsers;
    final top = (data['topProducts'] as List?) ?? [];
    final revenue = (data['revenue'] ?? 0.0) as double;
    final monthly = (data['monthlyRevenue'] ?? []) as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Avanzado')),
      body: Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                // Top filters + metrics
                Row(
                  children: [
                    Expanded(
                        child: DropdownButtonFormField<String>(
                            initialValue: _selectedPeriod,
                            items: [
                              'Último mes',
                              'Últimos 3 meses',
                              'Año en curso'
                            ]
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedPeriod = v);
                                _applyFiltersAndRegenerate();
                              }
                            },
                            decoration: InputDecoration(labelText: 'Periodo'))),
                    SizedBox(width: 12),
                    Expanded(
                        child: DropdownButtonFormField<String>(
                            initialValue: _selectedLocation,
                            items: [
                              'Todas',
                              'Sopetrán',
                              'Santa Fe de Antioquia',
                              'San Jerónimo'
                            ]
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedLocation = v);
                                _applyFiltersAndRegenerate();
                              }
                            },
                            decoration:
                                InputDecoration(labelText: 'Ubicación'))),
                    SizedBox(width: 12),
                    ElevatedButton(
                        onPressed: _exportCsv, child: Text('Exportar CSV'))
                  ],
                ),
                SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _statCard('Total Usuarios', '$totalUsers',
                          color: Colors.green)),
                  SizedBox(width: 12),
                  Expanded(
                      child: _statCard('Paquetes activas', '${top.length}')),
                  SizedBox(width: 12),
                  Expanded(
                      child: _statCard(
                          'Ingresos', 'COP ${revenue.toStringAsFixed(0)}',
                          color: Colors.green))
                ]),
                SizedBox(height: 12),
                Card(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Distribución por Tipo de Servicio',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              SizedBox(height: 8),
                              _pieChart(top),
                              SizedBox(height: 8),
                              ...top
                                  .take(5)
                                  .map((t) => ListTile(
                                      title: Text(t['name'] ?? '-'),
                                      trailing: Text('${t['sales'] ?? 0}')))
                                  .toList()
                            ]))),
                SizedBox(height: 12),
                Card(
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tendencia Mensual (Ingresos)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              SizedBox(height: 8),
                              _monthlyChart(monthly)
                            ]))),
                SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Demanda por Ubicación',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 12),
                                    Container(
                                        height: 120,
                                        child: Center(
                                            child: Text(
                                                'Espacio reservado para gráfico de barras')))
                                  ])))),
                  SizedBox(width: 12),
                  Expanded(
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Análisis por Tipo de Experiencia',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8),
                                    ListTile(
                                        title: Text('Rutas'),
                                        subtitle: LinearProgressIndicator(
                                            value: 0.7,
                                            color: Colors.green,
                                            backgroundColor:
                                                Colors.green.shade100),
                                        trailing: Text('4.7')),
                                    ListTile(
                                        title: Text('Fincas'),
                                        subtitle: LinearProgressIndicator(
                                            value: 0.5,
                                            color: Colors.green,
                                            backgroundColor:
                                                Colors.green.shade100),
                                        trailing: Text('4.6'))
                                  ]))))
                ]),
                SizedBox(height: 24),
                // Satisfaction & NPS
                SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Satisfacción Promedio',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8),
                                    Text('${data['satisfactionAvg'] ?? 0.0}',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                    SizedBox(height: 6),
                                    Text(
                                        'Valoraciones: ${data['ratingCount'] ?? 0}')
                                  ])))),
                  SizedBox(width: 12),
                  Expanded(
                      child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('NPS',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 8),
                                    Text('${data['nps'] ?? 0.0}%',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                    SizedBox(height: 6),
                                    Text('Promotores vs Detractores')
                                  ]))))
                ]),
                SizedBox(height: 12),
                Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                                content: Text('Exportando reporte...'))),
                        child: Text('Exportar Reporte')))
              ]))),
    );
  }
}
