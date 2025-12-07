// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class RouteDetailScreen extends StatelessWidget {
  static const routeName = '/rutas/detail';
  final String? productId;
  RouteDetailScreen({this.productId});
  @override
  Widget build(BuildContext context) {
    final id = productId ?? ModalRoute.of(context)!.settings.arguments as String;
    final prov = Provider.of<ProductsProvider>(context);
    late final p;
    try { p = prov.findById(id); } catch (e) { return Scaffold(appBar: AppBar(title: Text('Ruta')), body: Center(child: Text('Ruta no encontrada'))); }

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
        SizedBox(height:8),
        Text('Código: ${p.code}'),
        SizedBox(height:8),
        Text('Categoría: ${p.category}'),
        SizedBox(height:8),
        Text('Precio: COP ${p.price.toStringAsFixed(0)}'),
        SizedBox(height:12),
        Text(p.description),
      ])),
    );
  }
}
