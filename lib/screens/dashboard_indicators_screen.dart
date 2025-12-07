import 'package:flutter/material.dart';

/// Pantalla de indicadores clave (KPI).
///
/// Muestra métricas resumidas como NPS, satisfacción y tasa de repetición.
/// Diseñada para ser una vista ligera consumiendo datos del `ReportsProvider`.
class DashboardIndicatorsScreen extends StatelessWidget {
  static const routeName = '/dashboard/indicators';
  @override
  Widget build(BuildContext context) {
    Widget metric(String title, String value, Color color){
      return Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)), SizedBox(height:8), Text(value, style: TextStyle(fontSize:20, fontWeight: FontWeight.bold))])));
    }

    return Scaffold(appBar: AppBar(title: Text('Indicadores')), body: Padding(padding: EdgeInsets.all(12), child: Column(children:[
      Wrap(spacing:12, runSpacing:12, children:[
        SizedBox(width: 180, child: metric('NPS', '+45', Colors.green)),
        SizedBox(width: 180, child: metric('Satisfacción', '4.6/5', Colors.blue)),
        SizedBox(width: 180, child: metric('Tasa de repetición', '23%', Colors.orange)),
      ]),
      SizedBox(height:12),
      Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Actualizaciones', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), Text('Datos actualizados cada 24h (simulado).')])))
    ])));
  }
}
