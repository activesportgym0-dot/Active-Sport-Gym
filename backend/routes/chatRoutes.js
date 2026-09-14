import { Router } from "express";
import { chatearConGym } from "../controllers/chatController.js";
import { verificarCliente, verificarToken } from "../middlewares/authMiddleware.js";

const router = Router();

router.post("/", chatearConGym, verificarToken, verificarCliente);

export default router;