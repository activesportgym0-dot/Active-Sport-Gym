// Importamos las funciones del modelo de perfil
import {
    obtenerPerfilPorUsuario,
    actualizarDatosUsuario,
    actualizarFotoPerfil
} from "../models/perfilModel.js";

// OBTENER PERFIL COMPLETO
export const obtenerPerfil = async (req, res) => {
    try {
        const { id_usuario } = req.params;
        // VALIDAR ID DEL USUARIO
        if (!id_usuario || isNaN(id_usuario)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }
        // OBTENER DATOS DEL USUARIO + PERFIL
        const { data, error } =
            await obtenerPerfilPorUsuario(Number(id_usuario));
        // VERIFICAR SI EXISTE
        if (error || !data) {
            console.error(
                "Error al obtener perfil:",
                error
            );
            return res.status(404).json({
                mensaje: "Perfil no encontrado"
            });
        }
        // RESPUESTA
        return res.status(200).json({
            mensaje: "Perfil obtenido correctamente",
            perfil: data
        });
    } catch (error) {
        console.error(
            "Error inesperado al obtener perfil:",
            error
        );
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};

// EDITAR PERFIL COMPLETO (DATOS DE TEXTO)
export const editarPerfil = async (req, res) => {
    try {
        const { id_usuario } = req.params;
        // VALIDAR ID
        if (!id_usuario || isNaN(id_usuario)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }
        const id = Number(id_usuario);
        // CAMPOS QUE PERTENECEN A USUARIOS
        const camposPermitidos = [
            "nombre",
            "apellido",
            "correo",
            "telefono",
            "cedula",
            "edad",
            "peso",
            "altura"
        ];
        const camposUsuario = {};
        // TOMAR SOLAMENTE LOS CAMPOS PERMITIDOS
        for (const campo of camposPermitidos) {
            if (req.body[campo] !== undefined) {
                camposUsuario[campo] = req.body[campo];
            }
        }
        // FOTO DEL PERFIL
        const fotoPerfil = req.body.foto_perfil;
        // VERIFICA QUE HAYA ALGO PARA ACTUALIZAR
        if (
            Object.keys(camposUsuario).length === 0 &&
            fotoPerfil === undefined
        ) {
            return res.status(400).json({
                mensaje:
                    "No se proporcionaron datos para actualizar"
            });
        }
        // LIMPIAR DATOS DE TEXTO
        if (camposUsuario.nombre !== undefined) {
            camposUsuario.nombre =
                String(camposUsuario.nombre).trim();
        }
        if (camposUsuario.apellido !== undefined) {
            camposUsuario.apellido =
                String(camposUsuario.apellido).trim();
        }
        if (camposUsuario.correo !== undefined) {
            camposUsuario.correo =
                String(camposUsuario.correo)
                    .trim()
                    .toLowerCase();
        }
        if (camposUsuario.telefono !== undefined) {
            camposUsuario.telefono =
                String(camposUsuario.telefono).trim();
        }
        // VALIDAR CORREO
        if (camposUsuario.correo !== undefined) {
            const expresionCorreo =
                /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!expresionCorreo.test(
                camposUsuario.correo
            )) {
                return res.status(400).json({
                    mensaje:
                        "El correo electrónico no tiene un formato válido"
                });
            }
        }
        // VALIDAR TELÉFONO
        if (camposUsuario.telefono !== undefined) {
            if (!/^\d{10}$/.test(
                camposUsuario.telefono
            )) {
                return res.status(400).json({
                    mensaje:
                        "El teléfono debe contener exactamente 10 números"
                });
            }
        }
        // VALIDAR CÉDULA
        if (camposUsuario.cedula !== undefined) {
            camposUsuario.cedula =
                String(camposUsuario.cedula).trim();
            if (!/^\d{6,20}$/.test(
                camposUsuario.cedula
            )) {
                return res.status(400).json({
                    mensaje:
                        "La cédula debe contener entre 6 y 20 números"
                });
            }
        }
        // VALIDAR EDAD
        if (camposUsuario.edad !== undefined) {
            camposUsuario.edad =
                Number(camposUsuario.edad);
            if (
                !Number.isInteger(camposUsuario.edad) ||
                camposUsuario.edad < 1 ||
                camposUsuario.edad > 120
            ) {
                return res.status(400).json({
                    mensaje: "La edad no es válida"
                });
            }
        }
        // VALIDAR PESO
        if (camposUsuario.peso !== undefined) {
            camposUsuario.peso =
                Number(camposUsuario.peso);
            if (
                !Number.isFinite(camposUsuario.peso) ||
                camposUsuario.peso <= 0 ||
                camposUsuario.peso > 500
            ) {
                return res.status(400).json({
                    mensaje: "El peso no es válido"
                });
            }
        }
        // VALIDAR ALTURA
        if (camposUsuario.altura !== undefined) {
            camposUsuario.altura =
                Number(camposUsuario.altura);
            if (
                !Number.isFinite(camposUsuario.altura) ||
                camposUsuario.altura <= 0 ||
                camposUsuario.altura > 3
            ) {
                return res.status(400).json({
                    mensaje: "La altura no es válida"
                });
            }
        }
        // ACTUALIZAR DATOS DEL USUARIO
        let usuarioActualizado = null;
        if (Object.keys(camposUsuario).length > 0) {
            const { data, error } =
                await actualizarDatosUsuario(
                    id,
                    camposUsuario
                );
            if (error) {
                console.error(
                    "Error al actualizar usuario:",
                    error
                );
                // DATO DUPLICADO
                if (error.code === "23505") {
                    return res.status(409).json({
                        mensaje:
                            "El correo, teléfono o cédula ya están registrados"
                    });
                }
                return res.status(500).json({
                    mensaje:
                        "No fue posible actualizar los datos del usuario",
                    error: error.message
                });
            }
            usuarioActualizado = data;
        }
        // ACTUALIZAR FOTO DEL PERFIL (POR URL DE TEXTO)
        let perfilActualizado = null;
        if (fotoPerfil !== undefined) {
            const { data, error } =
                await actualizarFotoPerfil(
                    id,
                    fotoPerfil
                );
            if (error) {
                console.error(
                    "Error al actualizar foto:",
                    error
                );
                return res.status(500).json({
                    mensaje:
                        "No fue posible actualizar la foto del perfil",
                    error: error.message
                });
            }
            perfilActualizado = data;
        }
        // RESPUESTA
        const respuesta = {
            mensaje: "Perfil actualizado correctamente"
        };
        if (usuarioActualizado !== null) {
            respuesta.usuario = usuarioActualizado;
        }
        if (perfilActualizado !== null) {
            respuesta.perfil = perfilActualizado;
        }
        return res.status(200).json(respuesta);
    } catch (error) {
        console.error(
            "Error inesperado al actualizar perfil:",
            error
        );
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};

// CAMBIAR FOTO DE PERFIL CON ARCHIVO CLOUDINARY
export const cambiarFotoPerfil = async (req, res) => {
    try {
        const { id_usuario } = req.params;

        if (!id_usuario || isNaN(id_usuario)) {
            return res.status(400).json({
                mensaje: "El ID del usuario debe ser un número válido"
            });
        }

        if (!req.file) {
            return res.status(400).json({
                mensaje: "Debes adjuntar una imagen"
            });
        }

        // req.file.path contiene la URL pública asignada por Cloudinary
        const urlImagen = req.file.path;

        const { data, error } = await actualizarFotoPerfil(
            Number(id_usuario),
            urlImagen
        );

        if (error) {
            console.error("Error al actualizar foto de perfil en BD:", error);
            return res.status(500).json({
                mensaje: "No fue posible guardar la foto de perfil en la base de datos"
            });
        }

        return res.status(200).json({
            mensaje: "Foto de perfil actualizada correctamente",
            foto_perfil: urlImagen,
            perfil: data
        });
    } catch (error) {
        console.error("Error inesperado en cambiarFotoPerfil:", error);
        return res.status(500).json({
            mensaje: "Error interno del servidor"
        });
    }
};