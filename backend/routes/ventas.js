const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ========================================
// VENTAS
// ========================================

// ================================================
// GET /api/ventas - Listar todas las ventas
// ================================================
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        v.id, 
        v.cliente_id,
        c.nombre as cliente_nombre,
        c.email as cliente_email,
        v.asesor_id,
        u.nombre as asesor_nombre,
        v.fecha,
        v.total,
        v.estado,
        COUNT(r.id) as num_reservas
       FROM ventas v
       LEFT JOIN clientes c ON v.cliente_id = c.id
       LEFT JOIN usuarios u ON v.asesor_id = u.id
       LEFT JOIN reservas r ON r.venta_id = v.id
       GROUP BY v.id, c.nombre, c.email, u.nombre
       ORDER BY v.fecha DESC, v.id DESC`
    );

    res.json({
      success: true,
      ventas: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    console.error('Error obteniendo ventas:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/ventas/:id - Obtener venta por ID
// ================================================
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const ventaResult = await db.query(
      `SELECT 
        v.id, 
        v.cliente_id,
        c.nombre as cliente_nombre,
        c.email as cliente_email,
        c.telefono as cliente_telefono,
        v.asesor_id,
        u.nombre as asesor_nombre,
        v.fecha,
        v.total,
        v.estado
       FROM ventas v
       LEFT JOIN clientes c ON v.cliente_id = c.id
       LEFT JOIN usuarios u ON v.asesor_id = u.id
       WHERE v.id = $1`,
      [id]
    );

    if (ventaResult.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Venta no encontrada',
        message: `No existe una venta con ID ${id}` 
      });
    }

    // Obtener reservas asociadas
    const reservasResult = await db.query(
      `SELECT 
        r.id,
        r.fecha,
        r.numero_personas,
        r.precio_total,
        r.estado,
        f.nombre as finca_nombre,
        p.fecha as programacion_fecha,
        p.hora as programacion_hora
       FROM reservas r
       LEFT JOIN fincas f ON r.finca_id = f.id
       LEFT JOIN programaciones p ON r.programacion_id = p.id
       WHERE r.venta_id = $1`,
      [id]
    );

    // Obtener abonos
    const abonosResult = await db.query(
      `SELECT id, fecha, monto
       FROM abonos
       WHERE venta_id = $1
       ORDER BY fecha DESC`,
      [id]
    );

    res.json({
      success: true,
      venta: {
        ...ventaResult.rows[0],
        reservas: reservasResult.rows,
        abonos: abonosResult.rows
      }
    });

  } catch (error) {
    console.error('Error obteniendo venta:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// POST /api/ventas - Crear nueva venta
// ================================================
router.post('/', async (req, res) => {
  try {
    const { 
      cliente_id, 
      asesor_id,
      fecha = new Date().toISOString().split('T')[0],
      total = 0,
      estado = 'pendiente',
      reservas_ids = [] // IDs de reservas a asociar
    } = req.body;

    console.log('🔧 POST /ventas - Crear nueva venta');
    console.log('   Datos:', { cliente_id, asesor_id, fecha, total, estado, reservas_ids });

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

    // Calcular total de las reservas si se proporcionaron IDs
    let totalCalculado = total;
    if (reservas_ids && reservas_ids.length > 0) {
      const reservasResult = await db.query(
        'SELECT SUM(precio_total) as total FROM reservas WHERE id = ANY($1)',
        [reservas_ids]
      );
      totalCalculado = reservasResult.rows[0].total || 0;
    }

    // Insertar venta
    const result = await db.query(
      `INSERT INTO ventas (
        cliente_id, 
        asesor_id,
        fecha, 
        total,
        estado
      )
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, cliente_id, asesor_id, fecha, total, estado`,
      [cliente_id, asesor_id, fecha, totalCalculado, estado]
    );

    const ventaId = result.rows[0].id;

    // Asociar reservas si se proporcionaron
    if (reservas_ids && reservas_ids.length > 0) {
      await db.query(
        'UPDATE reservas SET venta_id = $1 WHERE id = ANY($2)',
        [ventaId, reservas_ids]
      );
    }

    res.status(201).json({
      success: true,
      message: 'Venta creada exitosamente',
      venta: result.rows[0]
    });

  } catch (error) {
    console.error('Error creando venta:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// PUT /api/ventas/:id - Actualizar venta
// ================================================
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      cliente_id,
      asesor_id,
      fecha, 
      total,
      estado
    } = req.body;

    console.log('🔧 PUT /ventas/:id');
    console.log('   ID a actualizar:', id);
    console.log('   Cambios:', { cliente_id, asesor_id, fecha, total, estado });

    // Verificar que la venta existe
    const ventaExiste = await db.query(
      'SELECT id FROM ventas WHERE id = $1',
      [id]
    );
    if (ventaExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Venta no encontrada',
        message: `No existe una venta con ID ${id}` 
      });
    }

    // Construir query dinámicamente
    const campos = [];
    const valores = [];
    let contador = 1;

    if (cliente_id !== undefined) {
      campos.push(`cliente_id = $${contador}`);
      valores.push(cliente_id);
      contador++;
    }
    if (asesor_id !== undefined) {
      campos.push(`asesor_id = $${contador}`);
      valores.push(asesor_id);
      contador++;
    }
    if (fecha !== undefined) {
      campos.push(`fecha = $${contador}`);
      valores.push(fecha);
      contador++;
    }
    if (total !== undefined) {
      campos.push(`total = $${contador}`);
      valores.push(total);
      contador++;
    }
    if (estado !== undefined) {
      campos.push(`estado = $${contador}`);
      valores.push(estado);
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
      UPDATE ventas 
      SET ${campos.join(', ')}
      WHERE id = $${contador}
      RETURNING id, cliente_id, asesor_id, fecha, total, estado
    `;

    const result = await db.query(query, valores);

    res.json({
      success: true,
      message: 'Venta actualizada exitosamente',
      venta: result.rows[0]
    });

  } catch (error) {
    console.error('Error actualizando venta:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// DELETE /api/ventas/:id - Eliminar venta
// ================================================
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    console.log('🗑️  DELETE /ventas/:id');
    console.log('   ID a eliminar:', id);

    // Verificar que la venta existe
    const ventaExiste = await db.query(
      'SELECT id FROM ventas WHERE id = $1',
      [id]
    );
    if (ventaExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Venta no encontrada',
        message: `No existe una venta con ID ${id}` 
      });
    }

    // Desvincular reservas
    await db.query(
      'UPDATE reservas SET venta_id = NULL WHERE venta_id = $1',
      [id]
    );

    // Eliminar venta (los abonos se eliminan por CASCADE)
    await db.query('DELETE FROM ventas WHERE id = $1', [id]);

    res.json({
      success: true,
      message: 'Venta eliminada exitosamente'
    });

  } catch (error) {
    console.error('Error eliminando venta:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// POST /api/ventas/:id/abono - Agregar abono a venta
// ================================================
router.post('/:id/abono', async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      fecha = new Date().toISOString().split('T')[0],
      monto
    } = req.body;

    if (!monto || monto <= 0) {
      return res.status(400).json({ 
        error: 'Monto inválido',
        message: 'El monto debe ser mayor a 0' 
      });
    }

    // Verificar que la venta existe
    const ventaExiste = await db.query(
      'SELECT id FROM ventas WHERE id = $1',
      [id]
    );
    if (ventaExiste.rows.length === 0) {
      return res.status(404).json({ 
        error: 'Venta no encontrada',
        message: `No existe una venta con ID ${id}` 
      });
    }

    // Insertar abono
    const result = await db.query(
      `INSERT INTO abonos (venta_id, fecha, monto)
       VALUES ($1, $2, $3)
       RETURNING id, venta_id, fecha, monto`,
      [id, fecha, monto]
    );

    res.status(201).json({
      success: true,
      message: 'Abono registrado exitosamente',
      abono: result.rows[0]
    });

  } catch (error) {
    console.error('Error registrando abono:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
