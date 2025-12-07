// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchases_provider.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';
import '../models/product.dart';

class PurchaseDetailScreen extends StatelessWidget {
  static const routeName = '/purchases/detail';
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = arg is String ? arg : null;
    if (id == null) return Scaffold(appBar: AppBar(title: Text('Compra')), body: Center(child: Text('Compra no encontrada')));
    final prov = Provider.of<PurchasesProvider>(context);
    final purchase = prov.purchases.firstWhere((p) => p['id'] == id, orElse: ()=> {});
    if (purchase.isEmpty) return Scaffold(appBar: AppBar(title: Text('Compra')), body: Center(child: Text('Compra no encontrada')));
    final auth = Provider.of<AuthProvider>(context, listen:false);
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Compra')),
      body: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(purchase['productName'] ?? '-', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
        SizedBox(height:8), Text('Proveedor: ${purchase['supplierName'] ?? '-'}'),
        SizedBox(height:6), Text('Cantidad: ${purchase['quantity'] ?? 0}'),
        SizedBox(height:6), Text('Precio unitario: COP ${((purchase['unitPrice'] ?? 0) as num).toStringAsFixed(0)}'),
        SizedBox(height:6), Text('Estado: ${purchase['status'] ?? '-'}'),
        Spacer(), Row(children:[
          ElevatedButton(onPressed: () async {
            // mark as received: increase product stock
            if ((purchase['status'] ?? '').toString().toLowerCase() == 'recibido') {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La compra ya está recibida')));
              return;
            }
            final confirm = await showDialog<bool>(context: context, builder: (ctx)=> AlertDialog(title: Text('Marcar como recibido'), content: Text('¿Confirmar recepción de la compra?'), actions: [TextButton(onPressed: ()=> Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(ctx).pop(true), child: Text('Confirmar'))]));
            if (confirm == true) {
              final productsProv = Provider.of<ProductsProvider>(context, listen:false);
              try {
                final prod = productsProv.findById(purchase['productId']);
                if (prod == null) throw Exception('Producto no encontrado');
                final prodNonNull = prod;
                final int qty = (purchase['quantity'] is int) ? purchase['quantity'] as int : int.tryParse('${purchase['quantity']}') ?? 0;
                final newStock = prodNonNull.stock + qty;
                // build updated Product
                final updated = Product(id: prodNonNull.id, code: prodNonNull.code, name: prodNonNull.name, description: prodNonNull.description, price: prodNonNull.price, imageUrl: prodNonNull.imageUrl, category: prodNonNull.category, stock: newStock, variants: prodNonNull.variants, popularity: prodNonNull.popularity);
                await productsProv.updateProduct(updated, reason: 'Recepción compra $id', actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
                await prov.setPurchaseStatus(id, 'Recibido', actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compra marcada como recibida y stock actualizado')));
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al recibir compra: $e')));
              }
            }
          }, child: Text('Marcar como recibido')),
          SizedBox(width:12),
          ElevatedButton(onPressed: () async {
            final confirm = await showDialog<bool>(context: context, builder: (ctx)=> AlertDialog(title: Text('Eliminar compra'), content: Text('¿Eliminar esta compra?'), actions: [TextButton(onPressed: ()=> Navigator.of(ctx).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(ctx).pop(true), child: Text('Eliminar'))]));
            if (confirm == true) {
              await prov.deletePurchase(id, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compra eliminada')));
              Navigator.of(context).pop();
            }
          }, child: Text('Eliminar', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.red))
        ])
      ]))
    );
  }

  // no helpers needed; copying handled inline in receive flow
}
