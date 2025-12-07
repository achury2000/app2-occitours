// parte isa
// parte linsaith
// parte juanjo
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/fincas_provider.dart';
import '../models/finca.dart';

/// Pantalla con mapa interactivo de fincas usando `flutter_map`.
///
/// Responsabilidades:
/// - Mostrar marcadores para fincas con coordenadas y permitir acciones rápidas (ver detalle, reservar).
///
/// Herencia / Overrides:
/// - Extiende `StatefulWidget` y su `State` llama a `FincasProvider.loadAll()` en `initState`.
///
/// Call-sites típicos:
/// - Accedida desde el menú o navegaciones que muestran el mapa global de fincas.
class FincasMapScreen extends StatefulWidget {
  static const routeName = '/fincas/map';
  @override
  _FincasMapScreenState createState() => _FincasMapScreenState();
}

class _FincasMapScreenState extends State<FincasMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Provider.of<FincasProvider>(context, listen: false).loadAll());
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<FincasProvider>(context);
    final markers = prov.items.where((f) => f.latitude != null && f.longitude != null).map((f) => Marker(
      width: 40,
      height: 40,
      point: LatLng(f.latitude!, f.longitude!),
      builder: (ctx) => GestureDetector(
        onTap: () => showDialog(context: context, builder: (dctx) => AlertDialog(title: Text(f.name), content: Text(f.location), actions: [TextButton(onPressed: ()=>Navigator.of(dctx).pop(), child: Text('Cerrar'))])),
        child: Icon(Icons.location_on, color: Colors.red, size: 32),
      ),
    )).toList();

    final center = markers.isNotEmpty ? markers.first.point : LatLng(6.217, -75.567);

    return Scaffold(
      appBar: AppBar(title: Text('Mapa de Fincas')),
      body: prov.loading ? Center(child: CircularProgressIndicator()) : FlutterMap(
        options: MapOptions(center: center, zoom: 10),
        children: [
          TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: ['a','b','c']),
          MarkerLayer(markers: markers.map((m) => Marker(
            width: m.width,
            height: m.height,
            point: m.point,
            builder: (ctx) => GestureDetector(
                onTap: () {
                Finca? finca;
                try {
                  finca = prov.items.firstWhere((f) => f.latitude == m.point.latitude && f.longitude == m.point.longitude);
                } catch (_) {
                  finca = null;
                }
                final fincaId = finca?.id;
                showDialog(context: context, builder: (dctx) => AlertDialog(
                  title: Text(finca?.name ?? 'Finca'),
                  content: Text(finca?.location ?? ''),
                  actions: [
                    TextButton(onPressed: ()=>Navigator.of(dctx).pop(), child: Text('Cerrar')),
                    if (fincaId != null) TextButton(onPressed: () {
                      Navigator.of(dctx).pop();
                      Navigator.of(context).pushNamed('/reservations/create', arguments: fincaId);
                    }, child: Text('Reservar'))
                  ],
                ));
              },
              child: m.builder(ctx),
            ),
          )).toList()),
        ],
      ),
    );
  }
}
