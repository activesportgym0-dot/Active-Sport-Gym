/// Ejercicio del catálogo (GET /ejercicios), tal como lo ve el cliente al armar una rutina.
/// Se llama "Catalogo" para no chocar con el EjercicioModel que ya tienes.
class EjercicioCatalogoModel {
  final int idEjercicio;
  final String nombre;
  final String maquina;
  final String descripcion;
  final String imagen; // URL de Cloudinary (vacía si no tiene)
  final List<String> categorias; // nombres de las categorías del ejercicio

  const EjercicioCatalogoModel({
    required this.idEjercicio,
    required this.nombre,
    this.maquina = '',
    this.descripcion = '',
    this.imagen = '',
    this.categorias = const [],
  });

  String get categoriaPrincipal => categorias.isNotEmpty ? categorias.first : 'Sin categoría';

  /// Texto de la etiqueta amarilla: "ESPALDA - MANCUERNAS".
  /// (Antes decía siempre "- RESISTENCIA", sin importar el ejercicio.)
  String get etiqueta {
    final base = categoriaPrincipal.toUpperCase();
    return maquina.trim().isEmpty ? base : '$base - ${maquina.trim().toUpperCase()}';
  }

  /// ¿Pertenece a esa categoría? (sin distinguir mayúsculas)
  bool perteneceA(String categoria) {
    final buscada = categoria.toLowerCase();
    return categorias.any((c) => c.toLowerCase() == buscada);
  }

  factory EjercicioCatalogoModel.fromJson(Map<String, dynamic> json) {
    // ejercicio_categoria: [{id_categoria, categoria_ejercicios: {id_categoria, nombre}}]
    final nombres = <String>[];
    final rawCategorias = json['ejercicio_categoria'];
    if (rawCategorias is List) {
      for (final item in rawCategorias) {
        if (item is! Map) continue;
        final categoria = item['categoria_ejercicios'];
        final nombre = categoria is Map ? categoria['nombre']?.toString() : null;
        if (nombre != null && nombre.isNotEmpty) nombres.add(nombre);
      }
    }

    return EjercicioCatalogoModel(
      idEjercicio: int.tryParse(json['id_ejercicio'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      maquina: (json['maquina'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      imagen: (json['imagen'] ?? '').toString(),
      categorias: nombres,
    );
  }

  /// Mapa con las claves que ya usan las pantallas de crear rutina, la tarjeta del
  /// ejercicio y los resúmenes (id_ejercicio, title, category, description, imagePath).
  Map<String, dynamic> toMapaSeleccion() {
    return {
      'id_ejercicio': idEjercicio,
      'title': nombre,
      'category': categoriaPrincipal,
      'etiqueta': etiqueta,
      'description': descripcion,
      'imagePath': imagen, // ahora es una URL de internet
    };
  }
}
