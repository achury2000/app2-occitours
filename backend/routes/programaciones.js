/**
 * =============================================
 * PROGRAMACIONES.JS - PROGRAMACIÓN DE RUTAS
 * =============================================
 * 
 * Maneja la programación de rutas turísticas,
 * incluyendo fecha, hora y guía asignado.
 * 
 * ENDPOINTS:
 * - GET  /          - Listar todas las programaciones
 * - GET  /:id       - Obtener detalles de una programación
 * 
 * MODELO:
 * Programacion { id, fecha, hora, guia_id }
 * 
 * RELACIONES:
 * - Programacion pertenece a Empleado (guía)
 * - Programacion tiene múltiples Rutas (via programacion_ruta)
 * - Las reservas se vinculan a programaciones (via reserva_programacion)
 * 
 * USO:
 * Permite organizar las salidas turísticas con guías
 * y vincular reservas a fechas/horarios específicos.
 */

const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/programaciones - Listar todas las programaciones
// ================================================
/**
 * Obtiene el listado de programaciones con información del guía.
 * 
 * RESPONSE:
 * {
 *   programaciones: [ { id, fecha, hora, guia_nombre }, ... ],
 *   total: 25
 * }
 */
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        p.id, 
        p.fecha,
        p.hora,
        p.guia_id,
        e.nombre as guia_nombre
       FROM programaciones p
       LEFT JOIN empleados e ON p.guia_id = e.id
       ORDER BY p.fecha ASC, p.hora ASC`
    );

    res.json({
      success: true,
      programaciones: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo programaciones:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/programaciones/:id - Obtener programación por ID
// ================================================
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT 
        p.id, 
        p.fecha,
        p.hora,
        p.guia_id,
        e.nombre as guia_nombre,
        e.cargo as guia_cargo
       FROM programaciones p
       LEFT JOIN empleados e ON p.guia_id = e.id
       WHERE p.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Programación no encontrada',
        message: `No existe una programación con ID ${id}` 
      });
    }

    res.json({
      success: true,
      programacion: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo programación:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
