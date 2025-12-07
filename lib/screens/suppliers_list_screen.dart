// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/suppliers_provider.dart';
import '../widgets/admin_only.dart';

class SuppliersListScreen extends StatelessWidget {
  static const routeName = '/suppliers';
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<SuppliersProvider>(context);
    final list = prov.suppliers;
    return Scaffold(
      appBar: AppBar(title: Text('Proveedores')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          AdminOnly(child: ElevatedButton(onPressed: ()=> Navigator.of(context).pushNamed('/suppliers/create'), child: Text('Crear Proveedor'))),
          SizedBox(height:12),
          Expanded(child: list.isEmpty ? Center(child: Text('No hay proveedores')) : ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_,__)=>SizedBox(height:8),
            itemBuilder: (ctx,i){ final s = list[i]; return Card(child: ListTile(
              title: Text(s['name'] ?? '-'),
              subtitle: Text(s['contact'] ?? ''),
              trailing: Icon(Icons.chevron_right),
              onTap: ()=> Navigator.of(context).pushNamed('/suppliers/detail', arguments: s['id']),
            )); }
          ))
        ])
      ),
    );
  }
}
