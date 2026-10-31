import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/regla_horario_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ReglaHorarioService {
  // ⚠️ Debe ser la misma ruta con la que montas el router en el index.js del backend:
  //    app.use("/reglas-horarios", reglasHorariosRouter);
  // Si la tuya se llama distinto, cámbiala solo aquí.
  static const String _rutaReglasHorarios = '/reglas-horarios';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sesionInvalida =
      'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  // El token se toma de la sesión global (SessionService), igual que en los otros servicios
  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  // CONSULTA (cualquier usuario con sesión: la pueden usar admin y cliente)

  /// GET /reglas-horarios -> todas las reglas y horarios.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<List<ReglaHorarioModel>> obtenerReglasHorarios() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaReglasHorarios'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((r) => ReglaHorarioModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    throw Exception(
      _mensajeError(response, 'No se pudieron cargar las reglas y horarios'),
    );
  }

  // ADMINISTRADOR

  /// POST /reglas-horarios (los tres campos son obligatorios).
  static Future<Map<String, dynamic>> crearReglaHorario({
    required String tipo,
    required String titulo,
    required String contenido,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaReglasHorarios'),
        headers: _headersJson,
        body: jsonEncode({'tipo': tipo, 'titulo': titulo, 'contenido': contenido}),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Registro creado correctamente.',
          'regla': _modeloDe(data['regla_horario']),
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo crear el registro'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// PUT /reglas-horarios/:id
  static Future<Map<String, dynamic>> actualizarReglaHorario({
    required int idReglaHorario,
    required String tipo,
    required String titulo,
    required String contenido,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$_rutaReglasHorarios/$idReglaHorario'),
        headers: _headersJson,
        body: jsonEncode({'tipo': tipo, 'titulo': titulo, 'contenido': contenido}),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Registro actualizado correctamente.',
          'regla': _modeloDe(data['regla_horario']),
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo actualizar el registro'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /reglas-horarios/:id
  static Future<Map<String, dynamic>> eliminarReglaHorario(int idReglaHorario) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaReglasHorarios/$idReglaHorario'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Registro eliminado correctamente.',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo eliminar el registro'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

  static ReglaHorarioModel? _modeloDe(dynamic json) {
    if (json is! Map) return null;
    return ReglaHorarioModel.fromJson(Map<String, dynamic>.from(json));
  }

  /// 401 = no hay token. El backend de reglas responde con 'error' (y 'detalle'
  /// cuando viene de la base de datos); el middleware también usa 'error'.
  static String _mensajeError(http.Response response, String porDefecto) {
    final data = _decodificarRespuesta(response.body);
    if (response.statusCode == 401) return _sesionInvalida;
    return (data['error'] ?? data['mensaje'] ?? '$porDefecto (${response.statusCode})')
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
