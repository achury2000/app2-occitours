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

// ================================================
// GET /api/auth/users/:id - Obtener usuario por ID (admin)
// ================================================
router.get('/users/:id', verificarToken, verificarRol(['admin']), async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT u.id, u.nombre, u.apellido, u.cedula, u.email, 
              u.activo, u.fecha_registro, r.nombre as rol, u.rol_id
       FROM usuarios u
       INNER JOIN roles r ON u.rol_id = r.id
       WHERE u.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Usuario no encontrado',
        message: `No existe un usuario con ID ${id}` 
      });
    }

    res.json({
      success: true,
      usuario: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo usuario:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// PUT /api/auth/users/:id - Actualizar usuario (admin o el mismo usuario)
// ================================================
router.put('/users/:id', verificarToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, apellido, email, telefono, activo, rol_id } = req.body;

    console.log('🔧 PUT /users/:id - Usuario autenticado:', req.usuario);
    console.log('   ID a actualizar:', id);
    console.log('   Cambios:', { nombre, apellido, email, telefono, activo, rol_id });

    // Verificar permisos: solo admin o el propio usuario puede actualizar
    const esAdmin = req.usuario.rol_nombre === 'admin';
    const esElMismoUsuario = req.usuario.id == id;

    console.log('   Es admin?', esAdmin);
    console.log('   Es el mismo usuario?', esElMismoUsuario);

    if (!esAdmin && !esElMismoUsuario) {
      return res.status(403).json({ 
        error: 'Acceso denegado',
        message: 'No tienes permisos para actualizar este usuario' 
      });
    }

    // Si no es admin, no puede cambiar rol ni estado activo
    if (!esAdmin && (rol_id !== undefined || activo !== undefined)) {
      return res.status(403).json({ 
        error: 'Acceso denegado',
        message: 'No puedes cambiar el rol o estado de activación' 
      });
    }

    // Verificar que el usuario existe
    const usuarioExiste = await db.query(
      'SELECT id FROM usuarios WHERE id = $1',
      [id]
    );
    if (usuarioExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Usuario no encontrado',
        message: `No existe un usuario con ID ${id}` 
      });
    }

    // Verificar si el nuevo email ya existe (si se está cambiando)
    if (email) {
      const emailExiste = await db.query(
        'SELECT id FROM usuarios WHERE email = $1 AND id != $2',
        [email, id]
      );
      if (emailExiste.rows.length > 0) {
        return res.status(409).json({ 
          error: 'Email duplicado',
          message: 'Este email ya está siendo usado por otro usuario' 
        });
      }
    }

    // Construir query dinámicamente
    const campos = [];
    const valores = [];
    let contador = 1;

    if (nombre !== undefined) {
      campos.push(`nombre = $${contador}`);
      valores.push(nombre);
      contador++;
    }
    if (apellido !== undefined) {
      campos.push(`apellido = $${contador}`);
      valores.push(apellido);
      contador++;
    }
    if (email !== undefined) {
      campos.push(`email = $${contador}`);
      valores.push(email);
      contador++;
    }
    if (activo !== undefined && esAdmin) {
      campos.push(`activo = $${contador}`);
      valores.push(activo);
      contador++;
    }
    if (rol_id !== undefined && esAdmin) {
      campos.push(`rol_id = $${contador}`);
      valores.push(rol_id);
      contador++;
    }

    if (campos.length === 0) {
      return res.status(400).json({ 
        error: 'No hay campos para actualizar',
        message: 'Debes proporcionar al menos un campo para actualizar' 
      });
    }

    valores.push(id);
    const query = `
      UPDATE usuarios 
      SET ${campos.join(', ')}
      WHERE id = $${contador}
      RETURNING id, nombre, apellido, cedula, email, activo
    `;

    const result = await db.query(query, valores);

    // Si se actualizó el email, actualizar también en tabla clientes
    if (email) {
      await db.query(
        'UPDATE clientes SET email = $1 WHERE cedula = (SELECT cedula FROM usuarios WHERE id = $2)',
        [email, id]
      );
    }

    res.json({
      success: true,
      message: 'Usuario actualizado exitosamente',
      usuario: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando usuario:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// DELETE /api/auth/users/:id - Eliminar usuario (solo admin)
// ================================================
router.delete('/users/:id', verificarToken, verificarRol(['admin']), async (req, res) => {
  try {
    const { id } = req.params;

    console.log('🗑️  DELETE /users/:id - Usuario autenticado:', req.usuario);
    console.log('   ID a eliminar:', id);

    // Verificar que el usuario existe
    const usuarioExiste = await db.query(
      'SELECT id, cedula FROM usuarios WHERE id = $1',
      [id]
    );
    if (usuarioExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Usuario no encontrado',
        message: `No existe un usuario con ID ${id}` 
      });
    }

    // No permitir que el admin se elimine a sí mismo
    if (req.usuario.id == id) {
      return res.status(400).json({ 
        error: 'Operación no permitida',
        message: 'No puedes eliminar tu propia cuenta' 
      });
    }

    const cedula = usuarioExiste.rows[0].cedula;

    // Eliminar el usuario (las FKs deben manejarse según tu esquema)
    // Primero intentar eliminar de clientes si existe
    await db.query('DELETE FROM clientes WHERE cedula = $1', [cedula]);
    
    // Luego eliminar el usuario
    await db.query('DELETE FROM usuarios WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Usuario eliminado exitosamente',
      id: parseInt(id)
    });

  } catch (error) {
    console.error('Error eliminando usuario:', error);
    
    // Manejar errores de foreign key
    if (error.code === '23503') {
      return res.status(409).json({ 
        error: 'No se puede eliminar',
        message: 'El usuario tiene registros relacionados. Considera desactivarlo en lugar de eliminarlo.' 
      });
    }

    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;

