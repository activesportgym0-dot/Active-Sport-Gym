import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';

/// 🌟 Servicio global para mantener la sesión activa en la app de Flutter
class SessionService {
  static String token = '';
  static String rol = '';
  static String nombreUsuario = '';
  static int? idUsuario;

  // Método para limpiar los datos cuando el usuario cierre sesión
  static void limpiarSesion() {
    token = '';
    rol = '';
    nombreUsuario = '';
    idUsuario = null;
  }
}

class AuthService {
  // Iniciar Sesión (Conecta con tu ruta /auth/login)
  static Future<Map<String, dynamic>> login(String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'correo': correo,
          'contraseña': password, // Coincide exacto con tu backend
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 🌟 Guardamos automáticamente el token y los datos en la sesión global
        final usuarioData = data['usuario'];
        SessionService.token = data['token'] ?? '';
        SessionService.rol = usuarioData['rol'] ?? 'cliente';
        SessionService.nombreUsuario = usuarioData['nombre'] ?? '';
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
          'message': errorData['mensaje'] ?? 'Error al iniciar sesión'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Registrar Usuario (Conecta con tu ruta /auth/registro)
  static Future<bool> registrar(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/registro'),
        headers: ApiConfig.headers,
        body: jsonEncode(user.toJson()),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error en el registro: $e');
      return false;
    }
  }

  // Verificar Cuenta con código de 6 dígitos
  static Future<Map<String, dynamic>> verificarCuenta(String correo, String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/verificar-cuenta'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'correo': correo,
          'codigo': codigo,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje']};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Código incorrecto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Reenviar Código de Verificación
  static Future<Map<String, dynamic>> reenviarCodigo(String correo) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/reenviar-codigo'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'correo': correo,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje']};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al reenviar código'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // 1. Solicitar código de recuperación de contraseña
  static Future<Map<String, dynamic>> solicitarCodigoRecuperacion(String correo) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/recuperar/solicitar'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'correo': correo,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje']};
      } else {
        return {'success': false, 'message': data['mensaje'] ?? 'Error al solicitar código'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // 2. Cambiar contraseña con el código de 6 dígitos
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
        return {'success': false, 'message': data['mensaje'] ?? 'Error al actualizar la contraseña'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}