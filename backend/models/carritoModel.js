import { supabase } from "../config/supabase.js";

// 1. OBTENER EL CARRITO DE UN USUARIO
export const obtenerCarritoPorUsuarioBD = async (id_usuario) => {
  const { data, error } = await supabase
    .from("carrito")
    .select(`
      id_carrito,
      cantidad,
      productos (
        id_producto,
        nombre,
        precio,
        stock
      )
    `)
    .eq("id_usuario", id_usuario);

  return { data, error };
};

// 2. BUSCAR SI UN PRODUCTO YA ESTÁ EN EL CARRITO DEL USUARIO
export const obtenerItemCarritoBD = async (id_usuario, id_producto) => {
  const { data, error } = await supabase
    .from("carrito")
    .select("*")
    .eq("id_usuario", id_usuario)
    .eq("id_producto", id_producto)
    .maybeSingle();

  return { data, error };
};

// 3. AGREGAR UN PRODUCTO AL CARRITO
export const agregarAlCarritoBD = async (id_usuario, id_producto, cantidad) => {
  const { data, error } = await supabase
    .from("carrito")
    .insert([{ id_usuario, id_producto, cantidad }])
    .select()
    .single();

  return { data, error };
};

// 4. ACTUALIZAR CANTIDAD DE UN ITEM EN EL CARRITO
export const actualizarCantidadCarritoBD = async (id_carrito, nuevaCantidad) => {
  const { data, error } = await supabase
    .from("carrito")
    .update({ cantidad: nuevaCantidad })
    .eq("id_carrito", id_carrito)
    .select()
    .single();

  return { data, error };
};

// 5. ELIMINAR UN ITEM DEL CARRITO
export const eliminarItemCarritoBD = async (id_carrito, id_usuario) => {
  const { data, error } = await supabase
    .from("carrito")
    .delete()
    .eq("id_carrito", id_carrito)
    .eq("id_usuario", id_usuario)
    .select()
    .maybeSingle();

  return { data, error };
};

// 6. VACIAR CARRITO COMPLETO DE UN USUARIO (Al finalizar compra)
export const vaciarCarritoBD = async (id_usuario) => {
  const { data, error } = await supabase
    .from("carrito")
    .delete()
    .eq("id_usuario", id_usuario);

  return { data, error };
};

// 7. OBTENER UN ITEM DEL CARRITO POR SU ID DE CARRITO
export const obtenerItemPorIdCarritoBD = async (id_carrito) => {
  const { data, error } = await supabase
    .from("carrito")
    .select("id_producto, cantidad")
    .eq("id_carrito", id_carrito)
    .maybeSingle();

  return { data, error };
};