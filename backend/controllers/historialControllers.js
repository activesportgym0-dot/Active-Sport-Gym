import {
    crearHistorialRutina,
    registrarTiempoEjercicio,
    obtenerHistorialesPorUsuario,
    eliminarHistorialPorId,
    vaciarHistorialUsuario
} from "../models/historialModel.js";

// REGISTRAR ENTRENAMIENTO FINALIZADO
export const registrarEntrenamiento = async (req, res) => {
    try {
        const idUsuarioRaw = req.usuario?.id_usuario || req.usuario?.id;
        const id_usuario = Number(idUsuarioRaw);
        const { id_rutina, tiempo_total, ejercicios } = req.body;
        if (!idUsuarioRaw || !Number.isInteger(id_usuario)) {
            return res.status(401).json({ mensaje: "Usuario no autenticado" });
        }
        const idRutinaNum = Number(id_rutina);
        if (!id_rutina || !Number.isInteger(idRutinaNum) || idRutinaNum <= 0) {
            return res.status(400).json({ mensaje: "ID de rutina no válido" });
        }
        const tiempoTotalNum = tiempo_total !== undefined && tiempo_total !== null ? Number(tiempo_total) : 0;
        // Llama a la función del modelo
        const { data: nuevoHistorial, error: errorCabecera } = await crearHistorialRutina(
            idRutinaNum,
            id_usuario,
            tiempoTotalNum
        );
        if (errorCabecera || !nuevoHistorial) {
            return res.status(500).json({
                mensaje: "Error al registrar la rutina en el historial",
                error: errorCabecera ? errorCabecera.message : "No se generó el registro"
            });
        }
        const ejerciciosRegistrados = [];
        // Guarda el tiempo total por cada ejercicio
        if (Array.isArray(ejercicios) && ejercicios.length > 0) {
            for (const ejec of ejercicios) {
                const idEjercicio = Number(ejec.id_ejercicio);
                const tiempoEjercicio = ejec.tiempo_ejercicio !== undefined ? Number(ejec.tiempo_ejercicio) : 0;
                if (Number.isInteger(idEjercicio) && idEjercicio > 0) {
                    const { data: ejecCreado, error: errorEjec } = await registrarTiempoEjercicio(
                        nuevoHistorial.id_historial,
                        idEjercicio,
                        tiempoEjercicio
                    );
                    if (!errorEjec && ejecCreado) {
                        ejerciciosRegistrados.push(ejecCreado);
                    }
                }
            }
        }
        return res.status(201).json({
            mensaje: "Entrenamiento guardado con éxito",
            historial: nuevoHistorial,
            detalle_ejercicios: ejerciciosRegistrados
        });
    } catch (error) {
        console.error("Error al registrar entrenamiento:", error);
        return res.status(500).json({ mensaje: "Error interno del servidor" });
    }
};

// CONSULTAR HISTORIAL PERSONAL DEL CLIENTE
export const listarHistorial = async (req, res) => {
    try {
        const idUsuarioRaw = req.usuario?.id_usuario || req.usuario?.id;
        const id_usuario = Number(idUsuarioRaw);
        if (!idUsuarioRaw || !Number.isInteger(id_usuario)) {
            return res.status(401).json({ mensaje: "Usuario no autenticado" });
        }
        // Llama a la función del modelo
        const { data, error } = await obtenerHistorialesPorUsuario(id_usuario);
        if (error) {
            return res.status(500).json({
                mensaje: "Error al obtener el historial",
                error: error.message
            });
        }
        return res.status(200).json(data);
    } catch (error) {
        console.error("Error al consultar historial:", error);
        return res.status(500).json({ mensaje: "Error interno del servidor" });
    }
};

    // ELIMINAR UN REGISTRO ESPECÍFICO DEL HISTORIAL
export const borrarHistorialPorId = async (req, res) => {
    try {
        const idUsuarioRaw = req.usuario?.id_usuario || req.usuario?.id;
        const id_usuario = Number(idUsuarioRaw);
        const { id } = req.params;
        if (!idUsuarioRaw || !Number.isInteger(id_usuario)) {
            return res.status(401).json({ mensaje: "Usuario no autenticado" });
        }
        const { data, error } = await eliminarHistorialPorId(id, id_usuario);
        if (error) {
            return res.status(500).json({ mensaje: "Error al borrar el historial", error: error.message });
        }
        return res.status(200).json({ mensaje: "Historial eliminado con éxito", data });
    } catch (error) {
        console.error("Error al borrar historial:", error);
        return res.status(500).json({ mensaje: "Error interno del servidor" });
    }
};

// VACIAR TODO EL HISTORIAL DEL USUARIO
export const borrarTodoElHistorial = async (req, res) => {
    try {
        const idUsuarioRaw = req.usuario?.id_usuario || req.usuario?.id;
        const id_usuario = Number(idUsuarioRaw);
        if (!idUsuarioRaw || !Number.isInteger(id_usuario)) {
            return res.status(401).json({ mensaje: "Usuario no autenticado" });
        }
        const { data, error } = await vaciarHistorialUsuario(id_usuario);
        if (error) {
            return res.status(500).json({ mensaje: "Error al vaciar el historial", error: error.message });
        }
        return res.status(200).json({ mensaje: "Historial vaciado con éxito", registros_eliminados: data.length });
    } catch (error) {
        console.error("Error al vaciar historial:", error);
        return res.status(500).json({ mensaje: "Error interno del servidor" });
    }
};