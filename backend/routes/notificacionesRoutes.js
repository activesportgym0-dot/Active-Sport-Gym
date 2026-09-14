import { Router } from "express";
import { verificarToken, verificarAdmin, verificarCliente } from "../middlewares/authMiddleware.js";
import { uploadNotificacion } from "../config/cloudinary.js";
import {
    consultarMisNotificaciones,
    crearNotificacion,
    marcarLeida,
    marcarTodasComoLeidas,
    borrarNotificacion
} from "../controllers/notificacionesController.js";

const router = Router();

// Rutas para los clientes (consultar sus notificaciones y marcar como leidas)
router.get("/mis-notificaciones", verificarToken, verificarCliente, consultarMisNotificaciones);
router.put("/marcar-leida/:id", verificarToken, verificarCliente, marcarLeida);
router.put("/marcar-todas-leidas", verificarToken, verificarCliente, marcarTodasComoLeidas);

// Rutas exclusivas del administrador (crear y eliminar notificaciones)
// El middleware de multer va primero para poder procesar multipart/form-data y armar req.body
router.post("/", uploadNotificacion.single("imagen"), verificarToken, verificarAdmin, crearNotificacion);
router.delete("/:id", verificarToken, verificarAdmin, borrarNotificacion);

export default router;