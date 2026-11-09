import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ChatService {
  static const String _rutaChat = '/chat';

  static const String _sinSesion =
      'No hay una sesión activa. Inicia sesión de nuevo.';
  static const String _sinConexion =
      'No se pudo conectar con el servidor. Revisa tu conexión e intenta de nuevo.';

  static bool get _haySesion => SessionService.token.isNotEmpty;

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  /// 👤 POST /chat/cliente -> Envía mensaje del cliente a la IA
  static Future<ChatResponseModel> enviarMensajeCliente({
    required String mensaje,
    required String? sesionId,
  }) =>
      _enviar('cliente', mensaje, sesionId);

  /// 👨‍💼 POST /chat/admin -> Envía consulta gerencial del administrador a la IA
  static Future<ChatResponseModel> enviarMensajeAdmin({
    required String mensaje,
    required String? sesionId,
  }) =>
      _enviar('admin', mensaje, sesionId);

  // AUXILIARES PRIVADOS

  static Future<ChatResponseModel> _enviar(
    String destino,
    String mensaje,
    String? sesionId,
  ) async {
    if (!_haySesion) throw Exception(_sinSesion);

    // Solo la llamada de red va dentro del try: así el mensaje real del servidor
    // (por ejemplo "El asistente está muy ocupado") no se disfraza de error de conexión.
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$_rutaChat/$destino'),
            headers: _headersJson,
            body: jsonEncode({'mensaje': mensaje, 'sesionId': sesionId}),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw Exception(_sinConexion);
    }

    final data = _decodificarRespuesta(response.body);

    if (response.statusCode == 200) {
      return ChatResponseModel.fromJson(data);
    }
    if (response.statusCode == 401) {
      throw Exception('Tu sesión expiró o no es válida. Inicia sesión de nuevo.');
    }
    throw Exception(
      _mensaje(data, 'No se pudo obtener respuesta del asistente (${response.statusCode})'),
    );
  }

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
