// Test de require de ventas
console.log('Intentando cargar el módulo de ventas...');

try {
  const ventasRoutes = require('./routes/ventas');
  console.log('✅ Módulo de ventas cargado correctamente');
  console.log('Tipo:', typeof ventasRoutes);
  console.log('Es función:', typeof ventasRoutes === 'function');
  console.log('Stack:', ventasRoutes.stack);
} catch (error) {
  console.error('❌ Error al cargar módulo de ventas:');
  console.error(error);
}

process.exit(0);
