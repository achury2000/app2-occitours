// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductsCsvScreen extends StatefulWidget {
  static const routeName = '/products/csv';
  @override
  _ProductsCsvScreenState createState() => _ProductsCsvScreenState();
}

class _ProductsCsvScreenState extends State<ProductsCsvScreen> {
  final _controller = TextEditingController();

  @override
  void dispose(){ _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Import / Export Productos (CSV)')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(children:[
          Row(children:[
            ElevatedButton(onPressed: (){
              final csv = prov.exportCsv();
              showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Exportar CSV'), content: SizedBox(width:500, height:300, child: SingleChildScrollView(child: SelectableText(csv))), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))]));
            }, child: Text('Exportar')),
            SizedBox(width:12),
            ElevatedButton(onPressed: (){ _controller.text = ''; showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Importar CSV'), content: Column(mainAxisSize: MainAxisSize.min, children: [Text('Pegue el CSV aquí (id,code,name,category,price,stock)'), SizedBox(height:8), TextField(controller: _controller, maxLines: 8, decoration: InputDecoration(border: OutlineInputBorder()))]), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar')), TextButton(onPressed: () async { Navigator.of(context).pop(); await prov.importFromCsv(_controller.text); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Importación finalizada'))); }, child: Text('Importar'))])); }, child: Text('Importar'))
          ]),
          SizedBox(height:12),
          Expanded(child: Text('Nota: la importación simple busca coincidencias por `id` o `code` y actualiza registros si existen. Evita CSV complejos con comillas.') )
        ])
      )
    );
  }
}
