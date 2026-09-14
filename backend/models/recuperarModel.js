import { supabase } from "../config/supabase.js";

// OBTENER USUARIO POR CORREO
export const obtenerUsuarioPorCorreo = async (correo) => {
  const { data, error } = await supabase
    .from("usuarios")
    .select("id_usuario, nombre, apellido, correo")
    .eq("correo", correo)
    .single();

  return { data, error };
};

// CREAR CÓDIGO DE RECUPERACIÓN
export const crearCodigoRecuperacion = async (id_usuario, codigo) => {
  const fechaExpira = new Date(Date.now() + 15 * 60 * 1000).toISOString();

  const { data, error } = await supabase
    .from("recovery_codes")
    .insert({
      usuario_id: id_usuario, // Nombre exacto de la columna en BD
      codigo: codigo,
      expires_at: fechaExpira, // Nombre exacto de la columna en BD
      usado: false
    });

  return { data, error };
};

// OBTENER CÓDIGO VÁLIDO
export const obtenerCodigoValido = async (id_usuario, codigo) => {
  const { data, error } = await supabase
    .from("recovery_codes")
    .select("*")
    .eq("usuario_id", id_usuario)
    .eq("codigo", codigo)
    .eq("usado", false)
    .gte("expires_at", new Date().toISOString())
    .maybeSingle();

  return { data, error };
};

// MARCAR CÓDIGO COMO USADO
export const marcarCodigoComoUsado = async (id) => {
  const { data, error } = await supabase
    .from("recovery_codes")
    .update({ usado: true })
    .eq("id", id);

  return { data, error };
};

// ACTUALIZAR CONTRASEÑA
export const actualizarPasswordUsuario = async (id_usuario, hashedPassword) => {
  const { data, error } = await supabase
    .from("usuarios")
    .update({ contraseña: hashedPassword })
    .eq("id_usuario", id_usuario);

  return { data, error };
};