import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clients_provider.dart';

class ClientsCampaignsScreen extends StatefulWidget {
  static const routeName = '/clients/campaigns';
  @override
  _ClientsCampaignsScreenState createState() => _ClientsCampaignsScreenState();
}

class _ClientsCampaignsScreenState extends State<ClientsCampaignsScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose(){ _title.dispose(); _desc.dispose(); super.dispose(); }

  void _create() async {
    if (_title.text.isEmpty) return;
    final prov = Provider.of<ClientsProvider>(context, listen: false);
    await prov.addCampaign({'title': _title.text, 'description': _desc.text});
    _title.clear();
    _desc.clear();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ClientsProvider>(context);
    if (prov.loading) return Scaffold(appBar: AppBar(title: Text('Fidelización y Campañas')), body: Center(child: CircularProgressIndicator()));
    final campaigns = prov.campaigns;
    return Scaffold(appBar: AppBar(title: Text('Fidelización y Campañas')), body: Padding(padding: EdgeInsets.all(12), child: Column(children:[
      Card(child: Padding(padding: EdgeInsets.all(12), child: Column(children:[TextFormField(controller: _title, decoration: InputDecoration(labelText: 'Título')), SizedBox(height:8), TextFormField(controller: _desc, decoration: InputDecoration(labelText: 'Descripción'), maxLines:2), SizedBox(height:8), Row(children:[Expanded(child: ElevatedButton(onPressed: _create, child: Text('Crear campaña')))])]))),
      SizedBox(height:12),
      Expanded(
        child: campaigns.isEmpty
            ? Center(child: Text('No hay campañas activas'))
            : ListView.separated(
                itemCount: campaigns.length,
                separatorBuilder: (_, __) => SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final c = campaigns[i];
                  return Card(
                    child: ListTile(
                      title: Text(c['title'] ?? ''),
                      subtitle: Text(c['description'] ?? ''),
                      trailing: TextButton(onPressed: () => {}, child: Text('Ver métricas')),
                    ),
                  );
                },
              ),
      ),
    ]),
    ),
    );
  }
}
