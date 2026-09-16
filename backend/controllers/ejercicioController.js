// Importamos las funciones del modelo de ejercicios
import {
    obtenerTodosEjercicios,
    obtenerEjercicioPorId,
    obtenerEjerciciosPorCategoria,
    crearEjercicio,
    actualizarEjercicio,
    eliminarEjercicio,
    agregarCategoriasEjercicio,
    actualizarCategoriasEjercicio
} from "../models/ejercicioModel.js";
// IMPORTAMOS SUPABASE PARA VALIDAR CATEGORIAS
import { supabase } from "../config/supabase.js";
// OBTENER TODOS LOS EJERCICIOS
export const listarEjercicios = async (req, res) => {
    try {
        // Llamo al modelo para traerme todos los ejercicios registrados
        const { data, error } = await obtenerTodosEjercicios();
        // Si hay error en la consulta, devuelvo un 500
        if (error) {
            console.error("Error al obtener ejercicios:", error);
            return res.status(500).json({
                mensaje: "Error al obtener los ejercicios",
                error: error.message
            });
        }
        // Si hay error en la consulta, devuelvo un 500
        return res.status(200).json({
            mensaje: "Ejercicios obtenidos correctamente",
            cantidad: data.length,
            ejercicios: data
        });
    } catch (error) {
        // Retorno la lista completa con la cantidad total
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// OBTENER EJERCICIO POR ID
export const obtenerEjercicio = async (req, res) => {
    try {
        const { id } = req.params;
        // Valido que el ID sea un número válido antes de buscarlo
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del ejercicio debe ser un número válido"
            });
        }
        const { data, error } = await obtenerEjercicioPorId(Number(id));
        // Si no lo encuentro o falla, devuelvo un 404
        if (error || !data) {
            console.error("Error al obtener ejercicio:", error);
            return res.status(404).json({
                mensaje: "Ejercicio no encontrado"
            });
        }
        return res.status(200).json({
            mensaje: "Ejercicio obtenido correctamente",
            ejercicio: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// OBTENER EJERCICIOS POR CATEGORÍA
export const listarEjerciciosPorCategoria = async (req, res) => {
    try {
        const { idCategoria } = req.params;
        // Compruebo que el ID de la categoría sea numérico
        if (!idCategoria || isNaN(idCategoria)) {
            return res.status(400).json({
                mensaje: "El ID de la categoría debe ser un número válido"
            });
        }
        const { data, error } = await obtenerEjerciciosPorCategoria(
            Number(idCategoria)
        );
        if (error) {
            console.error("Error al obtener ejercicios por categoría:", error);
            return res.status(500).json({
                mensaje: "Error al obtener los ejercicios de la categoría",
                error: error.message
            });
        }
        // Mapeo los datos para extraer únicamente la información de los ejercicios
        const ejercicios = data
            .map(item => item.ejercicios)
            .filter(ejercicio => ejercicio !== null);
        return res.status(200).json({
            mensaje: "Ejercicios de la categoría obtenidos correctamente",
            cantidad: ejercicios.length,
            ejercicios: ejercicios
        });
    } catch (error) {
        console.error("Error inesperado al obtener ejercicios por categoría:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// CREAR EJERCICIO
export const registrarEjercicio = async (req, res) => {
    try {
        const {
            nombre,
            maquina,
            instrucciones,
            descripcion,
            beneficios,
            rango_movimiento,
            respiracion,
            ritmo_movimiento
        } = req.body;
        let categorias = req.body.categorias;
        // Si las categorías me llegan como String (por ejemplo desde form-data), las parseo o las separo por comas
        if (typeof categorias === "string") {
            try {
                categorias = JSON.parse(categorias);
            } catch {
                categorias = categorias.split(",").map(item => item.trim());
            }
        }
        // Si me mandan un solo valor suelto, lo convierto en un arreglo
        if (!Array.isArray(categorias) && categorias !== undefined) {
            categorias = [categorias];
        }
        // Obtengo las URLs de las imágenes y GIFs (ya sea desde Multer o directamente del body)
        const urlImagen = req.files?.imagen ? req.files.imagen[0].path : (req.body.imagen || null);
        const urlGif = req.files?.gif_url ? req.files.gif_url[0].path : (req.body.gif_url || null);
        
        // Valido que no me falte ningún campo obligatorio
        if (
            !nombre ||
            !maquina ||
            !descripcion ||
            !instrucciones ||
            !beneficios ||
            !rango_movimiento ||
            !respiracion ||
            !ritmo_movimiento ||
            !urlImagen ||
            !urlGif
        ) {
            return res.status(400).json({
                mensaje:
                    "Los campos nombre, máquina, descripción, instrucciones, beneficios, rango de movimiento, respiración, ritmo del movimiento, imagen y gif_url son obligatorios"
            });
        }
        // Limpio los espacios en blanco de los textos
        const nombreLimpio = nombre.trim();
        const maquinaLimpia = maquina.trim();
        const descripcionLimpia = descripcion.trim();
        const instruccionesLimpias = instrucciones.trim();
        const beneficiosLimpios = beneficios.trim();
        const rangoMovimientoLimpio = rango_movimiento.trim();
        const respiracionLimpia = respiracion.trim();
        const ritmoMovimientoLimpio = ritmo_movimiento.trim();
        if (nombreLimpio.length < 2) {
            return res.status(400).json({
                mensaje: "El nombre del ejercicio no es válido"
            });
        }
        // Me aseguro de que el ejercicio tenga al menos una categoría asignada
        if (!Array.isArray(categorias) || categorias.length === 0) {
            return res.status(400).json({
                mensaje: "El ejercicio debe tener al menos una categoría"
            });
        }
        const categoriasNumericas = categorias.map(Number);
        // Valido que los IDs de las categorías sean números enteros positivos
        if (
            categoriasNumericas.some(
                id => !Number.isInteger(id) || id <= 0
            )
        ) {
            return res.status(400).json({
                mensaje: "Las categorías deben contener IDs numéricos válidos"
            });
        }
        // Elimino categorías duplicadas por si acaso
        const categoriasUnicas = [...new Set(categoriasNumericas)];
        // Consulto en Supabase para verificar que las categorías realmente existan
        const { data: categoriasExistentes, error: errorCategorias } =
            await supabase
                .from("categoria_ejercicios")
                .select("id_categoria")
                .in("id_categoria", categoriasUnicas);
        if (errorCategorias) {
            console.error("Error al verificar categorías:", errorCategorias);
            return res.status(500).json({
                mensaje: "No fue posible verificar las categorías",
                error: errorCategorias.message
            });
        }
        if (categoriasExistentes.length !== categoriasUnicas.length) {
            return res.status(400).json({
                mensaje: "Una o más categorías no existen"
            });
        }
        // Armo el objeto con el nuevo ejercicio limpio
        const nuevoEjercicio = {
            nombre: nombreLimpio,
            maquina: maquinaLimpia,
            imagen: urlImagen,
            gif_url: urlGif,
            instrucciones: instruccionesLimpias,
            descripcion: descripcionLimpia,
            beneficios: beneficiosLimpios,
            rango_movimiento: rangoMovimientoLimpio,
            respiracion: respiracionLimpia,
            ritmo_movimiento: ritmoMovimientoLimpio
        };
        // GUARDAR EJERCICIO EN LA BASE DE DATOS
        const { data: ejercicio, error } = await crearEjercicio(nuevoEjercicio);
        if (error) {
            console.error("Error al crear ejercicio:", error);
            return res.status(500).json({
                mensaje: "No fue posible crear el ejercicio",
                error: error.message
            });
        }
        // Asocio las categorías al ejercicio recién creado
        const { data: relaciones, error: errorRelaciones } =
            await agregarCategoriasEjercicio(
                ejercicio.id_ejercicio,
                categoriasUnicas
            );
        // Si falla la relación con las categorías, hago un rollback eliminando el ejercicio que creé
        if (errorRelaciones) {
            console.error("Error al guardar categorías:", errorRelaciones);
            await eliminarEjercicio(ejercicio.id_ejercicio);
            return res.status(500).json({
                mensaje: "No fue posible asociar las categorías al ejercicio"
            });
        }
        return res.status(201).json({
            mensaje: "Ejercicio creado correctamente",
            ejercicio: ejercicio,
            categorias: relaciones
        });
    } catch (error) {
        console.error("Error inesperado al registrar ejercicio:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// ACTUALIZAR EJERCICIO
export const editarEjercicio = async (req, res) => {
    try {
        const { id } = req.params;
        // Valido que el ID que quiero actualizar sea un número
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del ejercicio debe ser un número válido"
            });
        }
        const camposPermitidos = [
            "nombre",
            "maquina",
            "imagen",
            "gif_url",
            "instrucciones",
            "descripcion",
            "beneficios",
            "rango_movimiento",
            "respiracion",
            "ritmo_movimiento"
        ];
        const campos = {};
        // Verifico qué campos me mandaron para actualizar dinámicamente
        for (const campo of camposPermitidos) {
            if (req.body[campo] !== undefined) {
                campos[campo] = req.body[campo];
            }
        }
        // Si subí nuevos archivos por Multer, actualizo sus rutas
        if (req.files?.imagen) {
        campos.imagen = req.files.imagen[0].path;
        }
        if (req.files?.gif_url) {
            campos.gif_url = req.files.gif_url[0].path;
        }  
        let categorias = req.body.categorias;
        if (typeof categorias === "string") {
            try {
                categorias = JSON.parse(categorias);
            } catch {
                categorias = categorias.split(",").map(item => item.trim());
            }
        }
        // Si no me mandaron nada para cambiar, devuelvo un error 400
        if (
            Object.keys(campos).length === 0 &&
            categorias === undefined
        ) {
            return res.status(400).json({
                mensaje: "No se proporcionaron datos para actualizar"
            });
        }
        const camposTexto = [
            "nombre",
            "maquina",
            "imagen",
            "gif_url",
            "instrucciones",
            "descripcion",
            "beneficios",
            "rango_movimiento",
            "respiracion",
            "ritmo_movimiento"
        ];
        // Les quito los espacios a los campos de texto si vienen definidos
        for (const campo of camposTexto) {
            if (campos[campo] !== undefined && campos[campo] !== null) {
                campos[campo] = String(campos[campo]).trim();
            }
        }
        let ejercicioActualizado = null;
        if (Object.keys(campos).length > 0) {
            const { data, error } = await actualizarEjercicio(
                Number(id),
                campos
            );
            if (error) {
                console.error("Error al actualizar ejercicio:", error);
                return res.status(500).json({
                    mensaje: "No fue posible actualizar el ejercicio",
                    error: error.message
                });
            }
            ejercicioActualizado = data;
        }
        let categoriasActualizadas = null;
        if (categorias !== undefined) {
            if (!Array.isArray(categorias)) {
                return res.status(400).json({
                    mensaje: "Las categorías deben enviarse como un arreglo"
                });
            }
            const categoriasNumericas = categorias.map(Number);
            if (
                categoriasNumericas.some(
                    idCat => !Number.isInteger(idCat) || idCat <= 0
                )
            ) {
                return res.status(400).json({
                    mensaje: "Las categorías contienen IDs inválidos"
                });
            }
            const categoriasUnicas = [...new Set(categoriasNumericas)];
            // Compruebo que las nuevas categorías existan antes de actualizar la relación
            const { data: categoriasExistentes, error: errorCategorias } =
                await supabase
                    .from("categoria_ejercicios")
                    .select("id_categoria")
                    .in("id_categoria", categoriasUnicas);
            if (errorCategorias) {
                return res.status(500).json({
                    mensaje: "No fue posible verificar las categorías",
                    error: errorCategorias.message
                });
            }
            if (categoriasExistentes.length !== categoriasUnicas.length) {
                return res.status(400).json({
                    mensaje: "Una o más categorías no existen"
                });
            }
            const { data, error } = await actualizarCategoriasEjercicio(
                Number(id),
                categoriasUnicas
            );
            if (error) {
                console.error("Error al actualizar categorías:", error);
                return res.status(500).json({
                    mensaje: "No fue posible actualizar las categorías del ejercicio",
                    error: error.message
                });
            }
            categoriasActualizadas = data;
        }
        const respuesta = {
            mensaje: "Ejercicio actualizado correctamente"
        };
        if (ejercicioActualizado !== null) {
            respuesta.ejercicio = ejercicioActualizado;
        }
        if (categoriasActualizadas !== null) {
            respuesta.categorias = categoriasActualizadas;
        }
        return res.status(200).json(respuesta);
    } catch (error) {
        console.error("Error inesperado al actualizar ejercicio:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor",
            error: error.message
        });
    }
};
// ELIMINAR EJERCICIO
export const borrarEjercicio = async (req, res) => {
    try {
        const { id } = req.params;
        // Valido que el ID sea numérico antes de proceder a borrar
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del ejercicio debe ser un número válido"
            });
        }
        // Ejecuto la función para eliminar el ejercicio de mi base de datos
        const { data, error } = await eliminarEjercicio(Number(id));
        if (error) {
            console.error("Error al eliminar ejercicio:", error);
            return res.status(500).json({
                mensaje: "No fue posible eliminar el ejercicio",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Ejercicio eliminado correctamente",
            ejercicio: {
                id_ejercicio: data.id_ejercicio,
                nombre: data.nombre
            }
        });
    } catch (error) {
        console.error("Error inesperado al eliminar ejercicio:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};