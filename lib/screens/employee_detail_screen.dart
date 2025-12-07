import 'package:flutter/material.dart';

class EmployeeDetailScreen extends StatelessWidget {
  static const routeName = '/employees/detail';
  @override
  Widget build(BuildContext context) {
    final emp = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Empleado')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text(emp?['name'] ?? 'Nombre', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
          SizedBox(height:8),
          Text('Cargo: ${emp?['position'] ?? '-'}'),
          SizedBox(height:6),
          Text('Rol asignado: ${emp?['role'] ?? '-'}'),
          SizedBox(height:6),
          Text('Estado: ${emp?['status'] ?? '-'}'),
          SizedBox(height:12),
          Text('Información personal', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height:8),
          Text('Dirección: -'),
          Text('Teléfono: -'),
          Spacer(),
          ElevatedButton.icon(onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.arrow_back), label: Text('Volver'))
        ])
      ),
    );
  }
}
