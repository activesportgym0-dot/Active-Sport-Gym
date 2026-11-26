import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';
import 'sesion_guardada_service.dart';

/// Servicio global para mantener la sesión activa en la app de Flutter.
class SessionService {
  static String token = '';
  static String rol = '';
  static String nombreUsuario = '';
  static String correo = '';
  static int? idUsuario;

  // Cuenta del administrador principal. La regla de seguridad real la hace el backend.
  static const String correoAdminPrincipal = 'activesportgym0@gmail.com';
  static bool get esAdminPrincipal =>
      rol == 'admin' && correo.trim().toLowerCase() == correoAdminPrincipal;

  // Limpia los datos cuando el usuario cierre sesión.
  static void limpiarSesion({bool borrarGuardada = true}) {
    token = '';
    rol = '';
    nombreUsuario = '';
    correo = '';
    idUsuario = null;
    if (borrarGuardada) SesionGuardada.olvidar();
  }
}

class AuthService {
  // Iniciar sesión.
  static Future<Map<String, dynamic>> login(
      String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'correo': correo,
          'contraseña': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usuarioData = data['usuario'];
        SessionService.token = data['token'] ?? '';
        SessionService.rol = usuarioData['rol'] ?? 'cliente';
        SessionService.nombreUsuario = usuarioData['nombre'] ?? '';
        SessionService.correo =
            (usuarioData['correo'] ?? correo).toString();
        SessionService.idUsuario = usuarioData['id_usuario'];

        return {
          'success': true,
          'token': data['token'],
          'usuario': usuarioData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['mensaje'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Registrar usuario. Ahora devuelve el mensaje del backend en vez de solo true/false.
  static Future<Map<String, dynamic>> registrar(
    UserModel user, {
    required bool aceptaTerminos,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/registro'),
            headers: ApiConfig.headers,
            body: jsonEncode({
              ...user.toJson(),
              'aceptaTerminos': aceptaTerminos,
            }),
          )
          .timeout(const Duration(seconds: 25));

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        decoded = <String, dynamic>{};
      }

      final Map<String, dynamic> data =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      final mensaje = (data['mensaje'] ??
              data['message'] ??
              (response.statusCode >= 200 && response.statusCode < 300
                  ? 'Registro recibido.'
                  : 'No se pudo completar el registro.'))
          .toString();

      final success = response.statusCode == 200 || response.statusCode == 201;

      return {
        'success': success,
        'message': mensaje,
        // Si el backend no envía este dato, se asume que el flujo de verificación sigue igual.
        'correoEnviado': data['correoEnviado'] ?? true,
        'statusCode': response.statusCode,
      };
    } on SocketException {
      return {
        'success': false,
        'message':
            'No hay conexión a Internet. Verifica tu conexión e inténtalo nuevamente.',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'El servidor está tardando demasiado en responder. Inténtalo nuevamente.',
      };
    } on http.ClientException {
      return {
        'success': false,
        'message':
            'No fue posible comunicarse con el servidor. Inténtalo nuevamente.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ocurrió un problema inesperado al registrar la cuenta.',
      };
    }
  }

  // Verificar cuenta con código de 6 dígitos.
  static Future<Map<String, dynamic>> verificarCuenta(
      String correo, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/verificar-cuenta'),
        headers: ApiConfig.headers,
        body: jsonEncode({'correo': correo, 'codigo': codigo}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje']};
      } else {
        return {
          'success': false,
          'message': data['mensaje'] ?? 'Código incorrecto',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Reenviar código de verificación.
  static Future<Map<String, dynamic>> reenviarCodigo(String correo) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/reenviar-codigo'),
        headers: ApiConfig.headers,
        body: jsonEncode({'correo': correo}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje']};
      } else {
        return {
          'success': false,
          'message': data['mensaje'] ?? 'Error al reenviar código',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Solicitar código de recuperación de contraseña.
  static Future<Map<String, dynamic>> solicitarCodigoRecuperacion(
      String correo) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/recuperar/solicitar'),
        headers: ApiConfig.headers,
        body: jsonEncode({'correo': correo}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje']};
      } else {
        return {
          'success': false,
          'message': data['mensaje'] ?? 'Error al solicitar código',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Cambiar contraseña con código de 6 dígitos.
  static Future<Map<String, dynamic>> cambiarContrasenaConCodigo({
    required String correo,
    required String codigo,
    required String nuevaContrasena,
    required String confirmarContrasena,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/recuperar/cambiar'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'correo': correo,
          'codigo': codigo,
          'nuevaContraseña': nuevaContrasena,
          'confirmarContraseña': confirmarContrasena,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje']};
      } else {
        return {
          'success': false,
          'message':
              data['mensaje'] ?? 'Error al actualizar la contraseña',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
