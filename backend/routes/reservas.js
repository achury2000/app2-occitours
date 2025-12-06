const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ========================================
// RESERVAS
// ========================================

// ================================================
// GET /api/reservas - Listar todas las reservas (público)
// ================================================
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        r.id, 
        r.cliente_id,
        c.nombre as cliente_nombre,
        c.email as cliente_email,
        r.programacion_id,
        r.finca_id,
        f.nombre as finca_nombre,
        r.venta_id,
        r.estado,
        r.fecha,
        r.numero_personas,
        r.precio_total,
        r.qr_code,
        r.comprobante_pago
       FROM reservas r
       LEFT JOIN clientes c ON r.cliente_id = c.id
       LEFT JOIN fincas f ON r.finca_id = f.id
       ORDER BY r.fecha DESC, r.id DESC`
    );

    res.json({
      success: true,
      reservas: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo reservas:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/reservas/:id - Obtener reserva por ID (público)
// ================================================
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await db.query(
      `SELECT 
        r.id, 
        r.cliente_id,
        c.nombre as cliente_nombre,
        c.email as cliente_email,
        c.telefono as cliente_telefono,
        r.programacion_id,
        r.finca_id,
        f.nombre as finca_nombre,
        r.venta_id,
        r.estado,
        r.fecha,
        r.numero_personas,
        r.precio_total,
        r.qr_code,
        r.comprobante_pago
       FROM reservas r
       LEFT JOIN clientes c ON r.cliente_id = c.id
       LEFT JOIN fincas f ON r.finca_id = f.id
       WHERE r.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Reserva no encontrada',
        message: `No existe una reserva con ID ${id}` 
      });
    }

    res.json({
      success: true,
      reserva: result.rows[0]
    });

  } catch (error) {
    console.error('Error obteniendo reserva:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// POST /api/reservas - Crear nueva reserva (público)
// ================================================
router.post('/', async (req, res) => {
  try {
    const { 
      cliente_id, 
      finca_id, 
      fecha, 
      numero_personas = 1, 
      precio_total = 0,
      notas 
    } = req.body;

    console.log('🔧 POST /reservas - Crear nueva reserva');
    console.log('   Datos:', { cliente_id, finca_id, fecha, numero_personas, precio_total });

    // Validar campos obligatorios
    if (!cliente_id || !fecha) {
      return res.status(400).json({ 
        error: 'Campos incompletos',
        message: 'cliente_id y fecha son obligatorios' 
      });
    }

    // Verificar que el cliente existe
    const clienteExiste = await db.query(
      'SELECT id FROM clientes WHERE id = $1',
      [cliente_id]
    );
    if (clienteExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Cliente no encontrado',
        message: `No existe un cliente con ID ${cliente_id}` 
      });
    }

    // Verificar que la finca existe (si se proporcionó)
    if (finca_id) {
      const fincaExiste = await db.query(
        'SELECT id FROM fincas WHERE id = $1',
        [finca_id]
      );
      if (fincaExiste.rows.length === 0) {
        return res.status(404).json({ 
          error: 'Finca no encontrada',
          message: `No existe una finca con ID ${finca_id}` 
        });
      }
    }

    // Insertar reserva
    const result = await db.query(
      `INSERT INTO reservas (
        cliente_id, 
        finca_id, 
        fecha, 
        numero_personas, 
        precio_total,
        estado
      )
       VALUES ($1, $2, $3, $4, $5, 'pendiente')
       RETURNING id, cliente_id, finca_id, fecha, numero_personas, precio_total, estado`,
      [cliente_id, finca_id, fecha, numero_personas, precio_total]
    );

    res.status(201).json({
      success: true,
      message: 'Reserva creada exitosamente',
      reserva: result.rows[0]
    });

  } catch (error) {
    console.error('Error creando reserva:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// PUT /api/reservas/:id - Actualizar reserva (público)
// ================================================
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      finca_id, 
      fecha, 
      numero_personas, 
      precio_total,
      estado,
      qr_code,
      comprobante_pago
    } = req.body;

    console.log('🔧 PUT /reservas/:id');
    console.log('   ID a actualizar:', id);
    console.log('   Cambios:', { finca_id, fecha, numero_personas, precio_total, estado });

    // Verificar que la reserva existe
    const reservaExiste = await db.query(
      'SELECT id FROM reservas WHERE id = $1',
      [id]
    );
    if (reservaExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Reserva no encontrada',
        message: `No existe una reserva con ID ${id}` 
      });
    }

    // Construir query dinámicamente
    const campos = [];
    const valores = [];
    let contador = 1;

    if (finca_id !== undefined) {
      campos.push(`finca_id = $${contador}`);
      valores.push(finca_id);
      contador++;
    }
    if (fecha !== undefined) {
      campos.push(`fecha = $${contador}`);
      valores.push(fecha);
      contador++;
    }
    if (numero_personas !== undefined) {
      campos.push(`numero_personas = $${contador}`);
      valores.push(numero_personas);
      contador++;
    }
    if (precio_total !== undefined) {
      campos.push(`precio_total = $${contador}`);
      valores.push(precio_total);
      contador++;
    }
    if (estado !== undefined) {
      campos.push(`estado = $${contador}`);
      valores.push(estado);
      contador++;
    }
    if (qr_code !== undefined) {
      campos.push(`qr_code = $${contador}`);
      valores.push(qr_code);
      contador++;
    }
    if (comprobante_pago !== undefined) {
      campos.push(`comprobante_pago = $${contador}`);
      valores.push(comprobante_pago);
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
      UPDATE reservas 
      SET ${campos.join(', ')}
      WHERE id = $${contador}
      RETURNING id, cliente_id, finca_id, fecha, numero_personas, precio_total, estado
    `;

    const result = await db.query(query, valores);

    res.json({
      success: true,
      message: 'Reserva actualizada exitosamente',
      reserva: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando reserva:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// DELETE /api/reservas/:id - Eliminar/Cancelar reserva (público)
// ================================================
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    console.log('🗑️  DELETE /reservas/:id');
    console.log('   ID a eliminar:', id);

    // Verificar que la reserva existe
    const reservaExiste = await db.query(
      'SELECT id, estado FROM reservas WHERE id = $1',
      [id]
    );
    if (reservaExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Reserva no encontrada',
        message: `No existe una reserva con ID ${id}` 
      });
    }

    // En lugar de eliminar, cambiar estado a 'cancelada'
    await db.query(
      'UPDATE reservas SET estado = $1 WHERE id = $2',
      ['cancelada', id]
    );

    res.json({
      success: true,
      message: 'Reserva cancelada exitosamente',
      id: parseInt(id)
    });

  } catch (error) {
    console.error('Error cancelando reserva:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/reservas/cliente/:cliente_id - Obtener reservas por cliente (público)
// ================================================
router.get('/cliente/:cliente_id', async (req, res) => {
  try {
    const { cliente_id } = req.params;

    const result = await db.query(
      `SELECT 
        r.id, 
        r.cliente_id,
        r.finca_id,
        f.nombre as finca_nombre,
        r.estado,
        r.fecha,
        r.numero_personas,
        r.precio_total
       FROM reservas r
       LEFT JOIN fincas f ON r.finca_id = f.id
       WHERE r.cliente_id = $1
       ORDER BY r.fecha DESC`,
      [cliente_id]
    );

    res.json({
      success: true,
      reservas: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo reservas del cliente:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
