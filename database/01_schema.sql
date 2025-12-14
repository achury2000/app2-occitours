-- ============================================================
-- OCCITOURS - Esquema de Base de Datos SIMPLIFICADO
-- Base de datos para sistema de reservas turísticas
-- Compatible con PostgreSQL 12+
-- ============================================================

-- ============================================================
-- AUTENTICACIÓN Y PERMISOS
-- ============================================================

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE permisos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE rol_permiso (
    rol_id INT NOT NULL,
    permiso_id INT NOT NULL,
    PRIMARY KEY (rol_id, permiso_id),
    FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE CASCADE
);

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    foto_perfil TEXT,
    fecha_nacimiento DATE,
    rol_id INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_cedula ON usuarios(cedula);

-- ============================================================
-- CLIENTES Y EMPLEADOS
-- ============================================================

CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) UNIQUE,
    tipo_documento VARCHAR(20) DEFAULT 'CC',
    email VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_nacimiento DATE
);

CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    cargo VARCHAR(100)
);

-- ============================================================
-- PROVEEDORES
-- ============================================================

CREATE TABLE tipos_proveedores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE proveedores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_id INT NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion TEXT,
    contacto_principal VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (tipo_id) REFERENCES tipos_proveedores(id)
);

-- ============================================================
-- CATÁLOGO (SERVICIOS, FINCAS, RUTAS)
-- ============================================================

CREATE TABLE servicios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) DEFAULT 0.00,
    categoria VARCHAR(50),
    imagen_url TEXT,
    disponible BOOLEAN DEFAULT TRUE
);

CREATE TABLE fincas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    direccion TEXT,
    ubicacion TEXT,
    precio_por_noche DECIMAL(10,2) DEFAULT 0.00,
    capacidad INT DEFAULT 0,
    imagen_principal TEXT,
    servicios_incluidos TEXT,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE rutas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_horas INT,
    precio DECIMAL(10,2) DEFAULT 0.00,
    dificultad VARCHAR(20) DEFAULT 'media',
    imagen_url TEXT,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE imagenes_fincas (
    id SERIAL PRIMARY KEY,
    finca_id INT NOT NULL,
    url TEXT NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    orden INT DEFAULT 0,
    FOREIGN KEY (finca_id) REFERENCES fincas(id) ON DELETE CASCADE
);

-- ============================================================
-- PROGRAMACIONES
-- ============================================================

CREATE TABLE programaciones (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    guia_id INT,
    cupos_disponibles INT DEFAULT 0,
    cupos_totales INT DEFAULT 0,
    estado VARCHAR(20) DEFAULT 'activa',
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (guia_id) REFERENCES empleados(id)
);

CREATE TABLE programacion_ruta (
    programacion_id INT NOT NULL,
    ruta_id INT NOT NULL,
    PRIMARY KEY (programacion_id, ruta_id),
    FOREIGN KEY (programacion_id) REFERENCES programaciones(id) ON DELETE CASCADE,
    FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE
);

-- ============================================================
-- VENTAS Y RESERVAS
-- ============================================================

CREATE TABLE ventas (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    asesor_id INT,
    fecha DATE NOT NULL,
    numero_factura VARCHAR(50) UNIQUE,
    total DECIMAL(10,2) NOT NULL,
    monto_pagado DECIMAL(10,2) DEFAULT 0.00,
    saldo_pendiente DECIMAL(10,2) DEFAULT 0.00,
    estado VARCHAR(20) DEFAULT 'pendiente',
    estado_pago VARCHAR(20) DEFAULT 'pendiente',
    observaciones TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (asesor_id) REFERENCIAS usuarios(id)
);

CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    programacion_id INT,
    finca_id INT,
    venta_id INT,
    estado VARCHAR(50) DEFAULT 'pendiente',
    fecha DATE NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    numero_personas INT DEFAULT 1,
    precio_total DECIMAL(10,2) DEFAULT 0.00,
    qr_code TEXT,
    comprobante_pago TEXT,
    notas TEXT,
    cancelado_por INT,
    fecha_cancelacion TIMESTAMP,
    motivo_cancelacion TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (programacion_id) REFERENCES programaciones(id),
    FOREIGN KEY (finca_id) REFERENCES fincas(id),
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    FOREIGN KEY (cancelado_por) REFERENCES usuarios(id)
);

CREATE TABLE reserva_servicio (
    reserva_id INT NOT NULL,
    servicio_id INT NOT NULL,
    cantidad INT DEFAULT 1,
    precio_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (reserva_id, servicio_id),
    FOREIGN KEY (reserva_id) REFERENCES reservas(id) ON DELETE CASCADE,
    FOREIGN KEY (servicio_id) REFERENCES servicios(id)
);

-- ============================================================
-- PAGOS
-- ============================================================

CREATE TABLE abonos (
    id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL,
    fecha DATE NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    metodo_pago VARCHAR(30) DEFAULT 'efectivo',
    numero_transaccion VARCHAR(100),
    comprobante_pago TEXT,
    estado VARCHAR(20) DEFAULT 'aprobado',
    FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE
);

CREATE TABLE pagos_proveedores (
    id SERIAL PRIMARY KEY,
    proveedor_id INT NOT NULL,
    fecha DATE NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

-- ============================================================
-- DASHBOARD
-- ============================================================

CREATE TABLE dashboard (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    metrica VARCHAR(100) NOT NULL,
    valor DECIMAL(10,2)
);

CREATE INDEX idx_dashboard_fecha ON dashboard(fecha);

-- ============================================================
-- ÍNDICES ADICIONALES
-- ============================================================

CREATE INDEX idx_clientes_cedula ON clientes(cedula);
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_reservas_fecha ON reservas(fecha);
CREATE INDEX idx_reservas_estado ON reservas(estado);
CREATE INDEX idx_reservas_cliente_id ON reservas(cliente_id);
CREATE INDEX idx_ventas_fecha ON ventas(fecha);
CREATE INDEX idx_ventas_estado_pago ON ventas(estado_pago);
CREATE INDEX idx_imagenes_fincas_finca_id ON imagenes_fincas(finca_id);

-- ============================================================
-- FIN DEL ESQUEMA
-- ============================================================
