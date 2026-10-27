class CategoriaAsociada {
  final int idCategoria;
  final String nombre;

  CategoriaAsociada({required this.idCategoria, required this.nombre});

  factory CategoriaAsociada.fromJson(Map<String, dynamic> json) {
    final cat = json['categoria_ejercicios'] ?? {};
    return CategoriaAsociada(
      idCategoria: cat['id_categoria'] ?? 0,
      nombre: cat['nombre'] ?? '',
    );
  }
}

class EjercicioModel {
  final int idEjercicio;
  final String nombre;
  final String? imagen;
  final String? gifUrl;
  final String maquina;
  final String? instrucciones;
  final String? descripcion;
  final String? beneficios;
  final String? rangoMovimiento;
  final String? respiracion;
  final String? ritmoMovimiento;
  final List<CategoriaAsociada> categorias;

  EjercicioModel({
    required this.idEjercicio,
    required this.nombre,
    this.imagen,
    this.gifUrl,
    required this.maquina,
    this.instrucciones,
    this.descripcion,
    this.beneficios,
    this.rangoMovimiento,
    this.respiracion,
    this.ritmoMovimiento,
    required this.categorias,
  });

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    var rawCategorias = json['ejercicio_categoria'] as List? ?? [];
    List<CategoriaAsociada> listaCats = rawCategorias
        .map((c) => CategoriaAsociada.fromJson(c))
        .toList();

    return EjercicioModel(
      idEjercicio: json['id_ejercicio'] ?? 0,
      nombre: json['nombre'] ?? '',
      imagen: json['imagen'],
      gifUrl: json['gif_url'],
      maquina: json['maquina'] ?? '',
      instrucciones: json['instrucciones'],
      descripcion: json['descripcion'],
      beneficios: json['beneficios'],
      rangoMovimiento: json['rango_movimiento'],
      respiracion: json['respiracion'],
      ritmoMovimiento: json['ritmo_movimiento'],
      categorias: listaCats,
    );
  }
}