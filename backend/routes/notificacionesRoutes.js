import { Router } from "express";
import { verificarToken, verificarAdmin, verificarCliente } from "../middlewares/authMiddleware.js";
import { uploadNotificacion } from "../config/cloudinary.js";
import {
    consultarMisNotificaciones,
    crearNotificacion,
    marcarLeida,
    marcarTodasComoLeidas,
    borrarNotificacion,
    listarNotificacionesAdmin
} from "../controllers/notificacionesController.js";
const router = Router();
// Rutas para los clientes (consultar sus notificaciones y marcar como leidas)
router.get("/mis-notificaciones", verificarToken, verificarCliente, consultarMisNotificaciones);
router.put("/marcar-leida/:id", verificarToken, verificarCliente, marcarLeida);
router.put("/marcar-todas-leidas", verificarToken, verificarCliente, marcarTodasComoLeidas);
// Rutas exclusivas del administrador
// Lista todas las notificaciones enviadas (para la pantalla de gestión del admin)
router.get("/admin", verificarToken, verificarAdmin, listarNotificacionesAdmin);
// Primero se valida el token y el rol; recién después multer procesa el multipart y sube la imagen
// (así nadie sin sesión puede subir archivos a Cloudinary).
router.post("/", verificarToken, verificarAdmin, uploadNotificacion.single("imagen"), crearNotificacion);
// Antes tenía verificarAdmin y verificarCliente juntos, lo cual no deja pasar a nadie (403 siempre).
router.delete("/:id", verificarToken, verificarAdmin, borrarNotificacion);

export default router;
