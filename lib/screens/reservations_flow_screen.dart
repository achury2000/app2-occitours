// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../providers/reservations_provider.dart';

class ReservationsFlowScreen extends StatefulWidget {
  static const routeName = '/reservations/flow';
  @override
  _ReservationsFlowScreenState createState() => _ReservationsFlowScreenState();
}

class _ReservationsFlowScreenState extends State<ReservationsFlowScreen> {
  final PageController _pc = PageController();
  int _page = 0;
  String _payment = 'card';

  @override
  void dispose(){
    _pc.dispose();
    super.dispose();
  }

  void _next(){
    if (_page < 2) {
      _pc.nextPage(duration: Duration(milliseconds:300), curve: Curves.ease);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _prev(){
    if (_page > 0) _pc.previousPage(duration: Duration(milliseconds:300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>?;
    final productId = args?['id'] as String?;
    final qty = args?['qty'] as int? ?? 1;
    // la variante es opcional; no es necesaria en este flujo actualmente
    final products = Provider.of<ProductsProvider>(context, listen:false);
    final product = productId != null ? products.findById(productId) : null;

    return Scaffold(
      appBar: AppBar(title: Text('Reserva'), leading: BackButton()),
      body: Column(children:[
        Expanded(child: PageView(controller: _pc, physics: NeverScrollableScrollPhysics(), onPageChanged: (i)=> setState(()=> _page = i), children:[
          // Step 1: Review
          Padding(padding: EdgeInsets.all(12), child: ListView(children:[
            Text('Revisa y continúa', style: TextStyle(fontSize:22, fontWeight: FontWeight.w700)),
            SizedBox(height:12),
            Card(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
              Row(children:[
                if (product != null) Image.network(product.imageUrl, width:72, height:72, fit: BoxFit.cover),
                SizedBox(width:12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[Text(product?.name ?? '-', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height:6), Text('x$qty')])),
                Text('COP ${product?.price.toStringAsFixed(0) ?? '0'}')
              ]),
              Divider(),
              ListTile(title: Text('Fechas'), subtitle: Text('22 – 23 de nov de 2025'), trailing: ElevatedButton(onPressed: ()=> null, child: Text('Cambiar'))),
              ListTile(title: Text('Huéspedes'), subtitle: Text('1 adulto'), trailing: ElevatedButton(onPressed: ()=> null, child: Text('Cambiar'))),
              ListTile(title: Text('Precio total'), subtitle: Text('COP ${(product?.price ?? 0 * qty).toStringAsFixed(0)}'), trailing: TextButton(onPressed: ()=> null, child: Text('Detalles'))),
              SizedBox(height:8), Text('Esta reservación no es reembolsable.', style: TextStyle(color: Colors.black54)),
            ])))
          ])),

          // Step 2: Payment methods
          Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text('Agrega un método de pago', style: TextStyle(fontSize:22, fontWeight: FontWeight.w700)),
            SizedBox(height:12),
            Card(child: Column(children:[
              ListTile(
                leading: Icon(_payment == 'card' ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text('Tarjeta de crédito o débito'),
                subtitle: Row(children:[Image.network('https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg', width:24), SizedBox(width:6), Image.network('https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg', width:24)]),
                onTap: () => setState(()=> _payment = 'card'),
              ),
              Divider(height:1),
              ListTile(
                leading: Icon(_payment == 'google' ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                title: Text('Google Pay'),
                onTap: () => setState(()=> _payment = 'google'),
              ),
            ])),
            SizedBox(height:8),
            if (_payment == 'card') Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: ()=> _showAddCard(context), child: Text('Agregar tarjeta')))
          ])),

          // Step 3: Confirmation (placeholder)
          Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text('Resumen final', style: TextStyle(fontSize:22, fontWeight: FontWeight.w700)),
            SizedBox(height:12),
            Expanded(child: Center(child: Text('Presiona Siguiente para confirmar la reserva'))),
          ]))
        ])),

        Container(padding: EdgeInsets.all(12), color: Colors.white, child: Row(children:[
          TextButton(onPressed: _prev, child: Text('Atrás')),
          Spacer(),
          ElevatedButton(onPressed: () async {
            if (_page < 2) {
              _next();
            } else {
              // confirm: create reservation
              final reservations = Provider.of<ReservationsProvider>(context, listen:false);
              await reservations.addReservation({
                'service': product?.name ?? 'Servicio',
                'date': DateTime.now().toIso8601String().split('T').first,
                'time': '09:00',
                'price': product?.price ?? 0,
                'status': 'Activa'
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva creada')));
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }, child: Text(_page < 2 ? 'Siguiente' : 'Confirmar'), style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal:24, vertical:14)))
        ]))
      ])
    );
  }

  Future<void> _showAddCard(BuildContext context) async {
    await showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx){
      return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), child: Container(padding: EdgeInsets.all(12), child: Column(mainAxisSize: MainAxisSize.min, children:[
        AppBar(title: Text('Agrega los datos de la tarjeta'), automaticallyImplyLeading: false, elevation: 0, backgroundColor: Colors.transparent),
        TextField(decoration: InputDecoration(labelText: 'Número de tarjeta')),
        Row(children:[Expanded(child: TextField(decoration: InputDecoration(labelText: 'Caducidad'))), SizedBox(width:8), Expanded(child: TextField(decoration: InputDecoration(labelText: 'Código CVV')))]),
        TextField(decoration: InputDecoration(labelText: 'Código postal')),
        SizedBox(height:8), Row(children:[TextButton(onPressed: ()=> Navigator.of(ctx).pop(), child: Text('Cancelar')), Spacer(), ElevatedButton(onPressed: ()=> Navigator.of(ctx).pop(), child: Text('Listo'))])
      ])));
    });
  }
}
