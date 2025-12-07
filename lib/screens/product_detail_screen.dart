// **Pantalla**: Detalle del producto.
// Muestra información completa del producto/recorrido, galería, stock y acciones de reserva.
// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'reservations_flow_screen.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  String? _variant;

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id == null) return Scaffold(body: Center(child: Text('Producto no especificado')));

    final prodProv = Provider.of<ProductsProvider>(context, listen: false);
    Product? product;
    try {
      product = prodProv.findById(id);
    } catch (e) {
      product = null;
    }

    if (product == null) return Scaffold(body: Center(child: Text('Producto no encontrado')));

    final p = product;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(p.imageUrl, height: 200, fit: BoxFit.cover, width: double.infinity),
              SizedBox(height: 8),
              Text(p.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('COP ${p.price.toStringAsFixed(0)}'),
              SizedBox(height: 12),
              Text(p.description),
              SizedBox(height:12),
              // Detalles adicionales para enriquecer la descripción de la ruta
              Card(
                margin: EdgeInsets.symmetric(vertical:8),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Itinerario', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height:6),
                    Text('- Punto de encuentro y registro\n- Recorrido guiado y paradas de interés\n- Actividad principal y tiempo para preguntas\n- Retorno y despedida', style: TextStyle(height:1.4)),
                    SizedBox(height:8),
                    Text('Incluye', style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height:6),
                    Wrap(spacing:8, children: [Chip(label: Text('Guía experto')), Chip(label: Text('Seguro básico')), Chip(label: Text('Transporte parcial'))]),
                    SizedBox(height:8),
                    Row(children:[Text('Duración:', style: TextStyle(fontWeight: FontWeight.w600)), SizedBox(width:8), Text('3-4 horas')])
                  ]),
                ),
              ),
              SizedBox(height:8),
              Card(
                margin: EdgeInsets.symmetric(vertical:8),
                child: Padding(padding: EdgeInsets.all(12), child: Row(children:[
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text('Control de Stock', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:6), Text('Stock actual: ${p.stock}')])),
                  Column(children:[
                    Text('Umbral'),
                    SizedBox(height:6),
                    ElevatedButton(onPressed: () async {
                      final prov = Provider.of<ProductsProvider>(context, listen: false);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      // solo administradores pueden establecer el umbral de reorden
                      final role = (auth.user?.role ?? '').toLowerCase();
                      if (role != 'admin'){
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Acceso denegado: solo administradores pueden cambiar el umbral')));
                        return;
                      }
                      final current = prov.reorderLevelFor(p.id);
                      final txtCtrl = TextEditingController(text: current.toString());
                      final confirmed = await showDialog<int?>(context: context, builder: (_)=> AlertDialog(title: Text('Ajustar umbral de reorden'), content: TextField(controller: txtCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Umbral')), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(null), child: Text('Cancelar')), TextButton(onPressed: (){ final v = int.tryParse(txtCtrl.text.trim()) ?? current; Navigator.of(context).pop(v); }, child: Text('Guardar'))]));
                      if (confirmed != null){
                        await prov.setReorderLevel(p.id, confirmed);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Umbral actualizado')));
                      }
                    }, child: Text('Editar'))
                  ])
                ])),
              ),
              SizedBox(height:8),
              Card(
                margin: EdgeInsets.symmetric(vertical:8),
                child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Text('Recomendaciones', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height:6),
                  Text('Traer calzado cómodo, bloqueador solar, agua y cámara. Respetar indicaciones del guía.')
                ])),
              ),

              SizedBox(height:8),
              // Pequeña galería
              Text('Galería', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height:8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (ctx,i){
                    final base = p.imageUrl;
                    final url = base.replaceFirst('/400/300', '/400/300?img=${i+1}');
                    return Padding(padding: EdgeInsets.only(right:8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url.isNotEmpty?url:'https://picsum.photos/120/80?random=${i}', width:120, height:80, fit: BoxFit.cover)));
                  }
                ),
              ),

              SizedBox(height:12),
              Card(
                margin: EdgeInsets.symmetric(vertical:8),
                child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
                  Text('Comentarios', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height:8),
                  ListTile(leading: CircleAvatar(child: Text('MC')), title: Text('María C.'), subtitle: Text('Excelente guía y paisajes increíbles. Muy recomendable.')),
                  Divider(),
                  ListTile(leading: CircleAvatar(child: Text('JP')), title: Text('Juan P.'), subtitle: Text('Buena logística, volvería con la familia.'), trailing: Text('4.5'))
                ])),
              ),
              SizedBox(height: 12),
              if (product.variants.isNotEmpty)
                DropdownButton<String>(
                  value: _variant ?? product.variants.first,
                  items: product.variants
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _variant = v);
                  },
                ),
              SizedBox(height: 8),
              Row(children: [
                Text('Cantidad:'),
                SizedBox(width: 10),
                IconButton(onPressed: () => setState(() => _qty = (_qty > 1 ? _qty - 1 : 1)), icon: Icon(Icons.remove)),
                Text('$_qty'),
                IconButton(onPressed: () => setState(() => _qty++), icon: Icon(Icons.add)),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    final redirect = ReservationsFlowScreen.routeName;
                    final redirectArgs = {'id': product!.id, 'qty': _qty, 'variant': _variant};
                    // solo clientes pueden acceder al flujo de reservas
                    final allowed = ['cliente','client'];
                    if (auth.isAuthenticated) {
                      final role = (auth.user?.role ?? '').toLowerCase();
                      if (allowed.contains(role)) {
                        Navigator.of(context).pushNamed(redirect, arguments: redirectArgs);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Acceso restringido: se necesita una cuenta de cliente.')));
                      }
                    } else {
                      // no autenticado -> redirigir al login con destino guardado
                      Navigator.of(context).pushNamed(LoginScreen.routeName, arguments: {'redirect': redirect, 'redirectArgs': redirectArgs, 'allowedRoles': allowed});
                    }
                  },
                  child: Text('Agregar reserva'),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
