import {
  obtenerReglasHorariosBD,
  obtenerReglaHorarioPorIdBD,
  crearReglaHorarioBD,
  actualizarReglaHorarioBD,
  eliminarReglaHorarioBD
} from "../models/reglasHorariosModel.js";

// Helper para validar que el ID sea un entero positivo
const esIdValido = (id) => Number.isInteger(Number(id)) && Number(id) > 0;

// 1. Obtener todas las reglas y horarios (Público)
export const obtenerReglasHorarios = async (req, res) => {
  try {
    const { data, error } = await obtenerReglasHorariosBD();
    if (error) {
      return res.status(500).json({ 
        error: "Error al consultar las reglas y horarios.", 
        detalle: error.message 
      });
    }
    return res.status(200).json(data || []);
  } catch (error) {
    console.error("Error en obtenerReglasHorarios:", error);
    return res.status(500).json({ error: "Error interno del servidor." });
  }
};

// 2. Crear una regla u horario (Admin - Todos los campos obligatorios)
export const crearReglaHorario = async (req, res) => {
  try {
    const { tipo, titulo, contenido } = req.body;

    if (!req.body || Object.keys(req.body).length === 0) {
      return res.status(400).json({ 
        error: "El cuerpo de la petición no puede estar vacío." 
      });
    }

    if (!tipo || typeof tipo !== "string" || !tipo.trim()) {
      return res.status(400).json({ 
        error: "El campo 'tipo' es obligatorio y debe ser un texto válido." 
      });
    }

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

    const { data, error } = await crearReglaHorarioBD({
      tipo: tipo.trim(),
      titulo: titulo.trim(),
      contenido: contenido.trim()
    });

    if (error) {
      return res.status(500).json({ 
        error: "No se pudo registrar en la base de datos.", 
        detalle: error.message 
      });
    }

    return res.status(201).json({ 
      mensaje: "Registro creado correctamente.", 
      regla_horario: data 
    });
  } catch (error) {
    console.error("Error en crearReglaHorario:", error);
    return res.status(500).json({ error: "Error interno al crear el registro." });
  }
};

// 3. Actualizar una regla u horario (Admin)
export const actualizarReglaHorario = async (req, res) => {
  try {
    const { id } = req.params;
    const { tipo, titulo, contenido } = req.body;

    if (!esIdValido(id)) {
      return res.status(400).json({ 
        error: "El ID proporcionado en la URL no es válido. Debe ser un número entero mayor a 0." 
      });
    }

    if (!tipo && !titulo && !contenido) {
      return res.status(400).json({ 
        error: "Debes proporcionar al menos un campo ('tipo', 'titulo' o 'contenido') para actualizar." 
      });
    }

    const idNumero = Number(id);

    const { data: registroExistente, error: errExist } = await obtenerReglaHorarioPorIdBD(idNumero);
    if (errExist || !registroExistente) {
      return res.status(404).json({ 
        error: `No se encontró ningún registro con el ID ${idNumero}.` 
      });
    }

    const camposActualizar = {};

    if (tipo !== undefined) {
      if (typeof tipo !== "string" || !tipo.trim()) {
        return res.status(400).json({ error: "El campo 'tipo' no puede estar vacío." });
      }
      camposActualizar.tipo = tipo.trim();
    }

    if (titulo !== undefined) {
      if (typeof titulo !== "string" || !titulo.trim()) {
        return res.status(400).json({ error: "El campo 'titulo' no puede estar vacío." });
      }
      camposActualizar.titulo = titulo.trim();
    }

    if (contenido !== undefined) {
      if (typeof contenido !== "string" || !contenido.trim()) {
        return res.status(400).json({ error: "El campo 'contenido' no puede estar vacío." });
      }
      camposActualizar.contenido = contenido.trim();
    }

    const { data, error } = await actualizarReglaHorarioBD(idNumero, camposActualizar);
    if (error) {
      return res.status(500).json({ 
        error: "No se pudo actualizar el registro.", 
        detalle: error.message 
      });
    }

    return res.status(200).json({ 
      mensaje: "Registro actualizado correctamente.", 
      regla_horario: data 
    });
  } catch (error) {
    console.error("Error en actualizarReglaHorario:", error);
    return res.status(500).json({ error: "Error interno al actualizar el registro." });
  }
};

// 4. Eliminar una regla u horario (Admin)
export const eliminarReglaHorario = async (req, res) => {
  try {
    const { id } = req.params;

    if (!esIdValido(id)) {
      return res.status(400).json({ 
        error: "El ID proporcionado en la URL no es válido. Debe ser un número entero mayor a 0." 
      });
    }

    const idNumero = Number(id);

    const { data: registroExistente, error: errExist } = await obtenerReglaHorarioPorIdBD(idNumero);
    if (errExist || !registroExistente) {
      return res.status(404).json({ 
        error: `No se encontró ningún registro con el ID ${idNumero} para eliminar.` 
      });
    }

    const { error } = await eliminarReglaHorarioBD(idNumero);
    if (error) {
      return res.status(500).json({ 
        error: "No se pudo eliminar el registro de la base de datos.", 
        detalle: error.message 
      });
    }

    return res.status(200).json({ 
      mensaje: `El registro con ID ${idNumero} fue eliminado correctamente.` 
    });
  } catch (error) {
    console.error("Error en eliminarReglaHorario:", error);
    return res.status(500).json({ error: "Error interno al eliminar el registro." });
  }
};