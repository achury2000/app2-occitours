/**
 * =============================================
 * AUTH.JS - MIDDLEWARE DE AUTENTICACIÓN JWT
 * =============================================
 * 
 * Middleware que protege rutas mediante validación de tokens JWT.
 * 
 * FUNCIONES PRINCIPALES:
 * - verificarToken: Valida que el token JWT sea válido y no haya expirado
 * - verificarRol: Verifica que el usuario tenga uno de los roles permitidos
 * 
 * USO EN RUTAS:
 * ```javascript
 * // Proteger ruta (requiere estar autenticado)
 * router.get('/perfil', verificarToken, (req, res) => {
 *   res.json({ usuario: req.usuario });
 * });
 * 
 * // Proteger por rol (solo admin)
 * router.delete('/usuarios/:id', verificarToken, verificarRol('admin'), (req, res) => {
 *   // solo admin puede eliminar usuarios
 * });
 * 
 * // Múltiples roles permitidos
 * router.put('/reservas/:id', verificarToken, verificarRol('admin', 'asesor'), (req, res) => {
 *   // admin o asesor pueden editar reservas
 * });
 * ```
 */

const jwt = require('jsonwebtoken'); // Librería para manejar JSON Web Tokens

/**
 * Middleware que verifica la validez del token JWT
 * 
 * FUNCIONAMIENTO:
 * 1. Extrae token del header Authorization (formato: "Bearer <token>")
 * 2. Valida que el token exista
 * 3. Verifica firma y expiración con jwt.verify()
 * 4. Decodifica payload y lo adjunta a req.usuario
 * 5. Permite continuar con next() o responde con error
 * 
 * @param {Object} req - Request de Express (contiene headers)
 * @param {Object} res - Response de Express
 * @param {Function} next - Callback para continuar al siguiente middleware
 * 
 * @returns {void} - Llama next() si token válido, o responde con error 401/403
 */
const verificarToken = (req, res, next) => {
  // 1️⃣ EXTRAER TOKEN DEL HEADER
  // Header ejemplo: "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  // .split(' ')[1] obtiene solo el token (después de "Bearer ")
  const token = req.headers['authorization']?.split(' ')[1];

  // 2️⃣ VALIDAR QUE EXISTA TOKEN
  if (!token) {
    return res.status(403).json({ 
      error: 'Token no proporcionado',
      message: 'Debes iniciar sesión' 
    });
  }

  try {
    // 3️⃣ VERIFICAR Y DECODIFICAR TOKEN
    // jwt.verify() lanza error si:
    // - Token expirado (TokenExpiredError)
    // - Firma inválida (JsonWebTokenError)
    // - Token malformado
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // 4️⃣ ADJUNTAR DATOS DEL USUARIO AL REQUEST
    // decoded contiene el payload del JWT:
    // { id: 1, email: "admin@occitours.com", rol_id: 1, rol_nombre: "admin", iat: ..., exp: ... }
    req.usuario = decoded;
    
    // 5️⃣ CONTINUAR AL SIGUIENTE MIDDLEWARE/RUTA
    next();
    
  } catch (error) {
    // MANEJO DE ERRORES ESPECÍFICOS
    
    // ⏰ Token expirado (5 minutos de inactividad)
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Token expirado',
        message: 'Tu sesión ha expirado por inactividad (5 min)' 
      });
    }
    
    // 🔒 Token inválido o corrupto
    return res.status(401).json({ 
      error: 'Token inválido',
      message: 'Token no válido o corrupto' 
    });
  }
};

/**
 * Middleware que verifica que el usuario tenga uno de los roles permitidos
 * 
 * NOTA: Debe usarse DESPUÉS de verificarToken para que req.usuario exista
 * 
 * FUNCIONAMIENTO:
 * 1. Verifica que req.usuario existe (token ya validado)
 * 2. Compara rol del usuario con roles permitidos
 * 3. Permite continuar o responde con 403 Forbidden
 * 
 * @param {...string} rolesPermitidos - Lista de roles que pueden acceder (admin, asesor, guia, cliente)
 * @returns {Function} - Middleware de Express que valida el rol
 * 
 * @example
 * // Solo admin puede eliminar usuarios
 * router.delete('/usuarios/:id', verificarToken, verificarRol('admin'), controller);
 * 
 * @example
 * // Admin o asesor pueden crear reservas
 * router.post('/reservas', verificarToken, verificarRol('admin', 'asesor'), controller);
 */
const verificarRol = (...rolesPermitidos) => {
  return (req, res, next) => {
    // 1️⃣ VERIFICAR QUE EL USUARIO ESTÉ AUTENTICADO
    // Si no hay req.usuario, significa que verificarToken no se ejecutó antes
    if (!req.usuario) {
      return res.status(403).json({ error: 'No autenticado' });
    }

    // 📝 LOG PARA DEBUGGING (útil en desarrollo)
    console.log('🔍 Verificando rol:');
    console.log('   Usuario:', req.usuario.email);
    console.log('   Rol actual:', req.usuario.rol_nombre);
    console.log('   Roles permitidos:', rolesPermitidos);

    // 2️⃣ VERIFICAR QUE EL ROL DEL USUARIO ESTÉ EN LA LISTA DE PERMITIDOS
    // req.usuario.rol_nombre viene del JWT (ej: "admin", "asesor", "guia", "cliente")
    if (!rolesPermitidos.includes(req.usuario.rol_nombre)) {
      return res.status(403).json({ 
        error: 'Acceso denegado',
        message: `Solo usuarios ${rolesPermitidos.join(', ')} pueden acceder` 
      });
    }

    // 3️⃣ ROL VÁLIDO → CONTINUAR
    next();
  };
};

// EXPORTAR MIDDLEWARES PARA USAR EN RUTAS
module.exports = { verificarToken, verificarRol };
