import {
    obtenerNotificacionesUsuarioBD,
    crearNotificacionBD,
    marcarNotificacionLeidaBD,
    marcarTodasLeidasBD,
    eliminarNotificacionBD
} from "../models/notificacionesModel.js";

// Extrae y valida el ID del usuario desde el token decodificado
const obtenerIdUsuario = (req) => {
    const raw = req.usuario?.id_usuario || req.usuario?.id;
    const id = Number(raw);
    return Number.isInteger(id) ? id : null;
};

// Retorna todas las notificaciones pertenecientes al usuario autenticado
export const consultarMisNotificaciones = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        const { data, error } = await obtenerNotificacionesUsuarioBD(id_usuario);

        if (error) {
            return res.status(500).json({ error: "Error al obtener tus notificaciones", detalle: error.message });
        }

        if (!data || data.length === 0) {
            return res.status(200).json({
                mensaje: "No tienes notificaciones por el momento",
                notificaciones: []
            });
        }

        return res.status(200).json(data);
    } catch (error) {
        console.error("Error en consultarMisNotificaciones:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al intentar obtener tus notificaciones" });
    }
};

// Permite al Administrador (o al sistema) crear una notificación
export const crearNotificacion = async (req, res) => {
    try {
        const body = req.body || {};
        const id_usuario = body.id_usuario;
        const titulo = body.titulo || body.título;
        const mensaje = body.mensaje;
        const tipo = body.tipo;
        
        if (!titulo || typeof titulo !== "string" || titulo.trim() === "") {
            return res.status(400).json({ error: "El título es obligatorio y debe ser un texto válido." });
        }

        if (!mensaje || typeof mensaje !== "string" || mensaje.trim() === "") {
            return res.status(400).json({ error: "El mensaje es obligatorio y debe ser un texto válido." });
        }

        if (!tipo || typeof tipo !== "string" || tipo.trim() === "") {
            return res.status(400).json({ error: "El tipo de notificación es obligatorio (ej. 'evento', 'membresia', 'stock', 'rutina')." });
        }

        // Si se subió un archivo pasa por Cloudinary, si no, queda en null
        const imagen_url = req.file ? req.file.path : null;

        const datosNotificacion = {
            id_usuario: id_usuario ? Number(id_usuario) : null,
            titulo: titulo.trim(),
            mensaje: mensaje.trim(),
            tipo: tipo.trim(),
            imagen_url
        };

        const { data, error } = await crearNotificacionBD(datosNotificacion);

        if (error) {
            return res.status(500).json({ error: "No se pudo registrar la notificación", detalle: error.message });
        }

        return res.status(201).json({
            mensaje: "Notificación creada y enviada con éxito",
            notificacion: data
        });
    } catch (error) {
        console.error("Error en crearNotificacion:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al intentar enviar la notificación" });
    }
};

// Marca una notificacion individual como leida
export const marcarLeida = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        const { id } = req.params;
        const id_notificacion = Number(id);

        if (!Number.isInteger(id_notificacion) || id_notificacion <= 0) {
            return res.status(400).json({ error: "El ID de la notificación proporcionado no es válido" });
        }

        const { data, error } = await marcarNotificacionLeidaBD(id_notificacion, id_usuario);

        if (error) {
            return res.status(500).json({ error: "Error al actualizar el estado de la notificación", detalle: error.message });
        }

        if (!data) {
            return res.status(404).json({ error: "La notificación solicitada no existe o no tienes acceso a ella" });
        }

        return res.status(200).json({
            mensaje: "Notificación marcada como leída exitosamente",
            notificacion: data
        });
    } catch (error) {
        console.error("Error en marcarLeida:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al marcar la notificación como leída" });
    }
};

// Marca todas las notificaciones del usuario como leidas
export const marcarTodasComoLeidas = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        const { data, error } = await marcarTodasLeidasBD(id_usuario);

        if (error) {
            return res.status(500).json({ error: "Error al intentar marcar las notificaciones como leídas", detalle: error.message });
        }

        if (!data || data.length === 0) {
            return res.status(200).json({
                mensaje: "No tenías notificaciones pendientes por marcar como leídas",
                actualizadas: 0
            });
        }

        return res.status(200).json({
            mensaje: "Todas tus notificaciones fueron marcadas como leídas",
            actualizadas: data.length
        });
    } catch (error) {
        console.error("Error en marcarTodasComoLeidas:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al actualizar todas las notificaciones" });
    }
};

// Elimina una notificacion especifica
export const borrarNotificacion = async (req, res) => {
    try {
        const { id } = req.params;
        const id_notificacion = Number(id);

        if (!Number.isInteger(id_notificacion) || id_notificacion <= 0) {
            return res.status(400).json({ error: "El ID de la notificación debe ser un número entero válido" });
        }

        const { data, error } = await eliminarNotificacionBD(id_notificacion);

        if (error) {
            return res.status(500).json({ error: "Error al eliminar la notificación", detalle: error.message });
        }

        if (!data) {
            return res.status(404).json({ error: "La notificación que intentas eliminar no existe o ya fue removida" });
        }

        return res.status(200).json({
            mensaje: "Notificación eliminada correctamente",
            eliminada: data
        });
    } catch (error) {
        console.error("Error en borrarNotificacion:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al eliminar la notificación" });
    }
};