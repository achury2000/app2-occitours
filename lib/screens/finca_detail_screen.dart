// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fincas_provider.dart';
import '../providers/services_provider.dart';

/// Pantalla que muestra detalle de una finca.
///
/// Responsabilidades:
/// - Mostrar información básica de la `Finca` (nombre, código, ubicación, servicios, precio, etc.).
/// - Proveer la acción de reservar que navega a la pantalla de creación de reservas.
///
/// Herencia / Interfaces:
/// - Extiende `StatelessWidget` y espera recibir el `id` de la finca como argumento de la ruta.
class FincaDetailScreen extends StatelessWidget {
  static const routeName = '/fincas/detail';
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final prov = Provider.of<FincasProvider>(context);
    late final finca;
    try { finca = prov.findById(id); } catch (e) { return Scaffold(appBar: AppBar(title: Text('Finca')), body: Center(child: Text('Finca no encontrada'))); }

    return Scaffold(
      appBar: AppBar(title: Text(finca.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(finca.name, style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)),
          SizedBox(height:8),
          Text('Código: ${finca.code}'),
          SizedBox(height:8),
          Text('Ubicación: ${finca.location}'),
          SizedBox(height:8),
          if (finca.latitude != null && finca.longitude != null) Text('Coordenadas: ${finca.latitude}, ${finca.longitude}'),
          SizedBox(height:8),
          Text('Capacidad: ${finca.capacity} personas'),
          SizedBox(height:8),
          Text('Precio por noche: COP ${finca.pricePerNight.toStringAsFixed(0)}'),
          SizedBox(height:12),
          Text(finca.description),
          SizedBox(height:12),
          Consumer<ServicesProvider>(builder: (ctx, sp, _) {
            final services = finca.serviceIds.map((id) => sp.getById(id)).where((s) => s != null).toList();
            if (services.isEmpty) return SizedBox.shrink();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Servicios disponibles', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height:6), Wrap(spacing:8, children: services.map((s) => Chip(label: Text(s!.name))).toList())]);
          }),
          SizedBox(height:12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){ Navigator.of(context).pushNamed('/reservations/create', arguments: finca.id); }, child: Text('Reservar'))),
        ]),
      ),
    );
  }
}
