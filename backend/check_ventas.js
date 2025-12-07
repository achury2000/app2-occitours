const db = require('./config/database');

db.query(`
  SELECT column_name, data_type 
  FROM information_schema.columns 
  WHERE table_name = 'ventas' 
  ORDER BY ordinal_position
`)
.then(result => {
  console.log('Columnas de la tabla ventas:');
  result.rows.forEach(col => {
    console.log(`  ${col.column_name}: ${col.data_type}`);
  });
  
  // También verificar si existe la tabla
  return db.query(`SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'ventas')`);
})
.then(result => {
  console.log('\n¿Existe la tabla ventas?', result.rows[0].exists);
  process.exit(0);
})
.catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
