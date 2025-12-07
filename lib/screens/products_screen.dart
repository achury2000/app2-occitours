import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends StatefulWidget {
  static const routeName = '/products';
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState(){
    super.initState();
    // Defer loading until after the first frame to avoid notifyListeners() during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args.containsKey('category') && args['category'] != null) {
        Provider.of<ProductsProvider>(context, listen: false).loadInitial(category: args['category']);
      } else {
        Provider.of<ProductsProvider>(context, listen: false).loadInitial();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Productos')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: TextField(controller: _searchCtrl, decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar...'), onSubmitted: (v){
                products.loadInitial(query: v);
              })),
              SizedBox(width:8),
              PopupMenuButton<String>(icon: Icon(Icons.filter_list), onSelected: (val){
                products.loadInitial(category: val=='Todas'?null:val);
              }, itemBuilder: (_)=>[
                PopupMenuItem(value: 'Todas', child: Text('Todas')),
                PopupMenuItem(value: 'Rutas', child: Text('Rutas')),
                PopupMenuItem(value: 'Paquetes', child: Text('Paquetes')),
                PopupMenuItem(value: 'Fincas', child: Text('Fincas')),
                PopupMenuItem(value: 'Servicios', child: Text('Servicios')),
                PopupMenuItem(value: 'Experiencias', child: Text('Experiencias')),
                PopupMenuItem(value: 'Alquiler', child: Text('Alquiler')),
              ])
            ]),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal:8), child: Row(children:[Text('Orden:'), SizedBox(width:8), DropdownButton<ProductSort?>(value: null, items:[
            DropdownMenuItem(value: ProductSort.priceAsc, child: Text('Precio ↑')),
            DropdownMenuItem(value: ProductSort.priceDesc, child: Text('Precio ↓')),
            DropdownMenuItem(value: ProductSort.nameAsc, child: Text('Nombre')),
            DropdownMenuItem(value: ProductSort.popularity, child: Text('Popularidad')),
          ], onChanged: (v){ products.loadInitial(sort: v); })])),

          Expanded(child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo){
              if (!products.loading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                products.loadMore();
                return true;
              }
              return false;
            },
            child: products.loading && products.items.isEmpty ? Center(child: CircularProgressIndicator()) : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: products.items.length + (products.loading ? 1 : 0),
              itemBuilder: (ctx,i){
                if (i<products.items.length) return ProductCard(product: products.items[i]);
                return Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
              },
            ),
          ))
        ],
      ),
    );
  }
}
