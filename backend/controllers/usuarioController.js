import { supabase } from "../config/supabase.js";
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
        // CAMPOS PERMITIDOS PARA ACTUALIZAR (Incluyendo is_active)
        // El rol NO está aquí a propósito: se cambia solo con cambiarRolUsuario (PATCH /:id/rol)
        const camposPermitidos = [
            "nombre",
            "apellido",
            // "correo" no se puede cambiar: es el que se verificó con el código al registrarse
            "telefono",
            "cedula",
            "edad",
            "peso",
            "altura",
            "municipio",
            "direccion",
            "is_active"
        ];
        const campos = {};
        const esAdmin = req.usuario?.rol === "admin";
        // TOMAR SOLAMENTE LOS CAMPOS ENVIADOS
        for (const campo of camposPermitidos) {
            // Activar o desactivar cuentas es solo del administrador
            if (campo === "is_active" && !esAdmin) continue;
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
        if (campos.municipio !== undefined) {
            campos.municipio = String(campos.municipio).trim();
        }
        if (campos.direccion !== undefined) {
            campos.direccion = String(campos.direccion).trim();
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

// CAMBIAR ESTADO DE USUARIO (ACTIVAR / DESACTIVAR) - ESPECÍFICO PARA ADMIN
export const cambiarEstadoUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }

        const { is_active } = req.body;
        if (is_active === undefined || typeof is_active !== "boolean") {
            return res.status(400).json({
                mensaje: "Debes especificar un valor booleano para is_active (true o false)"
            });
        }

        const { data, error } = await actualizarUsuario(Number(id), { is_active });

        if (error) {
            console.error("Error al cambiar estado de usuario:", error);
            return res.status(500).json({
                mensaje: "No fue posible actualizar el estado del usuario",
                error: error.message
            });
        }

        if (!data) {
            return res.status(404).json({
                mensaje: "Usuario no encontrado"
            });
        }

        return res.status(200).json({
            mensaje: `La cuenta ha sido ${is_active ? "activada" : "desactivada"} exitosamente`,
            usuario: data
        });
    } catch (error) {
        console.error("Error inesperado al cambiar estado:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};

// CAMBIAR ROL DE USUARIO - ESPECÍFICO PARA ADMIN (PATCH /usuarios/:id/rol)
// Body: { "rol": "admin" }  o  { "rol": "cliente" }
const ROLES_VALIDOS = ["admin", "cliente"];

export const cambiarRolUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        if (!id || isNaN(id)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }

        const rolNuevo = typeof req.body.rol === "string"
            ? req.body.rol.trim().toLowerCase()
            : "";
        if (!ROLES_VALIDOS.includes(rolNuevo)) {
            return res.status(400).json({
                mensaje: `El rol debe ser uno de estos: ${ROLES_VALIDOS.join(", ")}`
            });
        }

        const idObjetivo = Number(id);

        // Un administrador no puede cambiarse el rol a sí mismo
        if (idObjetivo === Number(req.usuario?.id_usuario)) {
            return res.status(400).json({
                mensaje: "No puedes cambiar tu propio rol"
            });
        }

        const { data: usuario, error: errorBusqueda } = await obtenerUsuarioPorId(idObjetivo);
        if (errorBusqueda || !usuario) {
            return res.status(404).json({
                mensaje: "Usuario no encontrado"
            });
        }

        if (usuario.rol === rolNuevo) {
            return res.status(200).json({
                mensaje: `El usuario ya tiene el rol ${rolNuevo}`,
                usuario: { id_usuario: idObjetivo, rol: rolNuevo }
            });
        }

        // Nunca puede quedar el sistema sin administradores
        if (usuario.rol === "admin" && rolNuevo !== "admin") {
            const { count, error: errorConteo } = await supabase
                .from("usuarios")
                .select("id_usuario", { count: "exact", head: true })
                .eq("rol", "admin");

            if (errorConteo) {
                console.error("Error al contar administradores:", errorConteo);
                return res.status(500).json({
                    mensaje: "No fue posible validar los administradores"
                });
            }
            if ((count ?? 0) <= 1) {
                return res.status(400).json({
                    mensaje: "No se puede quitar el rol al único administrador"
                });
            }
        }

        const { data, error } = await actualizarUsuario(idObjetivo, { rol: rolNuevo });

        if (error) {
            console.error("Error al cambiar rol de usuario:", error);
            return res.status(500).json({
                mensaje: "No fue posible actualizar el rol del usuario",
                error: error.message
            });
        }

        if (!data) {
            return res.status(404).json({
                mensaje: "Usuario no encontrado"
            });
        }

        return res.status(200).json({
            mensaje: `El rol del usuario ahora es ${rolNuevo}`,
            usuario: data
        });
    } catch (error) {
        console.error("Error inesperado al cambiar rol:", error);
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