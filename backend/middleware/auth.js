const jwt = require('jsonwebtoken');

const verificarToken = (req, res, next) => {
  const token = req.headers['authorization']?.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(403).json({ 
      error: 'Token no proporcionado',
      message: 'Debes iniciar sesión' 
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = decoded; // { id, email, rol_id, rol_nombre }
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        error: 'Token expirado',
        message: 'Tu sesión ha expirado por inactividad (5 min)' 
      });
    }
    return res.status(401).json({ 
      error: 'Token inválido',
      message: 'Token no válido o corrupto' 
    });
  }
};

const verificarRol = (...rolesPermitidos) => {
  return (req, res, next) => {
    if (!req.usuario) {
      return res.status(403).json({ error: 'No autenticado' });
    }

    if (!rolesPermitidos.includes(req.usuario.rol_nombre)) {
      return res.status(403).json({ 
        error: 'Acceso denegado',
        message: `Solo usuarios ${rolesPermitidos.join(', ')} pueden acceder` 
      });
    }

    next();
  };
};

module.exports = { verificarToken, verificarRol };
