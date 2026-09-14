// Importamos la conexión con Supabase
import { supabase } from "../config/supabase.js";

// OBTENER TODAS LAS RUTINAS
export const obtenerTodasRutinas = async () => {
    const { data, error } = await supabase
        .from("rutinas")
        .select(`
            id_rutina,
            id_usuario,
            nombre,
            tipo,
            fecha_creacion,
            rutina_dias (
                id_rutina_dia,
                dia_semana,
                nombre_dia,
                rutina_ejercicios (
                    id_rutina_ejercicio,
                    id_ejercicio,
                    orden,
                    descanso_final,
                    ejercicios (
                        id_ejercicio,
                        nombre,
                        gif_url,
                        maquina
                    ),
                    rutina_series (
                        id_rutina_serie,
                        numero_serie,
                        repeticiones,
                        peso,
                        descanso_entre_series
                    )
                )
            )
        `)
        .order("id_rutina", { ascending: true });
    return { data, error };
};

// OBTENER UNA RUTINA POR ID
export const obtenerRutinaPorId = async (id) => {
    const { data, error } = await supabase
        .from("rutinas")
        .select(`
            id_rutina,
            id_usuario,
            nombre,
            tipo,
            fecha_creacion,
            rutina_dias (
                id_rutina_dia,
                dia_semana,
                nombre_dia,
                rutina_ejercicios (
                    id_rutina_ejercicio,
                    id_ejercicio,
                    orden,
                    descanso_final,
                    ejercicios (
                        id_ejercicio,
                        nombre,
                        gif_url,
                        maquina
                    ),
                    rutina_series (
                        id_rutina_serie,
                        numero_serie,
                        repeticiones,
                        peso,
                        descanso_entre_series
                    )
                )
            )
        `)
        .eq("id_rutina", id)
        .single();
    return { data, error };
};

// OBTENER RUTINAS DE UN USUARIO
export const obtenerRutinasPorUsuario = async (idUsuario) => {
    const { data, error } = await supabase
        .from("rutinas")
        .select(`
            id_rutina,
            id_usuario,
            nombre,
            tipo,
            fecha_creacion,
            rutina_dias (
                id_rutina_dia,
                dia_semana,
                nombre_dia,
                rutina_ejercicios (
                    id_rutina_ejercicio,
                    id_ejercicio,
                    orden,
                    descanso_final,
                    ejercicios (
                        id_ejercicio,
                        nombre,
                        gif_url,
                        maquina
                    ),
                    rutina_series (
                        id_rutina_serie,
                        numero_serie,
                        repeticiones,
                        peso,
                        descanso_entre_series
                    )
                )
            )
        `)
        .eq("id_usuario", idUsuario)
        .order("id_rutina", { ascending: true });
    return { data, error };
};

// CREAR RUTINA
export const crearRutina = async (idUsuario, nombre, tipo) => {
    const { data, error } = await supabase
        .from("rutinas")
        .insert({
            id_usuario: idUsuario,
            nombre: nombre,
            tipo: tipo
        })
        .select(`
            id_rutina,
            id_usuario,
            nombre,
            tipo,
            fecha_creacion
        `)
        .single();
    return { data, error };
};

// AGREGAR DÍA A UNA RUTINA
export const crearDiaRutina = async (idRutina, diaSemana, nombreDia) => {
    const { data, error } = await supabase
        .from("rutina_dias")
        .insert({
            id_rutina: idRutina,
            dia_semana: diaSemana,
            nombre_dia: nombreDia
        })
        .select(`
            id_rutina_dia,
            id_rutina,
            dia_semana,
            nombre_dia
        `)
        .single();
    return { data, error };
};

// AGREGAR EJERCICIO A UN DÍA DE LA RUTINA
export const agregarEjercicioRutina = async (idRutinaDia, idEjercicio, orden, descansoFinal) => {
    const { data, error } = await supabase
        .from("rutina_ejercicios")
        .insert({
            id_rutina_dia: idRutinaDia,
            id_ejercicio: idEjercicio,
            orden: orden,
            descanso_final: descansoFinal
        })
        .select(`
            id_rutina_ejercicio,
            id_rutina_dia,
            id_ejercicio,
            orden,
            descanso_final
        `)
        .single();
    return { data, error };
};

// AGREGAR SERIE A UN EJERCICIO DE LA RUTINA
export const agregarSerieRutina = async (idRutinaEjercicio, numeroSerie, repeticiones, peso, descansoEntreSeries) => {
    const { data, error } = await supabase
        .from("rutina_series")
        .insert({
            id_rutina_ejercicio: idRutinaEjercicio,
            numero_serie: numeroSerie,
            repeticiones: repeticiones,
            peso: peso,
            descanso_entre_series: descansoEntreSeries
        })
        .select(`
            id_rutina_serie,
            id_rutina_ejercicio,
            numero_serie,
            repeticiones,
            peso,
            descanso_entre_series
        `)
        .single();
    return { data, error };
};

// ACTUALIZAR RUTINA
export const actualizarRutina = async (id, campos) => {
    const { data, error } = await supabase
        .from("rutinas")
        .update(campos)
        .eq("id_rutina", id)
        .select(`
            id_rutina,
            id_usuario,
            nombre,
            tipo,
            fecha_creacion
        `)
        .single();
    return { data, error };
};

// ACTUALIZAR DÍA DE UNA RUTINA
export const actualizarDiaRutina = async (idRutinaDia, campos) => {
    const { data, error } = await supabase
        .from("rutina_dias")
        .update(campos)
        .eq("id_rutina_dia", idRutinaDia)
        .select(`
            id_rutina_dia,
            id_rutina,
            dia_semana,
            nombre_dia
        `)
        .single();
    return { data, error };
};

// ACTUALIZAR EJERCICIO DE UNA RUTINA
export const actualizarEjercicioRutina = async (idRutinaEjercicio, campos) => {
    const { data, error } = await supabase
        .from("rutina_ejercicios")
        .update(campos)
        .eq("id_rutina_ejercicio", idRutinaEjercicio)
        .select(`
            id_rutina_ejercicio,
            id_rutina_dia,
            id_ejercicio,
            orden,
            descanso_final
        `)
        .single();
    return { data, error };
};

// ACTUALIZAR SERIE
export const actualizarSerieRutina = async (idRutinaSerie, campos) => {
    const { data, error } = await supabase
        .from("rutina_series")
        .update(campos)
        .eq("id_rutina_serie", idRutinaSerie)
        .select(`
            id_rutina_serie,
            id_rutina_ejercicio,
            numero_serie,
            repeticiones,
            peso,
            descanso_entre_series
        `)
        .single();
    return { data, error };
};

// ELIMINAR DÍA DE UNA RUTINA
export const eliminarDiaRutina = async (idRutinaDia) => {
    const { data, error } = await supabase
        .from("rutina_dias")
        .delete()
        .eq("id_rutina_dia", idRutinaDia)
        .select(`
            id_rutina_dia,
            id_rutina,
            dia_semana,
            nombre_dia
        `)
        .single();
    return { data, error };
};

// ELIMINAR EJERCICIO DE UNA RUTINA
export const eliminarEjercicioRutina = async (idRutinaEjercicio) => {
    const { data, error } = await supabase
        .from("rutina_ejercicios")
        .delete()
        .eq("id_rutina_ejercicio", idRutinaEjercicio)
        .select(`
            id_rutina_ejercicio,
            id_rutina_dia,
            id_ejercicio,
            orden,
            descanso_final
        `)
        .single();
    return { data, error };
};

// ELIMINAR SERIE
export const eliminarSerieRutina = async (idRutinaSerie) => {
    const { data, error } = await supabase
        .from("rutina_series")
        .delete()
        .eq("id_rutina_serie", idRutinaSerie)
        .select(`
            id_rutina_serie,
            id_rutina_ejercicio,
            numero_serie,
            repeticiones,
            peso,
            descanso_entre_series
        `)
        .single();
    return { data, error };
};

// ELIMINAR RUTINA
export const eliminarRutina = async (id) => {
    const { data, error } = await supabase
        .from("rutinas")
        .delete()
        .eq("id_rutina", id)
        .select(`
            id_rutina,
            id_usuario,
            nombre,
            tipo,
            fecha_creacion
        `)
        .single();
    return { data, error };
};