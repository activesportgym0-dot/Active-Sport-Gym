import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/perfil_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Perfil de usuario: lo usan "Mi perfil" (cliente y admin) y el detalle
/// de usuario que ve el administrador.
class PerfilService {
  static const String _rutaPerfil = '/perfil';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sesionInvalida =
      'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  /// GET /perfil/:id_usuario -> datos del usuario + foto.
  /// Devuelve {success: true, perfil: PerfilModel} o {success: false, message}.
  static Future<Map<String, dynamic>> obtenerPerfil(int idUsuario) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$_rutaPerfil/$idUsuario'),
        headers: _headersJson,
      );

      if (response.statusCode == 200) {
        final data = _decodificarRespuesta(response.body);
        final perfil = data['perfil'];
        if (perfil is Map) {
          return {
            'success': true,
            'perfil': PerfilModel.fromJson(Map<String, dynamic>.from(perfil)),
          };
        }
        return {'success': false, 'message': 'Perfil no encontrado'};
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo cargar el perfil'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// PUT /perfil/:id_usuario con los campos de texto a cambiar
  /// (nombre, apellido, correo, telefono, cedula, edad, peso, altura).
  static Future<Map<String, dynamic>> editarPerfil(
    int idUsuario,
    Map<String, dynamic> campos,
  ) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$_rutaPerfil/$idUsuario'),
        headers: _headersJson,
        body: jsonEncode(campos),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Perfil actualizado correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No fue posible actualizar el perfil'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// PUT /perfil/foto/:id_usuario (multipart, campo "foto"). El backend la sube a Cloudinary.
  static Future<Map<String, dynamic>> cambiarFoto(int idUsuario, XFile foto) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}$_rutaPerfil/foto/$idUsuario'),
      );
      request.headers['Authorization'] = 'Bearer ${SessionService.token}';

      final nombre = foto.name.trim().isEmpty ? 'perfil.jpg' : foto.name;
      request.files.add(
        http.MultipartFile.fromBytes('foto', await foto.readAsBytes(), filename: nombre),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Foto de perfil actualizada correctamente',
          'foto_perfil': data['foto_perfil'],
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo cambiar la foto'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

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
