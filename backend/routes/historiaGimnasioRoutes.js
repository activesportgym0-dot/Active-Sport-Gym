import { Router } from "express";
import multer from "multer";
import {
  obtenerHistorias,
  crearHistoria,
  actualizarHistoria,
  eliminarHistoria
} from "../controllers/historiaGimnasioController.js";
import { verificarToken, verificarAdmin } from "../middlewares/authMiddleware.js";

import { uploadHistoria } from "../config/cloudinary.js";

const upload = multer({ dest: "uploads/" });
const router = Router();

// Ruta pública para la app en Flutter
router.get("/", obtenerHistorias);

// Rutas de administración (requieren Token, Rol Admin y soporte de archivo de imagen)
router.post("/", verificarToken, verificarAdmin, uploadHistoria.single("imagen"), crearHistoria);
router.put("/:id", verificarToken, verificarAdmin, uploadHistoria.single("imagen"), actualizarHistoria);
router.delete("/:id", verificarToken, verificarAdmin, eliminarHistoria);

export default router;