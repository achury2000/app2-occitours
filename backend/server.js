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
app.use('/api/auth', authRoutes);
app.use('/api/roles', rolesRoutes);
app.use('/api/reservas', reservasRoutes);

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
  console.log(`   GET    http://localhost:${PORT}/api/reservas/cliente/:cliente_id\n`);
  console.log(`✅ Conectado a PostgreSQL`);
});

module.exports = app;
