// parte isa
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fincas_provider.dart';
import 'finca_form_screen.dart';
import 'fincas_map_screen.dart';
import 'finca_detail_screen.dart';

class FincasManageScreen extends StatefulWidget {
  static const routeName = '/fincas/manage';
  @override
  _FincasManageScreenState createState() => _FincasManageScreenState();
}

class _FincasManageScreenState extends State<FincasManageScreen> {
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FincasProvider>(context, listen: false).loadAll();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 400), () {
      _query = v.trim();
      // simple client-side filter
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fincas'), actions: [IconButton(icon: Icon(Icons.map), tooltip: 'Ver en mapa', onPressed: ()=> Navigator.of(context).pushNamed(FincasMapScreen.routeName))]),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(8), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por nombre o código'), onChanged: _onSearch)),
          Expanded(child: Consumer<FincasProvider>(builder: (ctx, prov, _) {
            if (prov.loading) return Center(child: CircularProgressIndicator());
            final items = prov.items.where((f) => _query.isEmpty || f.name.toLowerCase().contains(_query.toLowerCase()) || f.code.toLowerCase().contains(_query.toLowerCase())).toList();
            if (items.isEmpty) return Center(child: Text('No hay fincas'));
            return ListView.builder(itemCount: items.length, itemBuilder: (ctx, i) {
              final f = items[i];
              return ListTile(
                onTap: ()=> Navigator.of(context).pushNamed(FincaDetailScreen.routeName, arguments: f.id),
                title: Text(f.name),
                subtitle: Text('${f.code} • ${f.location} • \$${f.pricePerNight.toStringAsFixed(0)}'),
                trailing: PopupMenuButton<String>(onSelected: (v) async {
                  if (v == 'edit') Navigator.of(context).push(MaterialPageRoute(builder: (_) => FincaFormScreen(finca: f)));
                  if (v == 'delete') {
                    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text('Confirmar'), content: Text('Eliminar finca "${f.name}"?'), actions: [TextButton(onPressed: ()=>Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=>Navigator.of(ctx).pop(true), child: Text('Eliminar'))]));
                    if (ok ?? false) {
                      try {
                        await prov.deleteFinca(f.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Finca eliminada')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                      }
                    }
                  }
                }, itemBuilder: (_) => [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))]),
              );
            });
          }))
        ],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>FincaFormScreen()))),
    );
  }
}
