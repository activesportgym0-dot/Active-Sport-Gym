import { Router } from "express";
import {
    listarUsuarios,
    obtenerUsuario,
    editarUsuario,
    cambiarEstadoUsuario,
    cambiarRolUsuario,
    eliminarMiCuenta,
    borrarUsuario
} from "../controllers/usuarioController.js";

import { verificarToken, verificarAdmin, verificarAdminPrincipal, verificarPropioOAdmin } from "../middlewares/authMiddleware.js";

const router = Router();

// OBTENER TODOS LOS USUARIOS (Solo Admin)
router.get("/", verificarToken, verificarAdmin, listarUsuarios);

// OBTENER USUARIO POR ID (Solo Admin)
router.get("/:id", verificarToken, verificarAdmin, obtenerUsuario);

// ACTUALIZAR USUARIO (el dueño de la cuenta o un administrador; solo el admin puede tocar is_active)
router.put("/:id", verificarToken, verificarPropioOAdmin, editarUsuario);

// CAMBIAR ESTADO DE USUARIO - ACTIVAR / DESACTIVAR (Solo Admin)
router.patch("/:id/estado", verificarToken, verificarAdmin, cambiarEstadoUsuario);

// CAMBIAR ROL DE USUARIO - admin o cliente (Solo el Administrador Principal)
router.patch("/:id/rol", verificarToken, verificarAdminPrincipal, cambiarRolUsuario);

// ELIMINAR MI PROPIA CUENTA (cualquier usuario con sesión)
// Va ANTES de "/:id", si no Express tomaría "mi-cuenta" como si fuera un id.
router.delete("/mi-cuenta", verificarToken, eliminarMiCuenta);

// ELIMINAR USUARIO (Solo Admin)
router.delete("/:id", verificarToken, verificarAdmin, borrarUsuario);

export default router;