// Importamos la conexión con Supabase
import { supabase } from "../config/supabase.js";
// OBTENER TODAS LAS CATEGORÍAS
export const obtenerTodasCategorias = async () => {
    const { data, error } = await supabase
        .from("categoria_ejercicios")
        .select(`
            id_categoria,
            nombre
        `)
        .order("id_categoria", { ascending: true });
    return { data, error };
};
// OBTENER CATEGORÍA POR ID
export const obtenerCategoriaPorId = async (id) => {
    const { data, error } = await supabase
        .from("categoria_ejercicios")
        .select(`
            id_categoria,
            nombre
        `)
        .eq("id_categoria", id)
        .single();
    return { data, error };
};
// CREAR CATEGORÍA
export const crearCategoria = async (nombre) => {
    const { data, error } = await supabase
        .from("categoria_ejercicios")
        .insert({
            nombre: nombre
        })
        .select(`
            id_categoria,
            nombre
        `)
        .single();
    return { data, error };
};
// ACTUALIZAR CATEGORÍA
export const actualizarCategoria = async (id, nombre) => {
    const { data, error } = await supabase
        .from("categoria_ejercicios")
        .update({
            nombre: nombre
        })
        .eq("id_categoria", id)
        .select(`
            id_categoria,
            nombre
        `)
        .single();
    return { data, error };
};
// VERIFICAR EJERCICIOS DE UNA CATEGORÍA
export const verificarEjerciciosCategoria = async (idCategoria) => {
    const { data, error } = await supabase
        .from("ejercicio_categoria")
        .select(`
            id_ejercicio,
            ejercicios (
                id_ejercicio,
                nombre,
                ejercicio_categoria (
                    id_categoria
                )
            )
        `)
        .eq("id_categoria", idCategoria);
    return { data, error };
};
// ELIMINAR CATEGORÍA
export const eliminarCategoria = async (id) => {
    // Primero eliminamos las relaciones de los ejercicios con esta categoría
    const {
        data: relaciones,
        error: errorRelaciones
    } = await supabase
        .from("ejercicio_categoria")
        .delete()
        .eq("id_categoria", id)
        .select(`
            id_ejercicio,
            id_categoria
        `);
    if (errorRelaciones) {
        return {
            data: null,
            error: errorRelaciones
        };
    }
    // Después eliminamos la categoría
    const {
        data,
        error
    } = await supabase
        .from("categoria_ejercicios")
        .delete()
        .eq("id_categoria", id)
        .select(`
            id_categoria,
            nombre
        `)
        .single();
    return {
        data,
        error
    };
};