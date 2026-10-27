import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_config.dart';
import 'auth_service.dart';

class EjercicioService {
  // GESTIÓN DE EJERCICIOS

  static Future<List<dynamic>> obtenerEjercicios() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ejercicios'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ejercicios'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error al obtener ejercicios: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> crearEjercicio({
    required String nombre,
    required String maquina,
    required String descripcion,
    required String instrucciones,
    required String beneficios,
    required String rangoMovimiento,
    required String respiracion,
    required String ritmoMovimiento,
    required XFile imagenFile,
    XFile? gifFile,
    required List<int> categoriasIds,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ejercicios');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer ${SessionService.token}',
      });

      request.fields['nombre'] = nombre;
      request.fields['maquina'] = maquina;
      request.fields['descripcion'] = descripcion;
      request.fields['instrucciones'] = instrucciones;
      request.fields['beneficios'] = beneficios;
      request.fields['rango_movimiento'] = rangoMovimiento;
      request.fields['respiracion'] = respiracion;
      request.fields['ritmo_movimiento'] = ritmoMovimiento;
      request.fields['categorias'] = jsonEncode(categoriasIds);

      request.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          await imagenFile.readAsBytes(),
          filename: _nombreArchivo(imagenFile, 'imagen.jpg'),
        ),
      );

      if (gifFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'gif_url',
            await gifFile.readAsBytes(),
            filename: _nombreArchivo(gifFile, 'demostracion.mp4'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Ejercicio creado correctamente',
          'data': data['ejercicio'],
        };
      }

      return {
        'success': false,
        'message': data['mensaje'] ?? 'Error al registrar el ejercicio',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> actualizarEjercicio({
    required int idEjercicio,
    required String nombre,
    required String maquina,
    required String descripcion,
    required String instrucciones,
    required String beneficios,
    required String rangoMovimiento,
    required String respiracion,
    required String ritmoMovimiento,
    XFile? imagenFile,
    XFile? gifFile,
    required List<int> categoriasIds,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/ejercicios/$idEjercicio');
      final request = http.MultipartRequest('PUT', uri);

      request.headers.addAll({
        'Authorization': 'Bearer ${SessionService.token}',
      });

      request.fields['nombre'] = nombre;
      request.fields['maquina'] = maquina;
      request.fields['descripcion'] = descripcion;
      request.fields['instrucciones'] = instrucciones;
      request.fields['beneficios'] = beneficios;
      request.fields['rango_movimiento'] = rangoMovimiento;
      request.fields['respiracion'] = respiracion;
      request.fields['ritmo_movimiento'] = ritmoMovimiento;
      request.fields['categorias'] = jsonEncode(categoriasIds);

      if (imagenFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'imagen',
            await imagenFile.readAsBytes(),
            filename: _nombreArchivo(imagenFile, 'imagen.jpg'),
          ),
        );
      }

      if (gifFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'gif_url',
            await gifFile.readAsBytes(),
            filename: _nombreArchivo(gifFile, 'demostracion.mp4'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Ejercicio actualizado correctamente',
          'data': data['ejercicio'],
        };
      }

      return {
        'success': false,
        'message': data['mensaje'] ?? 'Error al actualizar el ejercicio',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static String _nombreArchivo(XFile archivo, String predeterminado) {
    final nombre = archivo.name.trim();
    return nombre.isEmpty ? predeterminado : nombre;
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

  static Future<bool> eliminarEjercicio(int idEjercicio) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/ejercicios/$idEjercicio'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar ejercicio: $e');
      return false;
    }
  }

  // GESTIÓN DE CATEGORÍAS

  static Future<List<dynamic>> obtenerCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['categorias'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error al obtener categorías: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> crearCategoria(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/categorias'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}',
        },
        body: jsonEncode({'nombre': nombre}),
      );

      final data = _decodificarRespuesta(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'],
          'categoria': data['categoria'],
        };
      }

      return {
        'success': false,
        'message': data['mensaje'] ?? 'Error al crear la categoría',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static Future<Map<String, dynamic>> actualizarCategoria(
    int idCategoria,
    String nuevoNombre,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/categorias/$idCategoria'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'nombre': nuevoNombre}),
      );

      final data = _decodificarRespuesta(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Categoría actualizada correctamente',
        };
      }

      return {
        'success': false,
        'message': data['mensaje'] ?? 'Error al actualizar la categoría',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión con el servidor',
      };
    }
  }

  static Future<Map<String, dynamic>> eliminarCategoria(int idCategoria) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/categorias/$idCategoria'),
        headers: {
          ...ApiConfig.headers,
          'Authorization': 'Bearer ${SessionService.token}',
        },
      );

      final data = _decodificarRespuesta(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Categoría eliminada correctamente',
        };
      }

      if (response.statusCode == 409) {
        final ejercicio = data['ejercicio'];
        final nombreEjercicio = ejercicio is Map
            ? (ejercicio['nombre'] ?? 'un ejercicio').toString()
            : 'un ejercicio';

        return {
          'success': false,
          'message': data['mensaje'] ??
              'No se puede eliminar porque hay ejercicios asociados.',
          'ejercicio': nombreEjercicio,
        };
      }

      return {
        'success': false,
        'message': data['mensaje'] ?? 'Error al eliminar la categoría',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor'};
    }
  }
}
