// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/suppliers_provider.dart';
import '../providers/auth_provider.dart';

class SupplierDetailScreen extends StatelessWidget {
  static const routeName = '/suppliers/detail';
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    String? id;
    if (arg is String) id = arg;
    if (id == null) return Scaffold(appBar: AppBar(title: Text('Proveedor')), body: Center(child: Text('Proveedor no encontrado')));
    final prov = Provider.of<SuppliersProvider>(context);
    final s = prov.getById(id);
    if (s == null) return Scaffold(appBar: AppBar(title: Text('Proveedor')), body: Center(child: Text('Proveedor no encontrado')));
    final auth = Provider.of<AuthProvider>(context, listen:false);
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Proveedor')),
      body: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(s['name'] ?? '-', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
        SizedBox(height:8), Text('Contacto: ${s['contact'] ?? '-'}'),
        Spacer(), Row(children:[ElevatedButton(onPressed: ()=> Navigator.of(context).pushNamed('/suppliers/form', arguments: id), child: Text('Editar')), SizedBox(width:12), ElevatedButton(onPressed: () async {
          final confirm = await showDialog<bool>(context: context, builder: (ctx)=> AlertDialog(title: Text('Eliminar proveedor'), content: Text('¿Eliminar este proveedor? Esta acción no se puede deshacer.'), actions: [TextButton(onPressed: ()=> Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(ctx).pop(true), child: Text('Eliminar'))]));
          if (confirm == true) {
            await prov.deleteSupplier(id!, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Proveedor eliminado')));
            Navigator.of(context).pop();
          }
        }, child: Text('Eliminar', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red))])
      ]))
    );
  }
}
