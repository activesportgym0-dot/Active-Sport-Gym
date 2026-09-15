import { Router } from "express";
import {
  confirmarPedido,
  obtenerMisPedidos,
  cancelarMiPedido,
  obtenerTodosPedidos,
  cambiarEstadoPedido
} from "../controllers/pedidoController.js";

import {
  verificarToken,
  verificarCliente,
  verificarAdmin
} from "../middlewares/authMiddleware.js";

const router = Router();

// RUTAS EXCLUSIVAS DEL CLIENTE

// Confirmar pedido desde el carrito de compras (Checkout)
router.post("/confirmar", verificarToken, verificarCliente, confirmarPedido);

// Consultar el historial de pedidos del cliente autenticado
router.get("/mis-pedidos", verificarToken, verificarCliente, obtenerMisPedidos);

// Cancelar un pedido propio en estado 'Pendiente'
router.put("/mis-pedidos/:id/cancelar", verificarToken, verificarCliente, cancelarMiPedido);

// RUTAS EXCLUSIVAS DEL ADMINISTRADOR

// Obtener la lista global de todos los pedidos registrados en la tienda
router.get("/admin", verificarToken, verificarAdmin, obtenerTodosPedidos);

// Cambiar el estado de un pedido (Botones de Aceptar / Cancelar desde el panel Admin)
router.put("/:id/estado", verificarToken, verificarAdmin, cambiarEstadoPedido);

export default router;