const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas
const authRoutes = require('./routes/auth');
const rolesRoutes = require('./routes/roles');
const reservasRoutes = require('./routes/reservas');
const clientesRoutes = require('./routes/clientes');
const fincasRoutes = require('./routes/fincas');
const serviciosRoutes = require('./routes/servicios');
const rutasRoutes = require('./routes/rutas');
const programacionesRoutes = require('./routes/programaciones');
const ventasRoutes = require('./routes/ventas');
const dashboardRoutes = require('./routes/dashboard');

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

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({ 
    message: '🚀 API Occitours funcionando',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth'
    }
  });
});

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({ 
    error: 'Ruta no encontrada',
    message: `La ruta ${req.method} ${req.url} no existe` 
  });
});

// Manejo de errores global
app.use((err, req, res, next) => {
  console.error('❌ Error no manejado:', err);
  res.status(500).json({
    error: 'Error interno del servidor',
    message: err.message
  });
});

// Capturar errores no manejados del proceso
process.on('uncaughtException', (err) => {
  console.error('💥 Excepción no capturada:', err);
  console.error('Stack:', err.stack);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('💥 Promesa rechazada no manejada:', reason);
  console.error('Promesa:', promise);
});

// Iniciar servidor en 0.0.0.0 para permitir conexiones desde emulador Android
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
