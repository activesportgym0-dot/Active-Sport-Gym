import { supabase } from "../config/supabase.js";

// OBTENER TODOS LOS USUARIOS
export const obtenerTodos = async () => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("id_usuario, nombre, correo, telefono, cedula, rol, fecha_registro")
    .order("id_usuario", { ascending: true });
  return { data, error };
};

// OBTENER USUARIO POR ID
export const obtenerUsuarioPorId = async (id) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("id_usuario, nombre, apellido, correo, telefono, cedula, edad, peso, altura, rol, fecha_registro")
    .eq("id_usuario", id)
    .maybeSingle();
  return { data, error };
};

// OBTENER USUARIO POR CORREO (Para Login y validación de Registro)
export const obtenerUsuarioPorEmail = async (correo) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("*")
    .eq("correo", correo)
    .maybeSingle();
  return { data, error };
};

// CREAR USUARIO (Para el Registro con bcrypt)
export const crearUser = async (
  nombre,
  apellido,
  correo,
  telefono,
  cedula,
  edad,
  peso,
  altura,
  contraseñaHasheada,
  rol,
  codigoVerificacion,
  codigoVerificacionExpiracion
) => {
  const { data, error } = await supabase
    .from("usuarios")
    .insert([
      {
        nombre,
        apellido,
        correo,
        telefono,
        cedula,
        edad,
        peso,
        altura,
        rol,
        contraseña: contraseñaHasheada,
        isVerified: false,
        codigoVerificacion,
        codigoVerificacionExpiracion
      }
    ])
    .select("id_usuario, nombre, apellido, correo, rol, fecha_registro")
    .single(); // <--- IMPORTANTE: Devuelve un objeto directo { id_usuario, ... } en lugar de un array [{...}]

  return { data, error };
};

// ACTUALIZAR USUARIO
export const actualizarUsuario = async (id, campos) => {
  const { data, error } = await supabase
    .from("usuarios")
    .update(campos)
    .eq("id_usuario", id)
    .select("id_usuario, nombre, apellido, correo, telefono, cedula, edad, peso, altura, rol")
    .maybeSingle();
  return { data, error };
};

// ELIMINAR USUARIO
export const eliminarUsuario = async (id) => {
  const { data, error } = await supabase
    .from("usuarios")
    .delete()
    .eq("id_usuario", id)
    .select("id_usuario, nombre, apellido, correo, telefono, cedula, edad, peso, altura, rol, fecha_registro")
    .maybeSingle();
  return { data, error };
};