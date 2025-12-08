/**
 * =============================================
 * SERVICIOS.JS - GESTIÓN DE SERVICIOS ADICIONALES
 * =============================================
 * 
 * Maneja los servicios adicionales que se pueden agregar
 * a las reservas (alimentación, transporte, guías, etc.).
 * 
 * ENDPOINTS:
 * - GET  /          - Listar todos los servicios
 * - GET  /:id       - Obtener detalles de un servicio
 * 
 * MODELO:
 * Servicio { id, nombre, precio }
 * 
 * RELACIONES:
 * - Los servicios se asocian a reservas mediante reserva_servicio
 * - Una reserva puede tener múltiples servicios
 * 
 * USO:
 * Al crear/editar reservas, se seleccionan servicios adicionales.
 */

const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/servicios - Listar todos los servicios
// ================================================
/**
 * Obtiene el catálogo completo de servicios adicionales.
 * 
 * RESPONSE:
 * {
 *   servicios: [ { id, nombre, precio }, ... ],
 *   total: 8
 * }
 */
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id, nombre, precio
       FROM servicios
       ORDER BY nombre ASC`
    );

    res.json({
      success: true,
      servicios: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo servicios:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/servicios/:id - Obtener servicio por ID
// ================================================
/**
 * Obtiene los detalles de un servicio específico.
 * 
 * PARAMS:
 * - id: ID del servicio
 * 
 * RESPONSE:
 * { servicio: { id, nombre, precio } }
 */
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT id, nombre, precio
       FROM servicios
       WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Servicio no encontrado',
        message: `No existe un servicio con ID ${id}` 
      });
    }

    res.json({
      success: true,
      servicio: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo servicio:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
