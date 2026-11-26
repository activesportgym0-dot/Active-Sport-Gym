
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

import {
  construirPromptCliente,
  construirPromptAdmin,
  construirPromptFiltro,
  MENSAJES_FUERA_DE_TEMA,
  MENSAJES_MATEMATICA_SUELTA,
  MARCADOR_FUERA_DE_ALCANCE,
} from "../config/chatPrompts.js";

import { esMatematicaSuelta } from "../config/filtroTemas.js";

console.log("[chat] Controlador con filtro de temas cargado");

// ───────────── CONFIGURACIÓN ─────────────

const MODELO_CHAT =
  process.env.GROQ_MODEL || "openai/gpt-oss-20b";

// Si no configuras otro modelo para el filtro, utiliza el principal.
const MODELO_FILTRO =
  process.env.GROQ_MODEL_FILTRO || MODELO_CHAT;

const MAX_CARACTERES_MENSAJE = 1000;
const MENSAJES_DE_MEMORIA = 10;

// ───────────── CLIENTE GROQ ─────────────

let groqClient = null;

const obtenerGroq = () => {
  if (!process.env.GROQ_API_KEY) {
    const error = new Error("Falta configurar GROQ_API_KEY.");
    error.status = 503;
    throw error;
  }

  if (!groqClient) {
    groqClient = new Groq({
      apiKey: process.env.GROQ_API_KEY,
    });
  }

  return groqClient;
};

// ───────────── FORMATO DE DATOS ─────────────

const formatearEjercicios = (ejercicios) => {
  const nombres = (ejercicios || [])
    .map((e) => e?.nombre)
    .filter(Boolean)
    .slice(0, 200);

  return nombres.length
    ? nombres.map((nombre) => `- ${nombre}`).join("\n")
    : "No hay ejercicios registrados.";
};

const formatearProductos = (productos) => {
  const disponibles = (productos || [])
    .filter((p) => Number(p?.stock) > 0)
    .slice(0, 100);

  if (!disponibles.length) {
    return "No hay productos con stock disponible.";
  }

  return disponibles
    .map((p) => {
      const detalles = [p.marca, p.sabor]
        .filter(Boolean)
        .join(" - ");

      const precio = Number(p.precio);

      const precioFormateado = Number.isFinite(precio)
        ? precio.toLocaleString("es-CO")
        : "Precio no disponible";

      return `- ${p.nombre}${detalles ? ` (${detalles})` : ""}: $${precioFormateado} COP`;
    })
    .join("\n");
};

const formatearReglasHorarios = (reglas) => {
  const lista = (reglas || []).slice(0, 40);

  if (!lista.length) {
    return "No hay horarios ni reglas registrados.";
  }

  return lista
    .map((r) => `- [${r.tipo}] ${r.titulo}: ${r.contenido}`)
    .join("\n");
};

const formatearMetricas = (m = {}) => {
  return [
    `- Usuarios registrados: ${m.totalUsuarios ?? 0}`,
    `- Membresías registradas: ${m.totalMembresias ?? 0}`,
    `- Ejercicios: ${m.totalEjercicios ?? 0} (en ${m.totalCategoriasEjercicios ?? 0} categorías)`,
    `- Rutinas registradas: ${m.totalRutinas ?? 0}`,
    `- Productos en tienda: ${m.totalProductos ?? 0} (en ${m.totalCategoriasProductos ?? 0} categorías)`,
    `- Pedidos registrados: ${m.totalPedidos ?? 0}`,
    `- Reglas y horarios registrados: ${m.totalReglasHorarios ?? 0}`,
  ].join("\n");
};

const formatearStockBajo = (productos) => {
  return (productos || []).length
    ? productos
        .map((p) => `- ${p.nombre}: ${p.stock} unidades`)
        .join("\n")
    : "Ningún producto tiene el stock bajo.";
};

// ───────────── SESIÓN ─────────────

const SESION_VALIDA = /^[A-Za-z0-9_-]{8,80}$/;

const resolverSesion = (sesionId, rol) => {
  if (
    typeof sesionId === "string" &&
    SESION_VALIDA.test(sesionId)
  ) {
    return sesionId;
  }

  return `chat_${rol}_${crypto.randomUUID()}`;
};

// ───────────── LLAMADA AL MODELO PRINCIPAL ─────────────

const pedirRespuestaIA = async (systemPrompt, historial, mensaje) => {
  const params = {
    model: MODELO_CHAT,
    temperature: 0.5,
    max_completion_tokens: 1200,
    messages: [
      {
        role: "system",
        content: systemPrompt,
      },
      ...historial.map((m) => ({
        role: m.emisor === "usuario" ? "user" : "assistant",
        content: m.mensaje,
      })),
      {
        role: "user",
        content: mensaje,
      },
    ],
  };

  if (MODELO_CHAT.includes("gpt-oss")) {
    params.reasoning_effort = "low";
  }

  const completion = await obtenerGroq()
    .chat.completions.create(params);

  return (
    completion.choices?.[0]?.message?.content?.trim() || ""
  );
};

// ───────────── FILTRO DE TEMAS ─────────────

const pedirVeredicto = async (
  modelo,
  rol,
  historial,
  mensaje
) => {
  const contexto = historial
    .slice(-4)
    .map((m) => {
      const emisor =
        m.emisor === "usuario" ? "Usuario" : "Asistente";

      return `${emisor}: ${m.mensaje}`;
    })
    .join("\n");

  const params = {
    model: modelo,
    temperature: 0,
    max_completion_tokens: modelo.includes("gpt-oss") ? 600 : 30,
    messages: [
      {
        role: "system",
        content: construirPromptFiltro(rol),
      },
      {
        role: "user",
        content:
          `Conversación reciente:\n${contexto || "(ninguna)"}\n\n` +
          `ÚLTIMO mensaje del usuario:\n"""${mensaje}"""\n\n` +
          "Responde únicamente DENTRO o FUERA.",
      },
    ],
  };

  if (modelo.includes("gpt-oss")) {
    params.reasoning_effort = "low";
  }

  const completion = await obtenerGroq()
    .chat.completions.create(params);

  const veredicto = (
    completion.choices?.[0]?.message?.content || ""
  )
    .trim()
    .toUpperCase();

  console.log(
    `[chat] Filtro ${modelo} (${rol}): ${veredicto || "(vacío)"}`
  );

  if (veredicto.startsWith("DENTRO")) {
    return true;
  }

  if (veredicto.startsWith("FUERA")) {
    return false;
  }

  return null;
};

// Si hay dos modelos distintos, el segundo sirve como respaldo.
// Si ambos fallan o responden algo inválido, no se permite continuar
// sin verificar el tema.
const estaDentroDelTema = async (rol, historial, mensaje) => {
  const modelos = [...new Set([MODELO_FILTRO, MODELO_CHAT])];

  for (const modelo of modelos) {
    try {
      const resultado = await pedirVeredicto(
        modelo,
        rol,
        historial,
        mensaje
      );

      if (resultado !== null) {
        return resultado;
      }

      console.warn(
        `[chat] El filtro ${modelo} devolvió un resultado inválido.`
      );
    } catch (error) {
      console.error(
        `[chat] Falló el filtro ${modelo}:`,
        error?.message || error
      );
    }
  }

  const error = new Error(
    "No fue posible verificar si el mensaje pertenece al gimnasio."
  );

  error.status = 503;
  throw error;
};

// ───────────── RESPUESTA FUERA DE TEMA ─────────────

const responderFueraDeTema = async (
  res,
  rol,
  sesionId,
  usuarioId,
  mensaje,
  respuestaFija = MENSAJES_FUERA_DE_TEMA[rol]
) => {
  await guardarMensajesChat(
    sesionId,
    usuarioId,
    mensaje,
    respuestaFija
  );

  return res.status(200).json({
    respuesta: respuestaFija,
    sesionId,
  });
};

// ───────────── FLUJO PRINCIPAL DEL CHAT ─────────────

const responderChat = async (req, res, { rol, armarPrompt }) => {
  try {
    const mensaje =
      typeof req.body?.mensaje === "string"
        ? req.body.mensaje.trim()
        : "";

    if (!mensaje) {
      return res.status(400).json({
        error: "Debes enviar un mensaje.",
      });
    }

    if (mensaje.length > MAX_CARACTERES_MENSAJE) {
      return res.status(400).json({
        error: `El mensaje es muy largo (máximo ${MAX_CARACTERES_MENSAJE} caracteres).`,
      });
    }

    // El ID se obtiene del token de autenticación.
    const usuarioId = Number(req.usuario?.id_usuario);

    if (!Number.isInteger(usuarioId) || usuarioId <= 0) {
      return res.status(401).json({
        error: "Usuario no autenticado.",
      });
    }

    const sesionId = resolverSesion(
      req.body?.sesionId,
      rol
    );

    // BARRERA 1: matemáticas sueltas sin relación con el gimnasio.
    if (esMatematicaSuelta(mensaje)) {
      return responderFueraDeTema(
        res,
        rol,
        sesionId,
        usuarioId,
        mensaje,
        MENSAJES_MATEMATICA_SUELTA[rol]
      );
    }

    // Recuperar conversación anterior.
    const historial = await obtenerHistorialChat(
      sesionId,
      usuarioId,
      MENSAJES_DE_MEMORIA
    );

    // BARRERA 2: verificar si el mensaje corresponde al gimnasio.
    const dentroDelTema = await estaDentroDelTema(
      rol,
      historial,
      mensaje
    );

    if (!dentroDelTema) {
      return responderFueraDeTema(
        res,
        rol,
        sesionId,
        usuarioId,
        mensaje
      );
    }

    // Construir prompt con información real de la base de datos.
    const systemPrompt = await armarPrompt();

    // Generar respuesta.
    const respuesta = await pedirRespuestaIA(
      systemPrompt,
      historial,
      mensaje
    );

    if (!respuesta) {
      return res.status(502).json({
        error: "El asistente no pudo generar una respuesta. Intenta de nuevo.",
      });
    }

    // BARRERA 3: revisar si el modelo principal marcó el mensaje
    // como algo que está fuera del alcance del gimnasio.
    if (respuesta.includes(MARCADOR_FUERA_DE_ALCANCE)) {
      return responderFueraDeTema(
        res,
        rol,
        sesionId,
        usuarioId,
        mensaje
      );
    }

    // Guardar conversación.
    await guardarMensajesChat(
      sesionId,
      usuarioId,
      mensaje,
      respuesta
    );

    return res.status(200).json({
      respuesta,
      sesionId,
    });
  } catch (error) {
    console.error(
      `[chat] Error en el chat (${rol}):`,
      error?.message || error
    );

    if (error?.status === 429) {
      return res.status(503).json({
        error: "El asistente está muy ocupado. Intenta de nuevo en unos segundos.",
      });
    }

    if (error?.status === 401 || error?.status === 403) {
      return res.status(503).json({
        error: "Hay un problema con la configuración del servicio de IA.",
      });
    }

    if (error?.status === 404) {
      return res.status(503).json({
        error: "El modelo de IA configurado no está disponible. Revisa la configuración.",
      });
    }

    if (error?.status === 503) {
      return res.status(503).json({
        error: "El asistente no está disponible en este momento. Intenta de nuevo.",
      });
    }

    return res.status(500).json({
      error: "El asistente no está disponible en este momento. Intenta de nuevo.",
    });
  }
};

// ───────────── CHAT DEL CLIENTE ─────────────

export const chatearConCliente = (req, res) =>
  responderChat(req, res, {
    rol: "cliente",

    armarPrompt: async () => {
      const [
        { data: ejercicios },
        { data: productos },
        reglas,
      ] = await Promise.all([
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

// ───────────── CHAT DEL ADMINISTRADOR ─────────────

export const chatearConAdmin = (req, res) =>
  responderChat(req, res, {
    rol: "admin",

    armarPrompt: async () => {
      const [metricas, reglas] = await Promise.all([
        obtenerMetricasAdmin(),
        obtenerReglasHorariosChat(),
      ]);

      return construirPromptAdmin({
        resumenMetricas: formatearMetricas(metricas),
        listaStockBajo: formatearStockBajo(
          metricas?.productosBajoStock
        ),
        listaReglasHorarios: formatearReglasHorarios(reglas),
      });
    },
  });

// Compatibilidad con el nombre anterior.
export const chatearConGym = chatearConCliente;
