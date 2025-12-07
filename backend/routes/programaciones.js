const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/programaciones - Listar todas las programaciones
// ================================================
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
