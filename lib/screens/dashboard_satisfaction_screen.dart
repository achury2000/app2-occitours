import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';

class DashboardSatisfactionScreen extends StatefulWidget {
  static const routeName = '/dashboard/satisfaction';
  @override
  _DashboardSatisfactionScreenState createState() => _DashboardSatisfactionScreenState();
}

class _DashboardSatisfactionScreenState extends State<DashboardSatisfactionScreen> {
  final _scoreCtrl = TextEditingController();
  final Set<String> _submitted = {};

  @override
  void dispose(){ _scoreCtrl.dispose(); super.dispose(); }

  void _submit(){
    final id = 'client@example.com';
    if(_submitted.contains(id)) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ya existe una puntuación para este cliente'))); return; }
    _submitted.add(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calificación registrada')));
    _scoreCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<ReportsProvider>(context);
    return Scaffold(appBar: AppBar(title: Text('Calificación de Satisfacción')), body: Padding(padding: EdgeInsets.all(12), child: Column(children:[
      TextFormField(controller: _scoreCtrl, decoration: InputDecoration(labelText: 'Puntuación (0-5)'), keyboardType: TextInputType.number),
      SizedBox(height:12),
      ElevatedButton(onPressed: _submit, child: Text('Registrar')),
      SizedBox(height:12),
      Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Alertas', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), Text('Se mostrarán alertas por puntuaciones críticas (simulado).')])),),
      SizedBox(height:12),
      Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Últimos reportes generados', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), reports.loading ? Center(child: CircularProgressIndicator()) : Text('Revenue simulado: COP ${reports.data['revenue'] ?? '-'}')])),)
    ])));
  }
}
