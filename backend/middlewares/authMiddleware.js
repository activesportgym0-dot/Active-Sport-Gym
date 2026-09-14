import jwt from 'jsonwebtoken';

// 1. VERIFICA QUE EXISTA UN TOKEN VÁLIDO (USUARIO AUTENTICADO)
export const verificarToken = (req, res, next) => {
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Token no proporcionado, por favor inicie sesión' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.usuario = decoded; 
        next();
    } catch (err) {
        return res.status(403).json({ error: 'Token inválido o expirado' });
    }
};

// 2. SOLO DEJA PASAR SI EL USUARIO TIENE ROL DE ADMINISTRADOR
export const verificarAdmin = (req, res, next) => {
    console.log("Usuario en el token:", req.usuario);
    
    if (req.usuario?.rol !== 'admin') {
        return res.status(403).json({ error: 'Acceso denegado: Se requieren permisos de administrador' });
    }
    next();
};

// 3. EXCLUSIVO PARA CLIENTES (BLOQUEA ADMINISTRADORES)
export const verificarCliente = (req, res, next) => {
    if (req.usuario?.rol !== 'cliente') {
        return res.status(403).json({ error: 'Acceso denegado: Los administradores no pueden realizar pedidos ni usar el carrito.' });
    }
    next();
};