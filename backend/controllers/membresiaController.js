import {
    obtenerMembresiaActualBD,
    obtenerHistorialMembresiasBD,
    registrarMembresiaBD,
    cambiarEstadoMembresiaBD
} from "../models/membresiaModel.js";

const obtenerIdUsuario = (req) => {
    const raw = req.usuario?.id_usuario || req.usuario?.id;
    const id = Number(raw);
    return Number.isInteger(id) ? id : null;
};

// [CLIENTE] Consulta únicamente el estado de su membresía actual/última
export const consultarMiMembresia = async (req, res) => {
    try {
        const id_usuario = obtenerIdUsuario(req);
        if (!id_usuario) {
            return res.status(401).json({ error: "Usuario no autenticado o token inválido" });
        }
        const { data, error } = await obtenerMembresiaActualBD(id_usuario);
        if (error) {
            return res.status(500).json({ error: "Error al consultar tu membresía", detalle: error.message });
        }
        if (!data) {
            return res.status(200).json({
                mensaje: "Actualmente no tienes ninguna membresía registrada",
                membresia: null
            });
        }
        return res.status(200).json(data);
    } catch (error) {
        console.error("Error en consultarMiMembresia:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al consultar tu membresía" });
    }
};

// [CLIENTE / ADMIN] Consulta todo el historial de membresías compradas por el cliente
export const consultarHistorialMembresias = async (req, res) => {
    try {
        // Si el admin pasa :id_usuario por params usa ese, si no, usa el del cliente autenticado
        const id_param = req.params.id_usuario;
        const id_usuario = id_param ? Number(id_param) : obtenerIdUsuario(req);
        if (!id_usuario || !Number.isInteger(id_usuario)) {
            return res.status(400).json({ error: "ID de usuario inválido o no autenticado" });
        }
        const { data, error } = await obtenerHistorialMembresiasBD(id_usuario);
        if (error) {
            return res.status(500).json({ error: "Error al consultar el historial de membresías", detalle: error.message });
        }
        return res.status(200).json(data || []);
    } catch (error) {
        console.error("Error en consultarHistorialMembresias:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al obtener el historial" });
    }
};

// [ADMIN] Registra un nuevo pago / renovación de membresía
export const asignarMembresia = async (req, res) => {
    try {
        const body = req.body || {};
        const { id_usuario, estado, fecha_inicio, fecha_fin } = body;
        const idUsuarioNum = Number(id_usuario);
        if (!Number.isInteger(idUsuarioNum) || idUsuarioNum <= 0) {
            return res.status(400).json({ error: "El ID del usuario es obligatorio y debe ser un número entero válido." });
        }
        if (!estado || typeof estado !== "string" || estado.trim() === "") {
            return res.status(400).json({ error: "El estado de la membresía es obligatorio (ej. 'activa', 'inactiva', 'vencida')." });
        }
        if (!fecha_inicio || isNaN(Date.parse(fecha_inicio))) {
            return res.status(400).json({ error: "La fecha de inicio es obligatoria y debe ser válida (YYYY-MM-DD)." });
        }
        if (!fecha_fin || isNaN(Date.parse(fecha_fin))) {
            return res.status(400).json({ error: "La fecha de fin es obligatoria y debe ser válida (YYYY-MM-DD)." });
        }
        if (new Date(fecha_fin) <= new Date(fecha_inicio)) {
            return res.status(400).json({ error: "La fecha de fin debe ser posterior a la fecha de inicio." });
        }
        const datosMembresia = {
            id_usuario: idUsuarioNum,
            estado: estado.trim().toLowerCase(),
            fecha_inicio,
            fecha_fin
        };
        const { data, error } = await registrarMembresiaBD(datosMembresia);
        if (error) {
            return res.status(500).json({ error: "Error al registrar la membresía", detalle: error.message });
        }
        return res.status(201).json({
            mensaje: "Membresía registrada con éxito en el historial",
            membresia: data
        });
    } catch (error) {
        console.error("Error en asignarMembresia:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al registrar la membresía" });
    }
};

// [ADMIN] Cambia el estado de un registro de membresía específico por su id_membresia
export const cambiarEstadoMembresia = async (req, res) => {
    try {
        const { id_membresia } = req.params;
        const { estado } = req.body || {};
        const idMembresiaNum = Number(id_membresia);
        if (!Number.isInteger(idMembresiaNum) || idMembresiaNum <= 0) {
            return res.status(400).json({ error: "El ID de la membresía debe ser un número entero válido." });
        }
        if (!estado || typeof estado !== "string" || estado.trim() === "") {
            return res.status(400).json({ error: "Debes proporcionar el nuevo estado para la membresía." });
        }
        const { data, error } = await cambiarEstadoMembresiaBD(idMembresiaNum, estado.trim().toLowerCase());
        if (error) {
            return res.status(500).json({ error: "Error al actualizar la membresía", detalle: error.message });
        }
        if (!data) {
            return res.status(404).json({ error: "No se encontró el registro de membresía especificado." });
        }
        return res.status(200).json({
            mensaje: `El estado de la membresía fue cambiado a '${estado}'`,
            membresia: data
        });
    } catch (error) {
        console.error("Error en cambiarEstadoMembresia:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al actualizar el estado" });
    }
};