import { Router } from "express";
import {
  verCarrito,
  agregarProductoCarrito,
  cambiarCantidadItem,
  eliminarItem,
  vaciarCarrito
} from "../controllers/carritoController.js";

import { verificarToken, verificarCliente } from "../middlewares/authMiddleware.js";

const router = Router();

// TODAS LAS RUTAS DEL CARRITO SON EXCLUSIVAS DEL CLIENTE AUTENTICADO
router.use(verificarToken, verificarCliente);

// Ver mi carrito personal
router.get("/", verCarrito);  

// Agregar producto al carrito
router.post("/agregar", agregarProductoCarrito);   

// Cambiar cantidad de un item   
router.put("/item/:id", cambiarCantidadItem); 

// Eliminar un item    
router.delete("/item/:id", eliminarItem);  

// Vaciar el carrito
router.delete("/vaciar", vaciarCarrito); 

export default router;