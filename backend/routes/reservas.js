/**
 * =============================================
 * RESERVAS.JS - GESTIÓN DE RESERVAS
 * =============================================
 * 
 * Maneja las operaciones CRUD de reservas de clientes.
 * Las reservas son el núcleo del sistema, conectando clientes,
 * fincas, rutas, servicios y ventas.
 * 
 * ENDPOINTS:
 * - GET    /                      - Listar todas las reservas
 * - GET    /:id                   - Obtener detalles de una reserva
 * - GET    /cliente/:cliente_id   - Reservas de un cliente específico
 * - POST   /                      - Crear nueva reserva
 * - PUT    /:id                   - Actualizar reserva
 * - DELETE /:id                   - Eliminar reserva
 * 
 * MODELO:
 * Reserva {
 *   id, cliente_id, finca_id, venta_id, estado,
 *   fecha, numero_personas, precio_total, qr_code, comprobante_pago
 * }
 * 
 * RELACIONES:
 * - Reserva pertenece a Cliente
 * - Reserva pertenece a Finca (opcional)
 * - Reserva puede tener múltiples Servicios (via reserva_servicio)
 * - Reserva puede tener múltiples Rutas (via programacion_ruta -> reserva_programacion)
 * - Reserva pertenece a Venta (cuando estado = 'confirmada')
 * 
 * LÓGICA ESPECIAL:
 * - Al cambiar estado a 'confirmada', se crea automáticamente una venta
 * - El precio_total se calcula automáticamente según servicios y rutas
 */

const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ========================================
// RESERVAS
// ========================================

// ================================================
// GET /api/reservas - Listar todas las reservas (público)
// ================================================
/**
 * Obtiene el listado completo de reservas con información
 * de cliente y finca asociados.
 * 
 * RESPONSE:
 * {
 *   reservas: [ {
 *     id, cliente_nombre, finca_nombre, fecha, 
 *     numero_personas, precio_total, estado, ...
 *   }, ... ],
 *   total: 120
 * }
 */
router.get('/', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT 
        r.id, 
        r.cliente_id,
        c.nombre as cliente_nombre,
        c.email as cliente_email,
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
      programacion_id,
      fecha, 
      numero_personas = 1, 
      precio_total = 0,
      notas,
      servicios = [] // Array de {servicio_id, cantidad, precio_unitario}
    } = req.body;

    console.log('🔧 POST /reservas - Crear nueva reserva');
    console.log('   Datos:', { cliente_id, finca_id, programacion_id, fecha, numero_personas, precio_total, servicios });

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

    // Verificar que la programación existe (si se proporcionó)
    if (programacion_id) {
      const programacionExiste = await db.query(
        'SELECT id FROM programaciones WHERE id = $1',
        [programacion_id]
      );
      if (programacionExiste.rows.length === 0) {
        return res.status(404).json({ 
          error: 'Programación no encontrada',
          message: `No existe una programación con ID ${programacion_id}` 
        });
      }
    }

    // Insertar reserva
    const result = await db.query(
      `INSERT INTO reservas (
        cliente_id, 
        finca_id,
        programacion_id, 
        fecha, 
        numero_personas, 
        precio_total,
        estado
      )
       VALUES ($1, $2, $3, $4, $5, $6, 'pendiente')
       RETURNING id, cliente_id, finca_id, programacion_id, fecha, numero_personas, precio_total, estado`,
      [cliente_id, finca_id, programacion_id, fecha, numero_personas, precio_total]
    );

    const reservaId = result.rows[0].id;

    // Insertar servicios asociados (si existen)
    if (servicios && servicios.length > 0) {
      for (const servicio of servicios) {
        const { servicio_id, cantidad = 1, precio_unitario } = servicio;

        // Validar que el servicio existe
        const servicioExiste = await db.query(
          'SELECT id FROM servicios WHERE id = $1',
          [servicio_id]
        );
        if (servicioExiste.rows.length === 0) {
          return res.status(404).json({ 
            error: 'Servicio no encontrado',
            message: `No existe un servicio con ID ${servicio_id}` 
          });
        }

        // Insertar en reserva_servicio
        await db.query(
          `INSERT INTO reserva_servicio (reserva_id, servicio_id, cantidad, precio_unitario)
           VALUES ($1, $2, $3, $4)`,
          [reservaId, servicio_id, cantidad, precio_unitario]
        );
      }
    }

    res.status(201).json({
      success: true,
      message: 'Reserva creada exitosamente',
      reserva: result.rows[0],
      servicios_agregados: servicios.length
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
      cliente_id,
      finca_id,
      programacion_id,
      fecha, 
      numero_personas, 
      precio_total,
      estado,
      qr_code,
      comprobante_pago
    } = req.body;

    console.log('🔧 PUT /reservas/:id');
    console.log('   ID a actualizar:', id);
    console.log('   Cambios:', { cliente_id, finca_id, programacion_id, fecha, numero_personas, precio_total, estado });

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

    if (cliente_id !== undefined) {
      campos.push(`cliente_id = $${contador}`);
      valores.push(cliente_id);
      contador++;
    }
    if (finca_id !== undefined) {
      campos.push(`finca_id = $${contador}`);
      valores.push(finca_id);
      contador++;
    }
    if (programacion_id !== undefined) {
      campos.push(`programacion_id = $${contador}`);
      valores.push(programacion_id);
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
      RETURNING id, cliente_id, finca_id, programacion_id, fecha, numero_personas, precio_total, estado
    `;

    const result = await db.query(query, valores);

    const reservaActualizada = result.rows[0];

    // Si el estado cambió a 'confirmada', crear/actualizar venta automáticamente
    if (estado && estado.toLowerCase() === 'confirmada') {
      const clienteId = reservaActualizada.cliente_id;
      const precioTotal = reservaActualizada.precio_total || 0;
      const fechaReserva = reservaActualizada.fecha;

      // Verificar si ya existe una venta para esta reserva
      const ventaExistente = await db.query(
        'SELECT id FROM ventas WHERE id = (SELECT venta_id FROM reservas WHERE id = $1)',
        [id]
      );

      if (ventaExistente.rows.length === 0) {
        // Crear nueva venta
        const nuevaVenta = await db.query(
          `INSERT INTO ventas (cliente_id, fecha, total, estado)
           VALUES ($1, $2, $3, 'pendiente')
           RETURNING id`,
          [clienteId, fechaReserva, precioTotal]
        );

        const ventaId = nuevaVenta.rows[0].id;

        // Asociar reserva con la venta
        await db.query(
          'UPDATE reservas SET venta_id = $1 WHERE id = $2',
          [ventaId, id]
        );

        console.log(`✅ Venta ${ventaId} creada automáticamente para reserva ${id}`);
      } else {
        // Actualizar total de la venta existente
        const ventaId = ventaExistente.rows[0].id;
        await db.query(
          `UPDATE ventas 
           SET total = (SELECT SUM(precio_total) FROM reservas WHERE venta_id = $1)
           WHERE id = $1`,
          [ventaId]
        );

        console.log(`✅ Venta ${ventaId} actualizada para reserva ${id}`);
      }
    }

    res.json({
      success: true,
      message: 'Reserva actualizada exitosamente',
      reserva: reservaActualizada
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
