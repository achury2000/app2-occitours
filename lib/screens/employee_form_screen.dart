import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employees_provider.dart';

class EmployeeFormScreen extends StatefulWidget {
  static const routeNameCreate = '/employees/create';
  static const routeNameEdit = '/employees/edit';
  @override
  _EmployeeFormScreenState createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _id;
  String _name = '';
  String _position = '';
  String _role = '';
  String _status = 'Activo';

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    if (_id == null){
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) _id = args;
      if (_id != null){
        final prov = Provider.of<EmployeesProvider>(context, listen: false);
        final emp = prov.employees.firstWhere((e) => e['id'] == _id, orElse: () => {});
        if (emp.isNotEmpty){
          _name = emp['name'] ?? '';
          _position = emp['position'] ?? '';
          _role = emp['role'] ?? '';
          _status = emp['status'] ?? 'Activo';
        }
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final prov = Provider.of<EmployeesProvider>(context, listen: false);
    final data = {'name': _name, 'position': _position, 'role': _role, 'status': _status};
    if (_id == null){
      await prov.addEmployee(Map<String,String>.from(data));
    } else {
      await prov.updateEmployee(_id!, Map<String,String>.from(data));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_id == null ? 'Crear Empleado' : 'Editar Empleado')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children:[
            TextFormField(initialValue: _name, decoration: InputDecoration(labelText: 'Nombre'), validator: (v)=> v==null||v.isEmpty? 'Nombre requerido': null, onSaved: (v)=> _name = v ?? ''),
            SizedBox(height:12),
            TextFormField(initialValue: _position, decoration: InputDecoration(labelText: 'Posición'), onSaved: (v)=> _position = v ?? ''),
            SizedBox(height:12),
            TextFormField(initialValue: _role, decoration: InputDecoration(labelText: 'Rol'), onSaved: (v)=> _role = v ?? ''),
            SizedBox(height:12),
            DropdownButtonFormField<String>(initialValue: _status, items: ['Activo','Inactivo'].map((s)=> DropdownMenuItem(child: Text(s), value: s)).toList(), onChanged: (v)=> setState(()=> _status = v ?? 'Activo'), decoration: InputDecoration(labelText: 'Estado')),
            SizedBox(height:20),
            Row(children:[Expanded(child: ElevatedButton(onPressed: _save, child: Text('Guardar')))])
          ]),
        )
      ),
    );
  }
}
