import { Router } from "express";
import { chatearConCliente, chatearConAdmin } from "../controllers/chatController.js";
import { verificarToken, verificarCliente, verificarAdmin } from "../middlewares/authMiddleware.js";

const router = Router();

// Primero se valida el token y el rol, y solo después se llama a la IA
router.post("/cliente", verificarToken, verificarCliente, chatearConCliente);
router.post("/admin", verificarToken, verificarAdmin, chatearConAdmin);

export default router;