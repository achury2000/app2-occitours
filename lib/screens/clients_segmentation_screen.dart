import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients_provider.dart';

class ClientsSegmentationScreen extends StatefulWidget {
  static const routeName = '/clients/segmentation';
  @override
  _ClientsSegmentationScreenState createState() => _ClientsSegmentationScreenState();
}

class _ClientsSegmentationScreenState extends State<ClientsSegmentationScreen> {
  String _filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ClientsProvider>(context);
    if (prov.loading) return Scaffold(appBar: AppBar(title: Text('Segmentación de Clientes')), body: Center(child: CircularProgressIndicator()));
    final clients = prov.clients;
    final segments = <String>{'Todos'}..addAll(clients.map((c) => (c['segment'] ?? 'General').toString()));
    final filtered = clients.where((c) => _filter == 'Todos' ? true : (c['segment'] ?? 'General') == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Segmentación de Clientes')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          Row(children:[
            Expanded(child: DropdownButtonFormField<String>(initialValue: _filter, items: segments.map((s)=> DropdownMenuItem(child: Text(s), value: s)).toList(), onChanged: (v)=> setState(()=> _filter = v ?? 'Todos'), decoration: InputDecoration(labelText: 'Segmento'))),
            SizedBox(width:12),
            ElevatedButton(onPressed: ()=> setState(()=> {}), child: Text('Filtrar'))
          ]),
          SizedBox(height:12),
          Expanded(child: ListView(children:[
            Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Segmentos', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), Text('Clientes en segmento: ${filtered.length}'), Container(height:150, color: Colors.grey[200], child: Center(child: Text('Gráfico placeholder')))]))),
            Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Clientes filtrados', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:8), ...filtered.map((c)=> ListTile(title: Text(c['name'] ?? '-'), subtitle: Text('${c['email'] ?? ''} • ${c['segment'] ?? ''}'))).toList()]))),
          ]))
        ])
      ),
    );
  }
}
