/**
 * =============================================
 * RUTAS.JS - GESTIÓN DE RUTAS TURÍSTICAS
 * =============================================
 * 
 * Maneja las operaciones CRUD para rutas turísticas.
 * Las rutas son itinerarios de naturaleza y aventura
 * con duración y actividades específicas.
 * 
 * ENDPOINTS:
 * - GET  /          - Listar todas las rutas
 * - GET  /:id       - Obtener detalles de una ruta
 * 
 * MODELO:
 * Ruta { id, nombre, duracion_horas }
 * 
 * USO:
 * Consumido por el catálogo de rutas en Flutter.
 */

const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/rutas - Listar todas las rutas
// ================================================
/**
 * Obtiene el listado completo de rutas turísticas.
 * 
 * RESPONSE:
 * {
 *   rutas: [ { id, nombre, duracion_horas }, ... ],
 *   total: 15
 * }
 */
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id, nombre, duracion_horas
       FROM rutas
       ORDER BY nombre ASC`
    );

    res.json({
      success: true,
      rutas: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo rutas:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/rutas/:id - Obtener ruta por ID
// ================================================
/**
 * Obtiene los detalles de una ruta específica.
 * 
 * PARAMS:
 * - id: ID de la ruta
 * 
 * RESPONSE:
 * { ruta: { id, nombre, duracion_horas } }
 */
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT id, nombre, duracion_horas
       FROM rutas
       WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Ruta no encontrada',
        message: `No existe una ruta con ID ${id}` 
      });
    }

    res.json({
      success: true,
      ruta: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo ruta:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
