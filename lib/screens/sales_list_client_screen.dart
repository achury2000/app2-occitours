// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../providers/auth_provider.dart';

class SalesListClientScreen extends StatefulWidget {
  static const routeName = '/sales/mine';
  @override
  _SalesListClientScreenState createState() => _SalesListClientScreenState();
}

class _SalesListClientScreenState extends State<SalesListClientScreen> {
  String _query = '';
  String _sort = 'date';
  bool _searching = false;
  final TextEditingController _searchCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final prov = Provider.of<SalesProvider>(context);
    final uid = auth.user?.id ?? '';
    List<Map<String,dynamic>> list = prov.salesForClient(uid);
    if (_query.isNotEmpty) list = list.where((s)=> (s['serviceName'] ?? '').toString().toLowerCase().contains(_query.toLowerCase())).toList();
    if (_sort == 'date') list.sort((a,b) => (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));
    else if (_sort == 'amount') list.sort((a,b) => ((b['amount'] ?? 0) as num).compareTo((a['amount'] ?? 0) as num));
    final _currency = NumberFormat.currency(locale: 'es_CO', symbol: 'COP ');

    return Scaffold(
      appBar: AppBar(title: _searching ? TextField(controller: _searchCtl, decoration: InputDecoration(hintText: 'Buscar servicio...', border: InputBorder.none), onChanged: (v){ setState(()=> _query = v.trim()); }) : Text('Mis Ventas'), actions:[IconButton(icon: Icon(_searching? Icons.close : Icons.search), onPressed: (){ setState((){ if (_searching){ _searchCtl.clear(); _query = ''; } _searching = !_searching; }); })]),
      body: Padding(padding: EdgeInsets.all(12), child: Column(children:[
        Row(children:[Text('Ordenar por:'), SizedBox(width:8), DropdownButton<String>(value: _sort, items: [DropdownMenuItem(value:'date', child: Text('Fecha')), DropdownMenuItem(value:'amount', child: Text('Monto'))], onChanged: (v)=> setState(()=> _sort = v ?? 'date'))]),
        SizedBox(height:8),
        Expanded(child: list.isEmpty ? Center(child: Text('No tienes ventas')) : ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_,__)=> SizedBox(height:8),
          itemBuilder: (ctx,i){ final s = list[i]; return Card(child: ListTile(
            title: Text(s['serviceName'] ?? '-'),
            subtitle: Text('Fecha: ${_formatDate(s['createdAt'])} • Estado: ${s['status'] ?? '-'}'),
            trailing: Text(_currency.format((s['amount'] ?? 0))),
            onTap: ()=> Navigator.of(context).pushNamed('/sales/detail', arguments: s['id']),
          )); }
        ))
      ])),
    );
  }

  

  String _formatDate(dynamic raw){ if (raw==null) return '-'; try{ final d = DateTime.parse(raw.toString()); return DateFormat('dd/MM/yyyy', 'es_CO').format(d); } catch(_){ return raw.toString(); }}
}
