import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends StatefulWidget {
  static const routeName = '/reports';
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<ReportsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Reportes')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ElevatedButton(onPressed: ()=>reports.generateReport(), child: Text('Generar reporte')),
          SizedBox(height:12),
          if(reports.loading) Center(child: CircularProgressIndicator()),
          if(!reports.loading && reports.data.isNotEmpty) Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Revenue: COP ${reports.data['revenue']}'),
                SizedBox(height:12),
                Text('Ventas (últimos días):', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height:8),
                _buildLineChart(reports.data['sales'] as List),
                SizedBox(height:12),
                Text('Top productos (por ventas):', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height:8),
                _buildBarChart(reports.data['topProducts'] as List),
                SizedBox(height:12),
                Text('Distribución (Top productos):', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height:8),
                _buildPieChart(reports.data['topProducts'] as List),
                SizedBox(height:24),
              ]),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildLineChart(List sales) {
    final spots = <FlSpot>[];
    for (var i = 0; i < sales.length; i++) {
      final v = (sales[i]['value'] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), v));
    }
    return SizedBox(
      height: 200,
      child: LineChart(LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) => Padding(padding: EdgeInsets.only(top:6), child: Text('D${v.toInt()+1}', style: TextStyle(fontSize:10))))), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true))),
        borderData: FlBorderData(show: false),
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Colors.blue, dotData: FlDotData(show: false))],
      )),
    );
  }

  Widget _buildBarChart(List topProducts) {
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < topProducts.length; i++) {
      final val = (topProducts[i]['sales'] as num).toDouble();
      groups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: val, color: Colors.teal)]));
    }
    return SizedBox(
      height: 180,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: groups,
        titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) { final idx = v.toInt(); if(idx<0 || idx>=topProducts.length) return Text(''); return Text(topProducts[idx]['name'].toString().split(' ').first, style: TextStyle(fontSize:10)); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true))),
        gridData: FlGridData(show: false),
      )),
    );
  }

  Widget _buildPieChart(List topProducts) {
    final total = topProducts.fold<double>(0, (s, e) => s + (e['sales'] as num).toDouble());
    final sections = <PieChartSectionData>[];
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
    for (var i = 0; i < topProducts.length; i++) {
      final val = (topProducts[i]['sales'] as num).toDouble();
      sections.add(PieChartSectionData(value: val, title: '${((val/ total)*100).toStringAsFixed(0)}%', color: colors[i % colors.length], radius: 40));
    }
    return SizedBox(
      height: 160,
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 24)),
    );
  }
}
