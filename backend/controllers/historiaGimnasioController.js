import {
  obtenerHistoriasBD,
  obtenerHistoriaPorIdBD,
  crearHistoriaBD,
  actualizarHistoriaBD,
  eliminarHistoriaBD
} from "../models/historiaGimnasioModel.js";

// Helper para validar que el ID sea un número entero positivo
const esIdValido = (id) => Number.isInteger(Number(id)) && Number(id) > 0;

// 1. Obtener todas las historias (Público)
export const obtenerHistorias = async (req, res) => {
  try {
    const { data, error } = await obtenerHistoriasBD();
    if (error) {
      return res.status(500).json({ 
        error: "Error al consultar la historia del gimnasio.", 
        detalle: error.message 
      });
    }
    return res.status(200).json(data || []);
  } catch (error) {
    console.error("Error en obtenerHistorias:", error);
    return res.status(500).json({ error: "Error interno del servidor." });
  }
};

// 2. Crear historia (Admin - La imagen es opcional)
export const crearHistoria = async (req, res) => {
  try {
    const { titulo, contenido } = req.body;
    
    // Capturar la URL de la imagen si se subió un archivo, de lo contrario queda como null o cadena vacía
    const imagenUrl = req.file?.path || req.file?.url || null;
    // Validar que el body no venga vacío
    if (!req.body || Object.keys(req.body).length === 0) {
      return res.status(400).json({ 
        error: "El cuerpo de la petición no puede estar vacío." 
      });
    }
    // Validaciones estrictas de campos obligatorios
    if (!titulo || typeof titulo !== "string" || !titulo.trim()) {
      return res.status(400).json({ 
        error: "El campo 'titulo' es obligatorio y debe ser un texto válido." 
      });
    }
    if (!contenido || typeof contenido !== "string" || !contenido.trim()) {
      return res.status(400).json({ 
        error: "El campo 'contenido' es obligatorio y debe ser un texto válido." 
      });
    }
    const { data, error } = await crearHistoriaBD({
      titulo: titulo.trim(),
      contenido: contenido.trim(),
      imagen: imagenUrl ? imagenUrl.trim() : null
    });
    if (error) {
      return res.status(500).json({ 
        error: "No se pudo registrar la historia en la base de datos.", 
        detalle: error.message 
      });
    }
    return res.status(201).json({ 
      mensaje: "Historia creada correctamente.", 
      historia: data 
    });
  } catch (error) {
    console.error("Error en crearHistoria:", error);
    return res.status(500).json({ error: "Error interno al crear la historia." });
  }
};
// 3. Actualizar historia (Admin)
export const actualizarHistoria = async (req, res) => {
  try {
    const { id } = req.params;
    const { titulo, contenido, imagen } = req.body;
    // Validación del parámetro ID
    if (!esIdValido(id)) {
      return res.status(400).json({ 
        error: "El ID proporcionado en la URL no es válido. Debe ser un número entero mayor a 0." 
      });
    }
    // Validar que al menos se envíe un campo para actualizar
    if (!titulo && !contenido && !imagen) {
      return res.status(400).json({ 
        error: "Debes proporcionar al menos un campo ('titulo', 'contenido' o 'imagen') para actualizar." 
      });
    }
    const idNumero = Number(id);
    // Verificar si el registro existe en la BD
    const { data: historiaExistente, error: errExist } = await obtenerHistoriaPorIdBD(idNumero);
    if (errExist || !historiaExistente) {
      return res.status(404).json({ 
        error: `No se encontró ninguna historia registrada con el ID ${idNumero}.` 
      });
    }
    const camposActualizar = {};
    if (titulo !== undefined) {
      if (typeof titulo !== "string" || !titulo.trim()) {
        return res.status(400).json({ error: "El 'titulo' no puede estar vacío." });
      }
      camposActualizar.titulo = titulo.trim();
    }
    if (contenido !== undefined) {
      if (typeof contenido !== "string" || !contenido.trim()) {
        return res.status(400).json({ error: "El 'contenido' no puede estar vacío." });
      }
      camposActualizar.contenido = contenido.trim();
    }
    if (imagen !== undefined) {
      if (typeof imagen !== "string" || !imagen.trim()) {
        return res.status(400).json({ error: "El campo 'imagen' no puede estar vacío." });
      }
      camposActualizar.imagen = imagen.trim();
    }
    const { data, error } = await actualizarHistoriaBD(idNumero, camposActualizar);
    if (error) {
      return res.status(500).json({ 
        error: "No se pudo actualizar la historia.", 
        detalle: error.message 
      });
    }
    return res.status(200).json({ 
      mensaje: "Historia actualizada correctamente.", 
      historia: data 
    });
  } catch (error) {
    console.error("Error en actualizarHistoria:", error);
    return res.status(500).json({ error: "Error interno al actualizar la historia." });
  }
};

// 4. Eliminar historia (Admin)
export const eliminarHistoria = async (req, res) => {
  try {
    const { id } = req.params;
    // Validación del parámetro ID
    if (!esIdValido(id)) {
      return res.status(400).json({ 
        error: "El ID proporcionado en la URL no es válido. Debe ser un número entero mayor a 0." 
      });
    }
    const idNumero = Number(id);
    // Verificar existencia previa
    const { data: historiaExistente, error: errExist } = await obtenerHistoriaPorIdBD(idNumero);
    if (errExist || !historiaExistente) {
      return res.status(404).json({ 
        error: `No se encontró ninguna historia con el ID ${idNumero} para eliminar.` 
      });
    }
    const { error } = await eliminarHistoriaBD(idNumero);
    if (error) {
      return res.status(500).json({ 
        error: "No se pudo eliminar la historia de la base de datos.", 
        detalle: error.message 
      });
    }
    return res.status(200).json({ 
      mensaje: `La historia con ID ${idNumero} fue eliminada correctamente.` 
    });
  } catch (error) {
    console.error("Error en eliminarHistoria:", error);
    return res.status(500).json({ error: "Error interno al eliminar la historia." });
  }
};