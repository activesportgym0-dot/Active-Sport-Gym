// routes/categoriaRoutes.js
import { Router } from "express";
import {
    listarCategorias,
    obtenerCategoria,
    registrarCategoria,
    editarCategoria,
    borrarCategoria
} from "../controllers/categoriaEjerciciosController.js";
import { verificarToken ,verificarAdmin } from "../middlewares/authMiddleware.js"; // <--- Importas el middleware

const router = Router();

// Rutas públicas (cualquier usuario logueado o visitante puede consultar)
router.get("/", listarCategorias);
router.get("/:id", obtenerCategoria);

// Rutas protegidas (SOLO ADMINISTRADOR)
router.post("/", verificarToken, verificarAdmin, registrarCategoria);
router.put("/:id", verificarToken, verificarAdmin, editarCategoria);
router.delete("/:id", verificarToken, verificarAdmin, borrarCategoria);

export default router;