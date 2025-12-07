// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/itinerary.dart';
import '../providers/itineraries_provider.dart';

class ItineraryCreateScreen extends StatefulWidget {
  @override
  _ItineraryCreateScreenState createState() => _ItineraryCreateScreenState();
}

class _ItineraryCreateScreenState extends State<ItineraryCreateScreen> {
  final _form = GlobalKey<FormState>();
  String _title = '';
  String _desc = '';
  String _routeIds = '';
  String _fincaIds = '';
  int _duration = 0;
  double _price = 0.0;
  bool _loading = false;

  void _save() async {
    final valid = _form.currentState?.validate() ?? false;
    if (!valid) return;
    _form.currentState?.save();
    setState(()=> _loading = true);
    final id = Uuid().v4();
    final it = Itinerary(id: id, title: _title, description: _desc, routeIds: _routeIds.split(',').map((s)=> s.trim()).where((s)=> s.isNotEmpty).toList(), fincaIds: _fincaIds.split(',').map((s)=> s.trim()).where((s)=> s.isNotEmpty).toList(), durationMinutes: _duration, price: _price);
    try{
      await Provider.of<ItinerariesProvider>(context, listen:false).addItinerary(it, actor: {'id':'system','name':'app'});
      Navigator.of(context).pop(true);
    }catch(e){ setState(()=> _loading = false); showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))])); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Crear Itinerario')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _form, child: SingleChildScrollView(child: Column(children:[
        TextFormField(decoration: InputDecoration(labelText: 'Título'), validator: (v)=> (v==null||v.trim().isEmpty) ? 'Requerido' : null, onSaved: (v)=> _title = v!.trim()),
        TextFormField(decoration: InputDecoration(labelText: 'Descripción'), onSaved: (v)=> _desc = v ?? ''),
        TextFormField(decoration: InputDecoration(labelText: 'Route IDs (coma separadas)'), onSaved: (v)=> _routeIds = v ?? ''),
        TextFormField(decoration: InputDecoration(labelText: 'Finca IDs (coma separadas)'), onSaved: (v)=> _fincaIds = v ?? ''),
        TextFormField(decoration: InputDecoration(labelText: 'Duración (min)'), keyboardType: TextInputType.number, onSaved: (v)=> _duration = int.tryParse(v ?? '0') ?? 0),
        TextFormField(decoration: InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number, onSaved: (v)=> _price = double.tryParse(v ?? '0') ?? 0.0),
        SizedBox(height:12), _loading ? CircularProgressIndicator() : ElevatedButton(child: Text('Crear'), onPressed: _save)
      ])))));
  }
}
