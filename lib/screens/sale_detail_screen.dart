// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../providers/auth_provider.dart';

class SaleDetailScreen extends StatelessWidget {
  static const routeName = '/sales/detail';
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = arg is String ? arg : null;
    if (id == null) return Scaffold(appBar: AppBar(title: Text('Venta')), body: Center(child: Text('Venta no encontrada')));
    final prov = Provider.of<SalesProvider>(context);
    final sale = prov.getById(id);
    if (sale.isEmpty) return Scaffold(appBar: AppBar(title: Text('Venta')), body: Center(child: Text('Venta no encontrada')));
    final auth = Provider.of<AuthProvider>(context, listen:false);
    // Security: if client, ensure ownership
    if ((auth.user?.role ?? '').toLowerCase() == 'cliente' || (auth.user?.role ?? '').toLowerCase() == 'client'){
      final uid = auth.user?.id ?? '';
      if ((sale['clientId'] ?? '') != uid) return Scaffold(appBar: AppBar(title: Text('Acceso denegado')), body: Center(child: Text('No tienes permiso para ver esta venta')));
    }
    final _currency = NumberFormat.currency(locale: 'es_CO', symbol: 'COP ');
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Venta')),
      body: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(sale['serviceName'] ?? '-', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
        SizedBox(height:8), Text('Cliente: ${sale['clientName'] ?? '-'}'),
        SizedBox(height:6), Text('Fecha: ${_formatDate(sale['createdAt'])}'),
        SizedBox(height:6), Text('Valor: ${_currency.format((sale['amount'] ?? 0))}'),
        SizedBox(height:6), Text('Estado: ${sale['status'] ?? '-'}'),
        SizedBox(height:12), Row(children:[
          ElevatedButton(onPressed: () async {
            final hasInvoice = (sale['invoice'] ?? null) != null;
            if (hasInvoice){
              // show existing invoice
              showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Factura'), content: SingleChildScrollView(child: SelectableText(sale['invoice'].toString())), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))]));
              return;
            }
            // generate simulated invoice and persist
            final auth = Provider.of<AuthProvider>(context, listen:false);
            final invoice = '''Factura Simulada\n\nVenta: ${sale['id']}\nCliente: ${sale['clientName'] ?? '-'}\nServicio: ${sale['serviceName'] ?? '-'}\nFecha: ${_formatDate(sale['createdAt'])}\nValor: ${_currency.format((sale['amount'] ?? 0))}\nGenerada por: ${auth.user?.name ?? '-'}\n''';
            try{
              await prov.updateSale(sale['id'], {'invoice': invoice}, actor: {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''});
              // show invoice
              showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Factura generada'), content: SingleChildScrollView(child: SelectableText(invoice)), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Cerrar'))]));
            } catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generando factura'))); }
          }, child: Text((sale['invoice'] ?? null) != null ? 'Descargar factura' : 'Generar factura (simulada)')) , SizedBox(width:12), ElevatedButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Volver'))]),
      ])),
    );
  }

  String _formatDate(dynamic raw){ if (raw==null) return '-'; try{ final d = DateTime.parse(raw.toString()); return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}'; } catch(_){ return raw.toString(); }}
}
