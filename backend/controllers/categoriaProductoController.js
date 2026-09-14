import {
    obtenerCategoriasBD,
    crearCategoriaBD,
    actualizarCategoriaBD,
    eliminarCategoriaBD
} from "../models/categoriaProductoModel.js";

// [CLIENTE / ADMIN] Consultar categorías con Token
export const listarCategorias = async (req, res) => {
    try {
        const { data, error } = await obtenerCategoriasBD();
        if (error) {
            return res.status(500).json({ error: "Error al obtener las categorías", detalle: error.message });
        }
        return res.status(200).json(data || []);
    } catch (error) {
        console.error("Error en listarCategorias:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al listar las categorías" });
    }
};

// [ADMIN] Crear categoría
export const crearCategoria = async (req, res) => {
    try {
        const body = req.body || {};
        const { nombre } = body;

        if (!nombre || typeof nombre !== "string" || nombre.trim() === "") {
            return res.status(400).json({ error: "El nombre de la categoría es obligatorio." });
        }

        const { data, error } = await crearCategoriaBD(nombre.trim());

        if (error) {
            return res.status(500).json({ error: "Error al registrar la categoría", detalle: error.message });
        }

        return res.status(201).json({
            mensaje: "Categoría creada con éxito",
            categoria: data
        });
    } catch (error) {
        console.error("Error en crearCategoria:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al crear la categoría" });
    }
};

// [ADMIN] Actualizar categoría
export const actualizarCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        const id_categoria = Number(id);

        if (!Number.isInteger(id_categoria) || id_categoria <= 0) {
            return res.status(400).json({ error: "El ID de la categoría no es válido" });
        }

        const { nombre } = req.body || {};

        if (!nombre || typeof nombre !== "string" || nombre.trim() === "") {
            return res.status(400).json({ error: "El nombre de la categoría es obligatorio." });
        }

        const { data, error } = await actualizarCategoriaBD(id_categoria, nombre.trim());

        if (error) {
            return res.status(500).json({ error: "Error al actualizar la categoría", detalle: error.message });
        }

        if (!data) {
            return res.status(404).json({ error: "La categoría especificada no existe." });
        }

        return res.status(200).json({
            mensaje: "Categoría actualizada correctamente",
            categoria: data
        });
    } catch (error) {
        console.error("Error en actualizarCategoria:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al actualizar la categoría" });
    }
};

// [ADMIN] Eliminar categoría
export const borrarCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        const id_categoria = Number(id);

        if (!Number.isInteger(id_categoria) || id_categoria <= 0) {
            return res.status(400).json({ error: "El ID de la categoría no es válido" });
        }

        const { data, error } = await eliminarCategoriaBD(id_categoria);

        if (error) {
            return res.status(500).json({ error: "No se puede eliminar la categoría si tiene productos asociados", detalle: error.message });
        }

        if (!data) {
            return res.status(404).json({ error: "La categoría especificada no existe." });
        }

        return res.status(200).json({
            mensaje: "Categoría eliminada con éxito",
            categoria: data
        });
    } catch (error) {
        console.error("Error en borrarCategoria:", error);
        return res.status(500).json({ error: "Ocurrió un error interno al eliminar la categoría" });
    }
};