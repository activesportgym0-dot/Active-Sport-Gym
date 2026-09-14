import { Router } from "express";
import {
    obtenerPerfil,
    editarPerfil,
    cambiarFotoPerfil
} from "../controllers/perfilController.js";
import { verificarToken } from "../middlewares/authMiddleware.js";
import { uploadPerfil } from "../config/cloudinary.js";

const router = Router();

// Permite a un usuario autenticado consultar la información de su perfil
router.get("/:id_usuario", verificarToken, obtenerPerfil);

// Permite a un usuario autenticado actualizar sus datos personales como peso o altura
router.put("/:id_usuario", verificarToken, editarPerfil);

// Permite a un usuario autenticado subir o cambiar su foto de perfil en Cloudinary
router.put("/foto/:id_usuario", verificarToken, uploadPerfil.single("foto"), cambiarFotoPerfil);

export default router;