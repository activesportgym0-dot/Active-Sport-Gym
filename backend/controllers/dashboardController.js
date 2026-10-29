import {
  obtenerTotalesBD,
  obtenerUltimosEjerciciosBD,
  obtenerUltimosProductosBD
} from "../models/dashboardModel.js";

const MAX_ACTIVIDAD = 5;

// [ADMIN] Resumen del home: totales de las tarjetas + últimas acciones registradas
export const obtenerResumenAdmin = async (req, res) => {
  try {
    const [totales, ejerciciosRes, productosRes] = await Promise.all([
      obtenerTotalesBD(),
      obtenerUltimosEjerciciosBD(MAX_ACTIVIDAD),
      obtenerUltimosProductosBD(MAX_ACTIVIDAD)
    ]);

    const actividad = [];

    // Si una de las dos consultas falla, igual se devuelve lo que sí se pudo leer
    if (ejerciciosRes.error) {
      console.error("Error al leer últimos ejercicios:", ejerciciosRes.error.message);
    } else {
      for (const e of ejerciciosRes.data || []) {
        actividad.push({
          tipo: "ejercicio",
          titulo: "Ejercicio añadido al catálogo",
          detalle: `Se añadió "${e.nombre}"${e.maquina ? ` - ${e.maquina}` : ""}`,
          fecha: e.created_at
        });
      }
    }

    if (productosRes.error) {
      console.error("Error al leer últimos productos:", productosRes.error.message);
    } else {
      for (const p of productosRes.data || []) {
        actividad.push({
          tipo: "producto",
          titulo: "Nuevo producto agregado",
          detalle: `${p.nombre}${p.marca ? ` (${p.marca})` : ""} - Stock: ${p.stock ?? 0} unidades`,
          fecha: p.creado_en
        });
      }
    }

    // Mezclo ejercicios y productos, dejo los más recientes primero y me quedo con 5
    actividad.sort((a, b) => new Date(b.fecha) - new Date(a.fecha));

    return res.status(200).json({
      totales,
      actividad: actividad.slice(0, MAX_ACTIVIDAD)
    });
  } catch (error) {
    console.error("Error en obtenerResumenAdmin:", error);
    return res.status(500).json({ error: "Error interno al generar el resumen." });
  }
};
