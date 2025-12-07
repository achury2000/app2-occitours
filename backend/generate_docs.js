const ExcelJS = require('exceljs');
const path = require('path');

// Definición de todas las tablas con su documentación
const tablas = [
  {
    nombre: 'roles',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 50, valor_defecto: '', null: '', unico: 'OK', indexado: '', observaciones: 'Nombre del rol (admin, cliente, asesor, guia)' }
    ]
  },
  {
    nombre: 'permisos',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 50, valor_defecto: '', null: '', unico: 'OK', indexado: '', observaciones: 'Nombre del permiso' }
    ]
  },
  {
    nombre: 'rol_permiso',
    campos: [
      { nombre: 'rol_id', llave_primaria: 'PK', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> roles(id)' },
      { nombre: 'permiso_id', llave_primaria: 'PK', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> permisos(id)' }
    ]
  },
  {
    nombre: 'usuarios',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'apellido', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'cedula', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'sin puntos y sin comas' },
      { nombre: 'email', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'siempre @' },
      { nombre: 'password_hash', llave_primaria: '', tipo: 'Varchar', tamaño: 255, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Hash bcrypt de la contraseña' },
      { nombre: 'rol_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> roles(id)' },
      { nombre: 'activo', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'TRUE', null: 'OK', unico: '', indexado: '', observaciones: 'Usuario activo/inactivo' }
    ]
  },
  {
    nombre: 'clientes',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'cedula', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: '', null: 'OK', unico: 'OK', indexado: '', observaciones: 'sin puntos y sin comas' },
      { nombre: 'email', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: '' },
      { nombre: 'telefono', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'sin puntos y sin comas' }
    ]
  },
  {
    nombre: 'empleados',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'cargo', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Ej: guía, asesor' }
    ]
  },
  {
    nombre: 'tipos_proveedores',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 50, valor_defecto: '', null: '', unico: 'OK', indexado: '', observaciones: 'Tipo de proveedor' }
    ]
  },
  {
    nombre: 'proveedores',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'tipo_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> tipos_proveedores(id)' }
    ]
  },
  {
    nombre: 'servicios',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'precio', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Precio del servicio' }
    ]
  },
  {
    nombre: 'fincas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'capacidad', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '0', null: 'OK', unico: '', indexado: '', observaciones: 'Capacidad máxima de personas' }
    ]
  },
  {
    nombre: 'rutas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'duracion_horas', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Duración en horas' }
    ]
  },
  {
    nombre: 'programaciones',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' },
      { nombre: 'hora', llave_primaria: '', tipo: 'TIME', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'HH:MM:SS' },
      { nombre: 'guia_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> empleados(id)' }
    ]
  },
  {
    nombre: 'programacion_ruta',
    campos: [
      { nombre: 'programacion_id', llave_primaria: 'PK', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> programaciones(id)' },
      { nombre: 'ruta_id', llave_primaria: 'PK', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> rutas(id)' }
    ]
  },
  {
    nombre: 'ventas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'cliente_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> clientes(id)' },
      { nombre: 'asesor_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> usuarios(id)' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' },
      { nombre: 'total', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Total de la venta' },
      { nombre: 'estado', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: 'pendiente', null: 'OK', unico: '', indexado: '', observaciones: 'pendiente, confirmada, cancelada' }
    ]
  },
  {
    nombre: 'reservas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'cliente_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> clientes(id)' },
      { nombre: 'programacion_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> programaciones(id)' },
      { nombre: 'finca_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> fincas(id)' },
      { nombre: 'venta_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> ventas(id)' },
      { nombre: 'estado', llave_primaria: '', tipo: 'Varchar', tamaño: 50, valor_defecto: 'pendiente', null: 'OK', unico: '', indexado: '', observaciones: 'pendiente, confirmada, pagada, cancelada' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' },
      { nombre: 'numero_personas', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '1', null: 'OK', unico: '', indexado: '', observaciones: 'Cantidad de personas' },
      { nombre: 'precio_total', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Precio total de la reserva' },
      { nombre: 'qr_code', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Código QR para pago' },
      { nombre: 'comprobante_pago', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'URL o path del comprobante' }
    ]
  },
  {
    nombre: 'reserva_servicio',
    campos: [
      { nombre: 'reserva_id', llave_primaria: 'PK', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> reservas(id)' },
      { nombre: 'servicio_id', llave_primaria: 'PK', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> servicios(id)' },
      { nombre: 'cantidad', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '1', null: 'OK', unico: '', indexado: '', observaciones: 'Cantidad del servicio' },
      { nombre: 'precio_unitario', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Precio unitario al momento de la reserva' }
    ]
  },
  {
    nombre: 'abonos',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'venta_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> ventas(id)' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' },
      { nombre: 'monto', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Monto del abono' }
    ]
  },
  {
    nombre: 'pagos_proveedores',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'proveedor_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> proveedores(id)' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' },
      { nombre: 'monto', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Monto del pago' }
    ]
  },
  {
    nombre: 'dashboard',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'DD/MM/AAAA' },
      { nombre: 'metrica', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Nombre de la métrica' },
      { nombre: 'valor', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Valor de la métrica' }
    ]
  }
];

async function generarExcel() {
  const workbook = new ExcelJS.Workbook();

  // Crear una hoja por cada tabla
  for (const tabla of tablas) {
    const worksheet = workbook.addWorksheet(tabla.nombre);

    // Establecer ancho de columnas
    worksheet.columns = [
      { width: 20 },  // A - Nombre de campo
      { width: 15 },  // B - Llave primaria
      { width: 15 },  // C - Tipo de dato
      { width: 10 },  // D - Tamaño
      { width: 18 },  // E - Valor por defecto
      { width: 10 },  // F - Null
      { width: 10 },  // G - Único
      { width: 12 },  // H - Indexado
      { width: 35 }   // I - Observaciones
    ];

    // Título de la tabla
    worksheet.mergeCells('A1:I1');
    const titleCell = worksheet.getCell('A1');
    titleCell.value = `Nombre de la tabla: ${tabla.nombre}`;
    titleCell.font = { size: 14, bold: true };
    titleCell.alignment = { vertical: 'middle', horizontal: 'center' };
    titleCell.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FFD9D9D9' }
    };

    // Encabezados
    const headers = ['Nombre de campo', 'Llave primaria', 'Tipo de dato', 'Tamaño', 'Valor por defecto', 'Null', 'Único', 'Indexado', 'Observaciones'];
    const headerRow = worksheet.getRow(2);
    headers.forEach((header, index) => {
      const cell = headerRow.getCell(index + 1);
      cell.value = header;
      cell.font = { bold: true, color: { argb: 'FFFFFFFF' } };
      cell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFFF0000' }
      };
      cell.alignment = { vertical: 'middle', horizontal: 'center' };
      cell.border = {
        top: { style: 'thin' },
        left: { style: 'thin' },
        bottom: { style: 'thin' },
        right: { style: 'thin' }
      };
    });

    // Datos de los campos
    tabla.campos.forEach((campo, index) => {
      const row = worksheet.getRow(index + 3);
      row.values = [
        campo.nombre,
        campo.llave_primaria,
        campo.tipo,
        campo.tamaño,
        campo.valor_defecto,
        campo.null,
        campo.unico,
        campo.indexado,
        campo.observaciones
      ];

      // Aplicar bordes y estilo
      for (let i = 1; i <= 9; i++) {
        const cell = row.getCell(i);
        cell.border = {
          top: { style: 'thin' },
          left: { style: 'thin' },
          bottom: { style: 'thin' },
          right: { style: 'thin' }
        };
        cell.alignment = { vertical: 'middle', horizontal: 'left' };
        
        // Color de fondo para celdas con "OK"
        if (cell.value === 'OK') {
          cell.fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'FF90EE90' }
          };
        }
      }
    });
  }

  // Guardar archivo
  const outputPath = path.join(__dirname, '../database/diccionario_datos_occitours.xlsx');
  await workbook.xlsx.writeFile(outputPath);
  console.log(`✅ Archivo Excel generado: ${outputPath}`);
}

generarExcel().catch(console.error);
