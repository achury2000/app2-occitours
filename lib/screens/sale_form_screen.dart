// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../providers/clients_provider.dart';
import '../providers/auth_provider.dart';

class SaleFormScreen extends StatefulWidget {
  static const routeName = '/sales/create';
  @override
  _SaleFormScreenState createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _clientId;
  String _clientName = '';
  String _serviceName = '';
  String _amount = '0';
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final clientsProv = Provider.of<ClientsProvider>(context);
    final clients = clientsProv.clients;
    if (_clientId == null && clients.isNotEmpty) { _clientId = clients.first['id']; _clientName = clients.first['name'] ?? ''; }
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Venta')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _formKey, child: Column(children:[
        DropdownButtonFormField<String>(initialValue: _clientId, items: clients.map((c) => DropdownMenuItem(value: c['id'] as String, child: Text('${c['name'] ?? ''} ${c['lastName'] ?? ''}'))).toList(), onChanged: (v){ setState(()=> _clientId = v); final sel = clients.firstWhere((c)=> c['id']==v, orElse: ()=>{}); _clientName = sel['name'] ?? ''; }, decoration: InputDecoration(labelText: 'Cliente'), validator: (v)=> v==null? 'Seleccione cliente' : null),
        SizedBox(height:8), TextFormField(decoration: InputDecoration(labelText: 'Servicio'), validator: (v)=> (v==null||v.trim().isEmpty)? 'Ingrese servicio' : null, onSaved: (v)=> _serviceName = v!.trim()),
        SizedBox(height:8), TextFormField(initialValue: _amount, decoration: InputDecoration(labelText: 'Monto'), keyboardType: TextInputType.number, validator: (v){ if (v==null) return 'Ingrese monto'; final n = double.tryParse(v); if (n==null || n<0) return 'Monto inválido'; return null; }, onSaved: (v)=> _amount = v!.trim()),
        SizedBox(height:8), Row(children:[Text('Fecha:'), SizedBox(width:12), Text('${_date.day}/${_date.month}/${_date.year}'), SizedBox(width:12), ElevatedButton(onPressed: ()=> _pickDate(context), child: Text('Cambiar'))]),
        SizedBox(height:12), Row(children:[ElevatedButton(onPressed: _submit, child: Text('Guardar')), SizedBox(width:12), TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar'))])
      ]))),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(()=> _date = d);
  }

  void _submit(){
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final prov = Provider.of<SalesProvider>(context, listen:false);
    final auth = Provider.of<AuthProvider>(context, listen:false);
    final data = {'clientId': _clientId, 'clientName': _clientName, 'serviceName': _serviceName, 'amount': double.tryParse(_amount) ?? 0.0, 'createdAt': _date.toIso8601String(), 'createdBy': auth.user?.id ?? ''};
    prov.addSale(data, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''}).then((id){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Venta creada: $id'))); Navigator.of(context).pop(); });
  }
}
