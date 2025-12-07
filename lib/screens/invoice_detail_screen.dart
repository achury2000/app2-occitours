// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/invoices_provider.dart';
import '../providers/payments_provider.dart';
import '../models/payment.dart';
import 'package:uuid/uuid.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;
  InvoiceDetailScreen({required this.invoiceId});
  @override
  _InvoiceDetailScreenState createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  bool _loading = false;

  Future<void> _markPaid() async {
    final paymentsProv = Provider.of<PaymentsProvider>(context, listen: false);
    final invoicesProv = Provider.of<InvoicesProvider>(context, listen: false);
    setState(() => _loading = true);
    try {
      // Optionally you could create a Payment and link it; here we just mark invoice as paid without paymentId
      await invoicesProv.setInvoiceStatus(widget.invoiceId, 'paid',
          paymentsProvider: paymentsProv,
          actor: {'id': 'system', 'name': 'app'});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Factura marcada como pagada')));
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cerrar'))
                  ]));
    }
    setState(() => _loading = false);
  }

  Future<void> _createPaymentAndMarkPaid() async {
    final paymentsProv = Provider.of<PaymentsProvider>(context, listen: false);
    final invoicesProv = Provider.of<InvoicesProvider>(context, listen: false);
    final amountController = TextEditingController();
    String currency = 'USD';
    String method = 'card';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Crear pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Monto'),
                  keyboardType: TextInputType.number),
              DropdownButton<String>(
                value: currency,
                items: ['USD', 'EUR', 'COP']
                    .map((c) => DropdownMenuItem(child: Text(c), value: c))
                    .toList(),
                onChanged: (v) {
                  currency = v ?? currency;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('OK')),
          ],
        );
      },
    );
    if (ok != true) return;
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Monto inválido')));
      return;
    }
    setState(() => _loading = true);
    try {
      final paymentId = Uuid().v4();
      final payment = Payment(
          id: paymentId,
          reservationId: null,
          amount: amount,
          currency: currency,
          method: method,
          status: 'completed',
          timestamp: DateTime.now(),
          metadata: {});
      await paymentsProv
          .addPayment(payment, actor: {'id': 'system', 'name': 'app'});
      await invoicesProv.setInvoiceStatus(widget.invoiceId, 'paid',
          paymentId: paymentId,
          paymentsProvider: paymentsProv,
          actor: {'id': 'system', 'name': 'app'});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pago creado y factura marcada como pagada')));
    } catch (e) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cerrar'))
                  ]));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoicesProvider>(context);
    final inv = prov.findById(widget.invoiceId);
    if (inv == null)
      return Scaffold(
          appBar: AppBar(title: Text('Factura')),
          body: Center(child: Text('No encontrada')));
    final itemWidgets = inv.items
        .map((it) => ListTile(
            title: Text(it.description),
            subtitle: Text('${it.quantity} x ${it.unitPrice}')))
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text('Factura ${inv.id}')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Estado: ${inv.status}'),
          SizedBox(height: 8),
          Text('Total: ${inv.total} ${inv.currency}'),
          SizedBox(height: 8),
          Text('Reservas: ${inv.reservationIds.join(', ')}'),
          SizedBox(height: 8),
          Text('Items:'),
          ...itemWidgets,
          SizedBox(height: 12),
          _loading
              ? CircularProgressIndicator()
              : Column(children: [
                  ElevatedButton(
                      child: Text('Marcar como pagada'), onPressed: _markPaid),
                  SizedBox(height: 8),
                  ElevatedButton(
                      child: Text('Crear pago y marcar pagada'),
                      onPressed: _createPaymentAndMarkPaid)
                ])
        ]),
      ),
    );
  }
}
