import { Router } from "express";
import { 
  registro, 
  login, 
  verificarCuenta, 
  reenviarCodigo 
} from "../controllers/authController.js";
import { 
    solicitarCodigo, 
    cambiarContraseñaConCodigo 
} from "../controllers/recuperarController.js";

const router = Router();

// REGISTRO DE USUARIO Y PERFIL
router.post("/registro", registro);

// INICIO DE SESIÓN
router.post("/login", login);

// VERIFICAR CUENTA
router.post("/verificar-cuenta", verificarCuenta);

// REENVIAR CÓDIGO DE VERIFICACIÓN
router.post("/reenviar-codigo", reenviarCodigo);

// SOLICITUD DE CÓDIGO DE RECUPERACIÓN
router.post("/recuperar/solicitar", solicitarCodigo);

// CAMBIO DE CONTRASEÑA CON CÓDIGO
router.post("/recuperar/cambiar", cambiarContraseñaConCodigo);

export default router;