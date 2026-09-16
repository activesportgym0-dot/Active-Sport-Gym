import { Router } from "express";
import {
    obtenerHistorias,
    crearHistoria,
    actualizarHistoria,
    eliminarHistoria
} from "../controllers/historiaGimnasioController.js";
import { verificarToken, verificarAdmin } from "../middlewares/authMiddleware.js";
import { uploadHistoria } from "../config/cloudinary.js";

const router = Router();

// Ruta protegida con token para consultar las historias
router.get("/", verificarToken, obtenerHistorias);

// Rutas de administración (requieren Token, Rol Admin y soporte de archivo de imagen con Cloudinary)
router.post("/", verificarToken, verificarAdmin, uploadHistoria.single("imagen"), crearHistoria);
router.put("/:id", verificarToken, verificarAdmin, uploadHistoria.single("imagen"), actualizarHistoria);
router.delete("/:id", verificarToken, verificarAdmin, eliminarHistoria);

export default router;