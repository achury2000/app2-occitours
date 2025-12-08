/**
 * =============================================
 * SERVER.JS - SERVIDOR BACKEND OCCITOURS
 * =============================================
 * 
 * Servidor Express que gestiona la API REST para la aplicación Occitours.
 * Proporciona endpoints para autenticación, gestión de reservas, ventas,
 * dashboard, y administración de recursos turísticos.
 * 
 * ARQUITECTURA:
 * - Express.js como framework web
 * - PostgreSQL como base de datos
 * - JWT para autenticación
 * - CORS habilitado para Flutter app
 * 
 * PUERTO: 3000 (por defecto)
 * HOST: 0.0.0.0 (permite conexiones desde emulador Android)
 * 
 * ENDPOINTS PRINCIPALES:
 * - /api/auth       - Autenticación y usuarios
 * - /api/reservas   - Gestión de reservas
 * - /api/ventas     - Gestión de ventas y pagos
 * - /api/dashboard  - Estadísticas y analytics
 * - /api/fincas     - Catálogo de fincas
 * - /api/rutas      - Catálogo de rutas
 * - /api/servicios  - Servicios adicionales
 */

const express = require('express');
const cors = require('cors');
require('dotenv').config(); // Carga variables de entorno desde .env

const app = express();
const PORT = process.env.PORT || 3000;

// =============================================
// MIDDLEWARES GLOBALES
// =============================================
// CORS: Permite peticiones desde cualquier origen (necesario para Flutter)
app.use(cors());
// JSON Parser: Convierte el body de las peticiones a objetos JavaScript
app.use(express.json());
// URL Encoded: Permite procesar formularios HTML
app.use(express.urlencoded({ extended: true }));

// =============================================
// IMPORTACIÓN DE RUTAS
// =============================================
// Cada archivo de routes maneja un recurso específico del sistema
const authRoutes = require('./routes/auth');                    // Autenticación y usuarios
const rolesRoutes = require('./routes/roles');                  // Gestión de roles
const reservasRoutes = require('./routes/reservas');            // Reservas de clientes
const clientesRoutes = require('./routes/clientes');            // Información de clientes
const fincasRoutes = require('./routes/fincas');                // Catálogo de fincas
const serviciosRoutes = require('./routes/servicios');          // Servicios adicionales
const rutasRoutes = require('./routes/rutas');                  // Rutas turísticas
const programacionesRoutes = require('./routes/programaciones');// Programación de rutas
const ventasRoutes = require('./routes/ventas');                // Ventas y pagos
const dashboardRoutes = require('./routes/dashboard');          // Estadísticas y analytics

// =============================================
// REGISTRO DE RUTAS EN LA APLICACIÓN
// =============================================
// Cada ruta se monta en un prefijo específico bajo /api
app.use('/api/auth', authRoutes);
app.use('/api/roles', rolesRoutes);
app.use('/api/reservas', reservasRoutes);
app.use('/api/clientes', clientesRoutes);
app.use('/api/fincas', fincasRoutes);
app.use('/api/servicios', serviciosRoutes);
app.use('/api/rutas', rutasRoutes);
app.use('/api/programaciones', programacionesRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/api/dashboard', dashboardRoutes);

// =============================================
// RUTA RAÍZ - Información de la API
// =============================================
app.get('/', (req, res) => {
  res.json({ 
    message: '🚀 API Occitours funcionando',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      reservas: '/api/reservas',
      ventas: '/api/ventas',
      dashboard: '/api/dashboard'
    }
  });
});

// =============================================
// MANEJO DE ERRORES
// =============================================
// 404 - Ruta no encontrada
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Ruta no encontrada',
    message: `La ruta ${req.method} ${req.url} no existe` 
  });
});

// 500 - Error interno del servidor
app.use((err, req, res, next) => {
  console.error('❌ Error no manejado:', err);
  res.status(500).json({
    error: 'Error interno del servidor',
    message: err.message
  });
});

// =============================================
// CAPTURA DE ERRORES NO MANEJADOS
// =============================================
// Previene que el servidor se caiga por errores no capturados
process.on('uncaughtException', (err) => {
  console.error('💥 Excepción no capturada:', err);
  console.error('Stack:', err.stack);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('💥 Promesa rechazada no manejada:', reason);
  console.error('Promesa:', promise);
});

// =============================================
// INICIO DEL SERVIDOR
// =============================================
// Escucha en 0.0.0.0 para permitir conexiones desde emulador Android
// El emulador Android usa 10.0.2.2 para acceder a localhost del host
app.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🚀 Servidor corriendo en http://localhost:${PORT}`);
  console.log(`📚 Endpoints disponibles (TODOS PÚBLICOS):`);
  console.log(`\n   === AUTENTICACIÓN ===`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/login`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/register`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/profile?id=X`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/logout`);
  console.log(`\n   === USUARIOS ===`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/users`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/users/:id`);
  console.log(`   PUT    http://localhost:${PORT}/api/auth/users/:id`);
  console.log(`   DELETE http://localhost:${PORT}/api/auth/users/:id`);
  console.log(`\n   === ROLES ===`);
  console.log(`   GET    http://localhost:${PORT}/api/roles`);
  console.log(`   GET    http://localhost:${PORT}/api/roles/:id`);
  console.log(`   POST   http://localhost:${PORT}/api/roles`);
  console.log(`   PUT    http://localhost:${PORT}/api/roles/:id`);
  console.log(`   DELETE http://localhost:${PORT}/api/roles/:id`);
  console.log(`\n   === RESERVAS ===`);
  console.log(`   GET    http://localhost:${PORT}/api/reservas`);
  console.log(`   GET    http://localhost:${PORT}/api/reservas/:id`);
  console.log(`   POST   http://localhost:${PORT}/api/reservas`);
  console.log(`   PUT    http://localhost:${PORT}/api/reservas/:id`);
  console.log(`   DELETE http://localhost:${PORT}/api/reservas/:id`);
  console.log(`   GET    http://localhost:${PORT}/api/reservas/cliente/:cliente_id`);
  console.log(`\n   === CLIENTES ===`);
  console.log(`   GET    http://localhost:${PORT}/api/clientes`);
  console.log(`   GET    http://localhost:${PORT}/api/clientes/:id`);
  console.log(`\n   === FINCAS ===`);
  console.log(`   GET    http://localhost:${PORT}/api/fincas`);
  console.log(`   GET    http://localhost:${PORT}/api/fincas/:id`);
  console.log(`\n   === SERVICIOS ===`);
  console.log(`   GET    http://localhost:${PORT}/api/servicios`);
  console.log(`   GET    http://localhost:${PORT}/api/servicios/:id`);
  console.log(`\n   === RUTAS ===`);
  console.log(`   GET    http://localhost:${PORT}/api/rutas`);
  console.log(`   GET    http://localhost:${PORT}/api/rutas/:id`);
  console.log(`\n   === PROGRAMACIONES ===`);
  console.log(`   GET    http://localhost:${PORT}/api/programaciones`);
  console.log(`   GET    http://localhost:${PORT}/api/programaciones/:id`);
  console.log(`\n   === VENTAS ===`);
  console.log(`   GET    http://localhost:${PORT}/api/ventas`);
  console.log(`   GET    http://localhost:${PORT}/api/ventas/:id`);
  console.log(`   POST   http://localhost:${PORT}/api/ventas`);
  console.log(`   PUT    http://localhost:${PORT}/api/ventas/:id`);
  console.log(`   DELETE http://localhost:${PORT}/api/ventas/:id`);
  console.log(`   POST   http://localhost:${PORT}/api/ventas/:id/abono`);
  console.log(`\n   === DASHBOARD ===`);
  console.log(`   GET    http://localhost:${PORT}/api/dashboard/stats`);
  console.log(`   GET    http://localhost:${PORT}/api/dashboard/ingresos-mensuales`);
  console.log(`   GET    http://localhost:${PORT}/api/dashboard/top-fincas`);
  console.log(`   GET    http://localhost:${PORT}/api/dashboard/top-rutas`);
  console.log(`   GET    http://localhost:${PORT}/api/dashboard/top-servicios`);
  console.log(`   GET    http://localhost:${PORT}/api/dashboard/reservas-recientes\n`);
});

module.exports = app;
