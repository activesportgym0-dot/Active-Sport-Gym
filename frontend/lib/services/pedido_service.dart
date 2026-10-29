import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pedido_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class PedidoService {
  static const String _rutaPedidos = '/pedidos';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sesionInvalida =
      'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';

  // El token se guarda en SessionService al iniciar sesión (AuthService.login)
  // y el backend lo valida con verificarToken + verificarAdmin.
  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  // ADMINISTRADOR

  /// GET /pedidos/admin -> todos los pedidos de la tienda.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<List<PedidoModel>> obtenerTodosLosPedidos() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaPedidos/admin'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((p) => PedidoModel.fromJson(Map<String, dynamic>.from(p)))
          .toList();
    }

    throw Exception(
      _mensajeError(response, 'No se pudieron cargar los pedidos'),
    );
  }

  /// PUT /pedidos/:id/estado. El backend envía los correos al cliente y,
  /// si el nuevo estado es Cancelado, devuelve las unidades al stock.
  static Future<Map<String, dynamic>> cambiarEstado({
    required int idPedido,
    required String estado,
    String? motivo,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final body = <String, dynamic>{'estado': estado};
      if (motivo != null && motivo.trim().isNotEmpty) {
        body['motivo'] = motivo.trim();
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$_rutaPedidos/$idPedido/estado'),
        headers: _headersJson,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = _decodificarRespuesta(response.body);
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Estado actualizado correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo actualizar el estado'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // AUXILIARES PRIVADOS

  /// Traduce la respuesta de error del backend a un texto para el usuario.
  /// 401 = token vencido o inválido, 403 = el usuario no es administrador.
  static String _mensajeError(http.Response response, String porDefecto) {
    final data = _decodificarRespuesta(response.body);
    switch (response.statusCode) {
      case 401:
        return _sesionInvalida;
      case 403:
        return _mensaje(
          data,
          'No tienes permisos de administrador para esta acción.',
        );
      default:
        return _mensaje(data, '$porDefecto (${response.statusCode})');
    }
  }

  /// El backend responde con 'mensaje' (éxito) o 'error' (fallo).
  static String _mensaje(Map<String, dynamic> data, String porDefecto) {
    return (data['mensaje'] ?? data['error'] ?? porDefecto).toString();
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
