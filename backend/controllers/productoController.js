import {
  obtenerProductosBD,
  obtenerProductoPorIdBD,
  crearProductoBD,
  actualizarProductoBD,
  eliminarProductoBD,
  registrarAlertaStockBD,
  obtenerUsuariosParaAvisoStockBD,
  eliminarAlertasStockBD
} from "../models/productoModel.js";

import { enviarAlertaStockBajo } from "../utils/emails/plantillaAlertaStock.js";

import { enviarCorreoStockDisponible } from "../utils/emails/plantillaStockDisponible.js";

const obtenerIdUsuario = (req) => {
  const raw = req.usuario?.id_usuario || req.usuario?.id;
  const id = Number(raw);
  return Number.isInteger(id) ? id : null;
};

// [CLIENTE / ADMIN] Listar productos con filtros
export const listarProductos = async (req, res) => {
  try {
    const { id_categoria, busqueda } = req.query;
    const { data, error } = await obtenerProductosBD({ id_categoria, busqueda });

    if (error) {
      return res.status(500).json({ error: "Error al consultar los productos", detalle: error.message });
    }

    return res.status(200).json(data || []);
  } catch (error) {
    console.error("Error en listarProductos:", error);
    return res.status(500).json({ error: "Ocurrió un error interno al obtener el catálogo de productos" });
  }
};

// [CLIENTE / ADMIN] Obtener detalle de un producto
export const verDetalleProducto = async (req, res) => {
  try {
    const id_producto = Number(req.params.id);
    if (!Number.isInteger(id_producto) || id_producto <= 0) {
      return res.status(400).json({ error: "El ID del producto no es válido" });
    }

    const { data, error } = await obtenerProductoPorIdBD(id_producto);
    if (error) {
      return res.status(500).json({ error: "Error al obtener la información del producto", detalle: error.message });
    }
    if (!data) {
      return res.status(404).json({ error: "El producto solicitado no existe" });
    }

    return res.status(200).json(data);
  } catch (error) {
    console.error("Error en verDetalleProducto:", error);
    return res.status(500).json({ error: "Error interno al obtener el detalle del producto" });
  }
};

// [ADMIN] Crear producto (con subida de imagen a Cloudinary)
export const crearProducto = async (req, res) => {
  try {
    const body = req.body || {};
    const {
      id_categoria,
      nombre,
      marca,
      sabor,
      peso_neto,
      servicios,
      precio,
      stock,
      descripcion,
      beneficios,
      modo_uso
    } = body;

    if (!id_categoria || !nombre || !precio) {
      return res.status(400).json({ error: "Los campos id_categoria, nombre y precio son obligatorios." });
    }

    // req.file.path contiene la URL pública asignada por Cloudinary
    const imagen_url = req.file ? req.file.path : null;

    const nuevoProducto = {
      id_categoria: Number(id_categoria),
      nombre: nombre.trim(),
      marca: marca ? marca.trim() : null,
      sabor: sabor ? sabor.trim() : null,
      peso_neto: peso_neto ? peso_neto.trim() : null,
      servicios: servicios ? servicios.trim() : null,
      precio: Number(precio),
      stock: stock ? Number(stock) : 0,
      descripcion: descripcion ? descripcion.trim() : null,
      beneficios: beneficios ? beneficios.trim() : null,
      modo_uso: modo_uso ? modo_uso.trim() : null,
      imagen_url
    };

    const { data, error } = await crearProductoBD(nuevoProducto);

    if (error) {
      return res.status(500).json({ error: "Error al registrar el producto", detalle: error.message });
    }

    return res.status(201).json({
      mensaje: "Producto registrado con éxito",
      producto: data
    });
  } catch (error) {
    console.error("Error en crearProducto:", error);
    return res.status(500).json({ error: "Ocurrió un error interno al crear el producto" });
  }
};
// [ADMIN] Actualizar producto, enviar alerta de stock bajo o notificar reabastecimiento
export const actualizarProducto = async (req, res) => {
  try {
    const id_producto = Number(req.params.id);
    if (!Number.isInteger(id_producto) || id_producto <= 0) {
      return res.status(400).json({ error: "El ID del producto no es válido" });
    }

    const { data: productoActual } = await obtenerProductoPorIdBD(id_producto);
    if (!productoActual) {
      return res.status(404).json({ error: "El producto a actualizar no existe" });
    }

    const body = req.body || {};
    const nuevoStock = body.stock !== undefined ? Number(body.stock) : productoActual.stock;

    // Conserva la URL de Cloudinary anterior salvo que req.file traiga una nueva
    const imagen_url = req.file ? req.file.path : productoActual.imagen_url;

    const datosActualizados = {
      id_categoria: body.id_categoria ? Number(body.id_categoria) : productoActual.id_categoria,
      nombre: body.nombre ? body.nombre.trim() : productoActual.nombre,
      marca: body.marca !== undefined ? body.marca : productoActual.marca,
      sabor: body.sabor !== undefined ? body.sabor : productoActual.sabor,
      peso_neto: body.peso_neto !== undefined ? body.peso_neto : productoActual.peso_neto,
      servicios: body.servicios !== undefined ? body.servicios : productoActual.servicios,
      precio: body.precio ? Number(body.precio) : productoActual.precio,
      stock: nuevoStock,
      descripcion: body.descripcion !== undefined ? body.descripcion : productoActual.descripcion,
      beneficios: body.beneficios !== undefined ? body.beneficios : productoActual.beneficios,
      modo_uso: body.modo_uso !== undefined ? body.modo_uso : productoActual.modo_uso,
      imagen_url
    };

    const { data, error } = await actualizarProductoBD(id_producto, datosActualizados);

    if (error) {
      return res.status(500).json({ error: "Error al actualizar el producto", detalle: error.message });
    }
// 1. Si el stock pasa de 0 a mayor que 0, notifica a los clientes interesados y limpia las alertas
if (productoActual.stock === 0 && nuevoStock > 0) {
  try {
    const { data: alertas, error: errAlertas } = await obtenerUsuariosParaAvisoStockBD(id_producto);

    if (errAlertas) {
      console.error("Error al obtener usuarios de alertas:", errAlertas.message);
    }

    if (alertas && alertas.length > 0) {
      console.log(`[AVISO STOCK] Se encontraron ${alertas.length} solicitud(es) para '${data.nombre}'.`);

      for (const alerta of alertas) {
        // Muestra en consola la estructura del registro recuperado
        console.log("Datos de la alerta recuperada:", JSON.stringify(alerta));

        // Intenta obtener el correo de la relación de Supabase o del objeto plano
        const correoDestino = alerta.usuarios?.correo || alerta.correo || alerta.correo;
        const nombreCliente = alerta.usuarios?.nombre || alerta.nombre || "Cliente";

        if (correoDestino) {
          console.log(`[AVISO STOCK] Enviando correo a: ${correoDestino}...`);
          
          const resultadoInfo = await enviarCorreoStockDisponible({
            correoCliente: correoDestino,
            nombreCliente,
            producto: data
          });

          console.log(`[AVISO STOCK] Correo enviado exitosamente. MessageId: ${resultadoInfo.messageId}`);
        } else {
          console.warn("[AVISO STOCK] No se encontró la propiedad 'correo' en el objeto del usuario.");
        }
      }

      await eliminarAlertasStockBD(id_producto);
      console.log(`[AVISO STOCK] Solicitudes limpiadas con éxito.`);
    }
  } catch (errAviso) {
    console.error("Error al notificar reabastecimiento a clientes:", errAviso);
  }
}
    // 2. Notificación por correo protegida para evitar errores 500 por fallo de Nodemailer
    const LIMITE_MINIMO_STOCK = 3;
    if (nuevoStock <= LIMITE_MINIMO_STOCK) {
      try {
        await enviarAlertaStockBajo({
          producto: {
            nombre: data.nombre,
            categoria: `Categoría ID ${data.id_categoria}`
          },
          stockActual: nuevoStock,
          limiteMinimo: LIMITE_MINIMO_STOCK
        });
      } catch (errEmail) {
        console.error("Error al enviar el correo de alerta de stock:", errEmail.message);
      }
    }

    return res.status(200).json({
      mensaje: "Producto actualizado con éxito",
      producto: data
    });
  } catch (error) {
    console.error("Error en actualizarProducto:", error);
    return res.status(500).json({ error: "Error interno al actualizar el producto", detalle: error.message });
  }
};

// [ADMIN] Eliminar producto
export const borrarProducto = async (req, res) => {
  try {
    const id_producto = Number(req.params.id);
    if (!Number.isInteger(id_producto) || id_producto <= 0) {
      return res.status(400).json({ error: "El ID del producto no es válido" });
    }

    const { data, error } = await eliminarProductoBD(id_producto);

    if (error) {
      return res.status(500).json({ error: "Error al eliminar el producto", detalle: error.message });
    }

    if (!data) {
      return res.status(404).json({ error: "El producto no existe" });
    }

    return res.status(200).json({ mensaje: "Producto eliminado correctamente", producto: data });
  } catch (error) {
    console.error("Error en borrarProducto:", error);
    return res.status(500).json({ error: "Error interno al borrar el producto" });
  }
};

// [CLIENTE] Registrar solicitud de aviso de stock
export const solicitarAvisoStock = async (req, res) => {
  try {
    const id_usuario = obtenerIdUsuario(req);
    const id_producto = Number(req.params.id);

    if (!id_usuario) {
      return res.status(401).json({ error: "Usuario no autenticado" });
    }

    if (!Number.isInteger(id_producto) || id_producto <= 0) {
      return res.status(400).json({ error: "El ID del producto no es válido" });
    }

    const { data: producto } = await obtenerProductoPorIdBD(id_producto);
    if (!producto) {
      return res.status(404).json({ error: "El producto no existe" });
    }

    if (producto.stock > 0) {
      return res.status(400).json({ mensaje: "El producto actualmente tiene unidades disponibles." });
    }

    const { data, error } = await registrarAlertaStockBD(id_usuario, id_producto);

    if (error) {
      if (error.code === "23505") {
        return res.status(200).json({ mensaje: "Ya habías registrado tu solicitud de aviso para este producto." });
      }
      return res.status(500).json({ error: "Error al registrar la solicitud", detalle: error.message });
    }

    return res.status(201).json({
      mensaje: "¡Te avisaremos apenas haya stock disponible!",
      alerta: data
    });
  } catch (error) {
    console.error("Error en solicitarAvisoStock:", error);
    return res.status(500).json({ error: "Error interno al procesar la solicitud de aviso" });
  }
};