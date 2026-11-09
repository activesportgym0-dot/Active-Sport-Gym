import { Router } from "express";
import {
    obtenerPerfil,
    editarPerfil,
    cambiarFotoPerfil
} from "../controllers/perfilController.js";
import { verificarToken, verificarPropioOAdmin } from "../middlewares/authMiddleware.js";
import { uploadPerfil } from "../config/cloudinary.js";

const router = Router();

// Permite consultar la información de un perfil (el dueño o un administrador)
router.get("/:id_usuario", verificarToken, verificarPropioOAdmin, obtenerPerfil);

// Permite a un usuario autenticado actualizar sus datos personales como peso o altura
router.put("/:id_usuario", verificarToken, verificarPropioOAdmin, editarPerfil);

// Permite a un usuario autenticado subir o cambiar su foto de perfil en Cloudinary
router.put("/foto/:id_usuario", verificarToken, verificarPropioOAdmin, uploadPerfil.single("foto"), cambiarFotoPerfil);

export default router;