// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../providers/invoices_provider.dart';

class InvoiceCreateScreen extends StatefulWidget {
  @override
  _InvoiceCreateScreenState createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  final _form = GlobalKey<FormState>();
  String _reservationIds = '';
  String _items = '';
  double _total = 0.0;
  String _currency = 'USD';
  bool _loading = false;

  void _save() async {
    final valid = _form.currentState?.validate() ?? false;
    if (!valid) return;
    _form.currentState?.save();
    setState(()=> _loading = true);
    final id = Uuid().v4();
    final itemList = _items.split(';').map((s){ final parts = s.split('|'); return InvoiceItem(description: parts[0].trim(), quantity: parts.length>1 ? int.tryParse(parts[1]) ?? 1 : 1, unitPrice: parts.length>2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0); }).toList();
    final inv = Invoice(id: id, reservationIds: _reservationIds.split(',').map((s)=> s.trim()).where((s)=> s.isNotEmpty).toList(), items: itemList, total: _total, currency: _currency, status: 'issued');
    try{
      await Provider.of<InvoicesProvider>(context, listen:false).addInvoice(inv, actor: {'id':'system','name':'app'});
      Navigator.of(context).pop(true);
    }catch(e){ setState(()=> _loading = false); showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))])); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Crear Factura')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _form, child: SingleChildScrollView(child: Column(children:[
        TextFormField(decoration: InputDecoration(labelText: 'Reservation IDs (coma separadas)'), onSaved: (v)=> _reservationIds = v ?? ''),
        TextFormField(decoration: InputDecoration(labelText: 'Items (desc|qty|unitPrice; desc2|qty2|unitPrice2)'), onSaved: (v)=> _items = v ?? ''),
        TextFormField(decoration: InputDecoration(labelText: 'Total'), keyboardType: TextInputType.number, validator: (v){ if (v==null||v.trim().isEmpty) return 'Requerido'; if (double.tryParse(v)==null) return 'Número inválido'; return null; }, onSaved: (v)=> _total = double.tryParse(v ?? '0') ?? 0.0),
        DropdownButtonFormField<String>(initialValue: _currency, items: ['USD','EUR','COP'].map((c)=> DropdownMenuItem(child: Text(c), value: c)).toList(), onChanged: (v)=> setState(()=> _currency = v ?? _currency), decoration: InputDecoration(labelText: 'Moneda')),
        SizedBox(height:12), _loading ? CircularProgressIndicator() : ElevatedButton(child: Text('Crear Factura'), onPressed: _save)
      ])))));
  }
}
