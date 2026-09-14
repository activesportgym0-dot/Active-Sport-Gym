import { supabase } from "../config/supabase.js";

// 1. OBTENER PRODUCTOS CON FILTROS (Sin relaciones complejas)
export const obtenerProductosBD = async ({ id_categoria, busqueda }) => {
  let query = supabase
    .from("productos")
    .select("*")
    .order("id_producto", { ascending: true });

  if (id_categoria) {
    query = query.eq("id_categoria", Number(id_categoria));
  }

  if (busqueda && busqueda.trim() !== "") {
    query = query.ilike("nombre", `%${busqueda.trim()}%`);
  }

  const { data, error } = await query;
  return { data, error };
};

// 2. OBTENER PRODUCTO POR ID
export const obtenerProductoPorIdBD = async (id_producto) => {
  const { data, error } = await supabase
    .from("productos")
    .select("*")
    .eq("id_producto", id_producto)
    .maybeSingle();

  return { data, error };
};

// 3. CREAR PRODUCTO
export const crearProductoBD = async (nuevoProducto) => {
  const { data, error } = await supabase
    .from("productos")
    .insert([nuevoProducto])
    .select()
    .single();

  return { data, error };
};

// 4. ACTUALIZAR PRODUCTO
export const actualizarProductoBD = async (id_producto, datosActualizados) => {
  const { data, error } = await supabase
    .from("productos")
    .update(datosActualizados)
    .eq("id_producto", id_producto)
    .select()
    .single();

  return { data, error };
};

// 5. ELIMINAR PRODUCTO
export const eliminarProductoBD = async (id_producto) => {
  const { data, error } = await supabase
    .from("productos")
    .delete()
    .eq("id_producto", id_producto)
    .select()
    .maybeSingle();

  return { data, error };
};

// 6. REGISTRAR ALERTA DE STOCK EN 'alertas_stock'
export const registrarAlertaStockBD = async (id_usuario, id_producto) => {
  const { data, error } = await supabase
    .from("alertas_stock")
    .insert([{ id_usuario, id_producto }])
    .select()
    .single();

  return { data, error };
};

// 7. OBTENER USUARIOS A NOTIFICAR CUANDO VUELVA EL STOCK
export const obtenerUsuariosParaAvisoStockBD = async (id_producto) => {
  const { data, error } = await supabase
    .from("alertas_stock")
    .select(`
      id_alerta,
      id_usuario,
      usuarios (
        id_usuario,
        nombre,
        correo
      )
    `)
    .eq("id_producto", id_producto);

  return { data, error };
};

// 8. ELIMINAR ALERTAS DE STOCK TRAS REABASTECER
export const eliminarAlertasStockBD = async (id_producto) => {
  const { data, error } = await supabase
    .from("alertas_stock")
    .delete()
    .eq("id_producto", id_producto);

  return { data, error };
};