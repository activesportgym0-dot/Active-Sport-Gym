import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ProductoService {
  // Ajusta si tu ruta en el backend es '/productos' (en plural) o '/producto'
  static const String _rutaProductos = '/producto'; 
  static const String _rutaCategorias = '/categorias-productos';

  static Map<String, String> get _headersJson => {
        ...ApiConfig.headers,
        'Authorization': 'Bearer ${SessionService.token}',
      };

  // GESTIÓN DE PRODUCTOS

  static Future<List<dynamic>> obtenerProductos() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$_rutaProductos'),
        headers: _headersJson,
      );
      
      if (response.statusCode == 200) {
        return _extraerListaFlexible(response.body);
      }
      
      throw Exception(
        _mensaje(
          _decodificarRespuesta(response.body),
          'No se pudieron cargar los productos (${response.statusCode})',
        ),
      );
    } catch (e) {
      print("Excepción en obtenerProductos: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> crearProducto({
    required int idCategoria,
    required String nombre,
    required String marca,
    required String tipoProducto,
    required String sabor,
    required String pesoNeto,
    required String servicios,
    required int precio,
    required int stock,
    required String descripcion,
    required String beneficios,
    required String modoUso,
    required XFile imagenFile,
  }) {
    return _enviarProducto(
      metodo: 'POST',
      ruta: _rutaProductos,
      codigoExito: 201,
      mensajeExito: 'Producto creado correctamente',
      mensajeError: 'Error al registrar el producto',
      imagenFile: imagenFile,
      campos: _camposProducto(
        idCategoria: idCategoria,
        nombre: nombre,
        marca: marca,
        tipoProducto: tipoProducto,
        sabor: sabor,
        pesoNeto: pesoNeto,
        servicios: servicios,
        precio: precio,
        stock: stock,
        descripcion: descripcion,
        beneficios: beneficios,
        modoUso: modoUso,
      ),
    );
  }

  static Future<Map<String, dynamic>> actualizarProducto({
    required int idProducto,
    required int idCategoria,
    required String nombre,
    required String marca,
    required String tipoProducto,
    required String sabor,
    required String pesoNeto,
    required String servicios,
    required int precio,
    required int stock,
    required String descripcion,
    required String beneficios,
    required String modoUso,
    XFile? imagenFile,
  }) {
    return _enviarProducto(
      metodo: 'PUT',
      ruta: '$_rutaProductos/$idProducto',
      codigoExito: 200,
      mensajeExito: 'Producto actualizado correctamente',
      mensajeError: 'Error al actualizar el producto',
      imagenFile: imagenFile,
      campos: _camposProducto(
        idCategoria: idCategoria,
        nombre: nombre,
        marca: marca,
        tipoProducto: tipoProducto,
        sabor: sabor,
        pesoNeto: pesoNeto,
        servicios: servicios,
        precio: precio,
        stock: stock,
        descripcion: descripcion,
        beneficios: beneficios,
        modoUso: modoUso,
      ),
    );
  }

  static Future<Map<String, dynamic>> eliminarProducto(int idProducto) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaProductos/$idProducto'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Producto eliminado correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensaje(data, 'No se pudo eliminar el producto'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // GESTIÓN DE CATEGORÍAS

  static Future<List<dynamic>> obtenerCategorias() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$_rutaCategorias'),
        headers: _headersJson,
      );
      if (response.statusCode == 200) {
        return _extraerListaFlexible(response.body);
      }
      return [];
    } catch (e) {
      print("Excepción en obtenerCategorias: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> crearCategoria(String nombre) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$_rutaCategorias'),
        headers: _headersJson,
        body: jsonEncode({'nombre': nombre}),
      );
      final data = _decodificarRespuesta(response.body);
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Categoría creada correctamente',
          'categoria': data['categoria'],
        };
      }
      return {
        'success': false,
        'message': _mensaje(data, 'Error al crear la categoría'),
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
        Uri.parse('${ApiConfig.baseUrl}$_rutaCategorias/$idCategoria'),
        headers: _headersJson,
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
        'message': _mensaje(data, 'Error al actualizar la categoría'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor'};
    }
  }

  static Future<Map<String, dynamic>> eliminarCategoria(int idCategoria) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$_rutaCategorias/$idCategoria'),
        headers: _headersJson,
      );
      final data = _decodificarRespuesta(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Categoría eliminada correctamente',
        };
      }
      return {
        'success': false,
        'message': _mensaje(data, 'Error al eliminar la categoría'),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión con el servidor'};
    }
  }

  // AUXILIARES PRIVADOS

  static Map<String, String> _camposProducto({
    required int idCategoria,
    required String nombre,
    required String marca,
    required String tipoProducto,
    required String sabor,
    required String pesoNeto,
    required String servicios,
    required int precio,
    required int stock,
    required String descripcion,
    required String beneficios,
    required String modoUso,
  }) {
    return {
      'id_categoria': idCategoria.toString(),
      'nombre': nombre,
      'marca': marca,
      'tipo_producto': tipoProducto,
      'sabor': sabor,
      'peso_neto': pesoNeto,
      'servicios': servicios,
      'precio': precio.toString(),
      'stock': stock.toString(),
      'descripcion': descripcion,
      'beneficios': beneficios,
      'modo_uso': modoUso,
    };
  }

  static Future<Map<String, dynamic>> _enviarProducto({
    required String metodo,
    required String ruta,
    required Map<String, String> campos,
    required int codigoExito,
    required String mensajeExito,
    required String mensajeError,
    XFile? imagenFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        metodo,
        Uri.parse('${ApiConfig.baseUrl}$ruta'),
      );
      request.headers['Authorization'] = 'Bearer ${SessionService.token}';
      request.fields.addAll(campos);

      if (imagenFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'imagen',
            await imagenFile.readAsBytes(),
            filename: _nombreArchivo(imagenFile, 'producto.jpg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _decodificarRespuesta(response.body);

      if (response.statusCode == codigoExito) {
        return {
          'success': true,
          'message': data['mensaje'] ?? mensajeExito,
          'data': data['producto'],
        };
      }
      return {'success': false, 'message': _mensaje(data, mensajeError)};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  static String _mensaje(Map<String, dynamic> data, String porDefecto) {
    return (data['mensaje'] ?? data['error'] ?? porDefecto).toString();
  }

  /// Extractor flexible que detecta listas sin importar cómo las envuelva el backend
  static List<dynamic> _extraerListaFlexible(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) return decoded;
      if (decoded is Map) {
        // Busca en cualquier llave común que devuelva una lista (productos, data, categorias, etc.)
        for (var entry in decoded.entries) {
          if (entry.value is List) {
            return entry.value as List;
          }
        }
      }
      return [];
    } catch (e) {
      print("Error decodificando lista: $e");
      return [];
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
}