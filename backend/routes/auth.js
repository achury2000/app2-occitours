const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
const { verificarToken, verificarRol } = require('../middleware/auth');

const router = express.Router();

// ========================================
// POST /api/auth/login - Inicio de sesión
// ========================================
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validar campos
    if (!email || !password) {
      return res.status(400).json({ 
        error: 'Campos incompletos',
        message: 'Email y contraseña son obligatorios' 
      });
    }

    // Buscar usuario con su rol
    const result = await db.query(
      `SELECT u.id, u.nombre, u.apellido, u.cedula, u.email, u.password_hash, 
              u.rol_id, u.activo, r.nombre as rol_nombre
       FROM usuarios u
       INNER JOIN roles r ON u.rol_id = r.id
       WHERE u.email = $1`,
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas',
        message: 'Email o contraseña incorrectos' 
      });
    }

    const usuario = result.rows[0];

    // Verificar si está activo
    if (!usuario.activo) {
      return res.status(403).json({ 
        error: 'Cuenta inactiva',
        message: 'Tu cuenta ha sido desactivada. Contacta al administrador' 
      });
    }

    // Verificar contraseña
    const passwordValido = await bcrypt.compare(password, usuario.password_hash);
    if (!passwordValido) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas',
        message: 'Email o contraseña incorrectos' 
      });
    }

    // Generar JWT (expira en 5 minutos)
    const token = jwt.sign(
      { 
        id: usuario.id,
        email: usuario.email,
        rol_id: usuario.rol_id,
        rol_nombre: usuario.rol_nombre
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.json({
      success: true,
      message: 'Login exitoso',
      token,
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        cedula: usuario.cedula,
        email: usuario.email,
        rol: usuario.rol_nombre
      }
    });

  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// POST /api/auth/register - Registro de cliente
// ================================================
router.post('/register', async (req, res) => {
  try {
    const { nombre, apellido, cedula, email, password, telefono } = req.body;

    // Validar campos obligatorios
    if (!nombre || !apellido || !cedula || !email || !password) {
      return res.status(400).json({ 
        error: 'Campos incompletos',
        message: 'Nombre, apellido, cédula, email y contraseña son obligatorios' 
      });
    }

    // Validar longitud de contraseña
    if (password.length < 6) {
      return res.status(400).json({ 
        error: 'Contraseña débil',
        message: 'La contraseña debe tener al menos 6 caracteres' 
      });
    }

    // Verificar si el email ya existe
    const emailExiste = await db.query(
      'SELECT id FROM usuarios WHERE email = $1',
      [email]
    );
    if (emailExiste.rows.length > 0) {
      return res.status(409).json({ 
        error: 'Email duplicado',
        message: 'Este email ya está registrado' 
      });
    }

    // Verificar si la cédula ya existe
    const cedulaExiste = await db.query(
      'SELECT id FROM usuarios WHERE cedula = $1',
      [cedula]
    );
    if (cedulaExiste.rows.length > 0) {
      return res.status(409).json({ 
        error: 'Cédula duplicada',
        message: 'Esta cédula ya está registrada' 
      });
    }

    // Obtener ID del rol "cliente"
    const rolCliente = await db.query(
      "SELECT id FROM roles WHERE nombre = 'cliente' LIMIT 1"
    );
    if (rolCliente.rows.length === 0) {
      return res.status(500).json({ 
        error: 'Error de configuración',
        message: 'Rol de cliente no encontrado en el sistema' 
      });
    }

    // Hash de la contraseña
    const passwordHash = await bcrypt.hash(password, 10);

    // Insertar usuario
    const nuevoUsuario = await db.query(
      `INSERT INTO usuarios (nombre, apellido, cedula, email, password_hash, rol_id, activo)
       VALUES ($1, $2, $3, $4, $5, $6, TRUE)
       RETURNING id, nombre, apellido, cedula, email`,
      [nombre, apellido, cedula, email, passwordHash, rolCliente.rows[0].id]
    );

    const usuario = nuevoUsuario.rows[0];

    // Crear registro en tabla clientes
    await db.query(
      `INSERT INTO clientes (nombre, cedula, email, telefono)
       VALUES ($1, $2, $3, $4)`,
      [
        `${nombre} ${apellido}`,
        cedula,
        email,
        telefono || null
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Usuario registrado exitosamente',
      usuario: {
        id: usuario.id,
        nombre: usuario.nombre,
        apellido: usuario.apellido,
        cedula: usuario.cedula,
        email: usuario.email,
        rol: 'cliente'
      }
    });

  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/auth/profile - Perfil del usuario
// ================================================
router.get('/profile', verificarToken, async (req, res) => {
  try {
    const result = await db.query(
      `SELECT u.id, u.nombre, u.apellido, u.cedula, u.email, 
              u.activo, u.fecha_registro,
              r.nombre as rol
       FROM usuarios u
       INNER JOIN roles r ON u.rol_id = r.id
       WHERE u.id = $1`,
      [req.usuario.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Usuario no encontrado' 
      });
    }

    res.json({
      success: true,
      usuario: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo perfil:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// POST /api/auth/logout - Cerrar sesión
// ================================================
router.post('/logout', verificarToken, (req, res) => {
  // En JWT no hay sesión en servidor, solo informamos al cliente
  // El cliente debe eliminar el token
  res.json({
    success: true,
    message: 'Sesión cerrada exitosamente'
  });
});

// ================================================
// GET /api/auth/users - Listar todos los usuarios (solo admin)
// ================================================
router.get('/users', verificarToken, verificarRol(['admin']), async (req, res) => {
  try {
    const result = await db.query(
      `SELECT u.id, u.nombre, u.apellido, u.cedula, u.email, 
              u.activo, r.nombre as rol
       FROM usuarios u
       INNER JOIN roles r ON u.rol_id = r.id
       ORDER BY u.id DESC`
    );

    res.json({
      success: true,
      usuarios: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo usuarios:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/auth/users/public - Listar usuarios (público, sin auth)
// ================================================
router.get('/users/public', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT u.id, u.nombre, u.apellido, u.cedula, u.email, 
              u.activo, r.nombre as rol
       FROM usuarios u
       INNER JOIN roles r ON u.rol_id = r.id
       ORDER BY u.id DESC`
    );

    res.json({
      success: true,
      usuarios: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo usuarios:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;

