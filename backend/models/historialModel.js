import { supabase } from "../config/supabase.js";

// 1. Guardar la sesión general de la rutina
export const crearHistorialRutina = async (id_rutina, id_usuario, tiempo_total) => {
    const { data, error } = await supabase
        .from("historial_rutinas")
        .insert([
            {
                id_rutina: Number(id_rutina),
                id_usuario: Number(id_usuario),
                tiempo_total: Number(tiempo_total) || 0,
                fecha_realizacion: new Date().toISOString()
            }
        ])
        .select()
        .single();

    return { data, error };
};

// 2. Guardar el tiempo consumido en un ejercicio completo
export const registrarTiempoEjercicio = async (id_historial, id_ejercicio, tiempo_ejercicio) => {
    const { data, error } = await supabase
        .from("historial_ejercicios")
        .insert([
            {
                id_historial: Number(id_historial),
                id_ejercicio: Number(id_ejercicio),
                tiempo_ejercicio: Number(tiempo_ejercicio) || 0
            }
        ])
        .select()
        .single();

    return { data, error };
};

// 3. Consultar todo el historial del usuario para organizar vistas diarias/semanales en Flutter
export const obtenerHistorialesPorUsuario = async (id_usuario) => {
    const { data, error } = await supabase
        .from("historial_rutinas")
        .select(`
            id_historial,
            fecha_realizacion,
            tiempo_total,
            rutinas (
                id_rutina,
                nombre,
                tipo
            ),
            historial_ejercicios (
                id_ejercicio,
                tiempo_ejercicio,
                ejercicios (
                    nombre,
                    imagen_url
                )
            )
        `)
        .eq("id_usuario", Number(id_usuario))
        .order("fecha_realizacion", { ascending: false });

    return { data, error };
};

    // 4. Eliminar un registro específico del historial por su ID
export const eliminarHistorialPorId = async (id_historial, id_usuario) => {
    const { data, error } = await supabase
        .from("historial_rutinas")
        .delete()
        .eq("id_historial", Number(id_historial))
        .eq("id_usuario", Number(id_usuario))
        .select()
        .single();

    return { data, error };
};

// 5. Vaciar todo el historial del usuario
export const vaciarHistorialUsuario = async (id_usuario) => {
    const { data, error } = await supabase
        .from("historial_rutinas")
        .delete()
        .eq("id_usuario", Number(id_usuario))
        .select();

    return { data, error };
};
