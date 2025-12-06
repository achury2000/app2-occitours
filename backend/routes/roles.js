const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ========================================
// ROLES
// ========================================

// ================================================
// GET /api/roles - Listar todos los roles (público)
// ================================================
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id, nombre 
       FROM roles 
       ORDER BY id ASC`
    );

    res.json({
      success: true,
      roles: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo roles:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/roles/:id - Obtener rol por ID con sus permisos (público)
// ================================================
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Obtener rol
    const rolResult = await db.query(
      'SELECT id, nombre FROM roles WHERE id = $1',
      [id]
    );

    if (rolResult.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Rol no encontrado',
        message: `No existe un rol con ID ${id}` 
      });
    }

    // Obtener permisos del rol
    const permisosResult = await db.query(
      `SELECT p.id, p.nombre 
       FROM permisos p
       INNER JOIN rol_permiso rp ON p.id = rp.permiso_id
       WHERE rp.rol_id = $1
       ORDER BY p.nombre`,
      [id]
    );

    const rol = rolResult.rows[0];
    rol.permisos = permisosResult.rows;

    res.json({
      success: true,
      rol: rol
    });

  } catch (error) {
    console.error('Error obteniendo rol:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// POST /api/roles - Crear nuevo rol (público)
// ================================================
router.post('/', async (req, res) => {
  try {
    const { nombre } = req.body;

    // Validar campos obligatorios
    if (!nombre) {
      return res.status(400).json({ 
        error: 'Campos incompletos',
        message: 'El nombre del rol es obligatorio' 
      });
    }

    // Verificar si el rol ya existe
    const rolExiste = await db.query(
      'SELECT id FROM roles WHERE nombre = $1',
      [nombre]
    );
    if (rolExiste.rows.length > 0) {
      return res.status(409).json({ 
        error: 'Rol duplicado',
        message: 'Este rol ya existe' 
      });
    }

    // Insertar rol
    const result = await db.query(
      `INSERT INTO roles (nombre)
       VALUES ($1)
       RETURNING id, nombre`,
      [nombre]
    );

    res.status(201).json({
      success: true,
      message: 'Rol creado exitosamente',
      rol: result.rows[0]
    });

  } catch (error) {
    console.error('Error creando rol:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// PUT /api/roles/:id - Actualizar rol (público)
// ================================================
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre } = req.body;

    console.log('🔧 PUT /roles/:id');
    console.log('   ID a actualizar:', id);
    console.log('   Nuevo nombre:', nombre);

    // Verificar que el rol existe
    const rolExiste = await db.query(
      'SELECT id FROM roles WHERE id = $1',
      [id]
    );
    if (rolExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Rol no encontrado',
        message: `No existe un rol con ID ${id}` 
      });
    }

    // Verificar si el nuevo nombre ya existe (si se está cambiando)
    if (nombre) {
      const nombreExiste = await db.query(
        'SELECT id FROM roles WHERE nombre = $1 AND id != $2',
        [nombre, id]
      );
      if (nombreExiste.rows.length > 0) {
        return res.status(409).json({ 
          error: 'Nombre duplicado',
          message: 'Este nombre de rol ya está siendo usado' 
        });
      }
    }

    // Actualizar rol
    const result = await db.query(
      `UPDATE roles 
       SET nombre = COALESCE($1, nombre)
       WHERE id = $2
       RETURNING id, nombre`,
      [nombre, id]
    );

    res.json({
      success: true,
      message: 'Rol actualizado exitosamente',
      rol: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando rol:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// DELETE /api/roles/:id - Eliminar rol (público)
// ================================================
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    console.log('🗑️  DELETE /roles/:id');
    console.log('   ID a eliminar:', id);

    // Verificar que el rol existe
    const rolExiste = await db.query(
      'SELECT id, nombre FROM roles WHERE id = $1',
      [id]
    );
    if (rolExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Rol no encontrado',
        message: `No existe un rol con ID ${id}` 
      });
    }

    // Verificar que no sea un rol del sistema (admin, cliente, guia)
    const rolNombre = rolExiste.rows[0].nombre.toLowerCase();
    if (['admin', 'cliente', 'guia'].includes(rolNombre)) {
      return res.status(400).json({ 
        error: 'Operación no permitida',
        message: 'No puedes eliminar roles del sistema (admin, cliente, guia)' 
      });
    }

    // Verificar que no haya usuarios con este rol
    const usuariosConRol = await db.query(
      'SELECT COUNT(*) as count FROM usuarios WHERE rol_id = $1',
      [id]
    );

    if (parseInt(usuariosConRol.rows[0].count) > 0) {
      return res.status(409).json({ 
        error: 'No se puede eliminar',
        message: `Hay ${usuariosConRol.rows[0].count} usuario(s) con este rol. Reasígnalos primero.` 
      });
    }

    // Eliminar permisos del rol primero (por la FK)
    await db.query('DELETE FROM rol_permiso WHERE rol_id = $1', [id]);
    
    // Eliminar el rol
    await db.query('DELETE FROM roles WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Rol eliminado exitosamente',
      id: parseInt(id)
    });

  } catch (error) {
    console.error('Error eliminando rol:', error);
    
    // Manejar errores de foreign key
    if (error.code === '23503') {
      return res.status(409).json({ 
        error: 'No se puede eliminar',
        message: 'El rol tiene registros relacionados.' 
      });
    }

    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
