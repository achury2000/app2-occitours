// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/reservations_provider.dart';
import '../services/api_service.dart';
// parte linsaith

/// Pantalla principal del panel de administración.
///
/// Responsabilidades:
/// - Mostrar métricas clave (usuarios, paquetes, ingresos).
/// - Proveer acceso rápido a secciones administrativas y al calendario de reservas.
/// - Escuchar cambios en `ReservationsProvider` para actualizar métricas en tiempo real.
class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin';
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  int _totalUsers = 0;
  int _totalFincas = 0;
  int _totalRutas = 0;
  double _revenue = 0.0;
  double _totalRevenue = 0.0; // Todos los ingresos
  int _displayYear = DateTime.now().year;
  int _displayMonth = DateTime.now().month;
  List<dynamic> _programaciones = [];
  List<dynamic> _reservasFromApi = []; // Reservas directas del backend

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
  }

  @override
  void dispose() {
    try {
      final reservationsProv =
          Provider.of<ReservationsProvider>(context, listen: false);
      reservationsProv.removeListener(_onReservationsChanged);
    } catch (_) {}
    super.dispose();
  }

  void _onReservationsChanged() {
    // Regenera el informe y actualiza tarjetas de ingresos/estadísticas; se programa después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats(); // Recargar todo desde el backend
    });
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    // users from API
    try {
      final apiService = ApiService();
      final users = await apiService.getUsers();
      _totalUsers = users.length;

      // Cargar programaciones
      _programaciones = await apiService.getProgramaciones();

      // Cargar fincas y rutas
      final fincas = await apiService.getFincas();
      _totalFincas = fincas.length;

      final rutas = await apiService.getRutas();
      _totalRutas = rutas.length;

      // Cargar reservas directamente del backend
      _reservasFromApi = await apiService.getReservas();

      // Calcular ingresos directamente de las reservas del backend
      _totalRevenue = _calcularTotalIngresos(_reservasFromApi);
      _revenue = _calcularIngresosCompletados(_reservasFromApi);
    } catch (e) {
      _totalUsers = 0;
      _programaciones = [];
      _totalFincas = 0;
      _totalRutas = 0;
      _reservasFromApi = [];
      _totalRevenue = 0.0;
      _revenue = 0.0;
    }
    // wait for reservations provider to load then generate report based on reservations
    final reservationsProv =
        Provider.of<ReservationsProvider>(context, listen: false);
    final reportsProv = Provider.of<ReportsProvider>(context, listen: false);
    // if reservations still loading, wait briefly (max tries)
    int tries = 0;
    while (reservationsProv.loading && tries < 10) {
      await Future.delayed(Duration(milliseconds: 200));
      tries++;
    }
    await reportsProv.generateReport(
        reservations: reservationsProv.reservations);

    // Escuchar cambios en reservas para actualizar el dashboard en tiempo real
    try {
      reservationsProv.removeListener(_onReservationsChanged);
    } catch (_) {}
    reservationsProv.addListener(_onReservationsChanged);
    setState(() => _loading = false);
  }

  double _calcularTotalIngresos(List<dynamic> reservas) {
    return reservas.fold(0.0, (sum, r) {
      final precio = (r['precio_total'] ?? 0);
      if (precio is String) {
        return sum + (double.tryParse(precio) ?? 0.0);
      }
      return sum + (precio as num).toDouble();
    });
  }

  double _calcularIngresosCompletados(List<dynamic> reservas) {
    return reservas
        .where((r) =>
            (r['status'] ?? r['estado'] ?? '').toString().toLowerCase() ==
            'completada')
        .fold(0.0, (sum, r) {
      // Intentar obtener precio de múltiples campos posibles
      final precio = (r['price'] ?? r['precio_total'] ?? 0);
      if (precio is String) {
        return sum + (double.tryParse(precio) ?? 0.0);
      }
      return sum + (precio as num).toDouble();
    });
  }

  int _contarReservasCompletadas(List<dynamic> reservas) {
    return reservas
        .where((r) =>
            (r['status'] ?? r['estado'] ?? '').toString().toLowerCase() ==
            'completada')
        .length;
  }

  Widget statCard(String title, String value, {Color? color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black)),
        ]),
      ),
    );
  }

  Widget quickTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade100)),
        child: Row(children: [
          Icon(icon, color: Colors.green),
          SizedBox(width: 12),
          Expanded(child: Text(title))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    final reservationsProv = Provider.of<ReservationsProvider>(context);
    final reportsProv = Provider.of<ReportsProvider>(context);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text('Panel de Administración')),
        body: Center(
            child: Text('Acceso denegado. Usuario no es administrador.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text('Panel de Administración'),
          leading: Builder(
              builder: (ctx) => IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(ctx).openDrawer())),
          actions: [
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => Navigator.of(context).pushNamed('/logout'))
          ]),
      drawer: _buildDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          // Top stats
          _loading
              ? LinearProgressIndicator()
              : Row(children: [
                  Expanded(
                      child: statCard('Fincas', '$_totalFincas',
                          color: Colors.brown)),
                  SizedBox(width: 12),
                  Expanded(
                      child: statCard('Rutas', '$_totalRutas',
                          color: Colors.orange)),
                  SizedBox(width: 12),
                  Expanded(
                      child: statCard(
                          'Completadas (${_contarReservasCompletadas(_reservasFromApi)})',
                          'COP ${_revenue.toStringAsFixed(0)}',
                          color: Colors.green)),
                  SizedBox(width: 12),
                  Expanded(
                      child: statCard('Total Ingresos',
                          'COP ${_totalRevenue.toStringAsFixed(0)}',
                          color: Colors.blue))
                ]),
          SizedBox(height: 16),
          // Acceso rápido eliminado del cuerpo; disponible desde el menú (hamburguesa)
          SizedBox(height: 12),
          // Área de calendario y panel
          Expanded(
              child: reportsProv.loading || reservationsProv.loading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          // Tarjeta de calendario con navegación por mes
                          Card(
                              child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Agenda del mes',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              Row(children: [
                                                IconButton(
                                                    icon: Icon(
                                                        Icons.chevron_left),
                                                    onPressed: _prevMonth),
                                                SizedBox(width: 6),
                                                IconButton(
                                                    icon: Icon(
                                                        Icons.chevron_right),
                                                    onPressed: _nextMonth)
                                              ])
                                            ]),
                                        SizedBox(height: 8),
                                        _buildCalendar(context,
                                            _reservasFromApi, _programaciones),
                                        SizedBox(height: 8),
                                        Wrap(
                                            spacing: 12,
                                            runSpacing: 6,
                                            children: [
                                              _legendItem(
                                                  Color.fromRGBO(
                                                      156, 39, 176, 0.9),
                                                  'Programaciones'),
                                              _legendItem(
                                                  Color.fromRGBO(
                                                      76, 175, 80, 0.9),
                                                  'Confirmado / En ejecución'),
                                              _legendItem(
                                                  Color.fromRGBO(
                                                      255, 235, 59, 0.9),
                                                  'Reservado (pendiente)'),
                                              _legendItem(
                                                  Color.fromRGBO(
                                                      33, 150, 243, 0.9),
                                                  'Horas de reserva'),
                                              _legendItem(Colors.white, 'Libre')
                                            ])
                                      ]))),
                          SizedBox(height: 12),
                          // Gráficos del panel
                          Card(
                              child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Dashboard',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(height: 8),
                                        Text('Top fincas y rutas',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(height: 8),
                                        ...((reportsProv.data['topProducts'] ??
                                                []) as List)
                                            .map<Widget>((p) => ListTile(
                                                title: Text(p['name'] ?? '-'),
                                                trailing:
                                                    Text('${p['sales'] ?? 0}')))
                                            .toList(),
                                        SizedBox(height: 12),
                                        Text('Mejores meses (Ingresos)',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(height: 8),
                                        _buildMonthlyBarChart(reportsProv
                                                .data['monthlyRevenue'] ??
                                            [])
                                      ])))
                        ])))
        ]),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(children: [
      Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300))),
      SizedBox(width: 8),
      Text(label)
    ]);
  }

  Widget _buildCalendar(BuildContext context, List<dynamic> reservations,
      List<dynamic> programaciones) {
    final year = _displayYear;
    final month = _displayMonth;
    final first = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Group reservations by day (exclude cancelled)
    final Map<int, List<Map<String, dynamic>>> dayRes = {};
    for (var r in reservations) {
      final dStr = r['date'] as String?;
      if (dStr == null) continue;
      try {
        final d = DateTime.parse(dStr);
        if (d.year == year && d.month == month) {
          if ((r['status'] ?? '').toString().toLowerCase() == 'cancelada')
            continue;
          dayRes[d.day] = [...(dayRes[d.day] ?? []), r];
        }
      } catch (_) {}
    }

    // Group programaciones by day
    final Map<int, List<dynamic>> dayProg = {};
    for (var p in programaciones) {
      final fechaStr = p['fecha'] as String?;
      if (fechaStr == null) continue;
      try {
        final d = DateTime.parse(fechaStr);
        if (d.year == year && d.month == month) {
          dayProg[d.day] = [...(dayProg[d.day] ?? []), p];
        }
      } catch (_) {}
    }

    final weekdayOffset = first.weekday % 7; // to start on Sunday

    List<Widget> dayWidgets = [];
    // leading blanks
    for (int i = 0; i < weekdayOffset; i++) {
      dayWidgets.add(Container());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final list = dayRes[d] ?? [];
      final progs = dayProg[d] ?? [];

      // Decide dominant state: green if any 'Activa', yellow if any 'Pendiente'/'Reservada',
      // purple if programaciones, otherwise blue for other reservations
      Color? bgColor;
      Color? displayDot;

      if (progs.isNotEmpty) {
        // Programaciones en morado
        bgColor = Color.fromRGBO(156, 39, 176, 0.25); // purple
        displayDot = Colors.purple.shade700;
      } else if (list.any(
          (r) => (r['status'] ?? '').toString().toLowerCase() == 'activa')) {
        bgColor = Color.fromRGBO(76, 175, 80, 0.30); // stronger green
        displayDot = Colors.green.shade700;
      } else if (list.any((r) =>
          (r['status'] ?? '').toString().toLowerCase().contains('pend') ||
          (r['status'] ?? '').toString().toLowerCase().contains('reserv'))) {
        bgColor = Color.fromRGBO(255, 235, 59, 0.30); // stronger yellow
        displayDot = Colors.yellow.shade800;
      } else if (list.isNotEmpty) {
        bgColor = Color.fromRGBO(33, 150, 243, 0.20); // blue for other
        displayDot = Colors.blue.shade700;
      } else {
        bgColor = Colors.white;
        displayDot = null;
      }

      dayWidgets.add(GestureDetector(
        onTap: () =>
            _showDayDetails(context, DateTime(year, month, d), list, progs),
        child: Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: (list.isNotEmpty || progs.isNotEmpty)
                        ? Colors.grey.shade400
                        : Colors.grey.shade300)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('$d', style: TextStyle(fontWeight: FontWeight.w600)),
                if (displayDot != null)
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: displayDot,
                          borderRadius: BorderRadius.circular(6)))
              ]),
              SizedBox(height: 6),
              // show up to 3 items (programaciones o reservas)
              if (progs.isNotEmpty)
                Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: progs.take(2).map<Widget>((p) {
                      final hora = p['hora'] ?? '-';
                      return Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.purple.shade600,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('$hora',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11)));
                    }).toList())
              else if (list.isNotEmpty)
                Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: list.take(3).map<Widget>((r) {
                      final time = r['time'] ?? '-';
                      return Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('$time',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11)));
                    }).toList()),
              if (progs.length > 2 || list.length > 3) SizedBox(height: 6),
              if (progs.length > 2)
                Align(
                    alignment: Alignment.bottomRight,
                    child: Text('+${progs.length - 2} más',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade700)))
              else if (list.length > 3)
                Align(
                    alignment: Alignment.bottomRight,
                    child: Text('+${list.length - 3} más',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade700)))
            ])),
      ));
    }

    return Column(children: [
      Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(6)),
          child: Center(
              child: Text('${_monthName(month)} $year',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)))),
      SizedBox(height: 8),
      GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: [
            for (var wd in ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'])
              Center(
                  child: Text(wd,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700]))),
            ...dayWidgets
          ])
    ]);
  }

  Drawer _buildDrawer() {
    final lowCount = Provider.of<ProductsProvider>(context, listen: false)
        .lowStockItems()
        .length;

    Widget drawerItem(IconData icon, String title, String route) {
      return ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(route);
        },
      );
    }

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Acceso Rápido',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    drawerItem(Icons.person, 'Usuarios', '/users'),
                    drawerItem(Icons.security, 'Roles y Permisos', '/roles'),
                    drawerItem(
                        Icons.calendar_today, 'Reservas', '/reservations'),
                    drawerItem(Icons.analytics, 'Dashboard Analítico',
                        '/admin/analytics'),
                    drawerItem(
                        Icons.insert_chart_outlined, 'Informes', '/reports'),
                    drawerItem(
                        Icons.payment, 'Pagos a proveedores', '/payments'),
                    drawerItem(Icons.store, 'Proveedores', '/suppliers'),
                    drawerItem(Icons.shopping_bag, 'Ventas', '/ventas'),
                    ListTile(
                      leading: Icon(Icons.warning_amber_rounded,
                          color: Colors.green),
                      title: Text('Stock bajo ($lowCount)'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed('/products/lowstock');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return names[m - 1];
  }

  void _showDayDetails(BuildContext context, DateTime day,
      List<Map<String, dynamic>> reservations, List<dynamic> programaciones) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Text('Detalles ${day.day}/${day.month}/${day.year}'),
              content: Container(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Programaciones
                        if (programaciones.isNotEmpty) ...[
                          Text('Programaciones',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple)),
                          SizedBox(height: 8),
                          ...programaciones.map((p) {
                            return Card(
                              color: Colors.purple.shade50,
                              child: ListTile(
                                leading:
                                    Icon(Icons.event, color: Colors.purple),
                                title: Text('${p['hora'] ?? '-'}'),
                                subtitle: Text(
                                    'Guía: ${p['guia_nombre'] ?? '-'}\nRuta: ${p['ruta_nombre'] ?? '-'}'),
                                isThreeLine: true,
                              ),
                            );
                          }).toList(),
                          Divider(),
                        ],

                        // Reservas
                        if (reservations.isNotEmpty) ...[
                          Text('Reservas',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          ...reservations.map((r) {
                            final st =
                                (r['status'] ?? '').toString().toLowerCase();
                            Color dotColor = Colors.blue;
                            if (st == 'activa' || st == 'completada')
                              dotColor = Colors.green;
                            else if (st.contains('pend') ||
                                st.contains('reserv'))
                              dotColor = Colors.yellow.shade700;
                            else if (st == 'cancelada') dotColor = Colors.grey;
                            return ListTile(
                              leading: CircleAvatar(
                                  radius: 12, backgroundColor: dotColor),
                              title: Text(r['service'] ?? '-'),
                              subtitle: Text(
                                  '${r['time'] ?? '-'} • ${r['status'] ?? '-'}'),
                              trailing: Text(
                                  'COP ${((r['price'] ?? 0) as num).toStringAsFixed(0)}'),
                            );
                          }).toList(),
                        ],

                        if (programaciones.isEmpty && reservations.isEmpty)
                          Text('No hay eventos este día'),
                      ],
                    ),
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cerrar'))
              ]);
        });
  }

  void _prevMonth() {
    setState(() {
      if (_displayMonth == 1) {
        _displayMonth = 12;
        _displayYear -= 1;
      } else {
        _displayMonth -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayMonth == 12) {
        _displayMonth = 1;
        _displayYear += 1;
      } else {
        _displayMonth += 1;
      }
    });
  }

  Widget _buildMonthlyBarChart(List<dynamic> monthly) {
    final list = monthly;
    if (list.isEmpty)
      return Container(height: 140, child: Center(child: Text('No hay datos')));
    final bars = list
        .map((m) => BarChartGroupData(x: (m['month'] as int), barRods: [
              BarChartRodData(
                  toY: (m['value'] as num).toDouble(), color: Colors.green)
            ]))
        .toList();
    final maxY = (list
            .map((m) => (m['value'] as num).toDouble())
            .reduce((a, b) => a > b ? a : b)) *
        1.1;
    return SizedBox(
        height: 200,
        child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
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
}
