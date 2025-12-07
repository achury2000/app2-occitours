import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';
import 'product_detail_screen.dart';
// imports intentionally minimal for this screen
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final products = Provider.of<ProductsProvider>(context, listen: false);
      products.loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductsProvider>(context);

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
          // Background GIF animado
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://media.giphy.com/media/v1.Y2lkPWVjZjA1ZTQ3M3oybjA0MDF0dTVncjcwMTBocmJua3VrMjhpM3ZoOXl2N3QyajhtcSZlcD12MV9naWZzX3JlbGF0ZWQmY3Q9Zw/sQ8hBISEvSdfeuqJs8/giphy.gif',
                ),
                fit: BoxFit.cover,
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
                // Logo de Occitours
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpvD2NuGT4_7VIryWjPy-9WChb-K7ntAa-fg&s',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.landscape,
                            size: 80,
                            color: Colors.green,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Mensaje de bienvenida
                Center(
                  child: Text(
                    '¡Bienvenidos a Occitours!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                Text('Descubre la Naturaleza Colombiana',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                    textAlign: TextAlign.center),
                SizedBox(height: 8),
                Text('Turismo de Naturaleza',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                SizedBox(height: 12),
                Text(
                    'Aventuras únicas en paisajes espectaculares con guías expertos y experiencias auténticas',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center),
                SizedBox(height: 18),
                // Mensaje de inicio de sesión
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Inicia sesión para explorar nuestro catálogo completo de rutas y fincas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

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
