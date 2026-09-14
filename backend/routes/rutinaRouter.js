import { Router } from "express";
import { verificarToken, verificarCliente } from "../middlewares/authMiddleware.js";

import {
    listarRutinas,
    obtenerRutina,
    listarRutinasPorUsuario,
    registrarRutina,
    editarRutina,
    editarDiaRutina,
    editarEjercicioRutina,
    editarSerieRutina,
    borrarSerieRutina,
    borrarEjercicioRutina,
    borrarRutina
} from "../controllers/rutinaController.js";


const router = Router();

// --- RUTAS DE GESTIÓN DE RUTINAS ---

// Aplicamos la verificación de token y de cliente a todas las rutas del módulo
router.use(verificarToken, verificarCliente);

// Obtener todas las rutinas
router.get("/", listarRutinas);

// Obtener rutinas de un usuario
router.get("/usuario/:idUsuario", listarRutinasPorUsuario);

// Obtener una rutina por ID
router.get("/:id", obtenerRutina);

// Crear una rutina
router.post("/", registrarRutina);

// Actualizar una rutina
router.put("/:id", editarRutina);

// Actualizar un día
router.put("/dia/:id", editarDiaRutina);

// Actualizar un ejercicio
router.put("/ejercicio/:id", editarEjercicioRutina);

// Actualizar una serie
router.put("/serie/:id", editarSerieRutina);

// Eliminar una serie
router.delete("/serie/:id", borrarSerieRutina);

// Eliminar un ejercicio
router.delete("/ejercicio/:id", borrarEjercicioRutina);

// Eliminar una rutina
router.delete("/:id", borrarRutina);


export default router;