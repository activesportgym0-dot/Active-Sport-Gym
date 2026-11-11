import jwt from 'jsonwebtoken';
import { supabase } from '../config/supabase.js';

// 1. VERIFICA QUE EXISTA UN TOKEN VÁLIDO (USUARIO AUTENTICADO)
// Además confirma en la base de datos que la cuenta siga existiendo y activa, y toma el rol de ahí:
// así una cuenta desactivada pierde el acceso de inmediato (aunque tenga "Recuérdame" y un token vigente)
// y un cambio de rol aplica sin que la persona tenga que volver a iniciar sesión.
export const verificarToken = async (req, res, next) => {
    const authHeader = req.headers['authorization'] || req.headers['Authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Token no proporcionado, por favor inicie sesión' });
    }

    let decoded;
    try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
        return res.status(403).json({ error: 'Token inválido o expirado' });
    }

    try {
        const { data: usuario, error } = await supabase
            .from('usuarios')
            .select('rol, is_active')
            .eq('id_usuario', decoded.id_usuario)
            .maybeSingle();

        if (error) {
            console.error('Error al validar la sesión:', error);
            return res.status(500).json({ error: 'No fue posible validar la sesión' });
        }
        if (!usuario) {
            return res.status(401).json({ error: 'La cuenta ya no existe. Inicia sesión de nuevo.' });
        }
        if (usuario.is_active === false) {
            return res.status(403).json({ error: 'Tu cuenta está desactivada. Comunícate con el gimnasio.' });
        }

        req.usuario = { ...decoded, rol: usuario.rol };
        next();
    } catch (err) {
        console.error('Error inesperado al validar la sesión:', err);
        return res.status(500).json({ error: 'No fue posible validar la sesión' });
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

// 4. DEJA PASAR SOLO AL DUEÑO DEL PERFIL (según :id_usuario o :id) O A UN ADMINISTRADOR
export const verificarPropioOAdmin = (req, res, next) => {
    const idSolicitado = Number(req.params.id_usuario ?? req.params.id);
    const esPropio = Number(req.usuario?.id_usuario) === idSolicitado;
    const esAdmin = req.usuario?.rol === 'admin';

    if (!esPropio && !esAdmin) {
        return res.status(403).json({ error: 'Acceso denegado: solo puedes consultar o modificar tu propio perfil' });
    }
    next();
};