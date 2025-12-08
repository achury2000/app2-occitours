/**
 * =============================================
 * DASHBOARD.JS - ENDPOINTS DE ESTADÍSTICAS Y ANALYTICS
 * =============================================
 * 
 * Proporciona endpoints para obtener estadísticas agregadas,
 * métricas de negocio y datos para visualización en dashboards.
 * 
 * ENDPOINTS:
 * - GET /stats                - Estadísticas generales del sistema
 * - GET /ingresos-mensuales   - Ingresos agrupados por mes
 * - GET /top-fincas           - Top 5 fincas más reservadas
 * - GET /top-rutas            - Top 5 rutas más populares
 * - GET /top-servicios        - Top 5 servicios más vendidos
 * - GET /reservas-recientes   - Últimas 10 reservas
 * 
 * USO:
 * Estos endpoints son consumidos por AdminDashboardScreen y
 * AdminAnalyticsScreen en la aplicación Flutter para mostrar
 * gráficos, tablas y métricas de negocio.
 */

const express = require('express');
const db = require('../config/database');

const router = express.Router();

// ========================================
// DASHBOARD ENDPOINTS
// ========================================

// ================================================
// GET /api/dashboard/stats - Estadísticas generales
// ================================================
/**
 * Obtiene un resumen general de estadísticas del sistema.
 * 
 * RESPONSE:
 * {
 *   totales: { fincas, rutas, servicios, clientes, reservas, ventas },
 *   ingresos: { total_general, total_completado, total_confirmado, total_pendiente },
 *   reservas_por_estado: [ { estado, cantidad }, ... ]
 * }
 */
router.get('/stats', async (req, res) => {
  try {
    // Contar totales de cada recurso
    const [fincas, rutas, servicios, clientes, reservas, ventas] = await Promise.all([
      db.query('SELECT COUNT(*) as total FROM fincas'),
      db.query('SELECT COUNT(*) as total FROM rutas'),
      db.query('SELECT COUNT(*) as total FROM servicios'),
      db.query('SELECT COUNT(*) as total FROM clientes'),
      db.query('SELECT COUNT(*) as total FROM reservas'),
      db.query('SELECT COUNT(*) as total FROM ventas'),
    ]);

    // Calcular ingresos totales y por estado de reserva
    const ingresos = await db.query(`
      SELECT 
        SUM(precio_total) as total_general,
        SUM(CASE WHEN estado = 'completada' THEN precio_total ELSE 0 END) as total_completado,
        SUM(CASE WHEN estado = 'confirmada' THEN precio_total ELSE 0 END) as total_confirmado,
        SUM(CASE WHEN estado = 'pendiente' THEN precio_total ELSE 0 END) as total_pendiente
      FROM reservas
      WHERE precio_total > 0
    `);

    // Contar reservas agrupadas por estado
    const reservasPorEstado = await db.query(`
      SELECT estado, COUNT(*) as cantidad
      FROM reservas
      GROUP BY estado
    `);

    res.json({
      success: true,
      data: {
        totales: {
          fincas: parseInt(fincas.rows[0].total),
          rutas: parseInt(rutas.rows[0].total),
          servicios: parseInt(servicios.rows[0].total),
          clientes: parseInt(clientes.rows[0].total),
          reservas: parseInt(reservas.rows[0].total),
          ventas: parseInt(ventas.rows[0].total),
        },
        ingresos: {
          total_general: parseFloat(ingresos.rows[0].total_general || 0),
          total_completado: parseFloat(ingresos.rows[0].total_completado || 0),
          total_confirmado: parseFloat(ingresos.rows[0].total_confirmado || 0),
          total_pendiente: parseFloat(ingresos.rows[0].total_pendiente || 0),
        },
        reservas_por_estado: reservasPorEstado.rows,
      }
    });

  } catch (error) {
    console.error('Error obteniendo estadísticas:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/dashboard/ingresos-mensuales - Ingresos por mes
// ================================================
/**
 * Obtiene los ingresos totales agrupados por mes para un año específico.
 * 
 * QUERY PARAMS:
 * - year (opcional): Año para filtrar (por defecto: año actual)
 * 
 * RESPONSE:
 * {
 *   year: 2025,
 *   data: [1500000, 2300000, ...] // Array de 12 posiciones (enero a diciembre)
 * }
 * 
 * USO:
 * Utilizado para generar gráficos de barras mensuales en el dashboard.
 */
router.get('/ingresos-mensuales', async (req, res) => {
  try {
    const { year } = req.query;
    const yearFilter = year || new Date().getFullYear();

    const result = await db.query(`
      SELECT 
        EXTRACT(MONTH FROM fecha) as mes,
        SUM(precio_total) as total
      FROM reservas
      WHERE EXTRACT(YEAR FROM fecha) = $1
        AND estado IN ('completada', 'confirmada')
        AND precio_total > 0
      GROUP BY EXTRACT(MONTH FROM fecha)
      ORDER BY mes
    `, [yearFilter]);

    // Crear array con todos los meses (1-12) inicializados en 0
    const ingresosPorMes = Array(12).fill(0);
    result.rows.forEach(row => {
      const mesIndex = parseInt(row.mes) - 1; // Convertir a índice 0-11
      ingresosPorMes[mesIndex] = parseFloat(row.total);
    });

    res.json({
      success: true,
      year: parseInt(yearFilter),
      data: ingresosPorMes,
      meses: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
    });

  } catch (error) {
    console.error('Error obteniendo ingresos mensuales:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/dashboard/top-fincas - Top 5 fincas más reservadas
// ================================================
router.get('/top-fincas', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        f.id,
        f.nombre,
        COUNT(r.id) as total_reservas,
        SUM(r.precio_total) as ingresos_totales
      FROM fincas f
      LEFT JOIN reservas r ON r.finca_id = f.id
      WHERE r.estado IN ('completada', 'confirmada')
      GROUP BY f.id, f.nombre
      ORDER BY total_reservas DESC
      LIMIT 5
    `);

    res.json({
      success: true,
      data: result.rows.map(row => ({
        id: row.id,
        nombre: row.nombre,
        total_reservas: parseInt(row.total_reservas || 0),
        ingresos_totales: parseFloat(row.ingresos_totales || 0),
      }))
    });

  } catch (error) {
    console.error('Error obteniendo top fincas:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/dashboard/top-rutas - Top 5 rutas más populares
// ================================================
router.get('/top-rutas', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        ru.id,
        ru.nombre,
        COUNT(DISTINCT r.id) as total_reservas,
        SUM(r.precio_total) as ingresos_totales
      FROM rutas ru
      INNER JOIN programacion_ruta pr ON pr.ruta_id = ru.id
      INNER JOIN programaciones p ON p.id = pr.programacion_id
      INNER JOIN reservas r ON r.programacion_id = p.id
      WHERE r.estado IN ('completada', 'confirmada')
      GROUP BY ru.id, ru.nombre
      ORDER BY total_reservas DESC
      LIMIT 5
    `);

    res.json({
      success: true,
      data: result.rows.map(row => ({
        id: row.id,
        nombre: row.nombre,
        total_reservas: parseInt(row.total_reservas || 0),
        ingresos_totales: parseFloat(row.ingresos_totales || 0),
      }))
    });

  } catch (error) {
    console.error('Error obteniendo top rutas:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/dashboard/top-servicios - Top 5 servicios más vendidos
// ================================================
router.get('/top-servicios', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        s.id,
        s.nombre,
        SUM(rs.cantidad) as total_vendido,
        SUM(rs.cantidad * rs.precio_unitario) as ingresos_totales
      FROM servicios s
      INNER JOIN reserva_servicio rs ON rs.servicio_id = s.id
      INNER JOIN reservas r ON r.id = rs.reserva_id
      WHERE r.estado IN ('completada', 'confirmada')
      GROUP BY s.id, s.nombre
      ORDER BY total_vendido DESC
      LIMIT 5
    `);

    res.json({
      success: true,
      data: result.rows.map(row => ({
        id: row.id,
        nombre: row.nombre,
        total_vendido: parseInt(row.total_vendido || 0),
        ingresos_totales: parseFloat(row.ingresos_totales || 0),
      }))
    });

  } catch (error) {
    console.error('Error obteniendo top servicios:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

// ================================================
// GET /api/dashboard/reservas-recientes - Últimas 10 reservas
// ================================================
router.get('/reservas-recientes', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT 
        r.id,
        r.fecha,
        r.estado,
        r.precio_total,
        r.numero_personas,
        c.nombre as cliente_nombre,
        f.nombre as finca_nombre
      FROM reservas r
      LEFT JOIN clientes c ON c.id = r.cliente_id
      LEFT JOIN fincas f ON f.id = r.finca_id
      ORDER BY r.fecha DESC, r.id DESC
      LIMIT 10
    `);

    res.json({
      success: true,
      data: result.rows
    });

  } catch (error) {
    console.error('Error obteniendo reservas recientes:', error);
    res.status(500).json({ 
      error: 'Error en el servidor',
      message: error.message 
    });
  }
});

module.exports = router;
