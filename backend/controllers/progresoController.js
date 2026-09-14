import {
    obtenerProgresoActualBD,
    registrarNuevaMedidaBD,
    obtenerHistorialMedidasBD,
    eliminarMedidaHistorialBD,
    vaciarHistorialBD
} from "../models/progresoModel.js";

// Lista de campos requeridos para la medicion
const camposObligatorios = [
    "peso_actual", "altura",
    "brazo_izquierdo", "brazo_derecho", "pecho", "cintura",
    "cadera", "muslo_izquierdo", "muslo_derecho",
    "pantorrilla_izquierda", "pantorrilla_derecha"
];

// Extrae y valida el ID del usuario desde el token decodificado
const obtenerIdUsuario = (req) => {
    const raw = req.usuario?.id_usuario || req.usuario?.id;
    const id = Number(raw);
    return Number.isInteger(id) ? id : null;
};

// Retorna la medida de progreso mas reciente del usuario
export const consultarProgresoActual = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        const { data, error } = await obtenerProgresoActualBD(id_usuario);

        if (error) {
            return res.status(500).json({ error: "Error al consultar la medida actual", detalle: error.message });
        }

        if (!data) {
            return res.status(200).json({
                mensaje: "No tienes medidas actuales registradas",
                progreso: null
            });
        }

        return res.status(200).json(data);
    } catch (error) {
        console.error("Error en consultarProgresoActual:", error);
        return res.status(500).json({ error: "Error interno del servidor" });
    }
};

// Registra un nuevo progreso previa validacion de campos
export const crearProgreso = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        for (const campo of camposObligatorios) {
            if (req.body[campo] === undefined || req.body[campo] === null || Number(req.body[campo]) <= 0) {
                return res.status(400).json({
                    error: `El campo '${campo}' es obligatorio y debe ser un número mayor a cero.`
                });
            }
        }

        const { data, error } = await registrarNuevaMedidaBD(id_usuario, req.body);

        if (error) {
            return res.status(500).json({ error: "Error al guardar el progreso", detalle: error.message });
        }

        return res.status(201).json({
            mensaje: "Medidas guardadas con éxito",
            progreso: data
        });
    } catch (error) {
        console.error("Error en crearProgreso:", error);
        return res.status(500).json({ error: "Error interno del servidor" });
    }
};

// Retorna el historial completo de medidas del usuario
export const consultarHistorialMedidas = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        const { data, error } = await obtenerHistorialMedidasBD(id_usuario);

        if (error) {
            return res.status(500).json({ error: "Error al obtener el historial", detalle: error.message });
        }

        if (!data || data.length === 0) {
            return res.status(200).json({
                mensaje: "No tienes historial de medidas registrado",
                historial: []
            });
        }

        return res.status(200).json(data);
    } catch (error) {
        console.error("Error en consultarHistorialMedidas:", error);
        return res.status(500).json({ error: "Error interno del servidor" });
    }
};

// Elimina un registro especifico del historial
export const borrarMedidaHistorial = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        const { id } = req.params;
        const { data, error } = await eliminarMedidaHistorialBD(id, id_usuario);

        if (error) {
            return res.status(500).json({ error: "Error al borrar el registro de progreso", detalle: error.message });
        }

        if (!data) {
            return res.status(404).json({
                error: "No se encontró la medida especificada o no tienes permisos para eliminarla"
            });
        }

        return res.status(200).json({
            mensaje: "Medida eliminada con éxito del historial",
            eliminado: data
        });
    } catch (error) {
        console.error("Error en borrarMedidaHistorial:", error);
        return res.status(500).json({ error: "Error interno del servidor" });
    }
};

// Elimina todos los registros del historial del usuario
export const borrarTodoElHistorial = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }

        const { data, error } = await vaciarHistorialBD(id_usuario);

        if (error) {
            return res.status(500).json({ error: "Error al vaciar el historial de progreso", detalle: error.message });
        }

        if (!data || data.length === 0) {
            return res.status(200).json({
                mensaje: "El historial ya se encontraba vacío",
                eliminados: 0
            });
        }

        return res.status(200).json({
            mensaje: "Historial de medidas vaciado con éxito",
            eliminados: data.length
        });
    } catch (error) {
        console.error("Error en borrarTodoElHistorial:", error);
        return res.status(500).json({ error: "Error interno del servidor" });
    }
};