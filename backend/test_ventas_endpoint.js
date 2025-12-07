const http = require('http');

function testEndpoint(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve({ status: res.statusCode, data: result });
        } catch (e) {
          resolve({ status: res.statusCode, data: data });
        }
      });
    });

    req.on('error', (error) => reject(error));
    req.setTimeout(5000, () => {
      req.destroy();
      reject(new Error('Timeout'));
    });
    
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Probando endpoints de ventas...\n');
  
  try {
    console.log('1. GET /api/ventas');
    const result = await testEndpoint('/api/ventas');
    console.log(`   Status: ${result.status}`);
    console.log(`   Respuesta:`, JSON.stringify(result.data, null, 2));
    
    if (result.status === 200 && result.data.success) {
      console.log('   ✅ Endpoint funcionando correctamente\n');
    } else {
      console.log('   ❌ Endpoint devolvió un error\n');
    }
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}\n`);
  }
  
  process.exit(0);
}

// Esperar 2 segundos para que el servidor esté listo
setTimeout(runTests, 2000);
