import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients_provider.dart';

class ClientsRegisterScreen extends StatefulWidget {
  static const routeName = '/clients/register';
  @override
  _ClientsRegisterScreenState createState() => _ClientsRegisterScreenState();
}

class _ClientsRegisterScreenState extends State<ClientsRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose(){ _name.dispose(); _email.dispose(); _phone.dispose(); super.dispose(); }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = Provider.of<ClientsProvider>(context, listen: false);
    final data = {'name': _name.text, 'email': _email.text, 'phone': _phone.text, 'segment': 'General'};
    final id = await prov.addClient(data);
    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Cliente creado'), content: Text('ID: $id'), actions: [TextButton(onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); }, child: Text('OK'))]));
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ClientsProvider>(context);
    return Scaffold(appBar: AppBar(title: Text('Registro de Cliente')), body: prov.loading ? Center(child: CircularProgressIndicator()) : Padding(padding: EdgeInsets.all(16), child: ListView(children:[
      Card(child: Padding(padding: EdgeInsets.all(12), child: Form(key:_formKey, child: Column(children:[
        TextFormField(controller: _name, decoration: InputDecoration(labelText: 'Nombre completo'), validator: (v)=> v==null||v.isEmpty? 'Requerido':null),
        SizedBox(height:8),
        TextFormField(controller: _email, decoration: InputDecoration(labelText: 'Correo'), keyboardType: TextInputType.emailAddress, validator: (v){ if(v==null||v.isEmpty) return 'Requerido'; if(!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(v)) return 'Email inválido'; return null;}),
        SizedBox(height:8),
        TextFormField(controller: _phone, decoration: InputDecoration(labelText: 'Teléfono')),
        SizedBox(height:12),
        Text('Historial de reservas', style: TextStyle(fontWeight: FontWeight.w700)),
        SizedBox(height:8),
        Container(height:120, child: ListView(children: [ListTile(title: Text('Reserva R1001'), subtitle: Text('2025-10-10')), ListTile(title: Text('Reserva R1002'), subtitle: Text('2025-08-02'))])),
        SizedBox(height:12),
        Row(children:[Expanded(child: ElevatedButton(onPressed: _save, child: Text('Guardar'))), SizedBox(width:8), OutlinedButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar'))])
      ]))))
    ])));
  }
}
