// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payments_provider.dart';
import 'payment_detail_screen.dart';

class PaymentsListScreen extends StatefulWidget {
  static const routeName = '/payments';
  @override
  _PaymentsListScreenState createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  String _query = '';
  @override
  void initState(){ super.initState(); WidgetsBinding.instance.addPostFrameCallback((_){ Provider.of<PaymentsProvider>(context, listen:false); }); }
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PaymentsProvider>(context);
    final list = prov.items.where((p) => _query.isEmpty || p.id.toLowerCase().contains(_query.toLowerCase()) || (p.reservationId ?? '').toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: Text('Pagos')),
      body: Column(children:[
        Padding(padding: EdgeInsets.all(12), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por id o reserva'), onChanged: (v)=> setState(()=> _query = v.trim()))),
        Expanded(child: prov.loading ? Center(child: CircularProgressIndicator()) : list.isEmpty ? Center(child: Text('No hay pagos')) : ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_,__)=> Divider(),
          itemBuilder: (ctx,i){ final p = list[i]; return ListTile(title: Text('${p.amount.toStringAsFixed(0)} ${p.currency}'), subtitle: Text('Reserva: ${p.reservationId ?? '-'} • ${p.method} • ${p.status}'), trailing: Icon(Icons.chevron_right), onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> PaymentDetailScreen(paymentId: p.id)))); }
        ))
      ]),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: ()=> Navigator.of(context).pushNamed('/payments/create')),
    );
  }
}
// parte linsaith
// parte juanjo
