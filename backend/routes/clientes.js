const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/clientes - Listar todos los clientes
// ================================================
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id, nombre, cedula, email, telefono
       FROM clientes
       ORDER BY nombre ASC`
    );

    res.json({
      success: true,
      clientes: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo clientes:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/clientes/by-cedula/:cedula - Obtener cliente por cédula
// ================================================
router.get('/by-cedula/:cedula', async (req, res) => {
  try {
    const { cedula } = req.params;
    
    console.log(`🔍 Buscando cliente con cédula: ${cedula}`);
    
    // Buscar cliente por cédula
    const result = await db.query(
      `SELECT id, nombre, cedula, email, telefono
       FROM clientes
       WHERE cedula = $1`,
      [cedula]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Cliente no encontrado',
        message: `No existe un cliente con cédula ${cedula}` 
      });
    }

    console.log(`✅ Cliente encontrado: ID ${result.rows[0].id} - ${result.rows[0].nombre}`);

    res.json({
      success: true,
      cliente: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo cliente por cédula:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/clientes/:id - Obtener cliente por ID
// ================================================
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT id, nombre, cedula, email, telefono
       FROM clientes
       WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Cliente no encontrado',
        message: `No existe un cliente con ID ${id}` 
      });
    }

    res.json({
      success: true,
      cliente: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo cliente:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
