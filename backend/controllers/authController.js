import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { supabase } from "../config/supabase.js";
import { crearUser, obtenerUsuarioPorEmail } from "../models/usuarioModel.js";
import { crearPerfilAutomatico } from "../models/perfilModel.js";
import { enviarCodigoVerificacion } from "../utils/emails/emailCodigoVerificacion.js";

// REGISTRO DE USUARIOS CON VALIDACIÓN DE CONFIRMAR CONTRASEÑA
export const registro = async (req, res) => {
  try {
    let { 
      nombre, 
      apellido, 
      correo, 
      telefono, 
      cedula, 
      edad, 
      peso, 
      altura, 
      contraseña, 
      confirmarContrasena 
    } = req.body;

    // 1. Validar que ningún campo obligatorio esté vacío
    if (!nombre || !apellido || !correo || !telefono || !cedula || !edad || !peso || !altura || !contraseña || !confirmarContrasena) {
      return res.status(400).json({
        mensaje: "Todos los campos son requeridos"
      });
    }

    // 2. Validar que la contraseña y la confirmación sean idénticas
    if (contraseña !== confirmarContrasena) {
      return res.status(400).json({
        mensaje: "Las contraseñas no coinciden"
      });
    }

    // Limpieza y formateo de campos de texto
    nombre = nombre.trim();
    apellido = apellido.trim();
    correo = correo.trim().toLowerCase();
    telefono = telefono.trim();

    // Validar formato del correo
    const expresionCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!expresionCorreo.test(correo)) {
      return res.status(400).json({
        mensaje: "El correo electrónico no tiene un formato válido"
      });
    }

    // 3. Verificar disponibilidad del correo
    const { data: usuarioExistente, error: errorBusqueda } = await obtenerUsuarioPorEmail(correo);
    if (errorBusqueda) {
      console.error("Error al verificar correo:", errorBusqueda);
      return res.status(500).json({
        mensaje: "Error al verificar la disponibilidad del correo"
      });
    }

    if (usuarioExistente) {
      return res.status(400).json({
        mensaje: "El correo electrónico ya está registrado"
      });
    }

    // 4. Encriptar contraseña y definir rol por defecto
    const hashedPassword = await bcrypt.hash(contraseña, 10);
    const rolPorDefecto = "cliente";

    // 5. Generar código de verificación (6 dígitos, expira en 15 min)
    const codigoVerificacion = Math.floor(100000 + Math.random() * 900000).toString();
    const codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000).toISOString();

    // 6. Insertar en la base de datos
    const { data: usuarioCreado, error } = await crearUser(
      nombre,
      apellido,
      correo,
      telefono,
      cedula,
      edad,
      peso,
      altura,
      hashedPassword,
      rolPorDefecto,
      codigoVerificacion,
      codigoVerificacionExpiracion
    );

    if (error) {
      console.error("Error al crear usuario:", error);
      if (error.code === "23505") {
        return res.status(409).json({
          mensaje: "El correo, la cédula o el teléfono ya están registrados"
        });
      }
      return res.status(500).json({
        mensaje: "Error al crear el usuario en la base de datos"
      });
    }

    // 7. Crear perfil automático
    const { data: perfilCreado, error: errorPerfil } = await crearPerfilAutomatico(usuarioCreado.id_usuario);
    if (errorPerfil) {
      console.error("Error al crear perfil automático:", errorPerfil);
    }

    // 8. Enviar correo de verificación
    const resultadoEnvio = await enviarCodigoVerificacion(correo, nombre, codigoVerificacion);
    const usuarioRespuesta = {
      id_usuario: usuarioCreado.id_usuario,
      nombre: usuarioCreado.nombre,
      correo: usuarioCreado.correo,
      rol: usuarioCreado.rol
    };

    if (!resultadoEnvio.exito) {
      return res.status(201).json({
        mensaje: "Tu cuenta fue creada, pero hubo un problema al enviar el código a tu correo. Contacta con soporte.",
        correoEnviado: false,
        usuario: usuarioRespuesta,
        perfil: perfilCreado || null
      });
    }

    return res.status(201).json({
      mensaje: "Usuario y perfil registrados con éxito. Hemos enviado un código de 6 dígitos a tu correo.",
      correoEnviado: true,
      usuario: usuarioRespuesta,
      perfil: perfilCreado || null
    });
  } catch (error) {
    console.error("Error inesperado en registro:", error);
    return res.status(500).json({
      mensaje: "Error interno del servidor"
    });
  }
};

// LOGIN DE USUARIO (Con verificación activa y validación de is_active)
export const login = async (req, res) => {
  try {
    let { correo, contraseña } = req.body;
    
    if (!correo || !contraseña) {
      return res.status(400).json({
        mensaje: "Todos los campos son requeridos: correo y contraseña"
      });
    }

    correo = correo.trim().toLowerCase();

    const { data: usuario, error: errorBusqueda } = await obtenerUsuarioPorEmail(correo);
    if (errorBusqueda) {
      console.error("Error al buscar usuario en login:", errorBusqueda);
      return res.status(500).json({
        mensaje: "Error al consultar las credenciales"
      });
    }

    if (!usuario) {
      return res.status(400).json({
        mensaje: "Credenciales incorrectas"
      });
    }

    const passwordValida = await bcrypt.compare(contraseña, usuario.contraseña);
    if (!passwordValida) {
      return res.status(400).json({
        mensaje: "Credenciales incorrectas"
      });
    }

    // Valido que la cuenta esté verificada antes de dejarlo entrar
    if (!usuario.isVerified) {
      return res.status(403).json({
        mensaje: "Tu cuenta no ha sido verificada. Por favor ingresa el código enviado a tu correo antes de iniciar sesión."
      });
    }

    if (usuario.is_active === false) {
      return res.status(403).json({
        mensaje: "Tu cuenta ha sido desactivada. Por favor comunícate con soporte."
      });
    }

    const token = jwt.sign(
      { id_usuario: usuario.id_usuario, rol: usuario.rol },
      process.env.JWT_SECRET || "luisa0012@",
      { expiresIn: "30d" }
    );

    return res.status(200).json({
      mensaje: "Inicio de sesión exitoso",
      token: token,
      usuario: {
        id_usuario: usuario.id_usuario,
        nombre: usuario.nombre,
        correo: usuario.correo,
        rol: usuario.rol
      }
    });
  } catch (error) {
    console.error("Error en login:", error);
    return res.status(500).json({
      mensaje: error.message || "Error interno del servidor"
    });
  }
};

// VERIFICAR CUENTA CON CÓDIGO DE 6 DÍGITOS
export const verificarCuenta = async (req, res) => {
  try {
    const { correo, codigo } = req.body;

    if (!correo || !codigo) {
      return res.status(400).json({
        mensaje: "El correo y el código de verificación son requeridos"
      });
    }

    const { data: usuario, error: errorUsuario } = await supabase
      .from("usuarios")
      .select("id_usuario, correo, isVerified, codigoVerificacion, codigoVerificacionExpiracion")
      .eq("correo", correo.trim().toLowerCase())
      .single();

    if (errorUsuario || !usuario) {
      return res.status(404).json({
        mensaje: "Usuario no encontrado"
      });
    }

    if (usuario.isVerified) {
      return res.status(400).json({
        mensaje: "La cuenta ya se encuentra verificada"
      });
    }

    if (String(usuario.codigoVerificacion).trim() !== String(codigo).trim()) {
      return res.status(400).json({
        mensaje: "El código de verificación es incorrecto"
      });
    }

    const ahora = new Date();
    const expiracion = new Date(usuario.codigoVerificacionExpiracion);
    if (ahora > expiracion) {
      return res.status(400).json({
        mensaje: "El código ha expirado. Por favor solicita uno nuevo"
      });
    }

    const { error: errorUpdate } = await supabase
      .from("usuarios")
      .update({
        isVerified: true,
        codigoVerificacion: null,
        codigoVerificacionExpiracion: null
      })
      .eq("id_usuario", usuario.id_usuario);

    if (errorUpdate) {
      return res.status(500).json({
        mensaje: "Error al actualizar el estado de verificación"
      });
    }

    return res.status(200).json({
      mensaje: "Cuenta verificada exitosamente. Ya puedes iniciar sesión en Active Sport Gym."
    });
  } catch (error) {
    console.error("Error en verificarCuenta:", error);
    return res.status(500).json({
      mensaje: error.message || "Error interno del servidor"
    });
  }
};

// REENVIAR CÓDIGO DE VERIFICACIÓN (Sobrescribe el código actual y actualiza expiración)
export const reenviarCodigo = async (req, res) => {
  try {
    let { correo } = req.body;
    if (!correo) {
      return res.status(400).json({ mensaje: "El correo es requerido" });
    }
    correo = correo.trim().toLowerCase();

    const { data: usuario, error } = await supabase
      .from("usuarios")
      .select("id_usuario, nombre, correo, isVerified")
      .eq("correo", correo)
      .single();

    if (error || !usuario) {
      return res.status(404).json({ mensaje: "Usuario no encontrado" });
    }

    if (usuario.isVerified) {
      return res.status(400).json({ mensaje: "Esta cuenta ya está verificada" });
    }

    // Generar nuevo código y nueva fecha de expiración (15 minutos más)
    const nuevoCodigo = Math.floor(100000 + Math.random() * 900000).toString();
    const nuevaExpiracion = new Date(Date.now() + 15 * 60 * 1000).toISOString();

    // Actualizar directamente en la misma celda del usuario (sobrescribe el anterior)
    const { error: errorUpdate } = await supabase
      .from("usuarios")
      .update({
        codigoVerificacion: nuevoCodigo,
        codigoVerificacionExpiracion: nuevaExpiracion
      })
      .eq("id_usuario", usuario.id_usuario);

    if (errorUpdate) {
      return res.status(500).json({ mensaje: "Error al actualizar el código de verificación" });
    }

    const resultadoEnvio = await enviarCodigoVerificacion(usuario.correo, usuario.nombre, nuevoCodigo);
    if (!resultadoEnvio.exito) {
      return res.status(500).json({ mensaje: "No se pudo enviar el correo con el nuevo código" });
    }

    return res.status(200).json({
      mensaje: "Se ha enviado un nuevo código de verificación a tu correo."
    });
  } catch (error) {
    console.error("Error en reenviarCodigo:", error);
    return res.status(500).json({ mensaje: "Error interno del servidor" });
  }
};