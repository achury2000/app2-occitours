import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';

/// Pantalla de generación y exportación de reportes.
///
/// Permite generar reportes de satisfacción y exportarlos en formatos simulados (PDF/Excel).
class DashboardReportsScreen extends StatelessWidget {
  static const routeName = '/dashboard/reports';
  @override
  Widget build(BuildContext context) {
    final reportsProv = Provider.of<ReportsProvider>(context);
    final items = List.generate(6, (i) => {'title': 'Reporte ${i+1}', 'desc': 'Comparativo'});
    return Scaffold(appBar: AppBar(title: Text('Reportes de Satisfacción')), body: Padding(padding: EdgeInsets.all(12), child: Column(children:[
      Row(children:[ElevatedButton(onPressed: ()=> reportsProv.generateReport(), child: Text('Generar reporte'))]),
      SizedBox(height:12),
      Expanded(child: reportsProv.loading ? Center(child: CircularProgressIndicator()) : ListView.separated(itemCount: items.length, separatorBuilder: (_,__)=>SizedBox(height:8), itemBuilder: (ctx,i){ final r = items[i]; return Card(child: ListTile(title: Text(r['title']!), subtitle: Text(r['desc']!), trailing: PopupMenuButton<String>(onSelected: (v) { if(v=='pdf') ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportando PDF (simulado)'))); if(v=='excel') ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exportando Excel (simulado)'))); }, itemBuilder: (_)=>[PopupMenuItem(value:'pdf', child: Text('Exportar PDF')), PopupMenuItem(value:'excel', child: Text('Exportar Excel'))]))); }))
    ])));
  }
}
