/**
 * =============================================
 * CLIENTES.JS - GESTIÓN DE CLIENTES
 * =============================================
 * 
 * Maneja las operaciones relacionadas con los clientes
 * que realizan reservas en el sistema.
 * 
 * ENDPOINTS:
 * - GET  /                  - Listar todos los clientes
 * - GET  /by-cedula/:cedula - Buscar cliente por cédula
 * - GET  /:id               - Obtener detalles de un cliente
 * - POST /                  - Crear nuevo cliente
 * 
 * MODELO:
 * Cliente { id, nombre, cedula, email, telefono }
 * 
 * USO:
 * - Al crear reservas, se busca/crea el cliente
 * - Los clientes pueden tener múltiples reservas
 * - Los clientes se asocian a ventas
 */

const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ================================================
// GET /api/clientes - Listar todos los clientes
// ================================================
/**
 * Obtiene el listado completo de clientes registrados.
 * 
 * RESPONSE:
 * {
 *   clientes: [ { id, nombre, cedula, email, telefono }, ... ],
 *   total: 50
 * }
 */
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
/**
 * Busca un cliente específico por su número de cédula.
 * Útil para verificar si un cliente ya existe antes de crear reserva.
 * 
 * PARAMS:
 * - cedula: Número de cédula del cliente
 * 
 * RESPONSE:
 * { cliente: { id, nombre, cedula, email, telefono } }
 * 
 * STATUS:
 * - 200: Cliente encontrado
 * - 404: Cliente no existe
 */
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
