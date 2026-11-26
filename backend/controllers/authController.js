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
      confirmarContrasena,
      municipio,
      direccion,
      departamento,
      aceptaTerminos
    } = req.body;

    // 1. Validar campos obligatorios.
    // Edad, peso y altura son opcionales.
    if (
      !nombre ||
      !apellido ||
      !correo ||
      !telefono ||
      !cedula ||
      !contraseña ||
      !confirmarContrasena ||
      !municipio ||
      !direccion ||
      !departamento
    ) {
      return res.status(400).json({
        mensaje: "Todos los campos obligatorios deben estar completos"
      });
    }

    // 2. Validar aceptación de términos.
    if (aceptaTerminos !== true) {
      return res.status(400).json({
        mensaje: "Debes aceptar los términos y condiciones y la política de tratamiento de datos para registrarte"
      });
    }

    // 3. Validar contraseñas.
    if (contraseña !== confirmarContrasena) {
      return res.status(400).json({
        mensaje: "Las contraseñas no coinciden"
      });
    }

    // 4. Limpiar datos.
    nombre = nombre.trim();
    apellido = apellido.trim();
    correo = correo.trim().toLowerCase();
    telefono = telefono.trim();
    cedula = String(cedula).trim();
    municipio = String(municipio).trim();
    direccion = String(direccion).trim();
    departamento = String(departamento).trim();

    // 5. Validar ubicación.
    if (!municipio || !direccion || !departamento) {
      return res.status(400).json({
        mensaje: "El municipio, la dirección y el departamento son requeridos"
      });
    }

    if (municipio.length > 100 || direccion.length > 150 || departamento.length > 100) {
      return res.status(400).json({
        mensaje: "El municipio (máx. 100), la dirección (máx. 150) o el departamento (máx. 100) son demasiado largos"
      });
    }

    // 6. Validar correo.
    const expresionCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

    if (!expresionCorreo.test(correo)) {
      return res.status(400).json({
        mensaje: "El correo electrónico no tiene un formato válido"
      });
    }

    // 7. Validar edad, peso y altura (opcionales).
    const edadFinal = edad === null || edad === undefined || edad === ""
      ? null
      : Number(edad);

    const pesoFinal = peso === null || peso === undefined || peso === ""
      ? null
      : Number(peso);

    const alturaFinal = altura === null || altura === undefined || altura === ""
      ? null
      : Number(altura);

    if (
      edadFinal !== null &&
      (!Number.isInteger(edadFinal) || edadFinal < 1 || edadFinal > 120)
    ) {
      return res.status(400).json({
        mensaje: "La edad debe estar entre 1 y 120 años"
      });
    }

    if (
      pesoFinal !== null &&
      (!Number.isFinite(pesoFinal) || pesoFinal <= 0)
    ) {
      return res.status(400).json({
        mensaje: "El peso debe ser un número mayor que cero"
      });
    }

    if (
      alturaFinal !== null &&
      (!Number.isFinite(alturaFinal) || alturaFinal <= 0)
    ) {
      return res.status(400).json({
        mensaje: "La altura debe ser un número mayor que cero"
      });
    }

    // 8. Verificar disponibilidad del correo.
    const { data: usuarioExistente, error: errorBusqueda } =
      await obtenerUsuarioPorEmail(correo);

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

    // 9. Encriptar contraseña.
    const hashedPassword = await bcrypt.hash(contraseña, 10);
    const rolPorDefecto = "cliente";

    // 10. Generar código de verificación.
    const codigoVerificacion = Math.floor(
      100000 + Math.random() * 900000
    ).toString();

    const codigoVerificacionExpiracion = new Date(
      Date.now() + 15 * 60 * 1000
    ).toISOString();

    // 11. Crear usuario.
    const { data: usuarioCreado, error } = await crearUser(
      nombre,
      apellido,
      correo,
      telefono,
      cedula,
      edadFinal,
      pesoFinal,
      alturaFinal,
      hashedPassword,
      rolPorDefecto,
      codigoVerificacion,
      codigoVerificacionExpiracion,
      municipio,
      direccion,
      departamento,
      new Date().toISOString()
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

    // 12. Crear perfil automático.
    const { data: perfilCreado, error: errorPerfil } =
      await crearPerfilAutomatico(usuarioCreado.id_usuario);

    if (errorPerfil) {
      console.error("Error al crear perfil automático:", errorPerfil);
    }

    // 13. Enviar código de verificación.
    const resultadoEnvio = await enviarCodigoVerificacion(
      correo,
      nombre,
      codigoVerificacion
    );

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
      mensaje: "Registro recibido. Hemos enviado un código de 6 dígitos a tu correo. Después de verificarlo, el gimnasio revisará tu registro y activará tu cuenta.",
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
        mensaje: "Tu cuenta aún no está activa. Si te acabas de registrar, el gimnasio la activará pronto. Si ya la tenías, comunícate con el gimnasio."
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
      mensaje: "Correo verificado. El gimnasio revisará tu registro y activará tu cuenta pronto; cuando esté activa podrás iniciar sesión en Active Sport Gym."      });
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