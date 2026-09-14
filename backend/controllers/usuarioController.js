// Importamos las funciones del modelo de usuarios
import {
    obtenerTodos,
    obtenerUsuarioPorId,
    actualizarUsuario,
    eliminarUsuario
} from "../models/usuarioModel.js";

// OBTENER TODOS LOS USUARIOS
export const listarUsuarios = async (req, res) => {
    try {
        const { data, error } = await obtenerTodos();
        if (error) {
            console.error("Error al obtener usuarios:", error);
            return res.status(500).json({
                mensaje: "Error al obtener los usuarios",
                error: error.message
            });
        }
        return res.status(200).json({
            mensaje: "Usuarios obtenidos correctamente",
            cantidad: data.length,
            usuarios: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// OBTENER USUARIO POR ID
export const obtenerUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        // Validamos que el ID sea un número
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }
        const { data, error } = await obtenerUsuarioPorId(Number(id));
        if (error || !data) {
            console.error("Error al obtener usuario:", error);
            return res.status(404).json({
                mensaje: "Usuario no encontrado"
            });
        }
        return res.status(200).json({
            mensaje: "Usuario obtenido correctamente",
            usuario: data
        });
    } catch (error) {
        console.error("Error inesperado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// ACTUALIZAR USUARIO
export const editarUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        // VALIDAR ID
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }
        // CAMPOS PERMITIDOS PARA ACTUALIZAR
        const camposPermitidos = [
            "nombre",
            "apellido",
            "correo",
            "telefono",
            "cedula",
            "edad",
            "peso",
            "altura",
        ];
        const campos = {};
        // TOMAR SOLAMENTE LOS CAMPOS ENVIADOS
        for (const campo of camposPermitidos) {
            if (req.body[campo] !== undefined) {
                campos[campo] = req.body[campo];
            }
        }
        // VERIFICAR QUE HAYA ALGO PARA ACTUALIZAR
        if (Object.keys(campos).length === 0) {
            return res.status(400).json({
                mensaje: "No se proporcionaron datos para actualizar"
            });
        }
        // LIMPIAR CAMPOS DE TEXTO
        if (campos.nombre !== undefined) {
            campos.nombre = campos.nombre.trim();
        }
        if (campos.apellido !== undefined) {
            campos.apellido = campos.apellido.trim();
        }
        if (campos.correo !== undefined) {
            campos.correo = campos.correo.trim().toLowerCase();
        }
        if (campos.telefono !== undefined) {
            campos.telefono = campos.telefono.trim();
        }
        // VALIDAR CORREO
        if (campos.correo !== undefined) {
            const expresionCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!expresionCorreo.test(campos.correo)) {
                return res.status(400).json({
                    mensaje: "El correo electrónico no tiene un formato válido"
                });
            }
        }
        // VALIDAR TELÉFONO
        if (campos.telefono !== undefined) {
            if (!/^\d{10}$/.test(campos.telefono)) {
                return res.status(400).json({
                    mensaje: "El teléfono debe contener exactamente 10 números"
                });
            }
        }
        // VALIDAR CÉDULA
        if (campos.cedula !== undefined) {
            campos.cedula = Number(campos.cedula);
            if (!Number.isInteger(campos.cedula) || campos.cedula <= 0) {
                return res.status(400).json({
                    mensaje: "La cédula debe ser un número entero válido"
                });
            }
        }
        // VALIDAR EDAD
        if (campos.edad !== undefined) {
            campos.edad = Number(campos.edad);
            if (
                !Number.isInteger(campos.edad) ||
                campos.edad < 1 ||
                campos.edad > 120
            ) {
                return res.status(400).json({
                    mensaje: "La edad no es válida"
                });
            }
        }
        // VALIDAR PESO
        if (campos.peso !== undefined) {
            campos.peso = Number(campos.peso);
            if (
                !Number.isFinite(campos.peso) ||
                campos.peso <= 0 ||
                campos.peso > 500
            ) {
                return res.status(400).json({
                    mensaje: "El peso no es válido"
                });
            }
        }
        // VALIDAR ALTURA
        if (campos.altura !== undefined) {
            campos.altura = Number(campos.altura);
            if (
                !Number.isFinite(campos.altura) ||
                campos.altura <= 0 ||
                campos.altura > 3
            ) {
                return res.status(400).json({
                    mensaje: "La altura no es válida"
                });
            }
        }
        // ACTUALIZAR USUARIO EN LA BD
        const { data, error } = await actualizarUsuario(
            Number(id),
            campos
        );
        // MANEJAR ERROR DE BASE DE DATOS
        if (error) {
            console.error("Error al actualizar usuario:", error);
            if (error.code === "23505") {
                return res.status(409).json({
                    mensaje: "El correo, la cédula o el teléfono ya están registrados por otro usuario"
                });
            }
            return res.status(500).json({
                mensaje: "No fue posible actualizar el usuario",
                error: error.message
            });
        }
        // VALIDAR SI EL USUARIO EXISTÍA
        if (!data) {
            return res.status(404).json({
                mensaje: "Usuario no encontrado para actualizar"
            });
        }
        // RESPUESTA EXITOSA
        return res.status(200).json({
            mensaje: "Usuario actualizado correctamente",
            usuario: data
        });
    } catch (error) {
        console.error("Error inesperado al actualizar:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};
// ELIMINAR USUARIO
export const borrarUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        // VALIDAR ID
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }
        // ELIMINAR
        const { data, error } = await eliminarUsuario(
            Number(id)
        );
        if (error) {
            console.error("Error al eliminar usuario:", error);
            return res.status(500).json({
                mensaje: "No fue posible eliminar el usuario",
                error: error.message
            });
        }
        // AGREGAR ESTA VALIDACIÓN
        if (!data) {
            return res.status(404).json({
                mensaje: "Usuario no encontrado para eliminar"
            });
        }
        // RESPUESTA
        return res.status(200).json({
            mensaje: "Usuario eliminado correctamente",
            usuario: data
        });
    } catch (error) {
        console.error("Error inesperado al eliminar:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};