// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchases_provider.dart';
import '../widgets/admin_only.dart';

class PurchasesListScreen extends StatelessWidget {
  static const routeName = '/purchases';
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PurchasesProvider>(context);
    final list = List<Map<String,dynamic>>.from(prov.purchases);
    // order by createdAt desc when possible
    list.sort((a,b){
      try{ final da = DateTime.parse(a['createdAt'] ?? '1970-01-01'); final db = DateTime.parse(b['createdAt'] ?? '1970-01-01'); return db.compareTo(da);} catch(_){ return 0; }
    });
    return Scaffold(
      appBar: AppBar(title: Text('Compras')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          AdminOnly(child: ElevatedButton(onPressed: ()=> Navigator.of(context).pushNamed('/purchases/create'), child: Text('Nueva Compra'))),
          SizedBox(height:12),
          Expanded(child: list.isEmpty ? Center(child: Text('No hay compras registradas')) : ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_,__)=>SizedBox(height:8),
            itemBuilder: (ctx,i){ final p = list[i]; return Card(child: ListTile(
              title: Text(p['productName'] ?? p['productId'] ?? '-'),
              subtitle: Text('${p['supplierName'] ?? '-'} • Cantidad: ${p['quantity'] ?? 0} • Estado: ${p['status'] ?? '-'}\n${_formatDate(p['createdAt'])}'),
              isThreeLine: true,
              trailing: Icon(Icons.chevron_right),
              onTap: ()=> Navigator.of(context).pushNamed('/purchases/detail', arguments: p['id']),
            )); }
          ))
        ])
      ),
    );
  }

  String _formatDate(dynamic raw){
    if (raw == null) return '';
    try{
      final d = DateTime.parse(raw.toString());
      return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
    } catch(_){ return raw.toString(); }
  }
}
