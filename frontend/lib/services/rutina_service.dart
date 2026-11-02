import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rutina_guardada_model.dart';
import '../models/rutina_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// SERVICIO ÚNICO DE RUTINAS: crear una rutina nueva y consultar las rutinas guardadas.
/// (Solo CLIENTE: el backend protege todas las rutas con
/// verificarToken + verificarCliente, un administrador recibe 403).
/// El catálogo de ejercicios y las categorías que se usan para armar la rutina
/// se piden con EjercicioService (obtenerEjercicios / obtenerCategorias).
class RutinaService {
  static const String _rutaRutinas = '/rutinas';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sesionInvalida =
      'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  /// GET /rutinas/usuario/:id -> rutinas del cliente con sus días, ejercicios y series.
  /// El backend toma el usuario del token (el id de la ruta solo hace falta para que
  /// la ruta exista), así que cada cliente solo recibe SUS rutinas.
  /// La más reciente va primero. Lanza una excepción con el motivo real si falla.
  static Future<List<RutinaGuardadaModel>> obtenerMisRutinas() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaRutinas/usuario/${SessionService.idUsuario ?? 0}'),
      headers: _headersJson,
    );
    final data = _decodificarRespuesta(response.body);

    if (response.statusCode == 200) {
      final raw = data['rutinas'] is List ? data['rutinas'] as List : const [];
      final rutinas = raw
          .whereType<Map>()
          .map((r) => RutinaGuardadaModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
      rutinas.sort((a, b) => b.idRutina.compareTo(a.idRutina));
      return rutinas;
    }

    throw Exception(_mensajeError(response, data, 'No se pudieron cargar tus rutinas'));
  }

  /// POST /rutinas -> crea la rutina con sus días, ejercicios y series.
  /// Devuelve {success, message, id_rutina}. Si algo falla, el mensaje trae el motivo
  /// real del backend (por ejemplo "Las repeticiones de la Serie 2 deben ser mayores que cero").
  static Future<Map<String, dynamic>> crearRutina(RutinaNuevaModel rutina) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaRutinas'),
        headers: _headersJson,
        body: jsonEncode(rutina.toJson()),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        final creada = data['rutina'];
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Rutina creada correctamente',
          'id_rutina': creada is Map ? creada['id_rutina'] : null,
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, data, 'No se pudo crear la rutina'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

  /// El backend de rutinas responde con 'mensaje' (y 'error' con el detalle de la
  /// base de datos cuando es un 500). El middleware de token usa solo 'error'.
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