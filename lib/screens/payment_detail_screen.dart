// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payments_provider.dart';

class PaymentDetailScreen extends StatelessWidget {
  static const routeName = '/payments/detail';
  final String? paymentId;
  PaymentDetailScreen({this.paymentId});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PaymentsProvider>(context);
    final id = paymentId ?? ModalRoute.of(context)?.settings.arguments as String?;
    if (id == null) return Scaffold(appBar: AppBar(title: Text('Pago')), body: Center(child: Text('Pago no especificado')));
    final p = prov.findById(id);
    if(p==null) return Scaffold(appBar: AppBar(title: Text('Pago')), body: Center(child: Text('No encontrado')));
    return Scaffold(appBar: AppBar(title: Text('Pago ${p.id}')),
      body: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text('ID: ${p.id}'),
        SizedBox(height:8),
        Text('Reserva: ${p.reservationId ?? '-'}'),
        SizedBox(height:8),
        Text('Monto: ${p.amount} ${p.currency}'),
        SizedBox(height:8),
        Text('Método: ${p.method}'),
        SizedBox(height:8),
        Text('Estado: ${p.status}'),
        SizedBox(height:8),
        Text('Fecha: ${p.timestamp}')
      ]))
    );
  }
}
