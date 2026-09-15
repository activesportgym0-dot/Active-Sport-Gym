import { Router } from "express";
import {
  obtenerReglasHorarios,
  crearReglaHorario,
  actualizarReglaHorario,
  eliminarReglaHorario
} from "../controllers/reglasHorariosController.js";
import { verificarToken, verificarAdmin } from "../middlewares/authMiddleware.js";

const router = Router();

// Ruta pública (para ser consumida en Flutter por cualquier usuario)
router.get("/", verificarToken,obtenerReglasHorarios);

// Rutas protegidas (Solo Administrador)
router.post("/", verificarToken, verificarAdmin, crearReglaHorario);
router.put("/:id", verificarToken, verificarAdmin, actualizarReglaHorario);
router.delete("/:id", verificarToken, verificarAdmin, eliminarReglaHorario);

export default router;