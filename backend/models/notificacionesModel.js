import { supabase } from "../config/supabase.js";

// Proyeccion de campos en orden organizado
const CAMPOS_ORDENADOS = `
    id_notificacion,
    id_usuario,
    titulo,
    mensaje,
    tipo,
    imagen_url,
    leida,
    fecha
`;

// Obtiene las notificaciones del usuario (las personales y las globales para todos)
export const obtenerNotificacionesUsuarioBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("notificaciones")
        .select(CAMPOS_ORDENADOS)
        .or(`id_usuario.eq.${id_usuario},id_usuario.is.null`)
        .order("fecha", { ascending: false });

    return { data, error };
};

// Crea una notificacion (puede ser para un usuario especifico o global si id_usuario es null)
export const crearNotificacionBD = async (datosNotificacion) => {
    const payload = {
        ...datosNotificacion,
        leida: false,
        fecha: new Date().toISOString()
    };

    const { data, error } = await supabase
        .from("notificaciones")
        .insert([payload])
        .select(CAMPOS_ORDENADOS)
        .single();

    return { data, error };
};

// Marca una notificacion especifica como leida
export const marcarNotificacionLeidaBD = async (id_notificacion, id_usuario) => {
    const { data, error } = await supabase
        .from("notificaciones")
        .update({ leida: true })
        .eq("id_notificacion", Number(id_notificacion))
        .or(`id_usuario.eq.${id_usuario},id_usuario.is.null`)
        .select(CAMPOS_ORDENADOS)
        .single();

    return { data, error };
};

// Marca todas las notificaciones del usuario como leidas
export const marcarTodasLeidasBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("notificaciones")
        .update({ leida: true })
        .or(`id_usuario.eq.${id_usuario},id_usuario.is.null`)
        .select(CAMPOS_ORDENADOS);

    return { data, error };
};

// Elimina una notificacion por parte del usuario o administrador
export const eliminarNotificacionBD = async (id_notificacion) => {
    const { data, error } = await supabase
        .from("notificaciones")
        .delete()
        .eq("id_notificacion", Number(id_notificacion))
        .select(CAMPOS_ORDENADOS)
        .single();

    return { data, error };
};