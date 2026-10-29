import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/membresia_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class MembresiaService {
  static const String _rutaMembresias = '/membresias';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  // ADMINISTRADOR

  /// GET /membresias/admin -> clientes con su membresía más reciente.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<List<ClienteMembresiaModel>> obtenerClientesConMembresia() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaMembresias/admin'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((c) => ClienteMembresiaModel.fromJson(Map<String, dynamic>.from(c)))
          .toList();
    }

    throw Exception(
      _mensaje(
        _decodificarRespuesta(response.body),
        'No se pudieron cargar las membresías (${response.statusCode})',
      ),
    );
  }

  /// POST /membresias -> registra un nuevo plan o renovación.
  /// Las fechas van en formato YYYY-MM-DD (MembresiaModel.fechaIso).
  static Future<Map<String, dynamic>> asignarMembresia({
    required int idUsuario,
    required String estado,
    required String fechaInicio,
    required String fechaFin,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaMembresias'),
        headers: _headersJson,
        body: jsonEncode({
          'id_usuario': idUsuario,
          'estado': estado,
          'fecha_inicio': fechaInicio,
          'fecha_fin': fechaFin,
        }),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Membresía registrada con éxito',
        };
      }
      return {
        'success': false,
        'message': _mensaje(data, 'No se pudo registrar la membresía'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// PUT /membresias/estado/:id_membresia
  static Future<Map<String, dynamic>> cambiarEstado({
    required int idMembresia,
    required String estado,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$_rutaMembresias/estado/$idMembresia'),
        headers: _headersJson,
        body: jsonEncode({'estado': estado}),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Estado actualizado correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensaje(data, 'No se pudo actualizar el estado'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// GET /membresias/historial/:id_usuario -> membresía actual de un usuario
  /// (la que vence más tarde) o null si nunca ha tenido plan.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<MembresiaModel?> obtenerMembresiaActual(int idUsuario) async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaMembresias/historial/$idUsuario'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return null;

      MembresiaModel? actual;
      for (final item in decoded.whereType<Map>()) {
        final membresia = MembresiaModel.fromJson(Map<String, dynamic>.from(item));
        if (actual == null || membresia.fechaFin.compareTo(actual.fechaFin) > 0) {
          actual = membresia;
        }
      }
      return actual;
    }

    throw Exception(
      _mensaje(
        _decodificarRespuesta(response.body),
        'No se pudo consultar la membresía (${response.statusCode})',
      ),
    );
  }

  // AUXILIARES PRIVADOS

  /// El backend de membresías responde con 'error' (fallo) o 'mensaje' (éxito).
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
