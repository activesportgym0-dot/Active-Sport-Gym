import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ChatService {
  static const String _rutaChat = '/chat';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  /// 👤 POST /chat/cliente -> Envía mensaje del cliente a la IA
  static Future<ChatResponseModel> enviarMensajeCliente({
    required String mensaje,
    required String? sesionId,
  }) async {
    if (!_haySesion) throw Exception(_sinSesion);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaChat/cliente'),
        headers: _headersJson,
        body: jsonEncode({
          'mensaje': mensaje,
          'sesionId': sesionId,
        }),
      );

      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return ChatResponseModel.fromJson(data);
      }

      throw Exception(
        _mensaje(data, 'Error en el chat del cliente (${response.statusCode})'),
      );
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// 👨‍💼 POST /chat/admin -> Envía consulta gerencial del administrador a la IA
  static Future<ChatResponseModel> enviarMensajeAdmin({
    required String mensaje,
    required String? sesionId,
  }) async {
    if (!_haySesion) throw Exception(_sinSesion);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaChat/admin'),
        headers: _headersJson,
        body: jsonEncode({
          'mensaje': mensaje,
          'sesionId': sesionId,
        }),
      );

      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return ChatResponseModel.fromJson(data);
      }

      throw Exception(
        _mensaje(data, 'Error en el chat administrativo (${response.statusCode})'),
      );
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // AUXILIARES PRIVADOS

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