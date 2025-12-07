// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';

class RouteFormScreen extends StatefulWidget {
  final Product? product;
  RouteFormScreen({this.product});
  @override
  _RouteFormScreenState createState() => _RouteFormScreenState();
}

class _RouteFormScreenState extends State<RouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  bool _saving = false;

  @override
  void initState(){
    super.initState();
    _codeCtrl = TextEditingController(text: widget.product?.code ?? '');
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '0');
  }
  @override
  void dispose(){ _codeCtrl.dispose(); _nameCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(()=>_saving=true);
    final prov = Provider.of<ProductsProvider>(context, listen: false);
    final id = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final p = Product(id: id, code: _codeCtrl.text.trim(), name: _nameCtrl.text.trim(), description: widget.product?.description ?? '', price: double.tryParse(_priceCtrl.text) ?? 0.0, imageUrl: widget.product?.imageUrl ?? '', category: 'Rutas', stock: widget.product?.stock ?? 0);
    try {
      if (widget.product == null) await prov.addProduct(p); else await prov.updateProduct(p);
      Navigator.of(context).pop();
    } catch (e) {
      await showDialog(context: context, builder: (ctx)=>AlertDialog(title: Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: ()=>Navigator.of(ctx).pop(), child: Text('OK'))]));
    } finally { if (mounted) setState(()=>_saving=false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(widget.product==null? 'Crear Ruta' : 'Editar Ruta')),
      body: Padding(padding: EdgeInsets.all(12), child: Form(key: _formKey, child: ListView(children: [
        TextFormField(controller: _codeCtrl, decoration: InputDecoration(labelText: 'Código'), validator: (v)=> (v==null||v.trim().isEmpty)?'El código es obligatorio':null),
        SizedBox(height:8),
        TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre'), validator: (v)=> (v==null||v.trim().isEmpty)?'El nombre es obligatorio':null),
        SizedBox(height:8),
        TextFormField(controller: _priceCtrl, decoration: InputDecoration(labelText: 'Precio'), keyboardType: TextInputType.number),
        SizedBox(height:16),
        ElevatedButton(onPressed: _saving?null:_save, child: _saving?CircularProgressIndicator(color: Colors.white):Text('Guardar'))
      ]))),
    );
  }
}
