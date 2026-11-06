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
// Obtiene las notificaciones del usuario (las personales y las globales para todos).
// En las PERSONALES, "leida" es la columna de la notificación. En las GLOBALES (id_usuario null)
// "leida" se calcula por usuario con la tabla notificaciones_leidas: así lo que lee un cliente
// no cambia lo que ven los demás.
export const obtenerNotificacionesUsuarioBD = async (id_usuario) => {
    const { data, error } = await supabase
        .from("notificaciones")
        .select(CAMPOS_ORDENADOS)
        .or(`id_usuario.eq.${id_usuario},id_usuario.is.null`)
        .order("fecha", { ascending: false });
    if (error) return { data: null, error };

    const { data: leidas, error: errorLeidas } = await supabase
        .from("notificaciones_leidas")
        .select("id_notificacion")
        .eq("id_usuario", id_usuario);
    if (errorLeidas) return { data: null, error: errorLeidas };

    const idsLeidas = new Set((leidas || []).map((l) => l.id_notificacion));
    const notificaciones = (data || []).map((n) => ({
        ...n,
        leida: n.id_usuario === null ? idsLeidas.has(n.id_notificacion) : n.leida
    }));
    return { data: notificaciones, error: null };
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
    // La notificación debe ser personal del usuario o general
    const { data: notificacion, error } = await supabase
        .from("notificaciones")
        .select(CAMPOS_ORDENADOS)
        .eq("id_notificacion", Number(id_notificacion))
        .or(`id_usuario.eq.${id_usuario},id_usuario.is.null`)
        .maybeSingle();
    if (error) return { data: null, error };
    if (!notificacion) return { data: null, error: null }; // el controller responde 404

    // GENERAL: se guarda que ESTE usuario la leyó (no se toca la notificación)
    if (notificacion.id_usuario === null) {
        const { error: errorLectura } = await supabase
            .from("notificaciones_leidas")
            .upsert(
                [{ id_notificacion: notificacion.id_notificacion, id_usuario }],
                { onConflict: "id_notificacion,id_usuario", ignoreDuplicates: true }
            );
        if (errorLectura) return { data: null, error: errorLectura };
        return { data: { ...notificacion, leida: true }, error: null };
    }

    // PERSONAL: se marca la notificación
    const { data, error: errorUpdate } = await supabase
        .from("notificaciones")
        .update({ leida: true })
        .eq("id_notificacion", notificacion.id_notificacion)
        .eq("id_usuario", id_usuario)
        .select(CAMPOS_ORDENADOS)
        .single();
    return { data, error: errorUpdate };
};
// Marca todas las notificaciones del usuario como leidas.
// Solo cambia lo del propio usuario: sus personales y las generales que él todavía no había leído.
export const marcarTodasLeidasBD = async (id_usuario) => {
    // Personales sin leer
    const { data: personales, error: errorPersonales } = await supabase
        .from("notificaciones")
        .update({ leida: true })
        .eq("id_usuario", id_usuario)
        .eq("leida", false)
        .select(CAMPOS_ORDENADOS);
    if (errorPersonales) return { data: null, error: errorPersonales };

    // Generales que este usuario todavía no ha leído
    const { data: generales, error: errorGenerales } = await supabase
        .from("notificaciones")
        .select("id_notificacion")
        .is("id_usuario", null);
    if (errorGenerales) return { data: null, error: errorGenerales };

    const { data: yaLeidas, error: errorYaLeidas } = await supabase
        .from("notificaciones_leidas")
        .select("id_notificacion")
        .eq("id_usuario", id_usuario);
    if (errorYaLeidas) return { data: null, error: errorYaLeidas };

    const idsYaLeidas = new Set((yaLeidas || []).map((l) => l.id_notificacion));
    const nuevas = (generales || [])
        .filter((g) => !idsYaLeidas.has(g.id_notificacion))
        .map((g) => ({ id_notificacion: g.id_notificacion, id_usuario }));

    if (nuevas.length > 0) {
        const { error: errorInsert } = await supabase.from("notificaciones_leidas").insert(nuevas);
        if (errorInsert) return { data: null, error: errorInsert };
    }

    return { data: [...(personales || []), ...nuevas], error: null };
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

// [ADMIN] Todas las notificaciones creadas (globales y personales), la más nueva primero.
// El nombre del destinatario se busca aparte para no depender de una llave foránea.
export const obtenerTodasNotificacionesBD = async () => {
    const { data, error } = await supabase
        .from("notificaciones")
        .select(CAMPOS_ORDENADOS)
        .order("fecha", { ascending: false });
    if (error) return { data: null, error };

    const ids = [...new Set((data || []).map((n) => n.id_usuario).filter((id) => id !== null))];
    let nombres = new Map();

    if (ids.length > 0) {
        const { data: usuarios, error: errorUsuarios } = await supabase
            .from("usuarios")
            .select("id_usuario, nombre")
            .in("id_usuario", ids);
        if (errorUsuarios) {
            console.error("No se pudieron leer los nombres de los destinatarios:", errorUsuarios.message);
        } else {
            nombres = new Map((usuarios || []).map((u) => [u.id_usuario, u.nombre]));
        }
    }

    const conDestinatario = (data || []).map((n) => ({
        ...n,
        destinatario_nombre: n.id_usuario === null ? null : (nombres.get(n.id_usuario) ?? null)
    }));
    return { data: conDestinatario, error: null };
};