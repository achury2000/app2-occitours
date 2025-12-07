// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchases_provider.dart';
import '../providers/products_provider.dart';
import '../providers/suppliers_provider.dart';
import '../providers/auth_provider.dart';

class PurchaseCreateScreen extends StatefulWidget {
  static const routeName = '/purchases/create';
  @override
  _PurchaseCreateScreenState createState() => _PurchaseCreateScreenState();
}

class _PurchaseCreateScreenState extends State<PurchaseCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _productId;
  String? _supplierId;
  String _quantity = '1';
  String _unitPrice = '0';

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final purchasesProv = Provider.of<PurchasesProvider>(context, listen: false);
    final productsProv = Provider.of<ProductsProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final prod = productsProv.findById(_productId!);
    final supplier = Provider.of<SuppliersProvider>(context, listen: false).getById(_supplierId!);
    final data = {
      'productId': _productId,
      'productName': prod?.name ?? '',
      'supplierId': _supplierId,
      'supplierName': supplier?['name'] ?? '',
      'quantity': int.tryParse(_quantity) ?? 1,
      'unitPrice': double.tryParse(_unitPrice) ?? 0.0,
      'status': 'Pendiente',
      'createdAt': DateTime.now().toIso8601String()
    };
    final id = await purchasesProv.addPurchase(data, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compra creada: $id')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final suppliersProv = Provider.of<SuppliersProvider>(context);
    final products = productsProv.items;
    final suppliers = suppliersProv.suppliers;
    if (_productId == null && products.isNotEmpty) _productId = products.first.id;
    if (_supplierId == null && suppliers.isNotEmpty) _supplierId = suppliers.first['id'] as String?;
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Compra')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _formKey, child: Column(children:[
        DropdownButtonFormField<String>(
          initialValue: products.isNotEmpty ? products.first.id : null,
          items: products.map((p)=> DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
          onChanged: (v)=> setState(()=> _productId = v),
          decoration: InputDecoration(labelText: 'Producto'),
          validator: (v)=> v==null? 'Seleccione un producto': null,
          onSaved: (v)=> _productId = v,
        ),
        SizedBox(height:8),
        DropdownButtonFormField<String>(
          initialValue: suppliers.isNotEmpty ? (suppliers.first['id'] ?? null) : null,
          items: suppliers.map((s)=> DropdownMenuItem(value: s['id'] as String, child: Text(s['name'] ?? '-'))).toList(),
          onChanged: (v)=> setState(()=> _supplierId = v),
          decoration: InputDecoration(labelText: 'Proveedor'),
          validator: (v)=> v==null? 'Seleccione un proveedor': null,
          onSaved: (v)=> _supplierId = v,
        ),
        SizedBox(height:8),
        TextFormField(initialValue: _quantity, decoration: InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number, validator: (v){
          if (v == null) return 'Ingrese cantidad válida';
          final n = int.tryParse(v.trim());
          if (n == null || n <= 0) return 'La cantidad debe ser mayor a 0';
          return null;
        }, onSaved: (v)=> _quantity = v!.trim()),
        SizedBox(height:8),
        TextFormField(initialValue: _unitPrice, decoration: InputDecoration(labelText: 'Precio unitario'), keyboardType: TextInputType.number, validator: (v){
          if (v == null) return 'Ingrese precio válido';
          final n = double.tryParse(v.trim());
          if (n == null || n < 0) return 'El precio debe ser 0 o mayor';
          return null;
        }, onSaved: (v)=> _unitPrice = v!.trim()),
        SizedBox(height:12), Row(children:[ElevatedButton(onPressed: _submit, child: Text('Crear')), SizedBox(width:12), TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cancelar'))])
      ])))
    );
  }
}
