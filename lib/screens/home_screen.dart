import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import 'product_detail_screen.dart';
import 'routes_screen.dart';
import 'fincas_screen.dart';
// imports intentionally minimal for this screen
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _assetBgAvailable = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final products = Provider.of<ProductsProvider>(context, listen: false);
      products.loadInitial();
      // Try to precache a local asset but do it non-blocking and with timeout
      // so a slow network or missing asset doesn't freeze the UI.
      final assetImage = AssetImage('assets/images/occitours_bg.jpg');
      final precacheFuture = precacheImage(assetImage, context);
      // Use a timeout to avoid long waits; if it completes quickly mark available
      precacheFuture.timeout(const Duration(seconds: 2)).then((_) {
        if (mounted) setState(() => _assetBgAvailable = true);
      }).catchError((_) {
        if (mounted) setState(() => _assetBgAvailable = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductsProvider>(context);
    final bgImage = products.items.isNotEmpty
        ? products.items.first.imageUrl
        : 'https://picsum.photos/seed/landscape/1200/800';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Occitours – Turismo de Naturaleza',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(LoginScreen.routeName),
            icon: Icon(Icons.person, color: Colors.white),
            tooltip: 'Iniciar Sesión',
          )
        ],
      ),
      body: Stack(
        children: [
          // Background image (asset preferred)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _assetBgAvailable
                    ? AssetImage('assets/images/occitours_bg.jpg')
                        as ImageProvider
                    : NetworkImage(bgImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient overlay (green nature tones)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(27, 94, 32, 0.85),
                  Color.fromRGBO(102, 187, 106, 0.25)
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: ListView(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 48),
              children: [
                SizedBox(height: 20),
                Text('Descubre la Naturaleza Colombiana',
                    style: TextStyle(color: Colors.white70, fontSize: 18)),
                SizedBox(height: 8),
                Text('Occitours – Turismo de Naturaleza',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text(
                    'Aventuras únicas en paisajes espectaculares con guías expertos y experiencias auténticas',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 18),
                Row(children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      try {
                        final auth = Provider.of(context, listen: false);
                        final role =
                            (auth.user?.role ?? '').toString().toLowerCase();
                        if (role == 'admin') {
                          Navigator.of(context).pushNamed('/rutas/manage');
                          return;
                        }
                      } catch (_) {}
                      Navigator.of(context).pushNamed(RoutesScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 6,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Explorar Rutas',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  )),
                  SizedBox(width: 12),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      // En admin mostrar gestión, para otros mostrar listado público
                      try {
                        final auth = Provider.of(context, listen: false);
                        final role =
                            (auth.user?.role ?? '').toString().toLowerCase();
                        if (role == 'admin') {
                          Navigator.of(context).pushNamed('/fincas/manage');
                          return;
                        }
                      } catch (_) {}
                      Navigator.of(context).pushNamed(FincasScreen.routeName);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      elevation: 3,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Text('Ver Fincas',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  )),
                ]),

                SizedBox(height: 26),

                SizedBox(height: 12),
                // Mostrar exactamente 2 tarjetas: una Finca y una Ruta
                if (products.items.isNotEmpty) ...[
                  Text('Algunas experiencias',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  // Rutas carousel (existing)
                  Builder(builder: (ctx) {
                    final rutas = products.items
                        .where((p) => p.category == 'Rutas')
                        .toList();
                    rutas.sort((a, b) => b.popularity.compareTo(a.popularity));
                    final list = rutas.take(4).toList();
                    return SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final p = list[i];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                ProductDetailScreen.routeName,
                                arguments: p.id),
                            child: Container(
                              width: 260,
                              child: Card(
                                color: Color.fromRGBO(255, 255, 255, 0.06),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                clipBehavior: Clip.hardEdge,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(p.imageUrl,
                                              width: 92,
                                              height: 84,
                                              fit: BoxFit.cover)),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(p.name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            SizedBox(height: 6),
                                            Text(p.description,
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            SizedBox(height: 8),
                                            Text(
                                                'COP ${p.price.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  SizedBox(height: 16),
                  // Fincas carousel (new)
                  Text('Fincas recomendadas',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Builder(builder: (ctx) {
                    final fincas = products.items
                        .where((p) => p.category == 'Fincas')
                        .toList();
                    fincas.sort((a, b) => b.popularity.compareTo(a.popularity));
                    final list = fincas.take(4).toList();
                    return SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12),
                        itemBuilder: (ctx, i) {
                          final p = list[i];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                ProductDetailScreen.routeName,
                                arguments: p.id),
                            child: Container(
                              width: 260,
                              child: Card(
                                color: Color.fromRGBO(255, 255, 255, 0.06),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                clipBehavior: Clip.hardEdge,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(p.imageUrl,
                                              width: 92,
                                              height: 84,
                                              fit: BoxFit.cover)),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(p.name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            SizedBox(height: 6),
                                            Text(p.description,
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            SizedBox(height: 8),
                                            Text(
                                                'COP ${p.price.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontWeight:
                                                        FontWeight.bold))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  })
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}

// removed _QuickTile — quick tiles replaced with top buttons only
