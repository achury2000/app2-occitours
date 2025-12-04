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
    email VARCHAR(100),
    telefono VARCHAR(20)
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
    FOREIGN KEY (tipo_id) REFERENCES tipos_proveedores(id)
);

-- ============================================================
-- CATÁLOGO (SERVICIOS, FINCAS, RUTAS)
-- ============================================================

CREATE TABLE servicios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) DEFAULT 0.00
);

CREATE TABLE fincas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    capacidad INT DEFAULT 0
);

CREATE TABLE rutas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    duracion_horas INT
);

-- ============================================================
-- PROGRAMACIONES
-- ============================================================

CREATE TABLE programaciones (
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    guia_id INT,
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
    total DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) DEFAULT 'pendiente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (asesor_id) REFERENCES usuarios(id)
);

CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    programacion_id INT,
    finca_id INT,
    venta_id INT,
    estado VARCHAR(50) DEFAULT 'pendiente',
    fecha DATE NOT NULL,
    numero_personas INT DEFAULT 1,
    precio_total DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id),
    FOREIGN KEY (programacion_id) REFERENCES programaciones(id),
    FOREIGN KEY (finca_id) REFERENCES fincas(id),
    FOREIGN KEY (venta_id) REFERENCES ventas(id)
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
-- FIN DEL ESQUEMA
-- ============================================================
