import { supabase } from "../config/supabase.js";

// Obtener todos los registros de reglas y horarios
export const obtenerReglasHorariosBD = async () => {
  return await supabase
    .from("reglas_horarios")
    .select("*")
    .order("id_regla_horario", { ascending: true });
};

// Obtener un registro por su ID
export const obtenerReglaHorarioPorIdBD = async (id) => {
  return await supabase
    .from("reglas_horarios")
    .select("*")
    .eq("id_regla_horario", id)
    .single();
};

// Crear una nueva regla u horario
export const crearReglaHorarioBD = async ({ tipo, titulo, contenido }) => {
  return await supabase
    .from("reglas_horarios")
    .insert([{ tipo, titulo, contenido }])
    .select()
    .single();
};

// Actualizar un registro existente
export const actualizarReglaHorarioBD = async (id, campos) => {
  return await supabase
    .from("reglas_horarios")
    .update(campos)
    .eq("id_regla_horario", id)
    .select()
    .single();
};

// Eliminar un registro
export const eliminarReglaHorarioBD = async (id) => {
  return await supabase
    .from("reglas_horarios")
    .delete()
    .eq("id_regla_horario", id);
};