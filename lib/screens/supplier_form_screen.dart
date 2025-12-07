// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/suppliers_provider.dart';
import '../providers/auth_provider.dart';

class SupplierFormScreen extends StatefulWidget {
  static const routeName = '/suppliers/form';
  @override
  _SupplierFormScreenState createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _id;
  String _name = '';
  String _contact = '';

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _id == null) {
      final prov = Provider.of<SuppliersProvider>(context, listen:false);
      final s = prov.getById(arg);
      if (s != null) { _id = s['id']; _name = s['name'] ?? ''; _contact = s['contact'] ?? ''; }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final prov = Provider.of<SuppliersProvider>(context, listen:false);
    final auth = Provider.of<AuthProvider>(context, listen:false);
    if (_id == null) {
      if (prov.existsByName(_name)) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ya existe un proveedor con ese nombre'))); return; }
      await prov.addSupplier({'name': _name, 'contact': _contact}, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
      Navigator.of(context).pop();
    } else {
      if (prov.existsByName(_name, excludeId: _id)) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ya existe un proveedor con ese nombre'))); return; }
      await prov.updateSupplier(_id!, {'name': _name, 'contact': _contact}, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_id == null ? 'Crear Proveedor' : 'Editar Proveedor')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _formKey, child: Column(children:[
        TextFormField(initialValue: _name, decoration: InputDecoration(labelText: 'Nombre'), validator: (v)=> v==null||v.trim().isEmpty? 'Nombre requerido' : null, onSaved: (v)=> _name = v!.trim()),
        TextFormField(initialValue: _contact, decoration: InputDecoration(labelText: 'Contacto'), onSaved: (v)=> _contact = v ?? ''),
        SizedBox(height:12), Row(children:[ElevatedButton(onPressed: _submit, child: Text('Guardar')), SizedBox(width:12), TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar'))])
      ])))
    );
  }
}
