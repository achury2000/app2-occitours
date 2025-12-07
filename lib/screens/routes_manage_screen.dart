// parte isa
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import 'route_form_screen.dart';
import 'route_detail_screen.dart';

class RoutesManageScreen extends StatefulWidget {
  static const routeName = '/rutas/manage';
  @override
  _RoutesManageScreenState createState() => _RoutesManageScreenState();
}

class _RoutesManageScreenState extends State<RoutesManageScreen> {
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadInitial(category: 'Rutas');
    });
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 400), () {
      _query = v.trim();
      Provider.of<ProductsProvider>(context, listen: false).loadInitial(category: 'Rutas', query: _query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rutas')),
      body: Column(children: [
        Padding(padding: EdgeInsets.all(8), child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por nombre o código'), onChanged: _onSearchChanged)),
        Expanded(child: Consumer<ProductsProvider>(builder: (ctx, prov, _) {
          if (prov.loading) return Center(child: CircularProgressIndicator());
          final items = prov.items.where((p) => p.category == 'Rutas').toList();
          if (items.isEmpty) return Center(child: Text('No hay rutas'));
          return ListView.builder(itemCount: items.length, itemBuilder: (ctx, i) {
            final p = items[i];
            return ListTile(
              title: Text(p.name),
              subtitle: Text('${p.code} • COP ${p.price.toStringAsFixed(0)}'),
              trailing: PopupMenuButton<String>(onSelected: (v) async {
                if (v == 'edit') Navigator.of(context).push(MaterialPageRoute(builder: (_)=>RouteFormScreen(product: p)));
                if (v == 'delete') {
                  final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text('Confirmar'), content: Text('Eliminar ruta "${p.name}"?'), actions: [TextButton(onPressed: ()=>Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=>Navigator.of(ctx).pop(true), child: Text('Eliminar'))]));
                  if (ok ?? false) {
                    try {
                      await prov.deleteProduct(p.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ruta eliminada')));
                    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'))); }
                  }
                }
                if (v == 'view') Navigator.of(context).push(MaterialPageRoute(builder: (_)=>RouteDetailScreen(productId: p.id)));
              }, itemBuilder: (_)=>[PopupMenuItem(value:'view', child: Text('Ver')), PopupMenuItem(value:'edit', child: Text('Editar')), PopupMenuItem(value:'delete', child: Text('Eliminar'))]),
            );
          });
        }))
      ]),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=>RouteFormScreen()))),
    );
  }
}
