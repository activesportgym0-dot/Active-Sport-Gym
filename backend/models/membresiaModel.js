import { supabase } from "../config/supabase.js";

// Obtener únicamente la membresía MÁS RECIENTE del usuario (Estado Actual)
export const obtenerMembresiaActualBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("membresias")
        .select("*")
        .eq("id_usuario", id_usuario)
        .order("fecha_fin", { ascending: false })
        .limit(1)
        .maybeSingle();

    return { data, error };
};

// Obtener TODO el historial de membresías de un usuario
export const obtenerHistorialMembresiasBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("membresias")
        .select("*")
        .eq("id_usuario", id_usuario)
        .order("fecha_inicio", { ascending: false });

    return { data, error };
};

// Crear un nuevo registro de membresía (Pago/Renovación)
export const registrarMembresiaBD = async (datosMembresia) => {
    const { data, error } = await supabase
        .from("membresias")
        .insert([datosMembresia])
        .select()
        .single();

    return { data, error };
};

// Actualizar el estado de una membresía específica por su id_membresia
export const cambiarEstadoMembresiaBD = async (id_membresia, estado) => {
    const { data, error } = await supabase
        .from("membresias")
        .update({ estado })
        .eq("id_membresia", id_membresia)
        .select()
        .maybeSingle();

    return { data, error };
};