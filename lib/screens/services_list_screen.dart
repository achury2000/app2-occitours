// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/services_provider.dart';
import '../providers/auth_provider.dart';

class ServicesListScreen extends StatefulWidget {
  static const routeName = '/services';
  @override
  _ServicesListScreenState createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ServicesProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final list = prov.search(query: _query);
    return Scaffold(
      appBar: AppBar(title: Text('Servicios')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar servicios...'), onChanged: (v)=> setState(()=> _query = v.trim())),
          SizedBox(height:12),
          Expanded(child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_,__)=> SizedBox(height:8),
            itemBuilder: (ctx,i){ final s = list[i]; return Card(child: ListTile(title: Text(s.name), subtitle: Text('${s.durationMinutes} min • ${s.capacity} pax • ${s.active? 'Activo' : 'Inactivo'}'), trailing: Icon(Icons.chevron_right), onTap: ()=> Navigator.of(context).pushNamed('/services/detail', arguments: s.id))); }
          ))
        ])
      ),
      floatingActionButton: auth.hasAnyRole(['admin']) ? FloatingActionButton(child: Icon(Icons.add), onPressed: ()=> Navigator.of(context).pushNamed('/services/create')) : null,
    );
  }
}

