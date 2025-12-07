// parte isa
// parte linsaith
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class RoutesScreen extends StatefulWidget {
  static const routeName = '/routes';
  @override
  _RoutesScreenState createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  String? _municipio;
  String? _activityType;
  RangeValues _priceRange = RangeValues(0, 1000000);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).loadInitial(category: 'Rutas');
    });
  }

  String difficultyFrom(Product p) {
    if (p.popularity >= 4.5) return 'Alta';
    if (p.popularity >= 4.0) return 'Media';
    return 'Baja';
  }

  String extractLocation(Product p) {
    // Try to extract a location from the name like 'Ruta X - Lugar'
    if (p.name.contains('-')) {
      final parts = p.name.split('-');
      return parts.last.trim();
    }
    return 'No especificado';
  }

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final all = productsProv.items.where((p) => p.category == 'Rutas').toList();
    final minPrice = all.isNotEmpty ? all.map((e) => e.price).reduce((a,b)=>a<b?a:b) : 0.0;
    final maxPrice = all.isNotEmpty ? all.map((e) => e.price).reduce((a,b)=>a>b?a:b) : 1000000.0;

    // adjust range if first time
    if (_priceRange.start == 0 && _priceRange.end == 1000000 && all.isNotEmpty) {
      _priceRange = RangeValues(minPrice, maxPrice);
    }

    final municipiosFixed = ['Todos','Sopetrán','Santa Fe de Antioquia','San Jerónimo'];

    List<Product> filtered;
    final noFilters = (_municipio == null) && (_activityType == null) && (_priceRange.start == minPrice && _priceRange.end == maxPrice);
    if (noFilters) {
      // show top 6 by popularity when no filters applied
      filtered = List<Product>.from(all);
      filtered.sort((a,b)=>b.popularity.compareTo(a.popularity));
      if (filtered.length > 6) filtered = filtered.take(6).toList();
    } else {
      filtered = all.where((p) {
        if (_municipio != null && _municipio!.isNotEmpty) {
          if (_municipio != 'Todos') {
            final loc = extractLocation(p).toLowerCase();
            if (!loc.contains(_municipio!.toLowerCase())) return false;
          }
        }
        if (_activityType != null && _activityType!.isNotEmpty) {
          if (!p.description.toLowerCase().contains(_activityType!.toLowerCase()) && !p.name.toLowerCase().contains(_activityType!.toLowerCase())) return false;
        }
        if (p.price < _priceRange.start || p.price > _priceRange.end) return false;
        return true;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Nuestras Rutas')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(children: [
              // Responsive filters: stack on narrow screens to avoid overflow
              LayoutBuilder(builder: (ctx, constraints) {
                final narrow = constraints.maxWidth < 380;
                if (narrow) {
                  return Column(children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _municipio ?? 'Todos',
                      decoration: InputDecoration(labelText: 'Municipio'),
                      items: municipiosFixed.map((m)=>DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v){ setState(()=>_municipio = (v=='Todos'?null:v)); }
                    ),
                    SizedBox(height:8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _activityType,
                      decoration: InputDecoration(labelText: 'Tipo de actividad'),
                      items: [DropdownMenuItem(value: '', child: Text('Todos')), DropdownMenuItem(value: 'senderismo', child: Text('Senderismo')), DropdownMenuItem(value: 'avistamiento', child: Text('Avistamiento')), DropdownMenuItem(value: 'gastronómico', child: Text('Gastronómico')), DropdownMenuItem(value: 'cultural', child: Text('Cultural'))],
                      onChanged: (v){ setState(()=>_activityType = (v==''?null:v)); }
                    ),
                  ]);
                }

                return Row(children: [
                  Expanded(child: DropdownButtonFormField<String>(isExpanded: true, initialValue: _municipio ?? 'Todos', decoration: InputDecoration(labelText: 'Municipio'), items: municipiosFixed.map((m)=>DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (v){ setState(()=>_municipio = (v=='Todos'?null:v)); })),
                  SizedBox(width: 8),
                  Expanded(child: DropdownButtonFormField<String>(isExpanded: true, initialValue: _activityType, decoration: InputDecoration(labelText: 'Tipo de actividad'), items: [DropdownMenuItem(value: '', child: Text('Todos')), DropdownMenuItem(value: 'senderismo', child: Text('Senderismo')), DropdownMenuItem(value: 'avistamiento', child: Text('Avistamiento')), DropdownMenuItem(value: 'gastronómico', child: Text('Gastronómico')), DropdownMenuItem(value: 'cultural', child: Text('Cultural'))], onChanged: (v){ setState(()=>_activityType = (v==''?null:v)); })),
                ]);
              }),
              SizedBox(height: 8),
              Row(children: [Text('Rango de Precio:'), Spacer(), Text('COP ${_priceRange.start.toStringAsFixed(0)} - ${_priceRange.end.toStringAsFixed(0)}')]),
              RangeSlider(values: _priceRange, min: minPrice, max: maxPrice>minPrice?maxPrice:minPrice+1, divisions: 6, labels: RangeLabels('${_priceRange.start.toStringAsFixed(0)}', '${_priceRange.end.toStringAsFixed(0)}'), onChanged: (v){ setState(()=>_priceRange = v); }),
            ]),
          ),

          Expanded(child: filtered.isEmpty ? Center(child: Text('No se encontraron rutas con esos filtros')) : ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: filtered.length,
            itemBuilder: (ctx,i){ final p = filtered[i]; return Card(
              margin: EdgeInsets.symmetric(vertical:8),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: Text(p.name, style: TextStyle(fontSize:16, fontWeight: FontWeight.bold))), Text(difficultyFrom(p), style: TextStyle(color: Colors.green[700]))]),
                  SizedBox(height:6),
                  Text(p.description),
                  SizedBox(height:8),
                  Row(children: [Icon(Icons.location_on, size:16), SizedBox(width:6), Text(extractLocation(p)) , Spacer(), Text('COP ${p.price.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold))]),
                  SizedBox(height:8),
                  Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: ()=>Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: p.id), child: Text('Ver Detalles')))
                ]),
              ),
            ); }
          ))
        ],
      ),
    );
  }
}
