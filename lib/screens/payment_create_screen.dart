// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment.dart';
import '../providers/payments_provider.dart';
import '../providers/reservations_provider.dart';

class PaymentCreateScreen extends StatefulWidget {
  static const routeName = '/payments/create';
  final String? reservationId;
  PaymentCreateScreen({this.reservationId});
  @override
  _PaymentCreateScreenState createState() => _PaymentCreateScreenState();
}

class _PaymentCreateScreenState extends State<PaymentCreateScreen> {
  final _form = GlobalKey<FormState>();
  String _method = 'card';
  String _currency = 'USD';
  double _amount = 0.0;
  bool _loading = false;

  void _save() async{
    final valid = _form.currentState?.validate() ?? false;
    if(!valid) return;
    _form.currentState?.save();
    setState(()=> _loading = true);
    final payment = Payment(id: DateTime.now().millisecondsSinceEpoch.toString(), reservationId: widget.reservationId, amount: _amount, currency: _currency, method: _method, status: 'completed', timestamp: DateTime.now(), metadata: {});
    try{
      await Provider.of<PaymentsProvider>(context, listen:false).addPayment(payment, actor: {'id':'system','name':'app'});
      // If the payment references a reservation, mark it as paid
      if (payment.reservationId != null && payment.reservationId!.isNotEmpty) {
        try{
          await Provider.of<ReservationsProvider>(context, listen:false).setReservationStatus(payment.reservationId!, 'Pagada', actor: {'id':'system','name':'app'}, reason: 'Pago registrado');
        } catch(_){ /* non-fatal */ }
      }
      Navigator.of(context).pop(true);
    }catch(e){
      setState(()=> _loading = false);
      showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Nuevo Pago')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _form, child: Column(children:[
        TextFormField(initialValue: widget.reservationId, decoration: InputDecoration(labelText: 'Reserva ID'), onSaved: (v)=> null),
        TextFormField(decoration: InputDecoration(labelText: 'Monto'), keyboardType: TextInputType.number, validator: (v){ if(v==null||v.trim().isEmpty) return 'Ingrese monto'; final n = double.tryParse(v); if(n==null||n<=0) return 'Monto inválido'; return null; }, onSaved: (v)=> _amount = double.parse(v!)),
        DropdownButtonFormField<String>(initialValue: _currency, items: ['USD','EUR','PEN'].map((c)=> DropdownMenuItem(child: Text(c), value: c)).toList(), onChanged: (v)=> setState(()=> _currency = v ?? _currency), decoration: InputDecoration(labelText: 'Moneda')),
        DropdownButtonFormField<String>(initialValue: _method, items: ['card','cash','transfer'].map((m)=> DropdownMenuItem(child: Text(m), value: m)).toList(), onChanged: (v)=> setState(()=> _method = v ?? _method), decoration: InputDecoration(labelText: 'Método')),
        SizedBox(height:12),
        _loading ? CircularProgressIndicator() : ElevatedButton(child: Text('Crear Pago'), onPressed: _save)
      ]))),
    );
  }
}
