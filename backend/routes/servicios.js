const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/servicios - Listar todos los servicios
// ================================================
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
