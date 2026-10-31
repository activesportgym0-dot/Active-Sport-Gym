import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/notificacion_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class NotificacionService {
  static const String _rutaNotificaciones = '/notificaciones';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  // ADMINISTRADOR

  /// GET /notificaciones/admin -> todas las notificaciones enviadas.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<List<NotificacionModel>> obtenerTodas() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaNotificaciones/admin'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((n) => NotificacionModel.fromJson(Map<String, dynamic>.from(n)))
          .toList();
    }

    throw Exception(
      _mensaje(
        _decodificarRespuesta(response.body),
        'No se pudieron cargar las notificaciones (${response.statusCode})',
      ),
    );
  }

  /// POST /notificaciones (multipart). Si [idUsuario] es null la notificación
  /// es global. La imagen es opcional (el backend la sube a Cloudinary).
  static Future<Map<String, dynamic>> crearNotificacion({
    required String titulo,
    required String mensaje,
    required String tipo,
    int? idUsuario,
    XFile? imagen,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}$_rutaNotificaciones'),
      );
      request.headers['Authorization'] = 'Bearer ${SessionService.token}';
      request.fields['titulo'] = titulo;
      request.fields['mensaje'] = mensaje;
      request.fields['tipo'] = tipo;
      if (idUsuario != null) {
        request.fields['id_usuario'] = idUsuario.toString();
      }

      if (imagen != null) {
        final nombre = imagen.name.trim().isEmpty ? 'notificacion.jpg' : imagen.name;
        request.files.add(
          http.MultipartFile.fromBytes(
            'imagen',
            await imagen.readAsBytes(),
            filename: nombre,
          ),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        // URL que el servidor guardó en la columna imagen_url (null = no recibió imagen)
        final creada = data['notificacion'];
        final imagenUrl = creada is Map ? creada['imagen_url']?.toString() : null;
        debugPrint(
          'Notificación creada | imagen enviada: ${imagen != null} | imagen_url guardada: $imagenUrl',
        );
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Notificación creada con éxito',
          'imagen_url': imagenUrl,
        };
      }
      return {
        'success': false,
        'message': _mensaje(data, 'No se pudo enviar la notificación'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /notificaciones/:id
  static Future<Map<String, dynamic>> eliminarNotificacion(int idNotificacion) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaNotificaciones/$idNotificacion'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Notificación eliminada correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensaje(data, 'No se pudo eliminar la notificación'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

  /// El backend de notificaciones responde con 'error' (fallo) o 'mensaje' (éxito).
  static String _mensaje(Map<String, dynamic> data, String porDefecto) {
    return (data['error'] ?? data['mensaje'] ?? porDefecto).toString();
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