import {
    obtenerTodasRutinas,
    obtenerRutinaPorId,
    obtenerRutinasPorUsuario,
    crearRutina,
    crearDiaRutina,
    agregarEjercicioRutina,
    agregarSerieRutina,
    actualizarRutina,
    actualizarDiaRutina,
    actualizarEjercicioRutina,
    actualizarSerieRutina,
    eliminarSerieRutina,
    eliminarEjercicioRutina,
    eliminarRutina
} from "../models/rutinaModel.js";
import { supabase } from "../config/supabase.js";

// 1. OBTENER TODAS LAS RUTINAS (Uso administrativo/general)
export const listarRutinas = async (req, res) => {
    try {
        const { data, error } = await obtenerTodasRutinas();
        if (error) {
            console.error("Error al obtener rutinas:", error);
            return res.status(500).json({
                mensaje: "Error al obtener las rutinas",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Rutinas obtenidas correctamente",
            cantidad: data ? data.length : 0,
            rutinas: data || []
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};

// 2. OBTENER UNA RUTINA ESPECÍFICA POR SU ID
export const obtenerRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID de la rutina debe ser un número válido"
            });
        }
        
        const { data, error } = await obtenerRutinaPorId(Number(id));
        if (error || !data) {
            return res.status(404).json({
                mensaje: "Rutina no encontrada"
            });
        }

        // Validación de propiedad mediante el token
        if (Number(data.id_usuario) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({
                mensaje: "No tienes permiso para consultar esta rutina"
            });
        }

        return res.status(200).json({
            mensaje: "Rutina obtenida correctamente",
            rutina: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};

// 3. OBTENER TODAS LAS RUTINAS DEL USUARIO AUTENTICADO (Automático por el Token)
export const listarRutinasPorUsuario = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        if (!idUsuarioAutenticado || isNaN(idUsuarioAutenticado)) {
            return res.status(401).json({
                mensaje: "Usuario no autenticado o token inválido"
            });
        }

        const { data, error } = await obtenerRutinasPorUsuario(Number(idUsuarioAutenticado));
        if (error) {
            console.error("Error al obtener rutinas del usuario:", error);
            return res.status(500).json({
                mensaje: "Error al obtener las rutinas del usuario",
                error: error.message
            });
        }

        return res.status(200).json({
            mensaje: "Rutinas del usuario obtenidas correctamente",
            cantidad: data ? data.length : 0,
            rutinas: data || []
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// 4. CREAR RUTINA
export const registrarRutina = async (req, res) => {
    try {
        const idUsuarioRaw = req.usuario?.id_usuario || req.usuario?.id;
        const id_usuario = Number(idUsuarioRaw);
        if (!idUsuarioRaw || !Number.isInteger(id_usuario)) {
            return res.status(401).json({
                mensaje: "Usuario no autenticado o token inválido"
            });
        }

        let { nombre, tipo, fecha, dias, ejercicios } = req.body;

        // Validaciones de Nombre
        if (!nombre || typeof nombre !== "string") {
            return res.status(400).json({
                mensaje: "El nombre de la rutina es obligatorio"
            });
        }
        const nombreLimpio = nombre.trim();
        if (nombreLimpio.length === 0) {
            return res.status(400).json({
                mensaje: "El nombre de la rutina no puede estar vacío"
            });
        }
        if (nombreLimpio.length > 100) {
            return res.status(400).json({
                mensaje: "El nombre de la rutina no puede superar los 100 caracteres"
            });
        }

        // Validación de Tipo
        if (tipo !== "diaria" && tipo !== "semanal") {
            return res.status(400).json({
                mensaje: "El tipo de rutina debe ser diaria o semanal"
            });
        }

        // Validación de Fecha
        let fechaLimpia = null;
        if (fecha) {
            const fechaParsed = new Date(fecha);
            if (isNaN(fechaParsed.getTime())) {
                return res.status(400).json({
                    mensaje: "La fecha enviada no tiene un formato válido"
                });
            }
            fechaLimpia = fecha;
        }

        // Adaptación automática para rutina diaria si envían 'ejercicios' en la raíz
        if (tipo === "diaria" && (!dias || !Array.isArray(dias))) {
            if (!ejercicios || !Array.isArray(ejercicios) || ejercicios.length === 0) {
                return res.status(400).json({
                    mensaje: "La rutina diaria debe contener un arreglo de ejercicios"
                });
            }
            dias = [
                {
                    dia_semana: "diario",
                    nombre_dia: nombreLimpio,
                    ejercicios: ejercicios
                }
            ];
        }

        // Validación del arreglo de días
        if (!Array.isArray(dias) || dias.length === 0) {
            return res.status(400).json({
                mensaje: "La rutina debe tener al menos un día con ejercicios"
            });
        }

        // Se incluye "diario" en la lista de días permitidos
        const diasValidos = [
            "lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo", "diario"
        ];
        const diasLimpios = [];

        for (const dia of dias) {
            if (!dia || typeof dia !== "object") {
                return res.status(400).json({ mensaje: "La información de los días no es válida" });
            }

            let diaSemana = typeof dia.dia_semana === "string" ? dia.dia_semana.trim().toLowerCase() : "";

            if (tipo === "diaria" && !diaSemana) {
                diaSemana = "diario";
            }

            if (!diasValidos.includes(diaSemana)) {
                return res.status(400).json({ mensaje: "Uno de los días enviados no es válido" });
            }

            if (diasLimpios.some(item => item.dia_semana === diaSemana)) {
                return res.status(400).json({ mensaje: "No se puede repetir un día dentro de la rutina" });
            }

            const listaEjercicios = dia.ejercicios === undefined ? [] : dia.ejercicios;

            if (!Array.isArray(listaEjercicios)) {
                return res.status(400).json({ mensaje: "Los ejercicios de cada día deben enviarse como un arreglo" });
            }

            if (listaEjercicios.length === 0) continue;

            const nombreDia = tipo === "diaria"
                ? (dia.nombre_dia || nombreLimpio)
                : String(dia.nombre_dia || "").trim();

            if (tipo === "semanal" && nombreDia.length === 0) {
                return res.status(400).json({ mensaje: `Debes colocar el nombre del día ${diaSemana}` });
            }

            diasLimpios.push({
                dia_semana: diaSemana,
                nombre_dia: nombreDia,
                ejercicios: listaEjercicios
            });
        }

        // Reglas de negocio según el tipo
        if (tipo === "diaria" && diasLimpios.length !== 1) {
            return res.status(400).json({
                mensaje: "Una rutina diaria debe tener exactamente un solo día con ejercicios"
            });
        }

        if (tipo === "semanal") {
            if (diasLimpios.length < 2 || diasLimpios.length > 7) {
                return res.status(400).json({
                    mensaje: "Una rutina semanal debe incluir entre 2 y 7 días con ejercicios"
                });
            }
        }

        // Insertar Rutina Principal
        const { data: rutina, error: errorRutina } = await crearRutina(
            id_usuario,
            nombreLimpio,
            tipo,
            fechaLimpia
        );

        if (errorRutina || !rutina) {
            return res.status(500).json({
                mensaje: "No fue posible crear la rutina",
                error: errorRutina ? errorRutina.message : "Error al obtener la rutina creada"
            });
        }

        const diasCreados = [];

        // Insertar Días, Ejercicios y Series
        for (const dia of diasLimpios) {
            const { data: diaCreado, error: errorDia } = await crearDiaRutina(
                rutina.id_rutina,
                dia.dia_semana,
                dia.nombre_dia
            );

            if (errorDia || !diaCreado) {
                await eliminarRutina(rutina.id_rutina);
                return res.status(500).json({
                    mensaje: "No fue posible crear los días de la rutina",
                    error: errorDia ? errorDia.message : "Error al obtener el día creado"
                });
            }

            const objetoDia = { ...diaCreado, ejercicios: [] };

            for (let indice = 0; indice < dia.ejercicios.length; indice++) {
                const ejercicio = dia.ejercicios[indice];
                const idEjercicio = Number(ejercicio?.id_ejercicio);

                if (!idEjercicio || !Number.isInteger(idEjercicio) || idEjercicio <= 0) {
                    await eliminarRutina(rutina.id_rutina);
                    return res.status(400).json({
                        mensaje: "Cada ejercicio debe tener un ID válido"
                    });
                }

                const { data: ejercicioExistente, error: errorEjercicio } = await supabase
                    .from("ejercicios")
                    .select("id_ejercicio")
                    .eq("id_ejercicio", idEjercicio)
                    .single();

                if (errorEjercicio || !ejercicioExistente) {
                    await eliminarRutina(rutina.id_rutina);
                    return res.status(404).json({
                        mensaje: `El ejercicio con ID ${idEjercicio} no existe en el catálogo`
                    });
                }

                const descansoFinal = ejercicio.descanso_final === undefined || ejercicio.descanso_final === null || ejercicio.descanso_final === ""
                    ? null
                    : Number(ejercicio.descanso_final);

                const { data: ejercicioRutina, error: errorEjercicioRutina } = await agregarEjercicioRutina(
                    diaCreado.id_rutina_dia,
                    idEjercicio,
                    indice + 1,
                    descansoFinal,
                    rutina.id_rutina
                );

                if (errorEjercicioRutina || !ejercicioRutina) {
                    await eliminarRutina(rutina.id_rutina);
                    return res.status(500).json({
                        mensaje: "No fue posible agregar un ejercicio a la rutina",
                        error: errorEjercicioRutina ? errorEjercicioRutina.message : "Error al vincular el ejercicio"
                    });
                }

                const series = ejercicio.series;
                if (!Array.isArray(series) || series.length === 0) {
                    await eliminarRutina(rutina.id_rutina);
                    return res.status(400).json({
                        mensaje: "Cada ejercicio debe tener al menos una serie"
                    });
                }

                for (let numeroSerie = 0; numeroSerie < series.length; numeroSerie++) {
                    const serie = series[numeroSerie];
                    const repeticiones = Number(serie?.repeticiones);

                    if (!Number.isInteger(repeticiones) || repeticiones <= 0) {
                        await eliminarRutina(rutina.id_rutina);
                        return res.status(400).json({
                            mensaje: `Las repeticiones de la Serie ${numeroSerie + 1} deben ser mayores que cero`
                        });
                    }
                    const peso = serie.peso === undefined || serie.peso === null || serie.peso === "" ? null : Number(serie.peso);
                    const descansoEntreSeries = serie.descanso_entre_series === undefined || serie.descanso_entre_series === null || serie.descanso_entre_series === "" ? null : Number(serie.descanso_entre_series);
                    const { error: errorSerie } = await agregarSerieRutina(
                        ejercicioRutina.id_rutina_ejercicio,
                        numeroSerie + 1,
                        repeticiones,
                        peso,
                        descansoEntreSeries
                    );
                    if (errorSerie) {
                        await eliminarRutina(rutina.id_rutina);
                        return res.status(500).json({
                            mensaje: `No fue posible agregar la Serie ${numeroSerie + 1}`,
                            error: errorSerie.message
                        });
                    }
                }
                objetoDia.ejercicios.push({
                    id_rutina_ejercicio: ejercicioRutina.id_rutina_ejercicio,
                    id_ejercicio: ejercicioRutina.id_ejercicio,
                    orden: ejercicioRutina.orden,
                    descanso_final: ejercicioRutina.descanso_final
                });
            }
            diasCreados.push(objetoDia);
        }
        return res.status(201).json({
            mensaje: "Rutina creada correctamente",
            rutina: rutina,
            dias: diasCreados
        });
    } catch (error) {
        console.error("Error inesperado al crear rutina:", error);
        return res.status(500).json({ mensaje: "Error interno del servidor" });
    }
};
// 5. ACTUALIZAR RUTINA COMPLETA (NOMBRE, TIPO, DÍAS Y EJERCICIOS)
export const editarRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        const numId = Number(id);
        if (!id || Number.isNaN(numId)) {
            return res.status(400).json({
                mensaje: "El ID de la rutina debe ser un número válido"
            });
        }
        // 1. Verificar propiedad y existencia de la rutina
        const { data: rutinaExistente, error: errorExistente } = await obtenerRutinaPorId(numId);
        if (errorExistente || !rutinaExistente) {
            return res.status(404).json({ mensaje: "Rutina no encontrada" });
        }
        if (Number(rutinaExistente.id_usuario) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({ mensaje: "No tienes permiso para modificar esta rutina" });
        }
        let { nombre, tipo, fecha, dias, ejercicios } = req.body;
        // 2. Validaciones básicas (Igual que en crear)
        if (!nombre || typeof nombre !== "string") {
            return res.status(400).json({ mensaje: "El nombre de la rutina es obligatorio" });
        }
        const nombreLimpio = nombre.trim();
        if (nombreLimpio.length === 0 || nombreLimpio.length > 100) {
            return res.status(400).json({ mensaje: "El nombre no es válido o supera los 100 caracteres" });
        }
        if (tipo !== "diaria" && tipo !== "semanal") {
            return res.status(400).json({ mensaje: "El tipo de rutina debe ser diaria o semanal" });
        }
        // Adaptación automática si mandan ejercicios en la raíz para rutina diaria
        if (tipo === "diaria" && (!dias || !Array.isArray(dias))) {
            if (!ejercicios || !Array.isArray(ejercicios) || ejercicios.length === 0) {
                return res.status(400).json({ mensaje: "La rutina diaria debe contener un arreglo de ejercicios" });
            }
            dias = [{ dia_semana: "diario", nombre_dia: nombreLimpio, ejercicios: ejercicios }];
        }
        if (!Array.isArray(dias) || dias.length === 0) {
            return res.status(400).json({ mensaje: "La rutina debe tener al menos un día con ejercicios" });
        }
        // Validaciones de días y estructura (la misma lógica que ya tienes)
        const diasValidos = ["lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo", "diario"];
        const diasLimpios = [];
        for (const dia of dias) {
            let diaSemana = typeof dia.dia_semana === "string" ? dia.dia_semana.trim().toLowerCase() : "";
            if (tipo === "diaria" && !diaSemana) diaSemana = "diario";
            if (!diasValidos.includes(diaSemana)) {
                return res.status(400).json({ mensaje: "Uno de los días enviados no es válido" });
            }
            const listaEjercicios = Array.isArray(dia.ejercicios) ? dia.ejercicios : [];
            if (listaEjercicios.length === 0) continue;
            const nombreDia = tipo === "diaria" ? (dia.nombre_dia || nombreLimpio) : String(dia.nombre_dia || "").trim();
            diasLimpios.push({
                dia_semana: diaSemana,
                nombre_dia: nombreDia,
                ejercicios: listaEjercicios
            });
        }
        if (tipo === "diaria" && diasLimpios.length !== 1) {
            return res.status(400).json({ mensaje: "Una rutina diaria debe tener exactamente un solo día con ejercicios" });
        }
        if (tipo === "semanal" && (diasLimpios.length < 2 || diasLimpios.length > 7)) {
            return res.status(400).json({ mensaje: "Una rutina semanal debe incluir entre 2 y 7 días con ejercicios" });
        }
        // 3. Actualizar los datos principales de la rutina (nombre, tipo, fecha si aplica)
        const { data: rutinaActualizada, error: errorUpdate } = await actualizarRutina(numId, {
            nombre: nombreLimpio,
            tipo: tipo,
            ...(fecha && { fecha })
        });
        if (errorUpdate) {
            return res.status(500).json({ mensaje: "Error al actualizar la información principal de la rutina" });
        }
        // 4. Limpiar los días y ejercicios viejos antes de meter los nuevos
        const { error: errorLimpiar } = await limpiarDiasRutina(numId);
        if (errorLimpiar) {
            return res.status(500).json({ mensaje: "Error al limpiar la estructura anterior de la rutina" });
        }
        const diasCreados = [];
        // 5. Reinsertar los nuevos días, ejercicios y series (Idéntico a la creación)
        for (const dia of diasLimpios) {
            const { data: diaCreado, error: errorDia } = await crearDiaRutina(
                numId,
                dia.dia_semana,
                dia.nombre_dia
            );
            if (errorDia || !diaCreado) {
                return res.status(500).json({ mensaje: "Error al registrar los nuevos días de la rutina" });
            }
            const objetoDia = { ...diaCreado, ejercicios: [] };
            for (let indice = 0; indice < dia.ejercicios.length; indice++) {
                const ejercicio = dia.ejercicios[indice];
                const idEjercicio = Number(ejercicio?.id_ejercicio);
                const descansoFinal = ejercicio.descanso_final === undefined || ejercicio.descanso_final === "" ? null : Number(ejercicio.descanso_final);
                const { data: ejercicioRutina, error: errorEjercicioRutina } = await agregarEjercicioRutina(
                    diaCreado.id_rutina_dia,
                    idEjercicio,
                    indice + 1,
                    descansoFinal,
                    numId
                );
                if (errorEjercicioRutina || !ejercicioRutina) {
                    return res.status(500).json({ mensaje: "Error al vincular los nuevos ejercicios" });
                }
                const series = ejercicio.series;
                if (Array.isArray(series)) {
                    for (let numeroSerie = 0; numeroSerie < series.length; numeroSerie++) {
                        const serie = series[numeroSerie];
                        const repeticiones = Number(serie?.repeticiones);
                        const peso = serie.peso === undefined || serie.peso === "" ? null : Number(serie.peso);
                        const descansoEntreSeries = serie.descanso_entre_series === undefined || serie.descanso_entre_series === "" ? null : Number(serie.descanso_entre_series);
                        await agregarSerieRutina(
                            ejercicioRutina.id_rutina_ejercicio,
                            numeroSerie + 1,
                            repeticiones,
                            peso,
                            descansoEntreSeries
                        );
                    }
                }
                objetoDia.ejercicios.push({
                    id_rutina_ejercicio: ejercicioRutina.id_rutina_ejercicio,
                    id_ejercicio: ejercicioRutina.id_rutina_ejercicio,
                    orden: ejercicioRutina.orden
                });
            }
            diasCreados.push(objetoDia);
        }
        return res.status(200).json({
            mensaje: "Rutina actualizada correctamente",
            rutina: rutinaActualizada,
            dias: diasCreados
        });
    } catch (error) {
        console.error("Error inesperado al actualizar rutina completa:", error);
        return res.status(500).json({ mensaje: "Error interno del servidor" });
    }
};
// 6. ACTUALIZAR DÍA DE LA RUTINA
export const editarDiaRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        const numId = Number(id);
        if (!id || Number.isNaN(numId)) {
            return res.status(400).json({
                mensaje: "El ID del día debe ser un número válido"
            });
        }
        // Validar propiedad del recurso mediante relación
        const { data: diaExistente, error: errorDiaConsulta } = await supabase
            .from("rutina_dias")
            .select("id_rutina_dia, rutinas(id_usuario)")
            .eq("id_rutina_dia", numId)
            .single();
        if (errorDiaConsulta || !diaExistente) {
            return res.status(404).json({ mensaje: "El día especificado no existe" });
        }
        if (Number(diaExistente.rutinas?.id_usuario) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({ mensaje: "No tienes permiso para modificar este día" });
        }
        const camposPermitidos = ["dia_semana", "nombre_dia"];
        const campos = {};
        for (const campo of camposPermitidos) {
            if (req.body[campo] !== undefined) {
                campos[campo] = req.body[campo];
            }
        }
        if (Object.keys(campos).length === 0) {
            return res.status(400).json({
                mensaje: "No se proporcionaron datos para actualizar"
            });
        }
        if (campos.dia_semana !== undefined) {
            if (typeof campos.dia_semana !== "string") {
                return res.status(400).json({
                    mensaje: "El día no es válido"
                });
            }
            campos.dia_semana = campos.dia_semana.trim().toLowerCase();
        }
        if (campos.nombre_dia !== undefined) {
            if (typeof campos.nombre_dia !== "string") {
                return res.status(400).json({
                    mensaje: "El nombre del día no es válido"
                });
            }
            campos.nombre_dia = campos.nombre_dia.trim();
        }
        const { data, error } = await actualizarDiaRutina(numId, campos);
        if (error) {
            console.error("Error al actualizar día:", error);
            return res.status(500).json({
                mensaje: "No fue posible actualizar el día",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Día actualizado correctamente",
            dia: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// 7. ACTUALIZAR EJERCICIO DE LA RUTINA
export const editarEjercicioRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        const numId = Number(id);
        if (!id || Number.isNaN(numId)) {
            return res.status(400).json({
                mensaje: "El ID del ejercicio de la rutina debe ser válido"
            });
        }
        // Validar propiedad del recurso mediante relación profunda
        const { data: ejExistente, error: errorEjConsulta } = await supabase
            .from("rutina_ejercicios")
            .select("id_rutina_ejercicio, rutina_dias(rutinas(id_usuario))")
            .eq("id_rutina_ejercicio", numId)
            .single();
        if (errorEjConsulta || !ejExistente) {
            return res.status(404).json({ mensaje: "El ejercicio de la rutina no existe" });
        }
        const idDuenio = ejExistente.rutina_dias?.rutinas?.id_usuario;
        if (Number(idDuenio) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({ mensaje: "No tienes permiso para modificar este ejercicio" });
        }

        // AGREGAMOS "id_ejercicio" A LOS CAMPOS PERMITIDOS
        const camposPermitidos = ["orden", "descanso_final", "id_ejercicio"];
        const campos = {};
        for (const campo of camposPermitidos) {
            if (req.body[campo] !== undefined) {
                campos[campo] = req.body[campo];
            }
        }
        if (Object.keys(campos).length === 0) {
            return res.status(400).json({
                mensaje: "No se proporcionaron datos para actualizar"
            });
        }

        // VALIDACIÓN PARA ID_EJERCICIO SI LO MANDAN
        if (campos.id_ejercicio !== undefined) {
            const idEj = Number(campos.id_ejercicio);
            if (!Number.isInteger(idEj) || idEj <= 0) {
                return res.status(400).json({
                    mensaje: "El ID del ejercicio del catálogo no es válido"
                });
            }
            campos.id_ejercicio = idEj;
        }

        if (campos.orden !== undefined) {
            const orden = Number(campos.orden);
            if (!Number.isInteger(orden) || orden <= 0) {
                return res.status(400).json({
                    mensaje: "El orden debe ser un número entero mayor que cero"
                });
            }
            campos.orden = orden;
        }
        if (campos.descanso_final !== undefined) {
            if (campos.descanso_final === null || campos.descanso_final === "") {
                campos.descanso_final = null;
            } else {
                const descanso = Number(campos.descanso_final);
                if (!Number.isInteger(descanso) || descanso < 0) {
                    return res.status(400).json({
                        mensaje: "El descanso final no es válido"
                    });
                }
                campos.descanso_final = descanso;
            }
        }
        const { data, error } = await actualizarEjercicioRutina(numId, campos);
        if (error) {
            console.error("Error al actualizar ejercicio:", error);
            return res.status(500).json({
                mensaje: "No fue posible actualizar el ejercicio de la rutina",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Ejercicio de la rutina actualizado correctamente",
            ejercicio: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// 8. ACTUALIZAR SERIE
export const editarSerieRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        const numId = Number(id);
        if (!id || Number.isNaN(numId)) {
            return res.status(400).json({
                mensaje: "El ID de la serie debe ser válido"
            });
        }
        // Validar propiedad del recurso mediante relación profunda
        const { data: serieExistente, error: errorSerieConsulta } = await supabase
            .from("rutina_series")
            .select("id_rutina_serie, rutina_ejercicios(rutina_dias(rutinas(id_usuario)))")
            .eq("id_rutina_serie", numId)
            .single();
        if (errorSerieConsulta || !serieExistente) {
            return res.status(404).json({ mensaje: "La serie no existe" });
        }
        const idDuenio = serieExistente.rutina_ejercicios?.rutina_dias?.rutinas?.id_usuario;
        if (Number(idDuenio) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({ mensaje: "No tienes permiso para modificar esta serie" });
        }
        const camposPermitidos = ["repeticiones", "peso", "descanso_entre_series"];
        const campos = {};
        for (const campo of camposPermitidos) {
            if (req.body[campo] !== undefined) {
                campos[campo] = req.body[campo];
            }
        }
        if (Object.keys(campos).length === 0) {
            return res.status(400).json({
                mensaje: "No se proporcionaron datos para actualizar"
            });
        }
        if (campos.repeticiones !== undefined) {
            const repeticiones = Number(campos.repeticiones);
            if (!Number.isInteger(repeticiones) || repeticiones <= 0) {
                return res.status(400).json({
                    mensaje: "Las repeticiones deben ser mayores que cero"
                });
            }
            campos.repeticiones = repeticiones;
        }
        if (campos.peso !== undefined) {
            if (campos.peso === null || campos.peso === "") {
                campos.peso = null;
            } else {
                const peso = Number(campos.peso);
                if (Number.isNaN(peso) || peso < 0) {
                    return res.status(400).json({
                        mensaje: "El peso no es válido"
                    });
                }
                campos.peso = peso;
            }
        }
        if (campos.descanso_entre_series !== undefined) {
            if (campos.descanso_entre_series === null || campos.descanso_entre_series === "") {
                campos.descanso_entre_series = null;
            } else {
                const descanso = Number(campos.descanso_entre_series);
                if (!Number.isInteger(descanso) || descanso < 0) {
                    return res.status(400).json({
                        mensaje: "El descanso entre series no es válido"
                    });
                }
                campos.descanso_entre_series = descanso;
            }
        }
        const { data, error } = await actualizarSerieRutina(numId, campos);
        if (error) {
            console.error("Error al actualizar serie:", error);
            return res.status(500).json({
                mensaje: "No fue posible actualizar la serie",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Serie actualizada correctamente",
            serie: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// 9. ELIMINAR SERIE
export const borrarSerieRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        const numId = Number(id);
        if (!id || Number.isNaN(numId)) {
            return res.status(400).json({
                mensaje: "El ID de la serie debe ser válido"
            });
        }
        const { data: serieExistente, error: errorSerieConsulta } = await supabase
            .from("rutina_series")
            .select("id_rutina_serie, rutina_ejercicios(rutina_dias(rutinas(id_usuario)))")
            .eq("id_rutina_serie", numId)
            .single();
        if (errorSerieConsulta || !serieExistente) {
            return res.status(404).json({ mensaje: "La serie no existe" });
        }
        const idDuenio = serieExistente.rutina_ejercicios?.rutina_dias?.rutinas?.id_usuario;
        if (Number(idDuenio) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({ mensaje: "No tienes permiso para eliminar esta serie" });
        }
        const { data, error } = await eliminarSerieRutina(numId);
        if (error) {
            console.error("Error al eliminar serie:", error);
            return res.status(500).json({
                mensaje: "No fue posible eliminar la serie",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Serie eliminada correctamente",
            serie: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// 10. ELIMINAR EJERCICIO DE LA RUTINA
export const borrarEjercicioRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        const numId = Number(id);
        if (!id || Number.isNaN(numId)) {
            return res.status(400).json({
                mensaje: "El ID del ejercicio de la rutina debe ser válido"
            });
        }
        const { data: ejExistente, error: errorEjConsulta } = await supabase
            .from("rutina_ejercicios")
            .select("id_rutina_ejercicio, rutina_dias(rutinas(id_usuario))")
            .eq("id_rutina_ejercicio", numId)
            .single();
        if (errorEjConsulta || !ejExistente) {
            return res.status(404).json({ mensaje: "El ejercicio de la rutina no existe" });
        }
        const idDuenio = ejExistente.rutina_dias?.rutinas?.id_usuario;
        if (Number(idDuenio) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({ mensaje: "No tienes permiso para eliminar este ejercicio" });
        }
        const { data, error } = await eliminarEjercicioRutina(numId);
        if (error) {
            console.error("Error al eliminar ejercicio:", error);
            return res.status(500).json({
                mensaje: "No fue posible eliminar el ejercicio de la rutina",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Ejercicio eliminado de la rutina correctamente",
            ejercicio: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// 11. ELIMINAR RUTINA COMPLETA
export const borrarRutina = async (req, res) => {
    try {
        const idUsuarioAutenticado = req.usuario?.id_usuario || req.usuario?.id;
        const { id } = req.params;
        const numId = Number(id);
        if (!id || Number.isNaN(numId)) {
            return res.status(400).json({
                mensaje: "El ID de la rutina debe ser un número válido"
            });
        }
        const { data: rutinaExistente, error: errorExistente } = await obtenerRutinaPorId(numId);
        if (errorExistente || !rutinaExistente) {
            return res.status(404).json({ mensaje: "Rutina no encontrada" });
        }
        if (Number(rutinaExistente.id_usuario) !== Number(idUsuarioAutenticado)) {
            return res.status(403).json({ mensaje: "No tienes permiso para eliminar esta rutina" });
        }
        const { data, error } = await eliminarRutina(numId);
        if (error) {
            console.error("Error al eliminar rutina:", error);
            return res.status(500).json({
                mensaje: "No fue posible eliminar la rutina",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Rutina eliminada correctamente",
            rutina: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};