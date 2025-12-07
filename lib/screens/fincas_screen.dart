// parte isa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class FincasScreen extends StatefulWidget {
  static const routeName = '/fincas';
  @override
  _FincasScreenState createState() => _FincasScreenState();
}

class _FincasScreenState extends State<FincasScreen> {
  final _nameCtrl = TextEditingController();
  RangeValues _priceRange = RangeValues(0, 1000000);
  String? _location;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadInitial(category: 'Fincas');
    });
  }

  bool _serviceAvailable(Product p, String service) {
    // Simple UI-only heuristic to vary service availability
    final code = p.id.hashCode;
    switch (service) {
      case 'wifi': return code % 2 == 0;
      case 'pool': return code % 3 == 0;
      case 'pet': return code % 5 != 0;
      case 'parking': return code % 7 == 0;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final all = productsProv.items.where((p) => p.category == 'Fincas').toList();
    final minPrice = all.isNotEmpty ? all.map((e) => e.price).reduce((a,b)=>a<b?a:b) : 0.0;
    final maxPrice = all.isNotEmpty ? all.map((e) => e.price).reduce((a,b)=>a>b?a:b) : 1000000.0;

    if (_priceRange.start == 0 && _priceRange.end == 1000000 && all.isNotEmpty) {
      _priceRange = RangeValues(minPrice, maxPrice);
    }

    final locationsFixed = ['Todos','Sopetrán','Santa Fe de Antioquia','San Jerónimo'];

    List<Product> filtered;
    final noFilters = _nameCtrl.text.isEmpty && _location == null && (_priceRange.start == minPrice && _priceRange.end == maxPrice);
    if (noFilters) {
      filtered = List<Product>.from(all);
      filtered.sort((a,b)=>b.popularity.compareTo(a.popularity));
      if (filtered.length > 6) filtered = filtered.take(6).toList();
    } else {
      filtered = all.where((p) {
        if (_nameCtrl.text.isNotEmpty && !p.name.toLowerCase().contains(_nameCtrl.text.toLowerCase())) return false;
        if (_location != null && _location!.isNotEmpty) {
          if (_location != 'Todos') {
            if (!p.name.toLowerCase().contains(_location!.toLowerCase()) && !p.description.toLowerCase().contains(_location!.toLowerCase())) return false;
          }
        }
        if (p.price < _priceRange.start || p.price > _priceRange.end) return false;
        return true;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Fincas y Hospedajes'), actions: [IconButton(icon: Icon(Icons.map), tooltip: 'Ver en mapa', onPressed: ()=> Navigator.of(context).pushNamed('/fincas/map'))]),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(children: [
              // responsive layout for filters
              LayoutBuilder(builder: (ctx, constraints) {
                final narrow = constraints.maxWidth < 380;
                if (narrow) {
                  return Column(children: [
                    TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre')),
                    SizedBox(height:8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _location,
                      decoration: InputDecoration(labelText: 'Ubicación'),
                      items: locationsFixed.map((l)=>DropdownMenuItem(value: l=='Todos'? '': l, child: Text(l))).toList(),
                      onChanged: (v){ setState(()=>_location = (v==''?null:v)); }
                    ),
                  ]);
                }

                return Row(children: [
                  Expanded(child: TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre'))),
                  SizedBox(width:8),
                  Expanded(child: DropdownButtonFormField<String>(isExpanded: true, initialValue: _location, decoration: InputDecoration(labelText: 'Ubicación'), items: locationsFixed.map((l)=>DropdownMenuItem(value: l=='Todos'? '': l, child: Text(l))).toList(), onChanged: (v){ setState(()=>_location = (v==''?null:v)); })),
                ]);
              }),
              SizedBox(height:8),
              Row(children: [Text('Rango de Precio:'), Spacer(), Text('COP ${_priceRange.start.toStringAsFixed(0)} - ${_priceRange.end.toStringAsFixed(0)}')]),
              RangeSlider(values: _priceRange, min: minPrice, max: maxPrice>minPrice?maxPrice:minPrice+1, divisions: 6, labels: RangeLabels('${_priceRange.start.toStringAsFixed(0)}', '${_priceRange.end.toStringAsFixed(0)}'), onChanged: (v){ setState(()=>_priceRange = v); }),
            ]),
          ),

          Expanded(child: filtered.isEmpty ? Center(child: Text('No se encontraron fincas')) : ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: filtered.length,
            itemBuilder: (ctx,i){ final p = filtered[i]; return Card(
              margin: EdgeInsets.symmetric(vertical:8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: TextStyle(fontSize:16, fontWeight: FontWeight.bold)),
                  SizedBox(height:6),
                  Text(p.description),
                  SizedBox(height:8),
                  Wrap(spacing:12, children: [
                    _ServiceChip(label: 'Wi‑Fi', enabled: _serviceAvailable(p,'wifi')),
                    _ServiceChip(label: 'Piscina', enabled: _serviceAvailable(p,'pool')),
                    _ServiceChip(label: 'Pet‑friendly', enabled: _serviceAvailable(p,'pet')),
                    _ServiceChip(label: 'Parqueadero', enabled: _serviceAvailable(p,'parking')),
                  ]),
                  SizedBox(height:8),
                  Row(children: [Text('COP ${p.price.toStringAsFixed(0)} / noche', style: TextStyle(fontWeight: FontWeight.bold)), Spacer(), ElevatedButton(onPressed: ()=>Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: p.id), child: Text('Ver Detalles'))]),
                ]),
              ),
            ); }
          ))
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  final bool enabled;
  const _ServiceChip({required this.label, required this.enabled});
  @override
  Widget build(BuildContext context) => Chip(backgroundColor: enabled?Colors.green[100]:Colors.grey[200], label: Row(children: [Icon(enabled?Icons.check_circle:Icons.cancel, size:16, color: enabled?Colors.green:Colors.grey), SizedBox(width:6), Text(label)]));
}
