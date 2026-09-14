import { Router } from "express";
import { verificarToken, verificarCliente } from "../middlewares/authMiddleware.js";
import {
    consultarProgresoActual,
    crearProgreso,
    consultarHistorialMedidas,
    borrarMedidaHistorial,
    borrarTodoElHistorial
} from "../controllers/progresoController.js";

const router = Router();

// Aplica autenticacion y rol a todas las rutas del modulo
router.use(verificarToken, verificarCliente);

// Rutas para el progreso actual
router.get("/actual", consultarProgresoActual);
router.post("/", crearProgreso);

// Rutas para el historial de medidas
router.get("/historial", consultarHistorialMedidas);
router.delete("/historial/:id", borrarMedidaHistorial);
router.delete("/historial", borrarTodoElHistorial);

export default router;