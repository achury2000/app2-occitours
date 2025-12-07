// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/itineraries_provider.dart';
import 'itinerary_detail_screen.dart';
import 'itinerary_create_screen.dart';

class ItinerariesListScreen extends StatefulWidget {
  static const routeName = '/itineraries';
  @override
  _ItinerariesListScreenState createState() => _ItinerariesListScreenState();
}

class _ItinerariesListScreenState extends State<ItinerariesListScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ItinerariesProvider>(context);
    final list = prov.search(query: _q);
    return Scaffold(appBar: AppBar(title: Text('Itinerarios')), body: Column(children:[
      Padding(padding: EdgeInsets.all(12), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar'), onChanged: (v)=> setState(()=> _q = v.trim()))),
      Expanded(child: prov.loading ? Center(child: CircularProgressIndicator()) : list.isEmpty ? Center(child: Text('No hay itinerarios')) : ListView.separated(itemCount: list.length, separatorBuilder: (_,__)=> Divider(), itemBuilder: (ctx,i){ final it = list[i]; return ListTile(title: Text(it.title), subtitle: Text('${it.durationMinutes} min • ${it.price.toStringAsFixed(2)}'), trailing: Icon(Icons.chevron_right), onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ItineraryDetailScreen(itineraryId: it.id)))); }))
    ]), floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ItineraryCreateScreen()))));
  }
}
