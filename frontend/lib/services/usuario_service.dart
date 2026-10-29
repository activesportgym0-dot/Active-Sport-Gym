import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';
import 'auth_service.dart'; // 👈 Importa auth_service para acceder a SessionService

class UsuarioService {
  static const String _rutaUsuarios = '/usuarios';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sesionInvalida =
      'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  // El token se toma automáticamente de la sesión global 🌟
  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  // OBTENER TODOS LOS USUARIOS (Requiere token de Administrador)
  static Future<Map<String, dynamic>> listarUsuarios() async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$_rutaUsuarios'),
        headers: _headersJson,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> listaJson = data['usuarios'] is List ? data['usuarios'] : [];
        final List<UserModel> usuarios = listaJson
            .whereType<Map>()
            .map((json) => UserModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return {'success': true, 'usuarios': usuarios};
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'Error al obtener usuarios'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // CAMBIAR ESTADO DE USUARIO (Activar / Desactivar)
  // Ahora devuelve {success, message} (antes devolvía solo true/false)
  // para poder mostrar el motivo real cuando algo falla.
  static Future<Map<String, dynamic>> cambiarEstado(int idUsuario, bool isActive) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}$_rutaUsuarios/$idUsuario/estado'),
        headers: _headersJson,
        body: jsonEncode({'is_active': isActive}),
      );

      if (response.statusCode == 200) {
        final data = _decodificarRespuesta(response.body);
        return {
          'success': true,
          'message': data['mensaje'] ??
              'La cuenta ha sido ${isActive ? 'activada' : 'desactivada'} exitosamente',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No fue posible actualizar el estado'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ELIMINAR USUARIO (Requiere token de Administrador)
  static Future<Map<String, dynamic>> eliminarUsuario(int idUsuario) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaUsuarios/$idUsuario'),
        headers: _headersJson,
      );

      if (response.statusCode == 200) {
        final data = _decodificarRespuesta(response.body);
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Usuario eliminado correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No fue posible eliminar el usuario'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

  /// 401 = no hay token, 403 = token vencido/inválido o sin permisos de admin.
  /// El backend de usuarios responde con 'mensaje' y, en los errores del
  /// middleware, con 'error'.
  static String _mensajeError(http.Response response, String porDefecto) {
    final data = _decodificarRespuesta(response.body);
    if (response.statusCode == 401) return _sesionInvalida;
    return (data['mensaje'] ?? data['error'] ?? '$porDefecto (${response.statusCode})')
        .toString();
  }

  static Map<String, dynamic> _decodificarRespuesta(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }
}
