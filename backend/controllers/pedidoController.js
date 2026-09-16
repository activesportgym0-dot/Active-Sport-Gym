import {
  crearPedidoBD,
  crearDetallePedidoBD,
  obtenerPedidosPorUsuarioBD,
  obtenerTodosLosPedidosBD,
  obtenerPedidoConDetallesBD,
  actualizarEstadoPedidoBD
} from "../models/pedidoModel.js";

import {
  obtenerCarritoPorUsuarioBD,
  vaciarCarritoBD
} from "../models/carritoModel.js";

import { actualizarProductoBD, obtenerProductoPorIdBD } from "../models/productoModel.js";
import { enviarCorreoConfirmacionPedido } from "../utils/emails/plantillaConfirmacionPedido.js";
import { enviarCorreoPedidoAceptado } from "../utils/emails/plantillaPedidoAceptado.js";
import { enviarCorreoNotificacionAdmin } from "../utils/emails/plantillaNotificacionAdmin.js";
import { enviarCorreoPedidoCancelado } from "../utils/emails/plantillaPedidoCancelado.js";
import { enviarCorreoPedidoCompletado } from "../utils/emails/plantillaPedidoCompletado.js";

// Helper para validar e identificar al usuario por Token
const obtenerIdUsuario = (req) => {
  const raw = req.usuario?.id_usuario || req.usuario?.id;
  const id = Number(raw);
  return Number.isInteger(id) && id > 0 ? id : null;
};

// Helper para evitar IDs inválidos o texto en los parámetros
const esIdValido = (id) => Number.isInteger(Number(id)) && Number(id) > 0;

// CONTROLADORES PARA CLIENTE
// 1. CLIENTE: Confirmar pedido desde el carrito
export const confirmarPedido = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    const rol = req.usuario?.rol?.toLowerCase();
    const correoCliente = req.usuario?.correo || req.usuario?.email;
    const nombreCliente = req.usuario?.nombre || "Cliente";
    // Verifico que la sesión sea válida
    if (!id_usuario) {
      return res.status(401).json({ error: "Sesión no válida. Inicia sesión de nuevo." });
    }
    // Bloqueo a los roles de administrador o mesero para que no realicen compras de esta manera
    if (rol === "admin" || rol === "mesero") {
      return res.status(403).json({ error: `El rol '${rol}' no puede realizar pedidos de compra.` });
    }
    // Obtengo los elementos actuales de mi carrito
    const { data: items, error: errCarrito } = await obtenerCarritoPorUsuarioBD(id_usuario);
    if (errCarrito) {
      return res.status(500).json({ error: "No se pudo consultar el carrito.", detalle: errCarrito.message });
    }
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: "El carrito está vacío." });
    }
    let total = 0;
    // Valido stock, precios y existencia de cada producto antes de procesar el pedido
    for (const item of items) {
      if (!item.productos) {
        return res.status(400).json({ error: "Uno de los productos en tu carrito ya no existe." });
      }
      const cantidad = Number(item.cantidad);
      const precio = Number(item.productos.precio);
      const stock = Number(item.productos.stock);
      if (!Number.isInteger(cantidad) || cantidad <= 0) {
        return res.status(400).json({ error: `Cantidad no válida para '${item.productos.nombre}'.` });
      }
      if (isNaN(precio) || precio <= 0) {
        return res.status(400).json({ error: `Precio inválido en '${item.productos.nombre}'.` });
      }
      if (isNaN(stock) || stock < cantidad) {
        return res.status(400).json({ error: `Sin stock suficiente para '${item.productos.nombre}'. Quedan: ${stock}` });
      }
      total += precio * cantidad;
    }
    if (total <= 0) {
      return res.status(400).json({ error: "El total debe ser un monto mayor a cero." });
    }
    // Creo el registro principal del pedido en estado "Pendiente"
    const { data: pedido, error: errPedido } = await crearPedidoBD(id_usuario, total, "Pendiente");
    if (errPedido || !pedido) {
      return res.status(500).json({ error: "No se pudo crear el pedido.", detalle: errPedido?.message });
    }
    // Mapeo los elementos del carrito para guardarlos en el detalle del pedido
    const detalles = items.map((item) => ({
      id_pedido: pedido.id_pedido,
      id_producto: item.productos.id_producto,
      cantidad: Number(item.cantidad),
      precio_unitario: Number(item.productos.precio)
    }));
    const { error: errDetalle } = await crearDetallePedidoBD(detalles);
    if (errDetalle) {
      return res.status(500).json({ error: "Error al registrar el detalle del pedido.", detalle: errDetalle.message });
    }
    // Descuento las unidades compradas del inventario de cada producto
    for (const item of items) {
      const nuevoStock = Number(item.productos.stock) - Number(item.cantidad);
      await actualizarProductoBD(item.productos.id_producto, { stock: nuevoStock });
    }
    // Vacío mi carrito de compras tras confirmar la orden con éxito
    await vaciarCarritoBD(id_usuario);
    // Envío el correo de confirmación al cliente si tiene un correo registrado
    if (correoCliente) {
      try {
        await enviarCorreoConfirmacionPedido({ correoCliente, nombreCliente, pedido, items });
      } catch (e) {
        console.error("Error al enviar correo al cliente:", e);
      }
    }
    // Notifico al administrador sobre el nuevo pedido realizado
    try {
      await enviarCorreoNotificacionAdmin({ nombreCliente, pedido, items });
    } catch (e) {
      console.error("Error al enviar correo al administrador:", e);
    }
    // Genero la URL y el texto formateado para redirigir directamente a WhatsApp
    const numeroWA = process.env.TELEFONO_GYM || "573115313005";
    const textoWA = encodeURIComponent(`🏋️ ¡Hola Active Sport Gym! Acabo de confirmar el pedido #${pedido.id_pedido} por$${total.toLocaleString("es-CO")}.`);
    return res.status(201).json({
      mensaje: "Pedido realizado correctamente",
      pedido,
      url_whatsapp: `https://wa.me/${numeroWA}?text=${textoWA}`
    });
  } catch (error) {
    console.error("Error en confirmarPedido:", error);
    return res.status(500).json({ error: "Error interno al procesar la compra." });
  }
};
// 2. CLIENTE: Ver mis pedidos
export const obtenerMisPedidos = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado." });
    }
    const { data, error } = await obtenerPedidosPorUsuarioBD(id_usuario);
    if (error) {
      return res.status(500).json({ error: "No se pudo obtener el historial.", detalle: error.message });
    }
    return res.status(200).json(data || []);
  } catch (error) {
    console.error("Error en obtenerMisPedidos:", error);
    return res.status(500).json({ error: "Error interno en la lectura del historial." });
  }
};
// 3. CLIENTE: Cancelar mi propio pedido
export const cancelarMiPedido = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    const id_pedidoParam = req.params.id;
    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado." });
    }
    if (!esIdValido(id_pedidoParam)) {
      return res.status(400).json({ error: "El ID del pedido no es válido." });
    }
    const id_pedido = Number(id_pedidoParam);
    const { data: pedido, error: errPedido } = await obtenerPedidoConDetallesBD(id_pedido);
    if (errPedido || !pedido) {
      return res.status(404).json({ error: "El pedido no existe." });
    }
    // Verifico que el pedido me pertenezca realmente
    if (pedido.id_usuario !== id_usuario) {
      return res.status(403).json({ error: "No tienes permiso para cancelar este pedido." });
    }
    // Solo permito cancelar si el pedido está en estado Pendiente
    if (pedido.estado !== "Pendiente") {
      return res.status(400).json({ error: `No puedes cancelar un pedido en estado '${pedido.estado}'.` });
    }
    const { data: pedidoCancelado, error: errUpdate } = await actualizarEstadoPedidoBD(id_pedido, "Cancelado");
    if (errUpdate) {
      return res.status(500).json({ error: "No se pudo cancelar el pedido.", detalle: errUpdate.message });
    }
    // Devuelvo las unidades al stock de cada producto al cancelarse el pedido
    if (pedido.detalle_pedidos && Array.isArray(pedido.detalle_pedidos)) {
      for (const item of pedido.detalle_pedidos) {
        const { data: prod } = await obtenerProductoPorIdBD(item.id_producto);
        if (prod) {
          await actualizarProductoBD(item.id_producto, { stock: Number(prod.stock) + Number(item.cantidad) });
        }
      }
    }
    return res.status(200).json({ mensaje: "Pedido cancelado correctamente.", pedido: pedidoCancelado });
  } catch (error) {
    console.error("Error en cancelarMiPedido:", error);
    return res.status(500).json({ error: "Error interno al cancelar." });
  }
};

// CONTROLADORES PARA ADMINISTRADOR
// 4. [ADMIN] Obtener la vista global de todos los pedidos registrados en el sistema
export const obtenerTodosPedidos = async (req, res) => {
  try {
    const { data, error } = await obtenerTodosLosPedidosBD();
    if (error) {
      return res.status(500).json({ error: "Error al consultar los pedidos.", detalle: error.message });
    }
    return res.status(200).json(data || []);
  } catch (error) {
    console.error("Error en obtenerTodosPedidos:", error);
    return res.status(500).json({ error: "Error interno de servidor." });
  }
};
// 5. [ADMIN] Cambiar el estado de un pedido y disparar notificaciones por correo según corresponda
export const cambiarEstadoPedido = async (req, res) => {
  try {
    const id_pedidoParam = req.params.id;
    const { estado, motivo } = req.body;
    if (!esIdValido(id_pedidoParam)) {
      return res.status(400).json({ error: "El ID del pedido no es válido." });
    }
    const id_pedido = Number(id_pedidoParam);
    const nuevoEstado = typeof estado === "string" ? estado.trim() : "";
    const estadosValidos = ["Pendiente", "Aceptado", "Completado", "Cancelado"];
    if (!nuevoEstado || !estadosValidos.includes(nuevoEstado)) {
      return res.status(400).json({ error: `Estado inválido. Valores permitidos: ${estadosValidos.join(", ")}` });
    }
    const { data: pedidoOriginal, error: errSearch } = await obtenerPedidoConDetallesBD(id_pedido);
    if (errSearch || !pedidoOriginal) {
      return res.status(404).json({ error: "Pedido no encontrado." });
    }
    if (pedidoOriginal.estado === nuevoEstado) {
      return res.status(400).json({ error: `El pedido ya está en estado '${nuevoEstado}'.` });
    }
    // Si el admin cancela un pedido que no estaba cancelado antes, restauro el stock
    if (nuevoEstado === "Cancelado" && pedidoOriginal.estado !== "Cancelado") {
      if (pedidoOriginal.detalle_pedidos && Array.isArray(pedidoOriginal.detalle_pedidos)) {
        for (const item of pedidoOriginal.detalle_pedidos) {
          const { data: prod } = await obtenerProductoPorIdBD(item.id_producto);
          if (prod) {
            await actualizarProductoBD(item.id_producto, { stock: Number(prod.stock) + Number(item.cantidad) });
          }
        }
      }
    }
    const { data, error } = await actualizarEstadoPedidoBD(id_pedido, nuevoEstado);
    if (error) {
      return res.status(500).json({ error: "No se pudo actualizar el estado.", detalle: error.message });
    }
    const correoCliente = data?.usuarios?.correo;
    const nombreCliente = data?.usuarios?.nombre || "Cliente";
    // Envío correos personalizados al cliente de acuerdo al nuevo estado del pedido
    if (correoCliente) {
      try {
        if (nuevoEstado === "Aceptado") {
          await enviarCorreoPedidoAceptado({
            correoCliente,
            nombreCliente,
            id_pedido: data.id_pedido,
            total: data.total
          });
        } else if (nuevoEstado === "Cancelado") {
          await enviarCorreoPedidoCancelado({
            correoCliente,
            nombreCliente,
            id_pedido: data.id_pedido,
            motivo: motivo ? String(motivo).trim() : "Cancelado por el administrador."
          });
        } else if (nuevoEstado === "Completado") {
          await enviarCorreoPedidoCompletado({
            correoCliente,
            nombreCliente,
            id_pedido: data.id_pedido
          });
        }
      } catch (err) {
        console.error("Error enviando notificación por correo:", err);
      }
    }
    return res.status(200).json({ mensaje: "Estado actualizado exitosamente", pedido: data });
  } catch (error) {
    console.error("Error en cambiarEstadoPedido:", error);
    return res.status(500).json({ error: "Error interno al actualizar estado." });
  }
};