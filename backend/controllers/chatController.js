import Groq from "groq-sdk";
import crypto from "crypto";
import { obtenerTodosEjercicios } from "../models/ejercicioModel.js";
import { obtenerProductosBD } from "../models/productoModel.js";
import {
  obtenerMetricasAdmin,
  obtenerHistorialChat,
  guardarMensajesChat,
  obtenerReglasHorariosChat,
} from "../models/chatModel.js";
import { construirPromptCliente, construirPromptAdmin } from "../config/chatPrompts.js";

const MODELO_CHAT = process.env.GROQ_MODEL || "openai/gpt-oss-20b";
const MAX_CARACTERES_MENSAJE = 1000; // largo máximo de cada pregunta
const MENSAJES_DE_MEMORIA = 10; // cuántos mensajes anteriores recuerda la IA

// El cliente de Groq se crea al primer uso: si falta la clave, el servidor no se cae al iniciar
let groqClient = null;
const obtenerGroq = () => {
  if (!groqClient) groqClient = new Groq({ apiKey: process.env.GROQ_API_KEY });
  return groqClient;
};

// ───────────── Formato de los datos que se le pasan a la IA ─────────────

const formatearEjercicios = (ejercicios) => {
  const nombres = (ejercicios || []).map((e) => e?.nombre).filter(Boolean).slice(0, 200);
  return nombres.length > 0 ? nombres.map((n) => `- ${n}`).join("\n") : "No hay ejercicios registrados.";
};

// Solo productos con stock; no se envían las cantidades
const formatearProductos = (productos) => {
  const disponibles = (productos || []).filter((p) => p.stock > 0).slice(0, 100);
  if (disponibles.length === 0) return "No hay productos con stock disponible.";
  return disponibles
    .map((p) => {
      const detalles = [p.marca, p.sabor].filter(Boolean).join(" - ");
      return `- ${p.nombre}${detalles ? ` (${detalles})` : ""}: $${Number(p.precio).toLocaleString("es-CO")} COP`;
    })
    .join("\n");
};

const formatearReglasHorarios = (reglas) => {
  const lista = (reglas || []).slice(0, 40);
  if (lista.length === 0) return "No hay horarios ni reglas registrados.";
  return lista.map((r) => `- [${r.tipo}] ${r.titulo}: ${r.contenido}`).join("\n");
};

const formatearMetricas = (m) =>
  [
    `- Usuarios registrados: ${m.totalUsuarios}`,
    `- Membresías registradas: ${m.totalMembresias}`,
    `- Ejercicios: ${m.totalEjercicios} (en ${m.totalCategoriasEjercicios} categorías)`,
    `- Rutinas registradas: ${m.totalRutinas}`,
    `- Productos en tienda: ${m.totalProductos} (en ${m.totalCategoriasProductos} categorías)`,
    `- Pedidos registrados: ${m.totalPedidos}`,
    `- Reglas y horarios registrados: ${m.totalReglasHorarios}`,
  ].join("\n");

const formatearStockBajo = (productos) =>
  (productos || []).length > 0
    ? productos.map((p) => `- ${p.nombre}: ${p.stock} unidades`).join("\n")
    : "Ningún producto tiene el stock bajo.";

// ───────────── Sesión y llamada a la IA ─────────────

// El id de sesión lo crea el servidor; si el cliente manda uno, debe tener un formato seguro
const SESION_VALIDA = /^[A-Za-z0-9_-]{8,80}$/;
const resolverSesion = (sesionId, rol) =>
  typeof sesionId === "string" && SESION_VALIDA.test(sesionId)
    ? sesionId
    : `chat_${rol}_${crypto.randomUUID()}`;

const pedirRespuestaIA = async (systemPrompt, historial, mensaje) => {
  const params = {
    model: MODELO_CHAT,
    temperature: 0.5,
    max_completion_tokens: 1200,
    messages: [
      { role: "system", content: systemPrompt },
      // Memoria de la conversación: los mensajes anteriores de esta sesión
      ...historial.map((m) => ({
        role: m.emisor === "usuario" ? "user" : "assistant",
        content: m.mensaje,
      })),
      { role: "user", content: mensaje },
    ],
  };
  // Los modelos gpt-oss aceptan este ajuste: respuestas más rápidas
  if (MODELO_CHAT.includes("gpt-oss")) params.reasoning_effort = "low";

  const completion = await obtenerGroq().chat.completions.create(params);
  return completion.choices?.[0]?.message?.content?.trim() || "";
};

// Flujo común del chat de cliente y de administrador
const responderChat = async (req, res, { rol, armarPrompt }) => {
  try {
    const mensaje = typeof req.body?.mensaje === "string" ? req.body.mensaje.trim() : "";
    if (!mensaje) {
      return res.status(400).json({ error: "Debes enviar un mensaje." });
    }
    if (mensaje.length > MAX_CARACTERES_MENSAJE) {
      return res
        .status(400)
        .json({ error: `El mensaje es muy largo (máximo ${MAX_CARACTERES_MENSAJE} caracteres).` });
    }

    // El usuario sale del token, nunca del body (así nadie puede hacerse pasar por otro)
    const usuarioId = Number(req.usuario?.id_usuario);
    if (!Number.isInteger(usuarioId) || usuarioId <= 0) {
      return res.status(401).json({ error: "Usuario no autenticado." });
    }

    const sesionId = resolverSesion(req.body?.sesionId, rol);

    const [systemPrompt, historial] = await Promise.all([
      armarPrompt(),
      obtenerHistorialChat(sesionId, usuarioId, MENSAJES_DE_MEMORIA),
    ]);

    const respuesta = await pedirRespuestaIA(systemPrompt, historial, mensaje);
    if (!respuesta) {
      return res.status(502).json({ error: "El asistente no pudo generar una respuesta. Intenta de nuevo." });
    }

    await guardarMensajesChat(sesionId, usuarioId, mensaje, respuesta);

    return res.status(200).json({ respuesta, sesionId });
  } catch (error) {
    console.error(`Error en el chat (${rol}):`, error);
    // No se envía error.message al usuario: puede traer datos internos
    if (error?.status === 429) {
      return res.status(503).json({ error: "El asistente está muy ocupado. Intenta de nuevo en unos segundos." });
    }
    return res.status(500).json({ error: "El asistente no está disponible en este momento. Intenta de nuevo." });
  }
};

// ───────────── CLIENTE ─────────────
export const chatearConCliente = (req, res) =>
  responderChat(req, res, {
    rol: "cliente",
    armarPrompt: async () => {
      const [{ data: ejercicios }, { data: productos }, reglas] = await Promise.all([
        obtenerTodosEjercicios(),
        obtenerProductosBD({}),
        obtenerReglasHorariosChat(),
      ]);
      return construirPromptCliente({
        listaEjercicios: formatearEjercicios(ejercicios),
        listaProductos: formatearProductos(productos),
        listaReglasHorarios: formatearReglasHorarios(reglas),
      });
    },
  });

// ───────────── ADMINISTRADOR ─────────────
export const chatearConAdmin = (req, res) =>
  responderChat(req, res, {
    rol: "admin",
    armarPrompt: async () => {
      const [metricas, reglas] = await Promise.all([obtenerMetricasAdmin(), obtenerReglasHorariosChat()]);
      return construirPromptAdmin({
        resumenMetricas: formatearMetricas(metricas),
        listaStockBajo: formatearStockBajo(metricas.productosBajoStock),
        listaReglasHorarios: formatearReglasHorarios(reglas),
      });
    },
  });

// Compatibilidad con el nombre anterior
export const chatearConGym = chatearConCliente;
