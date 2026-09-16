import {
  obtenerCarritoPorUsuarioBD,
  obtenerItemCarritoBD,
  agregarAlCarritoBD,
  actualizarCantidadCarritoBD,
  eliminarItemCarritoBD,
  vaciarCarritoBD,
  obtenerItemPorIdCarritoBD
} from "../models/carritoModel.js";

import { obtenerProductoPorIdBD } from "../models/productoModel.js";

// Extraer ID del usuario desde req.usuario (Token JWT)
const obtenerIdUsuario = (req) => {
  const raw = req.usuario?.id_usuario || req.usuario?.id;
  const id = Number(raw);
  return Number.isInteger(id) ? id : null;
};
// 1. OBTENER EL CARRITO CON CÁLCULO DE TOTALES
export const verCarrito = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado" });
    }
    const { data: items, error } = await obtenerCarritoPorUsuarioBD(id_usuario);
    if (error) {
      return res.status(500).json({ error: "Error al obtener el carrito", detalle: error.message });
    }
    // Calcular subtotales y total general
    let totalGeneral = 0;
    const itemsFormateados = (items || []).map((item) => {
      const precio = item.productos?.precio || 0;
      const subtotal = precio * item.cantidad;
      totalGeneral += subtotal;
      return {
        id_carrito: item.id_carrito,
        id_producto: item.productos?.id_producto,
        nombre: item.productos?.nombre,
        precio,
        imagen_url: item.productos?.imagen_url,
        cantidad: item.cantidad,
        stock_disponible: item.productos?.stock,
        subtotal
      };
    });
    return res.status(200).json({
      items: itemsFormateados,
      total_items: itemsFormateados.length,
      total_pagar: totalGeneral
    });
  } catch (error) {
    console.error("Error en verCarrito:", error);
    return res.status(500).json({ error: "Error interno al consultar el carrito" });
  }
};
// 2. AGREGAR PRODUCTO AL CARRITO
export const agregarProductoCarrito = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    const { id_producto, cantidad = 1 } = req.body;
    const cantNum = Number(cantidad);
    const idProdNum = Number(id_producto);
    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado" });
    }
    if (!Number.isInteger(idProdNum) || idProdNum <= 0) {
      return res.status(400).json({ error: "ID de producto no válido" });
    }
    if (!Number.isInteger(cantNum) || cantNum <= 0) {
      return res.status(400).json({ error: "La cantidad debe ser mayor a 0" });
    }
    // Validar existencia y stock del producto
    const { data: producto, error: errProducto } = await obtenerProductoPorIdBD(idProdNum);
    if (errProducto || !producto) {
      return res.status(404).json({ error: "El producto no existe" });
    }
    if (producto.stock < cantNum) {
      return res.status(400).json({ error: `Stock insuficiente. Disponible: ${producto.stock}` });
    }
    // Verificar si ya está en el carrito
    const { data: itemExistente } = await obtenerItemCarritoBD(id_usuario, idProdNum);
    if (itemExistente) {
      const nuevaCantidad = itemExistente.cantidad + cantNum;
      if (producto.stock < nuevaCantidad) {
        return res.status(400).json({
          error: `No puedes agregar más unidades. Supera el stock disponible (${producto.stock}).`
        });
      }
      const { data, error } = await actualizarCantidadCarritoBD(itemExistente.id_carrito, nuevaCantidad);
      if (error) return res.status(500).json({ error: "Error al actualizar la cantidad", detalle: error.message });
      return res.status(200).json({ mensaje: "Cantidad actualizada en el carrito", item: data });
    }
    // Si no está, se inserta
    const { data, error } = await agregarAlCarritoBD(id_usuario, idProdNum, cantNum);
    if (error) return res.status(500).json({ error: "Error al agregar al carrito", detalle: error.message });
    return res.status(201).json({ mensaje: "Producto agregado al carrito", item: data });
  } catch (error) {
    console.error("Error en agregarProductoCarrito:", error);
    return res.status(500).json({ error: "Error interno al agregar al carrito" });
  }
};
// 3. ACTUALIZAR CANTIDAD DE UN ITEM CON VALIDACIÓN DE STOCK
export const cambiarCantidadItem = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    const id_carrito = Number(req.params.id);
    const { cantidad } = req.body;
    const nuevaCantidad = Number(cantidad);
    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado" });
    }
    if (!Number.isInteger(nuevaCantidad) || nuevaCantidad <= 0) {
      return res.status(400).json({ error: "La cantidad debe ser mayor a 0" });
    }
    // 1. Obtener la información del item del carrito desde el modelo
    const { data: itemCarrito } = await obtenerItemPorIdCarritoBD(id_carrito);
    if (!itemCarrito) {
      return res.status(404).json({ error: "El elemento no existe en el carrito" });
    }
    // 2. Validar contra el stock del producto
    const { data: producto } = await obtenerProductoPorIdBD(itemCarrito.id_producto);
    if (producto && nuevaCantidad > producto.stock) {
      return res.status(400).json({ 
        error: `No hay suficiente stock. Máximo disponible: ${producto.stock}` 
      });
    }
    const { data, error } = await actualizarCantidadCarritoBD(id_carrito, nuevaCantidad);
    if (error) {
      return res.status(500).json({ error: "Error al cambiar cantidad", detalle: error.message });
    }
    return res.status(200).json({ mensaje: "Cantidad actualizada", item: data });
  } catch (error) {
    console.error("Error en cambiarCantidadItem:", error);
    return res.status(500).json({ error: "Error interno al modificar la cantidad" });
  }
};
// 4. ELIMINAR UN ITEM DEL CARRITO
export const eliminarItem = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    const id_carrito = Number(req.params.id);
    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado" });
    }
    const { data, error } = await eliminarItemCarritoBD(id_carrito, id_usuario);
    if (error) {
      return res.status(500).json({ error: "Error al eliminar el item del carrito", detalle: error.message });
    }
    return res.status(200).json({ mensaje: "Producto eliminado del carrito", item: data });
  } catch (error) {
    console.error("Error en eliminarItem:", error);
    return res.status(500).json({ error: "Error interno al eliminar del carrito" });
  }
};
// 5. VACIAR CARRITO COMPLETO
export const vaciarCarrito = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado" });
    }
    const { error } = await vaciarCarritoBD(id_usuario);
    if (error) {
      return res.status(500).json({ error: "Error al vaciar el carrito", detalle: error.message });
    }
    return res.status(200).json({ mensaje: "Carrito vaciado correctamente" });
  } catch (error) {
    console.error("Error en vaciarCarrito:", error);
    return res.status(500).json({ error: "Error interno al vaciar el carrito" });
  }
};