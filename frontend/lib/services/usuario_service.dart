import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';
import 'auth_service.dart'; // 👈 Importa auth_service para acceder a SessionService

class UsuarioService {
  // OBTENER TODOS LOS USUARIOS (Requiere token de Administrador)
  // Ya no necesitas pasar el token por parámetro 🌟
  static Future<Map<String, dynamic>> listarUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/usuarios'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}', // 👈 Se toma automáticamente de la sesión global
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> listaJson = data['usuarios'];
        List<UserModel> usuarios = listaJson.map((json) => UserModel.fromJson(json)).toList();
        return {'success': true, 'usuarios': usuarios};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['mensaje'] ?? 'Error al obtener usuarios'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // CAMBIAR ESTADO DE USUARIO (Activar / Desactivar)
  // Tampoco necesitas pasar el token por parámetro 🌟
  static Future<bool> cambiarEstado(int idUsuario, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/$idUsuario/estado'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}', // 👈 Se toma automáticamente de la sesión global
        },
        body: jsonEncode({'is_active': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al cambiar estado: $e');
      return false;
    }
  }
}