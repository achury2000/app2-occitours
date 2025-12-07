import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employees_provider.dart';
import '../widgets/admin_only.dart';

class EmployeesListScreen extends StatelessWidget {
  static const routeName = '/employees';
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<EmployeesProvider>(context);
    final _emps = prov.employees;
    return Scaffold(
      appBar: AppBar(title: Text('Empleados'), actions: [AdminOnly(child: IconButton(icon: Icon(Icons.add), onPressed: ()=> Navigator.of(context).pushNamed('/employees/create')))]),
      floatingActionButton: AdminOnly(child: FloatingActionButton(child: Icon(Icons.add), onPressed: ()=> Navigator.of(context).pushNamed('/employees/create'))),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView.separated(
          itemCount: _emps.length,
          separatorBuilder: (_,__)=>SizedBox(height:10),
          itemBuilder: (ctx,i){ final e = _emps[i]; return Card(
            child: ListTile(
              title: Text(e['name']!),
              subtitle: Text('${e['position']} • ${e['role']}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children:[ IconButton(icon: Icon(Icons.edit), onPressed: ()=> Navigator.of(context).pushNamed('/employees/edit', arguments: e['id'])), IconButton(icon: Icon(Icons.delete), onPressed: (){ prov.deleteEmployee(e['id']!); })]),
              onTap: ()=> Navigator.of(context).pushNamed('/employees/detail', arguments: e),
            ),
          ); }
        ),
      ),
    );
  }
}
