
import 'dart:convert';
import 'package:http/http.dart' as http;

class ColombiaService {
  static const String _baseUrl = 'https://api-colombia.com/api/v1';

  // Consultar departamentos
  static Future<List<Map<String, dynamic>>> obtenerDepartamentos() async {
    final url = Uri.parse('$_baseUrl/Department');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(response.body);

      return datos.map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
        };
      }).toList();
    } else {
      throw Exception('No se pudieron cargar los departamentos');
    }
  }

  // Consultar municipios de un departamento
  static Future<List<Map<String, dynamic>>> obtenerMunicipios(
    int departamentoId,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/Department/$departamentoId/cities',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(response.body);

      return datos.map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
        };
      }).toList();
    } else {
      throw Exception('No se pudieron cargar los municipios');
    }
  }
}
