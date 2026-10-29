import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/resumen_admin_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class DashboardService {
  static const String _rutaResumen = '/dashboard/resumen';

  /// GET /dashboard/resumen (solo administrador, con el token de la sesión).
  /// Lanza una excepción con el motivo real si algo falla.
  static Future<ResumenAdminModel> obtenerResumen() async {
    if (SessionService.token.isEmpty) {
      throw Exception('No hay una sesión activa. Inicia sesión de nuevo.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$_rutaResumen'),
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      },
    );

    final data = _decodificarRespuesta(response.body);

    if (response.statusCode == 200) {
      return ResumenAdminModel.fromJson(data);
    }

    // verificarToken responde 401 sin token y 403 con token vencido o sin permisos.
    throw Exception(
      (data['error'] ?? data['mensaje'] ??
              'No se pudo cargar el resumen (${response.statusCode})')
          .toString(),
    );
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
