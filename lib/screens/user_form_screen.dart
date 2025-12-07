// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class UserFormScreen extends StatefulWidget {
  static const routeName = '/users/create';
  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _role = 'Cliente';
  String? _editingId;

  @override
  void dispose(){ _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final editing = arg != null && arg['id'] != null;
    final usersProv = Provider.of<UsersProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // parte linsaith
    // initialize editing values if editing
    if (editing && _editingId == null) {
      _editingId = arg['id'] as String;
      final u = usersProv.users.firstWhere((x) => x.id == _editingId, orElse: () => User(id: '', name: '', email: '', role: 'customer'));
      _name.text = u.name;
      _email.text = u.email;
      _role = _mapRoleLabel(u.role);
    }
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar Usuario' : 'Crear Usuario')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children:[
            TextFormField(controller: _name, decoration: InputDecoration(labelText: 'Nombre de usuario'), validator: (v)=> v==null||v.isEmpty? 'Requerido':null),
            SizedBox(height:8),
            TextFormField(controller: _email, decoration: InputDecoration(labelText: 'Correo'), keyboardType: TextInputType.emailAddress, validator: (v){ if(v==null||v.isEmpty) return 'Requerido'; if(!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v)) return 'Email inválido'; return null;}),
            SizedBox(height:8),
            TextFormField(controller: _password, decoration: InputDecoration(labelText: 'Contraseña temporal'), obscureText: true, validator: (v){ if(!editing && (v==null||v.length<4)) return 'Mínimo 4 caracteres'; return null;}),
            SizedBox(height:8),
            // parte linsaith
            DropdownButtonFormField<String>(initialValue: _role, items: ['Cliente','Guía','Administrador'].map((r)=> DropdownMenuItem(child: Text(r), value: r)).toList(), onChanged: (v)=> setState(()=> _role = v ?? 'Cliente'), decoration: InputDecoration(labelText: 'Rol')),
            SizedBox(height:16),
            Row(children:[ Expanded(child: ElevatedButton(onPressed: ()=> _save(usersProv, auth), child: Text('Guardar'))), SizedBox(width:12), OutlinedButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar')) ])
          ])
        ),
      ),
    );
  }

  String _mapRoleLabel(String role){
    switch(role.toLowerCase()){
      case 'admin': return 'Administrador';
      case 'guide': return 'Guía';
      default: return 'Cliente';
    }
  }

  String _inverseRoleLabel(String label){
    switch(label){
      case 'Administrador': return 'admin';
      case 'Guía': return 'guide';
      default: return 'customer';
    }
  }

  void _save(UsersProvider usersProv, AuthProvider auth) async {
    if(!_formKey.currentState!.validate()) return;
    final name = _name.text.trim();
    final email = _email.text.trim();
    final roleVal = _inverseRoleLabel(_role);
    if (usersProv.emailExists(email, excludeId: _editingId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El correo ya está en uso')));
      return;
    }
    if (_editingId != null) {
      await usersProv.updateUser(_editingId!, { 'name': name, 'email': email, 'role': roleVal }, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario actualizado')));
    } else {
      await usersProv.addUser({'name': name, 'email': email, 'role': roleVal}, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Usuario creado')));
    }
    Navigator.of(context).pop();
  }
}
