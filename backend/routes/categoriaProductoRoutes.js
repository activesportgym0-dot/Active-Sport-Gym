import { Router } from "express";
import { verificarToken, verificarCliente, verificarAdmin } from "../middlewares/authMiddleware.js";
import {
    listarCategorias,
    crearCategoria,
    actualizarCategoria,
    borrarCategoria
} from "../controllers/categoriaProductoController.js";

const router = Router();

// Consulta de Categorías para Clientes Logueados
// Exige que el usuario haya iniciado sesión (Token) y tenga rol de Cliente
router.get("/", verificarToken, verificarCliente, listarCategorias);

// Gestión Exclusiva del Administrador
// Exige que el usuario tenga inicio de sesión activo y permisos de Administrador
router.post("/", verificarToken, verificarAdmin, crearCategoria);
router.put("/:id", verificarToken, verificarAdmin, actualizarCategoria);
router.delete("/:id", verificarToken, verificarAdmin, borrarCategoria);

export default router;