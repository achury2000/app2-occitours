// parte lucho
// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/roles_provider.dart';
import '../providers/auth_provider.dart';

class RoleDetailScreen extends StatelessWidget {
  static const routeName = '/roles/detail';
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments?.toString();
    final rolesProv = Provider.of<RolesProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final idx = rolesProv.roles.indexWhere((r) => r['id'] == id);
    if (idx < 0) {
      return Scaffold(appBar: AppBar(title: Text('Detalle de Rol')), body: Center(child: Text('Rol no encontrado')));
    }
    final role = rolesProv.roles[idx];
    final perms = List<String>.from(role['permissions'] ?? <String>[]);
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Rol')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(role['name'] ?? 'Sin nombre', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
          SizedBox(height:8),
          Text(role['description'] ?? '', style: TextStyle(color: Colors.black87)),
          SizedBox(height:12),
          Row(children:[Text('Estado: '), Chip(label: Text((role['active'] as bool) ? 'Activo' : 'Inactivo'), backgroundColor: (role['active'] as bool) ? Colors.green[100] : Colors.grey[200])]),
          SizedBox(height:12),
          Row(children:[
            ElevatedButton.icon(onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (ctx)=> AlertDialog(
                title: Text('Cambiar estado'),
                content: Text('¿Desea ${ (role['active'] as bool) ? 'desactivar' : 'activar' } el rol ${role['name']}?'),
                actions: [TextButton(onPressed: ()=> Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(ctx).pop(true), child: Text('Confirmar'))],
              ));
              if (confirm == true) {
                await rolesProv.toggleActiveWithAudit(role['id'], actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado')));
              }
            }, icon: Icon(Icons.sync), label: Text('Cambiar estado')),
            SizedBox(width:12),
            ElevatedButton.icon(onPressed: ()=> Navigator.of(context).pushNamed('/roles/assign', arguments: role['id']), icon: Icon(Icons.security), label: Text('Asignar permisos'))
          ]),
          SizedBox(height:16),
          Text('Permisos asignados', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height:8),
          if (perms.isEmpty) Text('No hay permisos asignados'),
          Wrap(spacing:8, children: perms.map((p)=> Chip(label: Text(p))).toList()),
          Spacer(),
          Align(alignment: Alignment.bottomLeft, child: ElevatedButton.icon(onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.arrow_back), label: Text('Volver')))
        ]),
      ),
    );
  }
}
