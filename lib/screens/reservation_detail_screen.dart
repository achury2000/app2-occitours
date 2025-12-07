// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reservations_provider.dart';
import '../providers/clients_provider.dart';
import '../providers/auth_provider.dart';

class ReservationDetailScreen extends StatelessWidget {
  static const routeName = '/reservations/detail';
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    Map<String,dynamic>? res;
    if (arg is String){
      final prov = Provider.of<ReservationsProvider>(context);
      res = prov.getById(arg);
    } else if (arg is Map<String,dynamic>){
      res = arg;
    }
    final clientsProv = Provider.of<ClientsProvider>(context, listen: false);
    final clientInfo = res != null && res['clientId'] != null ? clientsProv.getById(res['clientId'] as String) : null;
    final existingRating = res != null ? (res['rating'] as num?)?.toInt() : null;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Detalle Reserva')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text('Reserva ${res?['id'] ?? '-'}', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
          SizedBox(height:8),
          Text('Servicio: ${res?['service'] ?? '-'}'),
          SizedBox(height:6),
          Text('Fecha: ${res?['date'] ?? '-'}'),
          SizedBox(height:6),
          Text('Hora: ${res?['time'] ?? '-'}'),
          SizedBox(height:6),
          Text('Estado: ${res?['status'] ?? '-'}'),
          SizedBox(height:6),
          Text('Precio: COP 180000'),
          SizedBox(height:12),
          if (clientInfo != null) ...[
            Text('Cliente', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height:6),
            Text('Nombre: ${clientInfo['name'] ?? '-'}'),
            Text('Email: ${clientInfo['email'] ?? '-'}'),
            SizedBox(height:12),
          ],
          Text('Contacto Proveedor', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height:6),
          Text('Proveedor: Occitours'),
          Text('Tel: +57 300 0000000'),
          SizedBox(height:12),
          Text('Notas y Políticas', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height:6),
          Text(res?['notes'] ?? 'Política de cancelación: ... (simulada)', style: TextStyle(color: Colors.black54)),
          Spacer(),
          // Para admins/asesores: permitir cambiar el estado
          if (auth.user != null && (auth.user?.role == 'admin' || auth.user?.role == 'asesor')) ...[
            Row(children:[
              ElevatedButton(onPressed: () async {
                if (res == null) return;
                final prov = Provider.of<ReservationsProvider>(context, listen: false);
                final current = (res['status'] ?? '').toString();
                final next = current.toLowerCase() == 'activa' ? 'Inactiva' : 'Activa';
                final confirm = await showDialog<bool>(context: context, builder: (_){
                  return AlertDialog(title: Text('Confirmar cambio de estado'), content: Text('¿Cambiar el estado a $next?'), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(false), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(context).pop(true), child: Text('Confirmar'))]);
                });
                if (confirm == true) {
                  try {
                    final reason = await showDialog<String>(context: context, builder: (_){
                      final ctrl = TextEditingController();
                      return AlertDialog(title: Text('Motivo (opcional)'), content: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'Escribe un motivo...')), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(''), child: Text('Saltar')), TextButton(onPressed: ()=> Navigator.of(context).pop(ctrl.text), child: Text('Aceptar'))]);
                    });
                    final actor = {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''};
                    await prov.setReservationStatus(res['id'] as String, next, actor: actor, reason: (reason?.isEmpty ?? true) ? null : reason);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado a $next')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar estado')));
                  }
                }
              }, child: Text('Cambiar Estado')),
              SizedBox(width:12),
            ]),
            SizedBox(height:12),
            // Cancel reservation button
            Row(children:[
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async {
                if (res == null) return;
                final confirm = await showDialog<bool>(context: context, builder: (_){
                  return AlertDialog(title: Text('Confirmar cancelación'), content: Text('¿Desea cancelar esta reserva?'), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(false), child: Text('No')), TextButton(onPressed: ()=> Navigator.of(context).pop(true), child: Text('Sí'))]);
                });
                if (confirm == true) {
                  final reason = await showDialog<String>(context: context, builder: (_){
                    final ctrl = TextEditingController();
                    return AlertDialog(title: Text('Motivo de cancelación (obligatorio)'), content: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'Escribe el motivo...')), actions: [TextButton(onPressed: ()=> Navigator.of(context).pop(''), child: Text('Cancelar')), TextButton(onPressed: ()=> Navigator.of(context).pop(ctrl.text), child: Text('Aceptar'))]);
                  });
                  if (reason == null || reason.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La cancelación requiere un motivo')));
                    return;
                  }
                  try {
                    final actor = {'id': auth.user?.id ?? '', 'name': auth.user?.name ?? ''};
                    await Provider.of<ReservationsProvider>(context, listen: false).cancelReservation(res['id'] as String, actor: actor, reason: reason.trim());
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reserva cancelada')));
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cancelar')));
                  }
                }
              }, child: Text('Cancelar Reserva')),
              SizedBox(width:12),
            ]),
          ],
          // UI de valoración para clientes que son propietarios de esta reserva
          if (auth.user != null && ((auth.user?.role ?? '').toLowerCase() == 'cliente' || (auth.user?.role ?? '').toLowerCase() == 'client') && res != null && (res['clientId'] ?? '') == (auth.user?.id ?? '')) ...[
            SizedBox(height:12),
            Text('Calificar esta experiencia', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(height:8),
            _RatingWidget(initialRating: existingRating, onSaved: (rating, comment) async {
              final prov = Provider.of<ReservationsProvider>(context, listen: false);
              await prov.updateReservation(res!['id'] as String, {'rating': rating, 'comment': comment});
              // refresh local copy
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gracias por tu valoración')));
            }),
            SizedBox(height:12)
          ],
          ElevatedButton(onPressed: ()=> Navigator.of(context).pop(), child: Text('Volver'))
        ])
      ),
    );
  }
}

class _RatingWidget extends StatefulWidget {
  final int? initialRating;
  final Future<void> Function(int rating, String comment) onSaved;
  _RatingWidget({this.initialRating, required this.onSaved});
  @override
  __RatingWidgetState createState() => __RatingWidgetState();
}

class __RatingWidgetState extends State<_RatingWidget> {
  int _rating = 0;
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void initState(){
    super.initState();
    _rating = widget.initialRating ?? 0;
    if (widget.initialRating != null) _ctrl.text = '';
  }

  @override
  void dispose(){ _ctrl.dispose(); super.dispose(); }

  Widget _star(int i){
    return IconButton(icon: Icon(i <= _rating ? Icons.star : Icons.star_border, color: Colors.amber), onPressed: (){ setState(()=> _rating = i); });
  }

  @override
  Widget build(BuildContext context){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Row(children: [for (var i=1;i<=5;i++) _star(i)]),
      SizedBox(height:8),
      TextField(controller: _ctrl, maxLines:3, decoration: InputDecoration(labelText: 'Comentario (opcional)')),
      SizedBox(height:8),
      Row(children:[Expanded(child: ElevatedButton(onPressed: _saving ? null : () async {
        if (_rating <= 0) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selecciona una calificación'))); return; }
        setState(()=> _saving = true);
        await widget.onSaved(_rating, _ctrl.text.trim());
        setState(()=> _saving = false);
      }, child: _saving ? SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2, color: Colors.white)) : Text('Guardar valoración')))]),
    ]);
  }
}
