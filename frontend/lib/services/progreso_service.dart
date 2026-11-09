import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/progreso_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ProgresoService {
  // ⚠️ Debe ser la misma ruta con la que montas el router en el index.js del backend:
  //    app.use("/progreso", progresoRouter);
  // Si la tuya se llama distinto, cámbiala solo aquí.
  static const String _rutaProgreso = '/progreso';

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

  // CLIENTE (todas las rutas del backend exigen token + rol cliente)

  /// GET /progreso/actual -> medida más reciente, o null si aún no tiene ninguna.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<ProgresoModel?> obtenerProgresoActual() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaProgreso/actual'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Sin medidas el backend responde { mensaje, progreso: null }
      if (decoded is Map && decoded['id_progreso'] != null) {
        return ProgresoModel.fromJson(Map<String, dynamic>.from(decoded));
      }
      return null;
    }

    throw Exception(
      _mensajeError(response, 'No se pudo cargar tu progreso actual'),
    );
  }

  /// GET /progreso/historial -> todas las medidas, de la más nueva a la más antigua.
  static Future<List<ProgresoModel>> obtenerHistorial() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaProgreso/historial'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Sin historial el backend responde { mensaje, historial: [] }
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((m) => ProgresoModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    throw Exception(
      _mensajeError(response, 'No se pudo cargar el historial de medidas'),
    );
  }

  /// POST /progreso -> registra una nueva medida (los 11 campos son obligatorios y > 0).
  static Future<Map<String, dynamic>> registrarMedida({
    required double pesoActual,
    required double altura,
    required double brazoIzquierdo,
    required double brazoDerecho,
    required double pecho,
    required double cintura,
    required double cadera,
    required double musloIzquierdo,
    required double musloDerecho,
    required double pantorrillaIzquierda,
    required double pantorrillaDerecha,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaProgreso'),
        headers: _headersJson,
        body: jsonEncode(ProgresoModel.toJsonCrear(
          pesoActual: pesoActual,
          altura: altura,
          brazoIzquierdo: brazoIzquierdo,
          brazoDerecho: brazoDerecho,
          pecho: pecho,
          cintura: cintura,
          cadera: cadera,
          musloIzquierdo: musloIzquierdo,
          musloDerecho: musloDerecho,
          pantorrillaIzquierda: pantorrillaIzquierda,
          pantorrillaDerecha: pantorrillaDerecha,
        )),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Medidas guardadas con éxito',
          'progreso': _modeloDe(data['progreso']),
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudieron guardar las medidas'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /progreso/historial/:id -> elimina una medida (id = id_progreso).
  static Future<Map<String, dynamic>> eliminarMedida(int idProgreso) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaProgreso/historial/$idProgreso'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Medida eliminada con éxito del historial',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo eliminar la medida'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /progreso/historial -> vacía todo el historial del cliente.
  static Future<Map<String, dynamic>> vaciarHistorial() async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaProgreso/historial'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Historial de medidas vaciado con éxito',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo vaciar el historial'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

  static ProgresoModel? _modeloDe(dynamic json) {
    if (json is! Map) return null;
    return ProgresoModel.fromJson(Map<String, dynamic>.from(json));
  }

  /// 401 = sin token. 403 = token vencido o usuario que no es cliente (el backend
  /// responde con 'error' en ambos casos, y 'detalle' cuando viene de la base de datos).
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
