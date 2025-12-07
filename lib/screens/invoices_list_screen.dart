// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoices_provider.dart';
import 'invoice_detail_screen.dart';
import 'invoice_create_screen.dart';

class InvoicesListScreen extends StatefulWidget {
  static const routeName = '/invoices';
  @override
  _InvoicesListScreenState createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoicesProvider>(context);
    final list = prov.search(query: _q);
    return Scaffold(appBar: AppBar(title: Text('Facturas')), body: Column(children:[
      Padding(padding: EdgeInsets.all(12), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por id o reserva'), onChanged: (v)=> setState(()=> _q = v.trim()))),
      Expanded(child: prov.loading ? Center(child: CircularProgressIndicator()) : list.isEmpty ? Center(child: Text('No hay facturas')) : ListView.separated(itemCount: list.length, separatorBuilder: (_,__)=> Divider(), itemBuilder: (ctx,i){ final it = list[i]; return ListTile(title: Text(it.id), subtitle: Text('${it.status} • ${it.total} ${it.currency}'), trailing: Icon(Icons.chevron_right), onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> InvoiceDetailScreen(invoiceId: it.id)))); }))
    ]), floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> InvoiceCreateScreen()))));
  }
}
