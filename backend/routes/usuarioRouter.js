import { Router } from "express";
import {
    listarUsuarios,
    obtenerUsuario,
    editarUsuario,
    borrarUsuario
} from "../controllers/usuarioController.js";

import { verificarToken, verificarAdmin, verificarCliente } from "../middlewares/authMiddleware.js";

const router = Router();

// OBTENER TODOS LOS USUARIOS (Solo Admin)
router.get("/", verificarToken, verificarAdmin, listarUsuarios);

// OBTENER USUARIO POR ID (Solo Admin)
router.get("/:id", verificarToken, verificarAdmin, obtenerUsuario);

// ACTUALIZAR USUARIO (Requiere token)
router.put("/:id", verificarToken, editarUsuario);

// ELIMINAR USUARIO (Solo Admin)
router.delete("/:id", verificarToken, verificarAdmin, borrarUsuario);

export default router;