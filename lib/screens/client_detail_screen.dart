// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/clients_provider.dart';
import '../providers/sales_provider.dart';
import '../providers/auth_provider.dart';

class ClientDetailScreen extends StatelessWidget {
  static const routeName = '/clients/detail';
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = arg is String ? arg : null;
    if (id == null) return Scaffold(appBar: AppBar(title: Text('Cliente')), body: Center(child: Text('Cliente no encontrado')));
    final prov = Provider.of<ClientsProvider>(context);
    final client = prov.getById(id);
    if (client == null) return Scaffold(appBar: AppBar(title: Text('Cliente')), body: Center(child: Text('Cliente no encontrado')));
    final salesProv = Provider.of<SalesProvider>(context);
    final sales = salesProv.search(clientId: id);
    final auth = Provider.of<AuthProvider>(context, listen:false);

    return Scaffold(
      appBar: AppBar(title: Text('Detalle Cliente')),
      body: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(client['name'] ?? '-', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
        SizedBox(height:8), Text('Email: ${client['email'] ?? '-'}'),
        SizedBox(height:4), Text('Teléfono: ${client['phone'] ?? '-'}'),
        SizedBox(height:4), Text('Dirección: ${client['address'] ?? '-'}'),
        SizedBox(height:8), Row(children:[Text('Estado: '), Text((client['active'] ?? true) ? 'Activo' : 'Bloqueado')]),
        SizedBox(height:12), Row(children:[
          ElevatedButton(onPressed: () async {
            // toggle active
            final currently = client['active'] ?? true;
            final confirm = await showDialog<bool>(context: context, builder: (_)=> AlertDialog(title: Text(currently? 'Bloquear cliente' : 'Activar cliente'), content: Text('Confirmar?'), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(context).pop(true), child: Text('Si'))]));
            if (confirm != true) return;
            await prov.setActive(id, !currently, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cliente actualizado')));
          }, child: Text((client['active'] ?? true) ? 'Bloquear' : 'Activar')),
          SizedBox(width:12), ElevatedButton(onPressed: ()=> _showSales(context, sales), child: Text('Historial (${sales.length})'))
        ]),
      ])),
    );
  }

  void _showSales(BuildContext context, List<Map<String,dynamic>> sales){
    final currency = NumberFormat.currency(locale: 'es_CO', symbol: 'COP ');
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Historial de compras'),
      content: Container(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: sales.length,
          separatorBuilder: (_,__) => Divider(),
          itemBuilder: (ctx,i){
            final s = sales[i];
            return ListTile(
              title: Text(s['serviceName'] ?? '-'),
              subtitle: Text(s['createdAt'] ?? ''),
              trailing: Text(currency.format((s['amount'] ?? 0))),
            );
          }
        )
      ),
      actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))],
    ));
  }
}
