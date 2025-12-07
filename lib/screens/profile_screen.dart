import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState(){
    super.initState();
    Provider.of<ProfileProvider>(context, listen: false).loadProfile('u3');
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    final user = profile.user;
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: profile.loading ? Center(child: CircularProgressIndicator()) : Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user?.name ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height:8),
          Text('Email: ${user?.email ?? ''}'),
          SizedBox(height:8),
          Text('Tel: ${user?.phone ?? '-'}'),
          SizedBox(height:12),
          ElevatedButton(onPressed: ()=>_showEditDialog(context, profile), child: Text('Editar'))
        ]),
      ),
    );
  }

  void _showEditDialog(BuildContext ctx, ProfileProvider profile) {
    final user = profile.user;
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final addressCtrl = TextEditingController(text: user?.address ?? '');

    showDialog(context: ctx, builder: (_) => AlertDialog(
      title: Text('Editar perfil'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nombre'), validator: (v)=> (v==null||v.trim().isEmpty)?'Nombre requerido':null),
          TextFormField(
            controller: phoneCtrl,
            decoration: InputDecoration(labelText: 'Teléfono'),
            keyboardType: TextInputType.phone,
            validator: (v){
              if(v==null||v.trim().isEmpty) return null;
              final text = v.trim();
              if(text.length < 7 || text.length > 15) return 'Teléfono inválido';
              final digitsOnly = text.split('').every((c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57);
              if(!digitsOnly) return 'Teléfono inválido';
              return null;
            }
          ),
          TextFormField(controller: addressCtrl, decoration: InputDecoration(labelText: 'Dirección')),
        ]),
      ),
      actions: [
        TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          if(!_formKey.currentState!.validate()) return;
          final u = profile.user!;
          final updated = User(id: u.id, name: nameCtrl.text.trim(), email: u.email, role: u.role, phone: phoneCtrl.text.trim(), address: addressCtrl.text.trim());
          await profile.updateProfile(updated);
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil actualizado')));
        }, child: profile.loading ? SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : Text('Guardar'))
      ],
    ));
  }
}
