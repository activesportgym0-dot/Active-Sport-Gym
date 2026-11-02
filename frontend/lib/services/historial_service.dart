import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/historial_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// SERVICIO DEL HISTORIAL DE ENTRENAMIENTOS (solo CLIENTE: el backend protege todas
/// las rutas con verificarToken + verificarCliente).
/// Se usa en dos lugares: al terminar una rutina (registrarEntrenamiento) y en la
/// pantalla Historial (obtenerMiHistorial, eliminarRegistro, vaciarHistorial).
class HistorialService {
  static const String _rutaHistorial = '/historial';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sesionInvalida =
      'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  /// POST /historial -> guarda un entrenamiento terminado.
  /// [tiempoTotalSegundos] y el tiempo de cada ejercicio van en segundos.
  /// [ejercicios]: [{id_ejercicio, tiempo_ejercicio}]
  static Future<Map<String, dynamic>> registrarEntrenamiento({
    required int idRutina,
    required int tiempoTotalSegundos,
    required List<Map<String, dynamic>> ejercicios,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaHistorial'),
        headers: _headersJson,
        body: jsonEncode({
          'id_rutina': idRutina,
          'tiempo_total': tiempoTotalSegundos,
          'ejercicios': ejercicios,
        }),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Entrenamiento guardado con éxito',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, data, 'No se pudo guardar el entrenamiento'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// GET /historial -> historial del cliente, el más reciente primero.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<List<HistorialModel>> obtenerMiHistorial() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaHistorial'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((h) => HistorialModel.fromJson(Map<String, dynamic>.from(h)))
          .toList();
    }

    throw Exception(
      _mensajeError(response, _decodificarRespuesta(response.body), 'No se pudo cargar tu historial'),
    );
  }

  /// DELETE /historial/:id -> elimina un registro (solo si es del cliente).
  static Future<Map<String, dynamic>> eliminarRegistro(int idHistorial) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaHistorial/$idHistorial'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje'] ?? 'Historial eliminado con éxito'};
      }
      return {
        'success': false,
        'message': _mensajeError(response, data, 'No se pudo eliminar el registro'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /historial -> vacía todo el historial del cliente.
  static Future<Map<String, dynamic>> vaciarHistorial() async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaHistorial'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje'] ?? 'Historial vaciado con éxito'};
      }
      return {
        'success': false,
        'message': _mensajeError(response, data, 'No se pudo vaciar el historial'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

  /// El backend de historial responde con 'mensaje' (y 'error' con el detalle de la base
  /// de datos cuando es un 500). El middleware de token usa solo 'error'.
  static String _mensajeError(http.Response response, Map<String, dynamic> data, String porDefecto) {
    if (response.statusCode == 401) return _sesionInvalida;

    final mensaje = data['mensaje']?.toString();
    final detalle = data['error']?.toString();
    if (mensaje != null && detalle != null && detalle.isNotEmpty) return '$mensaje: $detalle';
    return mensaje ?? detalle ?? '$porDefecto (${response.statusCode})';
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
