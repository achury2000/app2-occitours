// parte lucho
// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../providers/auth_provider.dart';

class UserDetailScreen extends StatelessWidget {
  static const routeName = '/users/detail';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final usersProv = Provider.of<UsersProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // Se espera que `args` pueda contener la clave 'id'
    final id = args != null && args['id'] != null ? args['id'] as String : null;
    // parte linsaith
    if (id == null) {
      // En ausencia de `id`, mostramos una vista alternativa leyendo los campos provistos en el mapa
      return Scaffold(appBar: AppBar(title: Text('Detalle de Usuario')), body: Center(child: Text('Usuario no especificado')));
    }
    final idx = usersProv.users.indexWhere((u) => u.id == id);
    if (idx < 0) return Scaffold(appBar: AppBar(title: Text('Detalle de Usuario')), body: Center(child: Text('Usuario no encontrado')));
    final u = usersProv.users[idx];
    return Scaffold(
      appBar: AppBar(title: Text('Detalle de Usuario')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text(u.name, style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
          SizedBox(height:8),
          Text('Correo: ${u.email}'),
          SizedBox(height:6),
          Text('Rol: ${u.role}'),
          SizedBox(height:6),
          Text('Estado: ${u.active ? 'Activo' : 'Inactivo'}'),
          SizedBox(height:6),
          Text('Fecha de registro: -'),
          SizedBox(height:6),
          Text('Última sesión: -'),
          Spacer(),
          Row(children:[
            ElevatedButton.icon(onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (ctx)=> AlertDialog(
                title: Text('Cambiar estado'),
                content: Text('¿Desea ${u.active ? 'desactivar' : 'activar'} al usuario ${u.name}?'),
                actions: [TextButton(onPressed: ()=> Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(ctx).pop(true), child: Text('Confirmar'))],
              ));
              if (confirm == true) {
                await usersProv.toggleActiveWithAudit(u.id, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado')));
              }
            }, icon: Icon(Icons.sync), label: Text('Cambiar estado')),
            SizedBox(width:12),
            ElevatedButton.icon(onPressed: () async {
              final confirm = await showDialog<bool>(context: context, builder: (ctx)=> AlertDialog(
                title: Text('Eliminar usuario'),
                content: Text('¿Eliminar al usuario ${u.name}?'),
                actions: [TextButton(onPressed: ()=> Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(ctx).pop(true), child: Text('Eliminar'))],
              ));
              if (confirm == true) {
                await usersProv.deleteUserWithAudit(u.id, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario eliminado')));
                Navigator.of(context).pop();
              }
            }, icon: Icon(Icons.delete), label: Text('Eliminar')),
            SizedBox(width:12),
            OutlinedButton.icon(onPressed: ()=> Navigator.of(context).pushNamed('/users/edit', arguments: {'id': u.id}), icon: Icon(Icons.edit), label: Text('Editar'))
          ]),
          SizedBox(height:8),
          ElevatedButton.icon(onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.arrow_back), label: Text('Volver'))
        ])
      ),
    );
  }
}
