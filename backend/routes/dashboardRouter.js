import { Router } from "express";
import { obtenerResumenAdmin } from "../controllers/dashboardController.js";
import { verificarToken, verificarAdmin } from "../middlewares/authMiddleware.js";

const router = Router();

// Resumen del home del administrador (totales y últimas acciones)
router.get("/resumen", verificarToken, verificarAdmin, obtenerResumenAdmin);

export default router;
