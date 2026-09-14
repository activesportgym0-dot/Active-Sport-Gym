import { Router } from "express";
import {
  listarProductos,
  verDetalleProducto,
  crearProducto,
  actualizarProducto,
  borrarProducto,
  solicitarAvisoStock
} from "../controllers/productoController.js";

// Middlewares para validar el Token JWT y los roles
import { verificarToken, verificarAdmin, verificarCliente } from "../middlewares/authMiddleware.js";

// Middleware para subir imágenes a Cloudinary
import { uploadProducto } from "../config/cloudinary.js";

const router = Router();

// RUTAS PARA CLIENTE Y ADMINISTRADOR
// Obtener todos los productos
router.get("/", verificarToken, listarProductos);

// Obtener detalle de un producto por ID
router.get("/:id", verificarToken, verDetalleProducto);

// RUTAS EXCLUSIVAS PARA CLIENTES
// Solicitar aviso cuando el producto esté agotado (stock 0)
router.post("/:id/solicitar-aviso", verificarToken, verificarCliente, solicitarAvisoStock);

// RUTAS EXCLUSIVAS PARA ADMINISTRADOR
// Crear un nuevo producto (con carga de imagen opcional u obligatoria)
router.post("/", verificarToken, verificarAdmin, uploadProducto.single("imagen"), crearProducto);

// Actualizar un producto existente
router.put("/:id", verificarToken, verificarAdmin, uploadProducto.single("imagen"), actualizarProducto);

// Eliminar un producto
router.delete("/:id", verificarToken, verificarAdmin, borrarProducto);

export default router;