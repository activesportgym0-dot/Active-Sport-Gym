import { Router } from "express";
import { verificarToken, verificarAdmin, verificarCliente } from "../middlewares/authMiddleware.js";
import {
    consultarMiMembresia,
    consultarHistorialMembresias,
    asignarMembresia,
    cambiarEstadoMembresia
} from "../controllers/membresiaController.js";

const router = Router();

// Rutas para Clientes

// Consulta el estado actual/más reciente de la membresía del cliente
router.get("/mi-membresia", verificarToken, verificarCliente, consultarMiMembresia);

// Consulta el historial completo de sus membresías
router.get("/mi-historial", verificarToken, verificarCliente, consultarHistorialMembresias);

// Rutas para Administrador

// Registra un nuevo pago / período de membresía a un cliente
router.post("/", verificarToken, verificarAdmin, asignarMembresia);

// Permite al admin consultar el historial de cualquier cliente pasando su :id_usuario
router.get("/historial/:id_usuario", verificarToken, verificarAdmin, consultarHistorialMembresias);

// Cambia el estado de una membresía específica mediante su :id_membresia
router.put("/estado/:id_membresia", verificarToken, verificarAdmin, cambiarEstadoMembresia);

export default router;