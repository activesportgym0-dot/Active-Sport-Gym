import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/carrito_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// SERVICIO DEL CARRITO DE COMPRAS (solo CLIENTE).
/// El backend protege todas estas rutas con verificarToken + verificarCliente:
/// un administrador recibe 403 ("no pueden usar el carrito").
/// Para confirmar la compra del carrito se usa PedidoService.confirmarPedido().
class CarritoService {
  static const String _rutaCarrito = '/carrito';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sesionInvalida =
      'Tu sesión expiró o no es válida. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  /// GET /carrito -> productos del carrito con subtotales y total a pagar.
  /// Lanza una excepción con el motivo real si el servidor responde con error.
  static Future<CarritoModel> obtenerCarrito() async {
    if (!_haySesion) throw Exception(_sinSesion);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaCarrito'),
      headers: _headersJson,
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return CarritoModel.fromJson(Map<String, dynamic>.from(decoded));
      }
      return const CarritoModel();
    }

    throw Exception(_mensajeError(response, 'No se pudo cargar tu carrito'));
  }

  /// POST /carrito/agregar. Si el producto ya estaba, el backend suma la cantidad.
  /// Valida el stock: devuelve el mensaje de error si no alcanza.
  static Future<Map<String, dynamic>> agregarProducto({
    required int idProducto,
    int cantidad = 1,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaCarrito/agregar'),
        headers: _headersJson,
        body: jsonEncode({'id_producto': idProducto, 'cantidad': cantidad}),
      );
      final data = _decodificarRespuesta(response.body);

      // 201 = producto nuevo en el carrito, 200 = se actualizó la cantidad
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Producto agregado al carrito',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo agregar al carrito'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// PUT /carrito/item/:id_carrito -> fija la cantidad de un producto del carrito.
  static Future<Map<String, dynamic>> cambiarCantidad({
    required int idCarrito,
    required int cantidad,
  }) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$_rutaCarrito/item/$idCarrito'),
        headers: _headersJson,
        body: jsonEncode({'cantidad': cantidad}),
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Cantidad actualizada',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo cambiar la cantidad'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /carrito/item/:id_carrito
  static Future<Map<String, dynamic>> eliminarItem(int idCarrito) async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaCarrito/item/$idCarrito'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Producto eliminado del carrito',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo eliminar el producto'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// DELETE /carrito/vaciar
  static Future<Map<String, dynamic>> vaciarCarrito() async {
    if (!_haySesion) return {'success': false, 'message': _sinSesion};

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaCarrito/vaciar'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Carrito vaciado correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensajeError(response, 'No se pudo vaciar el carrito'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
    // CLIENTE: confirmar la compra desde el carrito.
  static Future<Map<String, dynamic>> confirmarPedido() async {
    if (!_haySesion) {
      return {
        'success': false,
        'message': _sinSesion,
      };
    }

    try {
      final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pedidos/confirmar'),        headers: _headersJson,
      );

      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'] ??
              'Pedido realizado correctamente.',
          'pedido': data['pedido'],
          'url_whatsapp': data['url_whatsapp'],
        };
      }

      return {
        'success': false,
        'message': data['error'] ??
            data['mensaje'] ??
            'No se pudo confirmar el pedido. '
                'Código: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  // AUXILIARES PRIVADOS

  /// 401 = no hay token. El backend responde con 'error' (y 'detalle' cuando
  /// viene de la base de datos). Un 403 trae el motivo (token vencido o rol).
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
