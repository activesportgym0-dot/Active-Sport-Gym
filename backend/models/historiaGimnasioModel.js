import { supabase } from "../config/supabase.js";

// Obtener todas las historias/secciones de historia
export const obtenerHistoriasBD = async () => {
  return await supabase
    .from("historia_gimnasio")
    .select("*")
    .order("id_historia", { ascending: true });
};

// Obtener una historia por ID
export const obtenerHistoriaPorIdBD = async (id) => {
  return await supabase
    .from("historia_gimnasio")
    .select("*")
    .eq("id_historia", id)
    .single();
};

// Crear un registro de historia
export const crearHistoriaBD = async ({ titulo, contenido, imagen }) => {
  return await supabase
    .from("historia_gimnasio")
    .insert([{ titulo, contenido, imagen }])
    .select()
    .single();
};

// Actualizar historia
export const actualizarHistoriaBD = async (id, campos) => {
  return await supabase
    .from("historia_gimnasio")
    .update(campos)
    .eq("id_historia", id)
    .select()
    .single();
};

// Eliminar historia
export const eliminarHistoriaBD = async (id) => {
  return await supabase
    .from("historia_gimnasio")
    .delete()
    .eq("id_historia", id);
};