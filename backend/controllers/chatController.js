import Groq from "groq-sdk";
import { obtenerTodosEjercicios } from "../models/ejercicioModel.js";
import { obtenerProductosBD } from "../models/productoModel.js";
import { supabase } from "../config/supabase.js";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const chatearConGym = async (req, res) => {
  try {
    const { mensaje, sesionId, usuarioId } = req.body;
    if (!mensaje || !mensaje.trim()) {
      return res.status(400).json({ mensaje: "Debes enviar un mensaje." });
    }
    const idSesionValido = sesionId || `gym_sesion_${Date.now()}`;
    // Obtener datos mediante las funciones obtener del modelo
    const [{ data: ejercicios }, { data: productos }] = await Promise.all([
      obtenerTodosEjercicios(),
      obtenerProductosBD({})
    ]);
    // Formatear la lista de ejercicios
    const listaEjercicios = ejercicios && ejercicios.length > 0
      ? ejercicios.map(e => `- ${e.nombre}`).join("\n")
      : "No hay ejercicios registrados.";
    // Formatear la lista de productos filtrando los que tienen stock
    const listaProductos = productos && productos.length > 0
      ? productos
          .filter(p => p.stock > 0)
          .map(p => {
            const detalles = [p.marca, p.sabor].filter(Boolean).join(" - ");
            return `- ${p.nombre}${detalles ? ` (${detalles})` : ""}: $${Number(p.precio).toLocaleString("es-CO")} COP`;
          }).join("\n")
      : "No hay productos con stock disponible.";
    // Definición de pautas para el asistente
    const systemPrompt = `
Eres el asistente virtual oficial de "Active Sport Gym". Tu objetivo es asesorar al usuario en rutinas de ejercicio, nutrición y suplementación deportiva.
EJERCICIOS REGISTRADOS:
${obtenerTodosEjercicios}
PRODUCTOS EN TIENDA:
${obtenerProductosBD}
WHATSAPP DE LA TIENDA: https://wa.me/573115313005
REGLAS DE RESPUESTA:
1. RUTINAS (Día o Semana):
   - Recomienda únicamente los ejercicios presentes en la lista anterior.
   - Incluye series y repeticiones sugeridas para el objetivo del usuario.

2. NUTRICIÓN:
   - Ofrece recomendaciones nutricionales según la meta (aumento de masa muscular, definición o resistencia).

3. VENTA Y RECOMENDACIÓN DE PRODUCTOS:
   - Recomienda exclusivamente los artículos que están en el catálogo disponible.
   - Para concretar la compra o solicitar información de pedidos, indica al usuario escribir al enlace de WhatsApp: https://wa.me/573115313005

TONO: Directo, claro y motivador.
`;

    // Consulta a la IA con Groq
    const completion = await groq.chat.completions.create({
      model: "openai/gpt-oss-20b",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: mensaje.trim() }
      ]
    });
    const respuestaTexto = completion.choices[0]?.message?.content || "";
    // Guardar la conversación en la tabla mensajes_chat
    await supabase.from("mensajes_chat").insert([
      { sesion_id: idSesionValido, usuario_id: usuarioId || null, emisor: "usuario", mensaje: mensaje.trim() },
      { sesion_id: idSesionValido, usuario_id: usuarioId || null, emisor: "asistente", mensaje: respuestaTexto }
    ]);
    return res.status(200).json({
      respuesta: respuestaTexto,
      sesionId: idSesionValido
    });
  } catch (error) {
    console.error("Error en el controlador del chat:", error);
    return res.status(500).json({
      mensaje: "Error interno del servidor",
      error: error.message
    });
  }
};