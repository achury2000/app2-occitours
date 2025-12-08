/**
 * =============================================
 * FINCAS.JS - GESTIÓN DE FINCAS TURÍSTICAS
 * =============================================
 * 
 * Maneja las operaciones CRUD para fincas turísticas.
 * Las fincas son propiedades rurales donde se realizan
 * actividades turísticas y de naturaleza.
 * 
 * ENDPOINTS:
 * - GET  /          - Listar todas las fincas
 * - GET  /:id       - Obtener detalles de una finca
 * 
 * MODELO:
 * Finca { id, nombre, capacidad }
 * 
 * USO:
 * Estos endpoints son consumidos por el catálogo de fincas
 * en la aplicación Flutter.
 */

const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/fincas - Listar todas las fincas
// ================================================
/**
 * Obtiene el listado completo de fincas disponibles.
 * 
 * RESPONSE:
 * {
 *   fincas: [ { id, nombre, capacidad }, ... ],
 *   total: 10
 * }
 */
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id, nombre, capacidad
       FROM fincas
       ORDER BY nombre ASC`
    );

    res.json({
      success: true,
      fincas: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo fincas:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/fincas/:id - Obtener finca por ID
// ================================================
/**
 * Obtiene los detalles de una finca específica.
 * 
 * PARAMS:
 * - id: ID de la finca
 * 
 * RESPONSE:
 * { finca: { id, nombre, capacidad } }
 */
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT id, nombre, capacidad
       FROM fincas
       WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Finca no encontrada',
        message: `No existe una finca con ID ${id}` 
      });
    }

    res.json({
      success: true,
      finca: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo finca:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
