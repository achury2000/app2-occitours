import 'package:flutter/material.dart';

class ClientHomeScreen extends StatelessWidget {
  static const routeName = '/client/home';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio Cliente'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushNamed('/logout'),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner superior con imagen
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape, size: 60, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Bienvenido a Occi Tours',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Explora los mejores destinos',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Menú principal
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué deseas hacer?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Tarjeta: Hacer Reserva
                  _buildMenuCard(
                    context,
                    title: 'Nueva Reserva',
                    subtitle: 'Reserva tu próxima aventura',
                    icon: Icons.add_circle_outline,
                    color: Colors.blue,
                    route: '/client/new-reservation',
                  ),
                  SizedBox(height: 12),

                  // Tarjeta: Mis Reservas
                  _buildMenuCard(
                    context,
                    title: 'Mis Reservas',
                    subtitle: 'Ver reservas activas y su historial',
                    icon: Icons.calendar_today,
                    color: Colors.orange,
                    route: '/client/my-reservations',
                  ),
                  SizedBox(height: 12),

                  // Tarjeta: Catálogo
                  _buildMenuCard(
                    context,
                    title: 'Catálogo de Rutas y Paquetes',
                    subtitle: 'Explora nuestras ofertas turísticas',
                    icon: Icons.explore,
                    color: Colors.green,
                    route: '/client/catalog',
                  ),
                  SizedBox(height: 12),

                  // Tarjeta: Mi Perfil
                  _buildMenuCard(
                    context,
                    title: 'Mi Perfil',
                    subtitle: 'Actualizar información personal',
                    icon: Icons.person,
                    color: Colors.purple,
                    route: '/client/profile',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.grey.shade400, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
