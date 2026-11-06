import { supabase } from "../config/supabase.js";

// MODELO PARA EL ADMINISTRADOR
// Obtiene el resumen general de métricas del gimnasio y contadores de tablas
export const obtenerMetricasAdmin = async () => {
  try {
    const [
      { count: totalUsuarios },
      { count: totalEjercicios },
      { count: totalProductos },
      { count: totalMembresias },
      { count: totalPedidos },
      { count: totalCategoriasEjercicios },
      { count: totalCategoriasProductos },
      { count: totalReglasHorarios },
      { count: totalRutinas }, // 👈 Nueva métrica agregada de la tabla 'rutinas'
      { data: productosBajoStock }
    ] = await Promise.all([
      supabase.from("usuarios").select("*", { count: 'exact', head: true }),
      supabase.from("ejercicios").select("*", { count: 'exact', head: true }),
      supabase.from("productos").select("*", { count: 'exact', head: true }),
      supabase.from("membresias").select("*", { count: 'exact', head: true }),
      supabase.from("pedidos").select("*", { count: 'exact', head: true }),
      supabase.from("categoria_ejercicios").select("*", { count: 'exact', head: true }),
      supabase.from("categorias_productos").select("*", { count: 'exact', head: true }),
      supabase.from("reglas_horarios").select("*", { count: 'exact', head: true }),
      supabase.from("rutinas").select("*", { count: 'exact', head: true }), // Conteo de rutinas registradas
      // Alerta de productos con stock bajo (5 o menos unidades)
      supabase.from("productos").select("nombre, stock, precio").lte("stock", 5)
    ]);

    return {
      totalUsuarios: totalUsuarios || 0,
      totalEjercicios: totalEjercicios || 0,
      totalProductos: totalProductos || 0,
      totalMembresias: totalMembresias || 0,
      totalPedidos: totalPedidos || 0,
      totalCategoriasEjercicios: totalCategoriasEjercicios || 0,
      totalCategoriasProductos: totalCategoriasProductos || 0,
      totalReglasHorarios: totalReglasHorarios || 0,
      totalRutinas: totalRutinas || 0,
      productosBajoStock: productosBajoStock || []
    };
  } catch (error) {
    console.error("Error al obtener métricas del administrador:", error);
    return {
      totalUsuarios: 0,
      totalEjercicios: 0,
      totalProductos: 0,
      totalMembresias: 0,
      totalPedidos: 0,
      totalCategoriasEjercicios: 0,
      totalCategoriasProductos: 0,
      totalReglasHorarios: 0,
      totalRutinas: 0,
      productosBajoStock: []
    };
  }
};

// FUNCIONES COMPARTIDAS DE MEMORIA Y ALMACENAMIENTO DE CHAT
// Funciona tanto para consultas de Cliente como de Administrador

// Recupera los últimos mensajes de una sesión para dar memoria conversacional a la IA.
// Solo trae los mensajes del propio usuario (nadie puede leer la sesión de otro) y
// devuelve los ÚLTIMOS "limite" mensajes en orden cronológico.
export const obtenerHistorialChat = async (sesionId, usuarioId, limite = 10) => {
  try {
    let consulta = supabase
      .from("mensajes_chat")
      .select("emisor, mensaje")
      .eq("sesion_id", sesionId);

    if (usuarioId) consulta = consulta.eq("usuario_id", usuarioId);

    const { data, error } = await consulta
      .order("id_mensaje", { ascending: false })
      .limit(limite);

    if (error) {
      console.error("Error al leer el historial del chat:", error);
      return [];
    }
    return (data || []).reverse();
  } catch (error) {
    console.error("Error al leer el historial del chat:", error);
    return [];
  }
};

// Guarda la pregunta del usuario y la respuesta generada por la IA en Supabase
export const guardarMensajesChat = async (sesionId, usuarioId, mensajeUsuario, respuestaAsistente) => {
  try {
    const { error } = await supabase.from("mensajes_chat").insert([
      { sesion_id: sesionId, usuario_id: usuarioId || null, emisor: "usuario", mensaje: mensajeUsuario.trim() },
      { sesion_id: sesionId, usuario_id: usuarioId || null, emisor: "asistente", mensaje: respuestaAsistente }
    ]);
    if (error) console.error("Error al guardar mensajes en la tabla mensajes_chat:", error);
  } catch (error) {
    console.error("Error al guardar mensajes en la tabla mensajes_chat:", error);
  }
};

// Horarios y reglas del gimnasio, para que la IA responda con datos reales
export const obtenerReglasHorariosChat = async () => {
  try {
    const { data, error } = await supabase
      .from("reglas_horarios")
      .select("tipo, titulo, contenido")
      .order("id_regla_horario", { ascending: true });
    if (error) {
      console.error("Error al leer reglas y horarios para el chat:", error);
      return [];
    }
    return data || [];
  } catch (error) {
    console.error("Error al leer reglas y horarios para el chat:", error);
    return [];
  }
};
