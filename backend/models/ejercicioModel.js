// Importamos la conexión con Supabase
import { supabase } from "../config/supabase.js";

// OBTENER TODOS LOS EJERCICIOS
export const obtenerTodosEjercicios = async () => {
    const { data, error } = await supabase
        .from("ejercicios")
        .select(`
            id_ejercicio,
            nombre,
            imagen,
            gif_url,
            maquina,
            ejercicio_categoria (
                id_categoria,
                categoria_ejercicios (
                    id_categoria,
                    nombre
                )
            )
        `)
        .order("id_ejercicio", { ascending: true });
    return { data, error };
};

// OBTENER UN EJERCICIO POR ID
export const obtenerEjercicioPorId = async (id) => {
    const { data, error } = await supabase
        .from("ejercicios")
        .select(`
            id_ejercicio,
            nombre,
            imagen,
            gif_url,
            instrucciones,
            maquina,
            descripcion,
            beneficios,
            rango_movimiento,
            respiracion,
            ritmo_movimiento,
            ejercicio_categoria (
                id_categoria,
                categoria_ejercicios (
                    id_categoria,
                    nombre
                )
            )
        `)
        .eq("id_ejercicio", id)
        .single();

    return { data, error };
};

// OBTENER EJERCICIOS POR CATEGORÍA
export const obtenerEjerciciosPorCategoria = async (idCategoria) => {
    const { data, error } = await supabase
        .from("ejercicio_categoria")
        .select(`
            id_categoria,
            ejercicios (
                id_ejercicio,
                nombre,
                imagen,
                gif_url,
                maquina
            )
        `)
        .eq("id_categoria", idCategoria);

    return { data, error };
};

// CREAR EJERCICIO
export const crearEjercicio = async (ejercicio) => {
    const {
        nombre,
        imagen,
        gif_url,
        instrucciones,
        maquina,
        descripcion,
        beneficios,
        rango_movimiento,
        respiracion,
        ritmo_movimiento
    } = ejercicio;
    const { data, error } = await supabase
        .from("ejercicios")
        .insert({
            nombre,
            imagen,
            gif_url,
            instrucciones,
            maquina,
            descripcion,
            beneficios,
            rango_movimiento,
            respiracion,
            ritmo_movimiento
        })
        .select(`
            id_ejercicio,
            nombre,
            imagen,
            gif_url,
            instrucciones,
            maquina,
            descripcion,
            beneficios,
            rango_movimiento,
            respiracion,
            ritmo_movimiento
        `)
        .single();
    return { data, error };
};

// ACTUALIZAR EJERCICIO
export const actualizarEjercicio = async (id, campos) => {
    const { data, error } = await supabase
        .from("ejercicios")
        .update(campos)
        .eq("id_ejercicio", id)
        .select(`
            id_ejercicio,
            nombre,
            imagen,
            gif_url,
            instrucciones,
            maquina,
            descripcion,
            beneficios,
            rango_movimiento,
            respiracion,
            ritmo_movimiento
        `)
        .single();
    return { data, error };
};

// ELIMINAR EJERCICIO
export const eliminarEjercicio = async (id) => {
    const { data, error } = await supabase
        .from("ejercicios")
        .delete()
        .eq("id_ejercicio", id)
        .select(`
            id_ejercicio,
            nombre,
            imagen,
            gif_url,
            instrucciones,
            maquina,
            descripcion,
            beneficios,
            rango_movimiento,
            respiracion,
            ritmo_movimiento
        `)
        .single();
    return { data, error };
};

// AGREGAR CATEGORÍAS A UN EJERCICIO
export const agregarCategoriasEjercicio = async (idEjercicio, categorias) => {
    const relaciones = categorias.map((idCategoria) => ({
        id_ejercicio: idEjercicio,
        id_categoria: idCategoria
    }));
    const { data, error } = await supabase
        .from("ejercicio_categoria")
        .insert(relaciones)
        .select(`
            id_ejercicio,
            id_categoria
        `);
    return { data, error };
};

// ELIMINAR TODAS LAS CATEGORÍAS DE UN EJERCICIO
export const eliminarCategoriasEjercicio = async (idEjercicio) => {
    const { data, error } = await supabase
        .from("ejercicio_categoria")
        .delete()
        .eq("id_ejercicio", idEjercicio);
    return { data, error };
};

// ACTUALIZAR CATEGORÍAS DE UN EJERCICIO
export const actualizarCategoriasEjercicio = async (idEjercicio, categorias) => {
    // Primero eliminamos las categorías actuales
    const { error: errorEliminar } = await eliminarCategoriasEjercicio(idEjercicio);
    if (errorEliminar) {
        return {
            data: null,
            error: errorEliminar
        };
    }
    // Si no se enviaron categorías, dejamos el ejercicio sin categorías
    if (!categorias || categorias.length === 0) {
        return {
            data: [],
            error: null
        };
    }
    // Agregamos las nuevas categorías
    return await agregarCategoriasEjercicio(idEjercicio, categorias);
};