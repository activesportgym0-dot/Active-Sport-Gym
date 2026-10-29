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

// [ADMIN] Todos los clientes con su membresía MÁS RECIENTE (o null si nunca tuvieron).
// No usa un join de Supabase para no depender de una llave foránea: se hacen
// dos consultas y se cruzan en memoria.
export const obtenerClientesConMembresiaBD = async () => {
    // 1. Solo los usuarios con rol "cliente" (los admin y meseros no tienen plan)
    const { data: usuarios, error: errorUsuarios } = await supabase
        .from("usuarios")
        .select("id_usuario, nombre, correo")
        .eq("rol", "cliente")
        .order("nombre", { ascending: true });
    if (errorUsuarios) return { data: null, error: errorUsuarios };

    // 2. Membresías, la que vence más tarde primero
    const { data: membresias, error: errorMembresias } = await supabase
        .from("membresias")
        .select("id_membresia, id_usuario, estado, fecha_inicio, fecha_fin")
        .order("fecha_fin", { ascending: false });
    if (errorMembresias) return { data: null, error: errorMembresias };

    // 3. Me quedo con la primera (la más reciente) de cada usuario
    const ultimaPorUsuario = new Map();
    for (const membresia of membresias || []) {
        if (!ultimaPorUsuario.has(membresia.id_usuario)) {
            ultimaPorUsuario.set(membresia.id_usuario, membresia);
        }
    }

    const data = (usuarios || []).map((u) => ({
        id_usuario: u.id_usuario,
        nombre: u.nombre,
        correo: u.correo,
        membresia: ultimaPorUsuario.get(u.id_usuario) ?? null
    }));

    return { data, error: null };
};
