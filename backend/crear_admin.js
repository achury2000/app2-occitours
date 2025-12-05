const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || "Occi's",
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'wilfredo4'
});

async function crearAdmin() {
  try {
    // Hashear contraseña
    const passwordHash = await bcrypt.hash('admin123', 10);
    
    // Insertar o actualizar usuario admin
    const query = `
      INSERT INTO usuarios (nombre, apellido, cedula, email, password_hash, rol_id, activo)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (email) 
      DO UPDATE SET password_hash = EXCLUDED.password_hash, rol_id = EXCLUDED.rol_id, activo = EXCLUDED.activo
      RETURNING id, email, nombre, apellido;
    `;
    
    const values = ['Admin', 'Sistema', '00000000', 'admin@occitours.com', passwordHash, 1, true];
    const result = await pool.query(query, values);
    
    console.log('✅ Usuario admin creado/actualizado:');
    console.log(result.rows[0]);
    console.log('\n📧 Email: admin@occitours.com');
    console.log('🔑 Contraseña: admin123');
    
    await pool.end();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

crearAdmin();
