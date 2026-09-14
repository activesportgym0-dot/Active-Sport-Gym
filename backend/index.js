// IMPORTACIONES

import express from "express";
import dotenv from "dotenv";
import cors from "cors";

import { conectaDB } from "./config/supabase.js";

import usuarioRouter from "./routes/usuarioRouter.js";

import perfilRouter from "./routes/perfilRouter.js";

import categoriaEjerciciosRouter from "./routes/categoriaEjerciciosRouter.js";

import ejercicioRouter from "./routes/ejercicioRouter.js";

import rutinaRouter from "./routes/rutinaRouter.js";

import authRouter from "./routes/authRouter.js";

import historialRouter from "./routes/historialRoutes.js";

import progresoRoutes from "./routes/progresoRouter.js";

import notificacionesRouter from "./routes/notificacionesRoutes.js";

import membresiaRouter from "./routes/membresiaRoutes.js";

import categoriaProductoRouter from "./routes/categoriaProductoRoutes.js";

import productoRouter from "./routes/productoRouter.js";

import carritoRouter from "./routes/carritoRoutes.js";

import pedidosRouter from "./routes/pedidosRoutes.js";

import historiaGimnasioRouter from "./routes/historiaGimnasioRoutes.js";

import reglasHorariosRouter from "./routes/reglasHorariosRoutes.js";

import chatearConGym from "./routes/chatRoutes.js";

// CONFIGURACIÓN DE VARIABLES DE ENTORNO
dotenv.config();

// CREACIÓN DE LA APP
const app = express();

// MIDDLEWARES

// Permite recibir datos JSON desde las peticiones
app.use(express.json());

// Permite la comunicación entre frontend y backend
app.use(cors());

// CONEXIÓN CON LA BASE DE DATOS
conectaDB();

// RUTAS

// Rutas de usuarios
app.use("/usuarios", usuarioRouter);

// Rutas de autenticación
app.use("/auth", authRouter);

// Rutas de perfil
app.use("/perfil", perfilRouter);

// Rutas de categorías de ejercicios
app.use("/categorias", categoriaEjerciciosRouter);

// Rutas de ejercicios
app.use("/ejercicios", ejercicioRouter);

// Rutas de rutinas
app.use("/rutinas", rutinaRouter);

// Rutas de historial
app.use("/historial", historialRouter);

// Rutas de progreso
app.use("/progreso", progresoRoutes);

// Rutas de notificaciones
app.use("/notificaciones", notificacionesRouter);

// Rutas de membresía
app.use("/membresias", membresiaRouter);

// Rutas de categorías de productos
app.use("/categorias-productos", categoriaProductoRouter);

// Rutas de productos
app.use("/producto", productoRouter);

// Rutas de carrito
app.use("/carrito", carritoRouter);

// Rutas de pedidos
app.use("/pedidos", pedidosRouter);

// Rutas de historia del gimnasio
app.use("/historia-gimnasio", historiaGimnasioRouter);

// Rutas de reglas y horarios
app.use("/reglas-horarios", reglasHorariosRouter);

// Rutas de chat
app.use("/chat", chatearConGym);

// RUTA PRINCIPAL
app.get("/", (req, res) => {
  res.json({
    message: "¡Hola, Bienvenido al backend de Active Sport Gym🦾!",
    estado: "En linea",
    Version: "1.0.0"
  });
});

// CONFIGURACIÓN DEL PUERTO
const PORT = process.env.PORT || 3000;

// INICIAR SERVIDOR
app.listen(PORT, () => {
  console.log(`Servidor escuchando el puerto ${PORT}`);
  console.log(`http://localhost:${PORT}`);
});