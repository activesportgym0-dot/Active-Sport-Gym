import { supabase } from "../config/supabase.js";

// ==========================================
// ACCIONES DEL CLIENTE
// ==========================================

// 1. Crear el encabezado del pedido
export const crearPedidoBD = async (id_usuario, total, estado = "Pendiente") => {
  const { data, error } = await supabase
    .from("pedidos")
    .insert([{ id_usuario, total, estado }])
    .select()
    .single();

  return { data, error };
};

// 2. Insertar los ítems del detalle del pedido
export const crearDetallePedidoBD = async (detalles) => {
  const { data, error } = await supabase
    .from("detalle_pedidos")
    .insert(detalles)
    .select();

  return { data, error };
};

// 3. Consultar ÚNICAMENTE los pedidos pertenecientes al cliente
export const obtenerPedidosPorUsuarioBD = async (id_usuario) => {
  const { data, error } = await supabase
    .from("pedidos")
    .select(`
      id_pedido,
      fecha_pedido,
      total,
      estado,
      detalle_pedidos (
        id_detalle,
        id_producto,
        cantidad,
        precio_unitario,
        productos (
          nombre
        )
      )
    `)
    .eq("id_usuario", id_usuario)
    .order("id_pedido", { ascending: false });

  return { data, error };
};

// 4. Consultar un pedido específico del cliente con su detalle
export const obtenerPedidoClientePorIdBD = async (id_pedido, id_usuario) => {
  const { data, error } = await supabase
    .from("pedidos")
    .select(`
      id_pedido,
      id_usuario,
      estado,
      total,
      detalle_pedidos (
        id_producto,
        cantidad
      )
    `)
    .eq("id_pedido", id_pedido)
    .eq("id_usuario", id_usuario)
    .single();

  return { data, error };
};

// ==========================================
// ACCIONES DEL ADMINISTRADOR
// ==========================================

// 5. Consultar el historial global de TODOS los pedidos de la app
export const obtenerTodosLosPedidosBD = async () => {
  const { data, error } = await supabase
    .from("pedidos")
    .select(`
      id_pedido,
      fecha_pedido,
      total,
      estado,
      usuarios (
        id_usuario,
        nombre,
        correo
      )
    `)
    .order("id_pedido", { ascending: false });

  return { data, error };
};

// 6. Consultar cualquier pedido con sus detalles para el Admin
export const obtenerPedidoConDetallesBD = async (id_pedido) => {
  const { data, error } = await supabase
    .from("pedidos")
    .select(`
      id_pedido,
      id_usuario,
      estado,
      total,
      usuarios (
        nombre,
        correo
      ),
      detalle_pedidos (
        id_producto,
        cantidad
      )
    `)
    .eq("id_pedido", id_pedido)
    .single();

  return { data, error };
};

// 7. Actualizar el estado de un pedido (Servirá tanto para cancelación del cliente como del admin)
export const actualizarEstadoPedidoBD = async (id_pedido, nuevoEstado) => {
  const { data, error } = await supabase
    .from("pedidos")
    .update({ estado: nuevoEstado })
    .eq("id_pedido", id_pedido)
    .select(`
      id_pedido,
      total,
      estado,
      id_usuario,
      usuarios (
        nombre,
        correo
      )
    `)
    .single();

  return { data, error };
};