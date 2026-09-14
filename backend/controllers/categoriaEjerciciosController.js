// Importamos las funciones del modelo
import {
    obtenerTodasCategorias,
    obtenerCategoriaPorId,
    crearCategoria,
    actualizarCategoria,
    eliminarCategoria,
    verificarEjerciciosCategoria
} from "../models/categoriaEjerciciosModel.js";

// Importamos Supabase
import { supabase } from "../config/supabase.js";
// OBTENER TODAS LAS CATEGORÍAS
export const listarCategorias = async (req, res) => {
    try {
        const { data, error } =
            await obtenerTodasCategorias();
        if (error) {
            console.error(
                "Error al obtener categorías:",
                error
            );
            return res.status(500).json({
                mensaje: "Error al obtener las categorías",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Categorías obtenidas correctamente",
            cantidad: data.length,
            categorias: data
        });
    } catch (error) {
        console.error(
            "Error inesperado:",
            error
        );
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// OBTENER CATEGORÍA POR ID
export const obtenerCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        // VALIDAR ID
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje:
                    "El ID de la categoría debe ser un número válido"
            });
        }
        const { data, error } =
            await obtenerCategoriaPorId(Number(id));
        if (error || !data) {
            console.error(
                "Error al obtener categoría:",
                error
            );
            return res.status(404).json({
                mensaje: "Categoría no encontrada"
            });
        }
        return res.status(200).json({
            mensaje: "Categoría obtenida correctamente",
            categoria: data
        });
    } catch (error) {
        console.error(
            "Error inesperado:",
            error
        );
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// CREAR CATEGORÍA
export const registrarCategoria = async (req, res) => {
    try {
        const { nombre } = req.body;
        // VALIDAR CAMPO
        if (!nombre) {
            return res.status(400).json({
                mensaje:
                    "El nombre de la categoría es obligatorio"
            });
        }
        // LIMPIAR NOMBRE
        const nombreLimpio = nombre.trim();
        // VALIDAR QUE NO QUEDE VACÍO
        if (nombreLimpio.length === 0) {
            return res.status(400).json({
                mensaje:
                    "El nombre de la categoría no puede estar vacío"
            });
        }
        // VALIDAR LONGITUD
        if (nombreLimpio.length > 100) {
            return res.status(400).json({
                mensaje:
                    "El nombre de la categoría no puede superar los 100 caracteres"
            });
        }
        // CREAR CATEGORÍA
        const { data, error } =
            await crearCategoria(nombreLimpio);
        if (error) {
            console.error(
                "Error al crear categoría:",
                error
            );
            // CATEGORÍA DUPLICADA
            if (error.code === "23505") {
                return res.status(409).json({
                    mensaje:
                        "Ya existe una categoría con ese nombre"
                });
            }
            return res.status(500).json({
                mensaje:
                    "No fue posible crear la categoría",
                error: error.message
            });
        }
        return res.status(201).json({
            mensaje:
                "Categoría creada correctamente",
            categoria: data
        });
    } catch (error) {
        console.error(
            "Error inesperado al crear categoría:",
            error
        );
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// ACTUALIZAR CATEGORÍA
export const editarCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre } = req.body;
        // VALIDAR ID
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje:
                    "El ID de la categoría debe ser un número válido"
            });
        }
        // VALIDAR NOMBRE
        if (!nombre) {
            return res.status(400).json({
                mensaje:
                    "El nombre de la categoría es obligatorio"
            });
        }
        const nombreLimpio = nombre.trim();
        if (nombreLimpio.length === 0) {
            return res.status(400).json({
                mensaje:
                    "El nombre de la categoría no puede estar vacío"
            });
        }
        if (nombreLimpio.length > 100) {
            return res.status(400).json({
                mensaje:
                    "El nombre de la categoría no puede superar los 100 caracteres"
            });
        }
        // ACTUALIZAR
        const { data, error } =
            await actualizarCategoria(
                Number(id),
                nombreLimpio
            );
        if (error) {
            console.error(
                "Error al actualizar categoría:",
                error
            );
            // NOMBRE DUPLICADO
            if (error.code === "23505") {
                return res.status(409).json({
                    mensaje:
                        "Ya existe una categoría con ese nombre"
                });
            }
            return res.status(500).json({
                mensaje:
                    "No fue posible actualizar la categoría",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje:
                "Categoría actualizada correctamente",
            categoria: data
        });
    } catch (error) {
        console.error(
            "Error inesperado al actualizar categoría:",
            error
        );
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// ELIMINAR CATEGORÍA
export const borrarCategoria = async (req, res) => {
    try {
        const { id } = req.params;
        // VALIDAR ID
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje:
                    "El ID de la categoría debe ser un número válido"
            });
        }
        const idCategoria = Number(id);
        // VERIFICAR QUE LA CATEGORÍA EXISTA
        const {
            data: categoria,
            error: errorCategoria
        } = await obtenerCategoriaPorId(idCategoria);
        if (errorCategoria || !categoria) {
            return res.status(404).json({
                mensaje:
                    "Categoría no encontrada"
            });
        }
        // BUSCAR EJERCICIOS DE LA CATEGORÍA
        const {
            data: ejerciciosRelacionados,
            error: errorEjercicios
        } = await verificarEjerciciosCategoria(
            idCategoria
        );
        if (errorEjercicios) {
            console.error(
                "Error al verificar ejercicios de la categoría:",
                errorEjercicios
            );
            return res.status(500).json({
                mensaje:
                    "No fue posible verificar los ejercicios asociados",
                error:
                    errorEjercicios.message
            });
        }
        // VERIFICAR SI ALGÚN EJERCICIO SOLO TIENE
        // ESTA CATEGORÍA
        const ejercicioSinOtraCategoria =
            ejerciciosRelacionados.find(
                relacion => {
                    const ejercicio =
                        relacion.ejercicios;
                    if (!ejercicio) {
                        return false;
                    }
                    const categorias =
                        ejercicio.ejercicio_categoria || [];
                    return categorias.length === 1;
                }
            );
        // NO PERMITIR ELIMINACIÓN
        if (ejercicioSinOtraCategoria) {
            const ejercicio =
                ejercicioSinOtraCategoria.ejercicios;
            return res.status(409).json({
                mensaje:
                    "No se puede eliminar la categoría porque existe un ejercicio que solo tiene esta categoría",
                ejercicio: {
                    id_ejercicio:
                        ejercicio.id_ejercicio,
                    nombre:
                        ejercicio.nombre
                }
            });
        }
        // ELIMINAR LAS RELACIONES
        const {
            error: errorRelaciones
        } = await supabase
            .from("ejercicio_categoria")
            .delete()
            .eq("id_categoria", idCategoria);
        if (errorRelaciones) {
            console.error(
                "Error al eliminar relaciones de la categoría:",
                errorRelaciones
            );
            return res.status(500).json({
                mensaje:
                    "No fue posible eliminar las relaciones de la categoría",
                error:
                    errorRelaciones.message
            });
        }
        // ELIMINAR LA CATEGORÍA
        const {
            data,
            error
        } = await eliminarCategoria(
            idCategoria
        );
        if (error) {
            console.error(
                "Error al eliminar categoría:",
                error
            );
            return res.status(500).json({
                mensaje:
                    "No fue posible eliminar la categoría",
                error:
                    error.message
            });
        }
        // RESPUESTA
        return res.status(200).json({
            mensaje:
                "Categoría eliminada correctamente",
            categoria: {
                id_categoria:
                    data.id_categoria,
                nombre:
                    data.nombre
            }
        });
} catch (error) {
    console.log("ERROR AL ELIMINAR CATEGORÍA:");
    console.log(error);
    return res.status(500).json({
        mensaje: "Error interno del servidor",
        error: error.message
    });
}
};