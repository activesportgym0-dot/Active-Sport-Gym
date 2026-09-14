import { Router } from "express";
import {
    listarUsuarios,
    obtenerUsuario,
    editarUsuario,
    borrarUsuario
} from "../controllers/usuarioController.js";

import { verificarToken, verificarAdmin, verificarCliente } from "../middlewares/authMiddleware.js";
const router = Router();

// OBTENER TODOS LOS USUARIOS
router.get("/", listarUsuarios, verificarToken,verificarAdmin);

// OBTENER USUARIO POR ID
router.get("/:id", obtenerUsuario, verificarToken,verificarAdmin);

// ACTUALIZAR USUARIO
router.put("/:id", editarUsuario, verificarToken,verificarAdmin, verificarCliente);

// ELIMINAR USUARIO
router.delete("/:id", borrarUsuario,verificarToken,verificarAdmin);

export default router;