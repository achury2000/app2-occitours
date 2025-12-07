// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class LowStockScreen extends StatelessWidget {
  static const routeName = '/products/lowstock';
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProductsProvider>(context);
    final list = prov.lowStockItems();
    return Scaffold(
      appBar: AppBar(title: Text('Productos con stock bajo')),
      body: Padding(padding: EdgeInsets.all(12), child: list.isEmpty ? Center(child: Text('No hay productos con stock bajo')) : ListView.separated(
        itemBuilder: (ctx,i){
          final p = list[i];
          return Card(
            child: ListTile(
              title: Text(p.name),
              subtitle: Text('Stock: ${p.stock} • Umbral: ${prov.reorderLevelFor(p.id)}'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => showDialog(context: context, builder: (_) {
                final hist = prov.stockHistoryFor(p.id);
                return AlertDialog(
                  title: Text(p.name),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stock actual: ${p.stock}'),
                      SizedBox(height:8),
                      Text('Historial reciente:'),
                      SizedBox(height:8),
                      Container(
                        height:150,
                        width:300,
                        child: ListView(
                          children: hist.take(10).map((h) => ListTile(
                            title: Text('${h['timestamp'] ?? ''}'),
                            subtitle: Text('De ${h['previous']} a ${h['new']} • ${h['reason'] ?? ''}'),
                          )).toList(),
                        ),
                      )
                    ],
                  ),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cerrar'))],
                );
              }),
            ),
          );
        }, separatorBuilder: (_,__)=> SizedBox(height:8), itemCount: list.length
      ))
    );
  }
}
