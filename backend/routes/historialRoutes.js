import { Router } from "express";
import { verificarToken, verificarCliente } from "../middlewares/authMiddleware.js";
import {
    registrarEntrenamiento,
    listarHistorial,
    borrarHistorialPorId,
    borrarTodoElHistorial
} from "../controllers/historialControllers.js";

const router = Router();

router.use(verificarToken, verificarCliente);

// Rutas usando los nombres exactos del controlador

// Registrar un entrenamiento (historial de rutina y ejercicios)
router.post("/", registrarEntrenamiento);
// Listar todo el historial del usuario
router.get("/", listarHistorial);

// Eliminar una sola entrada del historial (icono de papelera en un elemento)
router.delete("/:id", borrarHistorialPorId);

// Vaciar todo el historial del usuario (icono de papelera general)
router.delete("/", borrarTodoElHistorial);

export default router;