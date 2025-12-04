-- ============================================================
-- OCCITOURS - Datos Iniciales (Seeds)
-- Datos de prueba para desarrollo y testing
-- ============================================================

-- ============================================================
-- 1. ROLES Y PERMISOS
-- ============================================================

INSERT INTO roles (nombre) VALUES
('admin'),
('cliente'),
('empleado'),
('guia'),
('asesor');

INSERT INTO permisos (nombre) VALUES
('gestionar_usuarios'),
('ver_usuarios'),
('gestionar_servicios'),
('ver_servicios'),
('crear_reservas'),
('ver_reservas_propias'),
('ver_todas_reservas'),
('gestionar_reservas'),
('crear_ventas'),
('ver_ventas'),
('gestionar_proveedores'),
('ver_dashboard'),
('gestionar_fincas'),
('gestionar_rutas');

-- Asignar permisos a roles
-- Admin: todos los permisos (IDs 1-14)
INSERT INTO rol_permiso (rol_id, permiso_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11), (1, 12), (1, 13), (1, 14);

-- Cliente: permisos básicos
INSERT INTO rol_permiso (rol_id, permiso_id) VALUES
(2, 4), -- ver_servicios
(2, 5), -- crear_reservas
(2, 6); -- ver_reservas_propias

-- Asesor: permisos operativos
INSERT INTO rol_permiso (rol_id, permiso_id) VALUES
(5, 4), -- ver_servicios
(5, 5), -- crear_reservas
(5, 7), -- ver_todas_reservas
(5, 8), -- gestionar_reservas
(5, 9), -- crear_ventas
(5, 10); -- ver_ventas

-- ============================================================
-- 2. USUARIOS
-- ============================================================

-- Contraseña: "123456" (hash bcrypt)
INSERT INTO usuarios (nombre, apellido, cedula, email, password_hash, rol_id, activo) VALUES
('Yeison', 'Uribe', '1234567890', 'admin@occitours.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye3jJc1W0f.KqRoJt3VUH7T6pYL6zQ9rC', 1, TRUE),
('Jose', 'Ramirez', '1234567891', 'asesor@occitours.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye3jJc1W0f.KqRoJt3VUH7T6pYL6zQ9rC', 5, TRUE),
('Maria', 'Lopez', '1234567892', 'cliente@demo.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye3jJc1W0f.KqRoJt3VUH7T6pYL6zQ9rC', 2, TRUE),
('Carlos', 'Mendez', '1234567893', 'guia@occitours.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye3jJc1W0f.KqRoJt3VUH7T6pYL6zQ9rC', 4, TRUE);

-- ============================================================
-- 3. CLIENTES Y EMPLEADOS
-- ============================================================

INSERT INTO clientes (nombre, cedula, email, telefono) VALUES
('Maria Lopez', '1234567892', 'cliente@demo.com', '3001112222'),
('Ana Garcia', '1234567894', 'cliente2@demo.com', '3009998888');

INSERT INTO empleados (nombre, cargo) VALUES
('Yeison Uribe', 'Administrador'),
('Jose Ramirez', 'Asesor Comercial'),
('Carlos Mendez', 'Guía Turístico');

-- ============================================================
-- 4. PROVEEDORES
-- ============================================================

INSERT INTO tipos_proveedores (nombre) VALUES
('Transporte'),
('Alimentos'),
('Hospedaje'),
('Actividades');

INSERT INTO proveedores (nombre, tipo_id) VALUES
('Transportes Andes', 1),
('Catering Delicias', 2),
('Finca El Paraíso', 3);

-- ============================================================
-- 5. SERVICIOS
-- ============================================================

INSERT INTO servicios (nombre, precio) VALUES
-- Alojamiento
('Habitación Estándar', 120000),
('Habitación Doble', 180000),
('Cabaña Familiar', 300000),
-- Alimentación
('Desayuno', 25000),
('Almuerzo', 35000),
('Cena', 35000),
('Refrigerio', 15000),
-- Actividades
('Parapente', 150000),
('Cabalgata', 80000),
('Senderismo', 50000),
('Tour Café', 60000),
('Canopy', 120000),
('Yoga', 40000);

-- ============================================================
-- 6. FINCAS
-- ============================================================

INSERT INTO fincas (nombre, capacidad) VALUES
('Finca La Esperanza', 50),
('Villa Naturaleza', 30),
('Hacienda El Sol', 40);

-- ============================================================
-- 7. RUTAS
-- ============================================================

INSERT INTO rutas (nombre, duracion_horas) VALUES
('Ruta del Café', 6),
('Aventura Extrema', 8),
('Ecoturismo Verde', 5);

-- ============================================================
-- 8. PROGRAMACIONES
-- ============================================================

INSERT INTO programaciones (fecha, hora, guia_id) VALUES
('2025-12-10', '08:00:00', 3),
('2025-12-14', '09:00:00', 3),
('2025-12-15', '10:00:00', 3);

INSERT INTO programacion_ruta (programacion_id, ruta_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- ============================================================
-- 9. VENTAS
-- ============================================================

INSERT INTO ventas (cliente_id, asesor_id, fecha, total, estado) VALUES
(1, 2, '2025-11-25', 350000, 'pagada'),
(2, 2, '2025-11-28', 480000, 'pagada');

-- ============================================================
-- 10. RESERVAS
-- ============================================================

INSERT INTO reservas (cliente_id, venta_id, programacion_id, finca_id, fecha, estado, numero_personas, precio_total) VALUES
(1, 1, 1, 1, '2025-12-10', 'confirmada', 4, 350000),
(2, 2, 3, 2, '2025-12-15', 'confirmada', 3, 480000);

INSERT INTO reserva_servicio (reserva_id, servicio_id, cantidad, precio_unitario) VALUES
-- Reserva 1
(1, 4, 4, 25000), -- Desayuno
(1, 11, 4, 60000), -- Tour Café
(1, 5, 4, 35000), -- Almuerzo
-- Reserva 2
(2, 3, 1, 300000), -- Cabaña Familiar
(2, 4, 3, 25000), -- Desayuno
(2, 10, 3, 50000); -- Senderismo

-- ============================================================
-- 11. ABONOS
-- ============================================================

INSERT INTO abonos (venta_id, fecha, monto) VALUES
(1, '2025-11-25', 350000),
(2, '2025-11-28', 480000);

-- ============================================================
-- 12. PAGOS A PROVEEDORES
-- ============================================================

INSERT INTO pagos_proveedores (proveedor_id, fecha, monto) VALUES
(1, '2025-11-30', 500000),
(2, '2025-11-30', 800000);

-- ============================================================
-- 13. DASHBOARD
-- ============================================================

INSERT INTO dashboard (fecha, metrica, valor) VALUES
('2025-11-01', 'reservas_totales', 45),
('2025-11-01', 'ingresos_diarios', 2500000),
('2025-11-15', 'reservas_totales', 52),
('2025-11-15', 'ingresos_diarios', 3200000),
('2025-12-01', 'reservas_totales', 38),
('2025-12-01', 'ingresos_diarios', 2800000),
('2025-12-01', 'clientes_nuevos', 8);

-- ============================================================
-- FIN DE SEEDS
-- ============================================================
