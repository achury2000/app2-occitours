// parte lucho
// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/roles_provider.dart';
import '../providers/auth_provider.dart';

class AssignPermissionsScreen extends StatefulWidget {
  static const routeName = '/roles/assign';
  @override
  _AssignPermissionsScreenState createState() => _AssignPermissionsScreenState();
}

class _AssignPermissionsScreenState extends State<AssignPermissionsScreen> {
  final Map<String, bool> _perms = {};
  bool _all = false;
  String? _roleId;

  void _toggleAll(bool v){
    setState((){
      _all = v;
      _perms.updateAll((_,__)=>v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final rolesProv = Provider.of<RolesProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_roleId == null) {
      _roleId = arg?.toString();
      final role = rolesProv.roles.firstWhere((r) => r['id'] == _roleId, orElse: ()=> {});
      final List perms = (role['permissions'] as List?) ?? [];
      // initialize perms map with existing permissions or a default set
      final baseKeys = perms.isNotEmpty ? perms : List.generate(12, (i)=> 'perm.${i+1}');
      for (final k in baseKeys) { _perms[k] = perms.contains(k); }
      _all = _perms.values.every((v) => v == true);
    }
    return Scaffold(
      appBar: AppBar(title: Text('Asignar Permisos')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          Align(alignment: Alignment.centerLeft, child: Text('Asignando permisos a rol ${arg ?? ''}', style: TextStyle(fontWeight: FontWeight.w700))),
          SizedBox(height:8),
          Row(children:[
            Checkbox(value: _all, onChanged: (v)=> _toggleAll(v ?? false)),
            SizedBox(width:8),
            Text(_all ? 'Deseleccionar todos' : 'Seleccionar todos')
          ]),
          SizedBox(height:8),
          Expanded(child: ListView.separated(
            itemCount: _perms.length,
            separatorBuilder: (_,__)=>Divider(),
            itemBuilder: (ctx,i){ final key = _perms.keys.elementAt(i); return CheckboxListTile(
              value: _perms[key],
              title: Text(key),
              onChanged: (v){ setState(()=> _perms[key] = v ?? false); },
            ); }
          )),
          SizedBox(height:8),
          Row(children:[
            Expanded(child: ElevatedButton(onPressed: () async {
              final selected = _perms.entries.where((e)=> e.value).map((e)=> e.key).toList();
              await rolesProv.setPermissions(_roleId ?? '', selected, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permisos guardados')));
              Navigator.of(context).pop();
            }, child: Text('Guardar cambios')))
          ])
        ])
      ),
    );
  }
}
