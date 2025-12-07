// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/itineraries_provider.dart';
import '../providers/reservations_provider.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final String itineraryId;
  ItineraryDetailScreen({required this.itineraryId});
  @override
  _ItineraryDetailScreenState createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  bool _loading = false;

  void _convertToReservations() async {
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final clientController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Convertir a reservas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)')),
              TextField(
                  controller: timeController,
                  decoration: InputDecoration(labelText: 'Hora (HH:mm)')),
              TextField(
                  controller: clientController,
                  decoration: InputDecoration(labelText: 'Cliente ID')),
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
    final dateStr = dateController.text.trim();
    final timeStr = timeController.text.trim();
    final clientId = clientController.text.trim();
    if (dateStr.isEmpty || timeStr.isEmpty || clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fecha, hora y cliente son requeridos')));
      return;
    }
    setState(() => _loading = true);
    try {
      final resProv = Provider.of<ReservationsProvider>(context, listen: false);
      final itinProv = Provider.of<ItinerariesProvider>(context, listen: false);
      final date = DateTime.parse(dateStr);
      final results = await itinProv.createReservationsFromItinerary(
          widget.itineraryId,
          date: date,
          time: timeStr,
          clientId: clientId,
          reservationsProvider: resProv,
          actor: {'id': 'system', 'name': 'app'});
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Resultado'),
            content: SingleChildScrollView(
              child: Column(
                children: results.entries
                    .map((e) => Text('${e.key}: ${e.value}'))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar'))
            ],
          );
        },
      );
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
    final prov = Provider.of<ItinerariesProvider>(context);
    final it = prov.findById(widget.itineraryId);
    if (it == null)
      return Scaffold(
          appBar: AppBar(title: Text('Itinerario')),
          body: Center(child: Text('No encontrado')));
    return Scaffold(
      appBar: AppBar(title: Text(it.title)),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Descripción: ${it.description ?? '-'}'),
          SizedBox(height: 8),
          Text('Rutas: ${it.routeIds.join(', ')}'),
          SizedBox(height: 8),
          Text('Fincas: ${it.fincaIds.join(', ')}'),
          SizedBox(height: 8),
          Text('Duración: ${it.durationMinutes} min'),
          SizedBox(height: 8),
          Text('Precio estimado: ${it.price}'),
          SizedBox(height: 12),
          _loading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  child: Text('Convertir a reservas'),
                  onPressed: _convertToReservations)
        ]),
      ),
    );
  }
}
