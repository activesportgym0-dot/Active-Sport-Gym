// Importamos la conexión con Supabase
import { supabase } from "../config/supabase.js";

// OBTENER PERFIL COMPLETO
export const obtenerPerfilPorUsuario = async (id_usuario) => {
    const { data, error } = await supabase
        .from("usuarios")
        .select(`
            id_usuario,
            nombre,
            apellido,
            correo,
            telefono,
            cedula,
            edad,
            peso,
            altura,
            rol,
            fecha_registro,
            perfil (
                id_perfil,
                foto_perfil,
                fecha_creacion,
                fecha_actualizacion
            )
        `)
        .eq("id_usuario", id_usuario)
        .single();
    return { data, error };
};

// CREAR PERFIL AUTOMÁTICAMENTE
export const crearPerfilAutomatico = async (id_usuario) => {
    const { data, error } = await supabase
        .from("perfil")
        .insert({
            id_usuario: id_usuario,
            foto_perfil: null
        })
        .select(`
            id_perfil,
            id_usuario,
            foto_perfil,
            fecha_creacion,
            fecha_actualizacion
        `)
        .single();
    return { data, error };
};

// ACTUALIZAR USUARIO DESDE PERFIL
export const actualizarDatosUsuario = async (id_usuario,campos) => {
    const { data, error } = await supabase
        .from("usuarios")
        .update(campos)
        .eq("id_usuario", id_usuario)
        .select(`
            id_usuario,
            nombre,
            apellido,
            correo,
            telefono,
            cedula,
            edad,
            peso,
            altura,
            rol,
            fecha_registro
        `)
        .single();
    return { data, error };
};
// ACTUALIZAR FOTO DEL PERFIL
export const actualizarFotoPerfil = async (id_usuario,foto_perfil) => {
    const { data, error } = await supabase
        .from("perfil")
        .update({
            foto_perfil: foto_perfil,
            fecha_actualizacion: new Date().toISOString()
        })
        .eq("id_usuario", id_usuario)
        .select(`
            id_perfil,
            id_usuario,
            foto_perfil,
            fecha_creacion,
            fecha_actualizacion
        `)
        .single();
    return { data, error };
};