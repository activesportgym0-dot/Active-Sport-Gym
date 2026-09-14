import { Router } from "express";
import {
    listarEjercicios,
    obtenerEjercicio,
    listarEjerciciosPorCategoria,
    registrarEjercicio,
    editarEjercicio,
    borrarEjercicio
} from "../controllers/ejercicioController.js";
import { verificarToken, verificarAdmin } from "../middlewares/authMiddleware.js";
import { uploadEjercicio } from "../config/cloudinary.js";

const router = Router();

// Permite a cualquier usuario autenticado consultar el catálogo de ejercicios
router.get("/", verificarToken, listarEjercicios);

// Filtra y obtiene los ejercicios pertenecientes a una categoría específica
router.get("/categoria/:idCategoria", verificarToken, listarEjerciciosPorCategoria);

// Busca y retorna la información detallada de un solo ejercicio por su ID
router.get("/:id", verificarToken, obtenerEjercicio);

// Permite solo al administrador registrar un nuevo ejercicio con sus archivos multimedia
router.post("/", verificarToken, verificarAdmin, uploadEjercicio.fields([{ name: "imagen", maxCount: 1 }, { name: "gif_url", maxCount: 1 }]), registrarEjercicio);

// Permite solo al administrador actualizar la información o imágenes de un ejercicio
router.put("/:id", verificarToken, verificarAdmin, uploadEjercicio.fields([{ name: "imagen", maxCount: 1 }, { name: "gif_url", maxCount: 1 }]), editarEjercicio);

// Permite solo al administrador eliminar un ejercicio del catálogo por su ID
router.delete("/:id", verificarToken, verificarAdmin, borrarEjercicio);

export default router;