// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservations_provider.dart';

class ReservationsCancelScreen extends StatefulWidget {
  static const routeName = '/reservations/cancel';
  @override
  _ReservationsCancelScreenState createState() => _ReservationsCancelScreenState();
}

class _ReservationsCancelScreenState extends State<ReservationsCancelScreen> {
  void _cancel(String id){
    showDialog(context: context, builder: (_)=> AlertDialog(title: Text('Confirmar cancelación'), content: Text('¿Confirmar cancelación de $id?'), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('No')), TextButton(onPressed: (){ Navigator.of(context).pop(); Provider.of<ReservationsProvider>(context, listen: false).cancelReservation(id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva $id cancelada'))); }, child: Text('Sí'))]));
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ReservationsProvider>(context);
    final active = prov.reservations.where((r) => r['status'] == 'Activa').toList();
    return Scaffold(
      appBar: AppBar(title: Text('Cancelar Reserva')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView.separated(
          itemCount: active.length,
          separatorBuilder: (_,__)=>SizedBox(height:8),
          itemBuilder: (ctx,i){
            final r = active[i];
            return Card(
              child: ListTile(
                title: Text('${r['service']} • ${r['date']}'),
                subtitle: Text('ID: ${r['id']}'),
                trailing: TextButton(onPressed: ()=> _cancel(r['id'] as String), child: Text('Cancelar', style: TextStyle(color: Colors.red))),
                onTap: ()=> Navigator.of(context).pushNamed('/reservations/detail', arguments: r),
              ),
            );
          }
        )
      )
    );
  }
}
