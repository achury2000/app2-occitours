import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  static const routeName = '/admin/analytics';

  @override
  _AdminAnalyticsScreenState createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final ApiService _apiService = ApiService();
  bool _loading = true;

  // Datos del dashboard
  Map<String, dynamic> _stats = {};
  List<double> _ingresosMensuales = List.filled(12, 0.0);
  List<String> _mesesNombres = [];
  List<dynamic> _topFincas = [];
  List<dynamic> _topRutas = [];
  List<dynamic> _topServicios = [];
  int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final stats = await _apiService.getDashboardStats();
      final ingresosMensuales =
          await _apiService.getIngresosMensuales(year: _currentYear);
      final topFincas = await _apiService.getTopFincas();
      final topRutas = await _apiService.getTopRutas();
      final topServicios = await _apiService.getTopServicios();

      setState(() {
        _stats = stats;
        _ingresosMensuales = List<double>.from(
            (ingresosMensuales['data'] as List)
                .map((e) => (e as num).toDouble()));
        _mesesNombres = List<String>.from(ingresosMensuales['meses']);
        _topFincas = topFincas;
        _topRutas = topRutas;
        _topServicios = topServicios;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Avanzado'),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Estadísticas generales
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Fincas',
                            '${_stats['totales']?['fincas'] ?? 0}',
                            Icons.landscape,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Rutas',
                            '${_stats['totales']?['rutas'] ?? 0}',
                            Icons.route,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Clientes',
                            '${_stats['totales']?['clientes'] ?? 0}',
                            Icons.people,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Ingresos
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            'Ingresos Totales',
                            'COP ${(_stats['ingresos']?['total_general'] ?? 0.0).toStringAsFixed(0)}',
                            Icons.attach_money,
                            Colors.teal,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            'Completados',
                            'COP ${(_stats['ingresos']?['total_completado'] ?? 0.0).toStringAsFixed(0)}',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Gráfica de ingresos mensuales
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tendencia Mensual (Ingresos $_currentYear)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildMonthlyChart(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Top Fincas
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Fincas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ..._topFincas
                                .map((f) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.green,
                                        child: Icon(Icons.landscape,
                                            color: Colors.white),
                                      ),
                                      title: Text(f['nombre'] ?? '-'),
                                      subtitle: Text(
                                          '${f['total_reservas']} reservas'),
                                      trailing: Text(
                                        'COP ${(f['ingresos_totales'] ?? 0.0).toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Top Rutas
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Rutas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ..._topRutas
                                .map((r) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Icon(Icons.route,
                                            color: Colors.white),
                                      ),
                                      title: Text(r['nombre'] ?? '-'),
                                      subtitle: Text(
                                          '${r['total_reservas']} reservas'),
                                      trailing: Text(
                                        'COP ${(r['ingresos_totales'] ?? 0.0).toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Top Servicios
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Servicios',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ..._topServicios
                                .map((s) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.orange,
                                        child: Icon(Icons.room_service,
                                            color: Colors.white),
                                      ),
                                      title: Text(s['nombre'] ?? '-'),
                                      subtitle: Text(
                                          '${s['total_vendido']} vendidos'),
                                      trailing: Text(
                                        'COP ${(s['ingresos_totales'] ?? 0.0).toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    if (_ingresosMensuales.isEmpty ||
        _ingresosMensuales.every((val) => val == 0)) {
      return Container(
        height: 200,
        child: Center(child: Text('No hay datos de ingresos')),
      );
    }

    final bars = List.generate(
      12,
      (index) => BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: _ingresosMensuales[index],
            color: Colors.green,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      ),
    );

    final maxY = _ingresosMensuales.reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY > 0 ? maxY : 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt() - 1;
                  if (idx < 0 || idx >= _mesesNombres.length) {
                    return Text('');
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      _mesesNombres[idx],
                      style: TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return Text('0');
                  return Text(
                    '${(value / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: bars,
        ),
      ),
    );
  }
}
