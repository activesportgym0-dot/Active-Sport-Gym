import {
  obtenerUsuarioPorCorreo,
  crearCodigoRecuperacion,
  obtenerCodigoValido,
  marcarCodigoComoUsado,
  actualizarPasswordUsuario
} from "../models/recuperarModel.js";
import bcrypt from "bcrypt";
import { transporter } from "../config/mailer.js";
import { plantillaCodigoRecuperacion } from "../utils/emails/plantillaCodigoRecuperacion.js";
import { plantillaPasswordCambiada } from "../utils/emails/plantillaPasswordCambiada.js";

// 1. SOLICITAR CÓDIGO DE RECUPERACIÓN
export const solicitarCodigo = async (req, res) => {
  try {
    const { correo } = req.body;

    if (!correo) {
      return res.status(400).json({ mensaje: "El correo electrónico es requerido" });
    }

    const correoLimpio = correo.trim().toLowerCase();

    // VERIFICAR SI EL USUARIO EXISTE
    const { data: usuarioResultado, error } = await obtenerUsuarioPorCorreo(correoLimpio);
    const usuario = Array.isArray(usuarioResultado) ? usuarioResultado[0] : usuarioResultado;

    if (error || !usuario) {
      return res.status(404).json({ mensaje: "No existe una cuenta registrada con este correo" });
    }

    // GENERAR CÓDIGO NUMÉRICO DE 6 DÍGITOS
    const codigo = Math.floor(100000 + Math.random() * 900000).toString();

    // GUARDAR CÓDIGO EN LA BD
    const { error: errorGuardar } = await crearCodigoRecuperacion(usuario.id_usuario, codigo);
    if (errorGuardar) {
      console.error("Error al guardar código:", errorGuardar);
      return res.status(500).json({ mensaje: "Error al generar el código de seguridad" });
    }

    // GENERAR CONTENIDO DEL CORREO DESDE LA PLANTILLA
    const contenidoCorreo = plantillaCodigoRecuperacion(usuario.nombre, codigo);

    // ENVIAR EL CORREO ELECTRÓNICO
    await transporter.sendMail({
      from: `"Active Sport Gym" <${process.env.EMAIL_USER}>`,
      to: correoLimpio,
      ...contenidoCorreo
    });

    return res.status(200).json({ mensaje: "Código enviado correctamente a tu correo electrónico" });

  } catch (error) {
    console.error("Error en solicitarCodigo:", error);
    return res.status(500).json({ mensaje: "Error interno al procesar la solicitud" });
  }
};

// 2. VERIFICAR CÓDIGO Y CAMBIAR CONTRASEÑA
export const cambiarContraseñaConCodigo = async (req, res) => {
  try {
    const { correo, codigo, nuevaContraseña, confirmarContraseña } = req.body;

    if (!correo || !codigo || !nuevaContraseña || !confirmarContraseña) {
      return res.status(400).json({ mensaje: "Todos los campos son obligatorios" });
    }

    if (nuevaContraseña !== confirmarContraseña) {
      return res.status(400).json({ mensaje: "Las contraseñas ingresadas no coinciden" });
    }

    if (nuevaContraseña.length < 6) {
      return res.status(400).json({ mensaje: "La contraseña debe tener un mínimo de 6 caracteres" });
    }

    const correoLimpio = correo.trim().toLowerCase();

    // OBTENER USUARIO DESDE LA BD
    const { data: usuarioResultado } = await obtenerUsuarioPorCorreo(correoLimpio);
    const usuario = Array.isArray(usuarioResultado) ? usuarioResultado[0] : usuarioResultado;

    if (!usuario) {
      return res.status(404).json({ mensaje: "Usuario no encontrado" });
    }

    // VALIDAR EL CÓDIGO DE RECUPERACIÓN
    const { data: registroCodigoResultado } = await obtenerCodigoValido(usuario.id_usuario, String(codigo).trim());
    const registroCodigo = Array.isArray(registroCodigoResultado) ? registroCodigoResultado[0] : registroCodigoResultado;

    if (!registroCodigo) {
      return res.status(400).json({ mensaje: "El código es incorrecto o ya ha expirado" });
    }

    // ENCRIPTAR LA NUEVA CONTRASEÑA CON BCRYPT
    const hashedPassword = await bcrypt.hash(nuevaContraseña, 10);

    // ACTUALIZAR CONTRASEÑA EN LA TABLA USUARIOS
    const { error: errorUpdate } = await actualizarPasswordUsuario(usuario.id_usuario, hashedPassword);

    if (errorUpdate) {
      console.error("Error al actualizar contraseña:", errorUpdate);
      return res.status(500).json({ mensaje: "Error al actualizar la contraseña en la base de datos" });
    }

    // MARCAR EL CÓDIGO COMO USADO
    await marcarCodigoComoUsado(registroCodigo.id);

    // GENERAR CONTENIDO DEL CORREO DESDE LA PLANTILLA
    const contenidoCorreo = plantillaPasswordCambiada(usuario.nombre);

    // NOTIFICAR AL CORREO DEL USUARIO
    await transporter.sendMail({
      from: `"Active Sport Gym" <${process.env.EMAIL_USER}>`,
      to: correoLimpio,
      ...contenidoCorreo
    });

    return res.status(200).json({ mensaje: "Contraseña actualizada exitosamente" });

  } catch (error) {
    console.error("Error en cambiarContraseñaConCodigo:", error);
    return res.status(500).json({ mensaje: "Error interno del servidor" });
  }
};