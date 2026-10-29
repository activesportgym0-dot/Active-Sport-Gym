import { supabase } from "../config/supabase.js";

// Cuenta filas sin descargarlas. Si una tabla falla, devuelve 0 y deja el
// error en consola para que el resto del resumen del home siga funcionando.
const contar = async (consulta, nombre) => {
  const { count, error } = await consulta;
  if (error) {
    console.error(`Error al contar ${nombre}:`, error.message);
    return 0;
  }
  return count ?? 0;
};

// Totales que se muestran en las tarjetas del home del administrador
export const obtenerTotalesBD = async () => {
  const conteo = { count: "exact", head: true };

  const [
    ejercicios,
    productos,
    productosConStock,
    membresias,
    membresiasActivas,
    usuarios
  ] = await Promise.all([
    contar(supabase.from("ejercicios").select("*", conteo), "ejercicios"),
    contar(supabase.from("productos").select("*", conteo), "productos"),
    contar(supabase.from("productos").select("*", conteo).gt("stock", 0), "productos con stock"),
    contar(supabase.from("membresias").select("*", conteo), "membresías"),
    contar(supabase.from("membresias").select("*", conteo).eq("estado", "activa"), "membresías activas"),
    contar(supabase.from("usuarios").select("*", conteo), "usuarios")
  ]);

  return { ejercicios, productos, productosConStock, membresias, membresiasActivas, usuarios };
};

// Últimos ejercicios registrados. Los ejercicios viejos no tienen created_at
// (la columna se agregó después), por eso se excluyen los que vienen en null.
export const obtenerUltimosEjerciciosBD = async (limite = 5) => {
  const { data, error } = await supabase
    .from("ejercicios")
    .select("id_ejercicio, nombre, maquina, created_at")
    .not("created_at", "is", null)
    .order("created_at", { ascending: false })
    .limit(limite);
  return { data, error };
};

// Últimos productos registrados (la columna de fecha de productos es creado_en)
export const obtenerUltimosProductosBD = async (limite = 5) => {
  const { data, error } = await supabase
    .from("productos")
    .select("id_producto, nombre, marca, stock, creado_en")
    .not("creado_en", "is", null)
    .order("creado_en", { ascending: false })
    .limit(limite);
  return { data, error };
};
