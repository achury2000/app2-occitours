import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/reports_provider.dart';

/// Pantalla de estadísticas detalladas.
///
/// Muestra gráficos de series temporales (ingresos por día) y listas top de paquetes.
/// Consume datos desde `ReportsProvider` y expone controles de periodo.
class DashboardStatisticsScreen extends StatefulWidget {
  static const routeName = '/dashboard/statistics';
  @override
  _DashboardStatisticsScreenState createState() => _DashboardStatisticsScreenState();
}

class _DashboardStatisticsScreenState extends State<DashboardStatisticsScreen> {
  String _period = 'Últimos 30 días';

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).generateReport();
    });
  }

  Widget buildChart(List<dynamic> sales){
    if (sales.isEmpty) return Container(height:180, child: Center(child: Text('No hay datos')));
    final spots = sales.map((s) => FlSpot((s['day'] as num).toDouble(), (s['value'] as num).toDouble())).toList();
    final minX = spots.first.x;
    final maxX = spots.last.x;
    final minY = spots.map((e)=> e.y).reduce((a,b)=> a<b?a:b);
    final maxY = spots.map((e)=> e.y).reduce((a,b)=> a>b?a:b);
    return SizedBox(height:200, child: LineChart(LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true))),
      minX: minX,
      maxX: maxX,
      minY: minY*0.9,
      maxY: maxY*1.1,
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3, dotData: FlDotData(show: true))],
    )));
  }

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<ReportsProvider>(context);
    final loading = reports.loading;
    final data = reports.data;

    return Scaffold(appBar: AppBar(title: Text('Estadísticas')), body: Padding(padding: EdgeInsets.all(12), child: Column(children:[
      Row(children:[Expanded(child: DropdownButtonFormField<String>(initialValue: _period, items: ['Últimos 7 días','Últimos 30 días','Último año'].map((s)=> DropdownMenuItem(child: Text(s), value: s)).toList(), onChanged: (v)=> setState(()=> _period = v ?? _period), decoration: InputDecoration(labelText: 'Periodo'))), SizedBox(width:12), ElevatedButton(onPressed: ()=> Provider.of<ReportsProvider>(context, listen:false).generateReport(), child: Text('Aplicar'))]),
      SizedBox(height:12),
      Expanded(child: loading ? Center(child: CircularProgressIndicator()) : ListView(children:[
        Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Ingresos por día', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), buildChart(data['sales'] ?? [])]))),
        Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Top Paquetes', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), ...(data['topProducts'] ?? []).map<Widget>((p)=> ListTile(title: Text(p['name'] ?? '-'), trailing: Text('${p['sales'] ?? 0} ventas'))).toList(), SizedBox(height:8), Text('Revenue: COP ${data['revenue'] ?? 0}', style: TextStyle(fontWeight: FontWeight.w600))]))),
      ]))
    ])));
  }
}
