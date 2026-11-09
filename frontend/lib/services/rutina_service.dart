import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rutina_guardada_model.dart';
import '../models/rutina_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// SERVICIO ÚNICO DE RUTINAS: crear, consultar, editar y eliminar rutinas.
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

  /// PUT /rutinas/:id -> actualiza nombre, tipo y TODA la estructura (días, ejercicios y series).
  /// Es la que usan las pantallas de edición: reemplaza lo anterior por lo que el usuario dejó.
  /// 403 si la rutina no es del cliente, 404 si no existe.
  static Future<Map<String, dynamic>> editarRutina(int idRutina, RutinaNuevaModel rutina) {
    return _enviar(
      'PUT',
      '$_rutaRutinas/$idRutina',
      cuerpo: rutina.toJson(),
      mensajeExito: 'Rutina actualizada correctamente',
      mensajeError: 'No se pudo actualizar la rutina',
    );
  }

  /// DELETE /rutinas/:id -> elimina la rutina completa (con sus días, ejercicios y series).
  static Future<Map<String, dynamic>> eliminarRutina(int idRutina) {
    return _enviar(
      'DELETE',
      '$_rutaRutinas/$idRutina',
      mensajeExito: 'Rutina eliminada correctamente',
      mensajeError: 'No se pudo eliminar la rutina',
    );
  }

  // Cambios puntuales (por si quieres tocar una sola pieza sin reenviar toda la rutina).
  // Los ids salen de RutinaGuardadaModel: idRutinaDia, idRutinaEjercicio e idRutinaSerie.

  /// PUT /rutinas/dia/:id -> cambia el día de la semana y/o el nombre de ese día.
  static Future<Map<String, dynamic>> editarDia(int idRutinaDia, {String? diaSemana, String? nombreDia}) {
    return _enviar(
      'PUT',
      '$_rutaRutinas/dia/$idRutinaDia',
      cuerpo: <String, dynamic>{
        if (diaSemana != null) 'dia_semana': diaSemana,
        if (nombreDia != null) 'nombre_dia': nombreDia,
      },
      mensajeExito: 'Día actualizado correctamente',
      mensajeError: 'No se pudo actualizar el día',
    );
  }

  /// PUT /rutinas/ejercicio/:id -> cambia el orden, el descanso final o el ejercicio del catálogo.
  static Future<Map<String, dynamic>> editarEjercicio(int idRutinaEjercicio, {int? orden, int? descansoFinal, int? idEjercicio}) {
    return _enviar(
      'PUT',
      '$_rutaRutinas/ejercicio/$idRutinaEjercicio',
      cuerpo: <String, dynamic>{
        if (orden != null) 'orden': orden,
        if (descansoFinal != null) 'descanso_final': descansoFinal,
        if (idEjercicio != null) 'id_ejercicio': idEjercicio,
      },
      mensajeExito: 'Ejercicio actualizado correctamente',
      mensajeError: 'No se pudo actualizar el ejercicio',
    );
  }

  /// PUT /rutinas/serie/:id -> cambia repeticiones, peso o descanso de una serie.
  static Future<Map<String, dynamic>> editarSerie(int idRutinaSerie, {int? repeticiones, double? peso, int? descansoEntreSeries}) {
    return _enviar(
      'PUT',
      '$_rutaRutinas/serie/$idRutinaSerie',
      cuerpo: <String, dynamic>{
        if (repeticiones != null) 'repeticiones': repeticiones,
        if (peso != null) 'peso': peso,
        if (descansoEntreSeries != null) 'descanso_entre_series': descansoEntreSeries,
      },
      mensajeExito: 'Serie actualizada correctamente',
      mensajeError: 'No se pudo actualizar la serie',
    );
  }

  /// DELETE /rutinas/ejercicio/:id -> quita un ejercicio de la rutina (y sus series).
  static Future<Map<String, dynamic>> eliminarEjercicio(int idRutinaEjercicio) {
    return _enviar(
      'DELETE',
      '$_rutaRutinas/ejercicio/$idRutinaEjercicio',
      mensajeExito: 'Ejercicio eliminado de la rutina correctamente',
      mensajeError: 'No se pudo eliminar el ejercicio',
    );
  }

  /// DELETE /rutinas/serie/:id -> elimina una serie.
  static Future<Map<String, dynamic>> eliminarSerie(int idRutinaSerie) {
    return _enviar(
      'DELETE',
      '$_rutaRutinas/serie/$idRutinaSerie',
      mensajeExito: 'Serie eliminada correctamente',
      mensajeError: 'No se pudo eliminar la serie',
    );
  }

  // AUXILIARES PRIVADOS

  /// Envía un PUT o un DELETE y devuelve {success, message} con el motivo real si falla.
  static Future<Map<String, dynamic>> _enviar(
    String metodo,
    String ruta, {
    Map<String, dynamic>? cuerpo,
    required String mensajeExito,
    required String mensajeError,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$ruta');
      final http.Response response = metodo == 'PUT'
          ? await http.put(uri, headers: _headersJson, body: jsonEncode(cuerpo ?? <String, dynamic>{}))
          : await http.delete(uri, headers: _headersJson);
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['mensaje'] ?? mensajeExito};
      }
      return {'success': false, 'message': _mensajeError(response, data, mensajeError)};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }


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