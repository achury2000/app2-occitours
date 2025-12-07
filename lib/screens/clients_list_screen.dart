// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// intl not required here yet
import '../providers/clients_provider.dart';
import '../providers/auth_provider.dart';

class ClientsListScreen extends StatefulWidget {
  static const routeName = '/clients';
  @override
  _ClientsListScreenState createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  String _query = '';
  bool _onlyActive = false;
  final _ctl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ClientsProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final list = prov.searchClients(query: _query, active: _onlyActive ? true : null);
    

    return Scaffold(
      appBar: AppBar(title: Text('Clientes'), actions: [
        IconButton(icon: Icon(Icons.download), onPressed: (){
          final csv = prov.exportCsv();
          showDialog(context: context, builder: (_){ return AlertDialog(title: Text('CSV de clientes'), content: SingleChildScrollView(child: SelectableText(csv)), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))]); });
        })
      ]),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          Row(children:[
            Expanded(child: TextField(controller: _ctl, decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por nombre/email/telefono'), onChanged: (v) => setState(()=> _query = v.trim()))),
            SizedBox(width:8), Column(children:[Text('Activos'), Switch(value: _onlyActive, onChanged: (v)=> setState(()=> _onlyActive = v))])
          ]),
          SizedBox(height:12),
          Expanded(child: list.isEmpty ? Center(child: Text('No hay clientes')) : ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_,__)=> SizedBox(height:8),
            itemBuilder: (ctx,i){ final c = list[i]; return Card(child: ListTile(
              title: Text(c['name'] ?? '-'),
              subtitle: Text('${c['email'] ?? ''} • ${c['phone'] ?? ''}'),
              trailing: Text((c['active'] ?? true) ? 'Activo' : 'Bloqueado'),
              onTap: ()=> Navigator.of(context).pushNamed('/clients/detail', arguments: c['id']),
            )); }
          ))
        ])
      ),
      floatingActionButton: auth.hasAnyRole(['admin']) ? FloatingActionButton(child: Icon(Icons.add), onPressed: ()=> Navigator.of(context).pushNamed('/clients/create')) : null,
    );
  }
}
