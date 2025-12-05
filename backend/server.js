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
app.use('/api/auth', authRoutes);

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
  console.log(`📚 Endpoints disponibles:`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/login`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/register`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/profile`);
  console.log(`   POST   http://localhost:${PORT}/api/auth/logout`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/users (admin)`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/users/:id (admin)`);
  console.log(`   PUT    http://localhost:${PORT}/api/auth/users/:id (admin/propio)`);
  console.log(`   DELETE http://localhost:${PORT}/api/auth/users/:id (admin)`);
  console.log(`   GET    http://localhost:${PORT}/api/auth/users/public (público)\n`);
});

module.exports = app;
