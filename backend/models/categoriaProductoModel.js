import { supabase } from "../config/supabase.js";

// Obtener todas las categorías
export const obtenerCategoriasBD = async () => {
    const { data, error } = await supabase
        .from("categorias_productos")
        .select("*")
        .order("nombre", { ascending: true });
    return { data, error };
};

// Crear categoría (solo Admin)
export const crearCategoriaBD = async (nombre) => {
    const { data, error } = await supabase
        .from("categorias_productos")
        .insert([{ nombre }])
        .select()
        .single();
    return { data, error };
};

// Actualizar categoría (solo Admin)
export const actualizarCategoriaBD = async (id_categoria, nombre) => {
    const { data, error } = await supabase
        .from("categorias_productos")
        .update({ nombre })
        .eq("id_categoria", id_categoria)
        .select()
        .maybeSingle();
    return { data, error };
};

// Eliminar categoría (solo Admin)
export const eliminarCategoriaBD = async (id_categoria) => {
    const { data, error } = await supabase
        .from("categorias_productos")
        .delete()
        .eq("id_categoria", id_categoria)
        .select()
        .maybeSingle();
    return { data, error };
};