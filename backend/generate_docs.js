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
      { nombre: 'telefono', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Teléfono del usuario' },
      { nombre: 'direccion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Dirección completa' },
      { nombre: 'foto_perfil', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'URL de la foto de perfil' },
      { nombre: 'fecha_nacimiento', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' },
      { nombre: 'rol_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> roles(id)' },
      { nombre: 'activo', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'TRUE', null: 'OK', unico: '', indexado: '', observaciones: 'Usuario activo/inactivo' }
    ]
  },
  {
    nombre: 'clientes',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'cedula', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: '', null: 'OK', unico: 'OK', indexado: 'OK', observaciones: 'sin puntos y sin comas' },
      { nombre: 'tipo_documento', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: 'CC', null: 'OK', unico: '', indexado: '', observaciones: 'CC, CE, Pasaporte' },
      { nombre: 'email', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: 'OK', unico: '', indexado: 'OK', observaciones: '' },
      { nombre: 'telefono', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'sin puntos y sin comas' },
      { nombre: 'direccion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Dirección completa' },
      { nombre: 'fecha_nacimiento', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' }
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
      { nombre: 'tipo_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'FK -> tipos_proveedores(id)' },
      { nombre: 'telefono', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Teléfono del proveedor' },
      { nombre: 'email', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Email del proveedor' },
      { nombre: 'direccion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Dirección del proveedor' },
      { nombre: 'contacto_principal', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Nombre del contacto principal' },
      { nombre: 'activo', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'TRUE', null: 'OK', unico: '', indexado: '', observaciones: 'Proveedor activo/inactivo' }
    ]
  },
  {
    nombre: 'servicios',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'descripcion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Descripción del servicio' },
      { nombre: 'precio', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Precio del servicio' },
      { nombre: 'categoria', llave_primaria: '', tipo: 'Varchar', tamaño: 50, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Categoría del servicio' },
      { nombre: 'imagen_url', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'URL de la imagen del servicio' },
      { nombre: 'disponible', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'TRUE', null: 'OK', unico: '', indexado: '', observaciones: 'Servicio disponible/no disponible' }
    ]
  },
  {
    nombre: 'fincas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'descripcion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Descripción de la finca' },
      { nombre: 'direccion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Dirección de la finca' },
      { nombre: 'ubicacion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Ubicación geográfica' },
      { nombre: 'precio_por_noche', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Precio por noche' },
      { nombre: 'capacidad', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '0', null: 'OK', unico: '', indexado: '', observaciones: 'Capacidad máxima de personas' },
      { nombre: 'imagen_principal', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'URL imagen principal' },
      { nombre: 'servicios_incluidos', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Servicios incluidos' },
      { nombre: 'activo', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'TRUE', null: 'OK', unico: '', indexado: '', observaciones: 'Finca activa/inactiva' }
    ]
  },
  {
    nombre: 'rutas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'nombre', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: '', unico: '', indexado: '', observaciones: '' },
      { nombre: 'descripcion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Descripción de la ruta' },
      { nombre: 'duracion_horas', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Duración en horas' },
      { nombre: 'precio', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Precio de la ruta' },
      { nombre: 'dificultad', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: 'media', null: 'OK', unico: '', indexado: '', observaciones: 'fácil, media, difícil' },
      { nombre: 'imagen_url', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'URL de la imagen de la ruta' },
      { nombre: 'activo', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'TRUE', null: 'OK', unico: '', indexado: '', observaciones: 'Ruta activa/inactiva' }
    ]
  },
  {
    nombre: 'programaciones',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'DD/MM/AAAA' },
      { nombre: 'hora', llave_primaria: '', tipo: 'TIME', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'HH:MM:SS' },
      { nombre: 'guia_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> empleados(id)' },
      { nombre: 'cupos_disponibles', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '0', null: 'OK', unico: '', indexado: '', observaciones: 'Cupos disponibles' },
      { nombre: 'cupos_totales', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '0', null: 'OK', unico: '', indexado: '', observaciones: 'Cupos totales' },
      { nombre: 'estado', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: 'activa', null: 'OK', unico: '', indexado: '', observaciones: 'activa, completada, cancelada' },
      { nombre: 'activo', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'TRUE', null: 'OK', unico: '', indexado: '', observaciones: 'Programación activa/inactiva' }
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
      { nombre: 'cliente_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> clientes(id)' },
      { nombre: 'asesor_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> usuarios(id)' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'DD/MM/AAAA' },
      { nombre: 'numero_factura', llave_primaria: '', tipo: 'Varchar', tamaño: 50, valor_defecto: '', null: 'OK', unico: 'OK', indexado: '', observaciones: 'Número de factura único' },
      { nombre: 'total', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Total de la venta' },
      { nombre: 'monto_pagado', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Monto pagado' },
      { nombre: 'saldo_pendiente', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Saldo pendiente' },
      { nombre: 'estado', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: 'pendiente', null: 'OK', unico: '', indexado: '', observaciones: 'pendiente, confirmada, cancelada' },
      { nombre: 'estado_pago', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: 'pendiente', null: 'OK', unico: '', indexado: 'OK', observaciones: 'pendiente, parcial, pagado' },
      { nombre: 'observaciones', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Observaciones de la venta' }
    ]
  },
  {
    nombre: 'reservas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'cliente_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> clientes(id)' },
      { nombre: 'programacion_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> programaciones(id)' },
      { nombre: 'finca_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> fincas(id)' },
      { nombre: 'venta_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> ventas(id)' },
      { nombre: 'estado', llave_primaria: '', tipo: 'Varchar', tamaño: 50, valor_defecto: 'pendiente', null: 'OK', unico: '', indexado: 'OK', observaciones: 'pendiente, confirmada, pagada, cancelada' },
      { nombre: 'fecha', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'DD/MM/AAAA' },
      { nombre: 'fecha_inicio', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Fecha inicio para fincas' },
      { nombre: 'fecha_fin', llave_primaria: '', tipo: 'DATE', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Fecha fin para fincas' },
      { nombre: 'numero_personas', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '1', null: 'OK', unico: '', indexado: '', observaciones: 'Cantidad de personas' },
      { nombre: 'precio_total', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '0.00', null: 'OK', unico: '', indexado: '', observaciones: 'Precio total de la reserva' },
      { nombre: 'qr_code', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Código QR para pago' },
      { nombre: 'comprobante_pago', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'URL o path del comprobante' },
      { nombre: 'notas', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Observaciones del cliente' },
      { nombre: 'cancelado_por', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'FK -> usuarios(id)' },
      { nombre: 'fecha_cancelacion', llave_primaria: '', tipo: 'TIMESTAMP', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Fecha y hora de cancelación' },
      { nombre: 'motivo_cancelacion', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Motivo de cancelación' }
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
      { nombre: 'monto', llave_primaria: '', tipo: 'DECIMAL', tamaño: '10,2', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'Monto del abono' },
      { nombre: 'metodo_pago', llave_primaria: '', tipo: 'Varchar', tamaño: 30, valor_defecto: 'efectivo', null: 'OK', unico: '', indexado: '', observaciones: 'efectivo, tarjeta, transferencia, nequi' },
      { nombre: 'numero_transaccion', llave_primaria: '', tipo: 'Varchar', tamaño: 100, valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'Número de transacción' },
      { nombre: 'comprobante_pago', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: 'OK', unico: '', indexado: '', observaciones: 'URL del comprobante' },
      { nombre: 'estado', llave_primaria: '', tipo: 'Varchar', tamaño: 20, valor_defecto: 'aprobado', null: 'OK', unico: '', indexado: '', observaciones: 'aprobado, pendiente, rechazado' }
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
  },
  {
    nombre: 'imagenes_fincas',
    campos: [
      { nombre: 'id', llave_primaria: 'PK', tipo: 'SERIAL', tamaño: '', valor_defecto: '', null: '', unico: 'OK', indexado: 'OK', observaciones: 'Autoincremental' },
      { nombre: 'finca_id', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: 'OK', observaciones: 'FK -> fincas(id)' },
      { nombre: 'url', llave_primaria: '', tipo: 'TEXT', tamaño: '', valor_defecto: '', null: '', unico: '', indexado: '', observaciones: 'URL de la imagen' },
      { nombre: 'es_principal', llave_primaria: '', tipo: 'BOOLEAN', tamaño: '', valor_defecto: 'FALSE', null: 'OK', unico: '', indexado: '', observaciones: 'Indica si es la imagen principal' },
      { nombre: 'orden', llave_primaria: '', tipo: 'INT', tamaño: '', valor_defecto: '0', null: 'OK', unico: '', indexado: '', observaciones: 'Orden de visualización' }
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
