import { Router } from "express";
import {
    listarUsuarios,
    obtenerUsuario,
    editarUsuario,
    cambiarEstadoUsuario,
    cambiarRolUsuario,
    borrarUsuario
} from "../controllers/usuarioController.js";

import { verificarToken, verificarAdmin, verificarPropioOAdmin } from "../middlewares/authMiddleware.js";

const router = Router();

// OBTENER TODOS LOS USUARIOS (Solo Admin)
router.get("/", verificarToken, verificarAdmin, listarUsuarios);

// OBTENER USUARIO POR ID (Solo Admin)
router.get("/:id", verificarToken, verificarAdmin, obtenerUsuario);

// ACTUALIZAR USUARIO (el dueño de la cuenta o un administrador; solo el admin puede tocar is_active)
router.put("/:id", verificarToken, verificarPropioOAdmin, editarUsuario);

// CAMBIAR ESTADO DE USUARIO - ACTIVAR / DESACTIVAR (Solo Admin)
router.patch("/:id/estado", verificarToken, verificarAdmin, cambiarEstadoUsuario);

// CAMBIAR ROL DE USUARIO - admin o cliente (Solo Admin)
router.patch("/:id/rol", verificarToken, verificarAdmin, cambiarRolUsuario);

// ELIMINAR USUARIO (Solo Admin)
router.delete("/:id", verificarToken, verificarAdmin, borrarUsuario);

export default router;