/// Una fila de "Últimas acciones registradas" del home del administrador.
class ActividadModel {
  final String tipo; // 'ejercicio' o 'producto'
  final String titulo;
  final String detalle;
  final String fecha;

  const ActividadModel({
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.fecha,
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) {
    return ActividadModel(
      tipo: (json['tipo'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      detalle: (json['detalle'] ?? '').toString(),
      fecha: (json['fecha'] ?? '').toString(),
    );
  }

  /// "Hace 5 min", "Hace 2 horas", "Hace 3 días" o la fecha si ya pasó una semana.
  String get tiempoRelativo {
    final fechaLocal = DateTime.tryParse(fecha)?.toLocal();
    if (fechaLocal == null) return '';

    final diferencia = DateTime.now().difference(fechaLocal);
    if (diferencia.inMinutes < 1) return 'Hace unos segundos';
    if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inHours < 24) {
      final h = diferencia.inHours;
      return 'Hace $h ${h == 1 ? 'hora' : 'horas'}';
    }
    if (diferencia.inDays < 7) {
      final d = diferencia.inDays;
      return 'Hace $d ${d == 1 ? 'día' : 'días'}';
    }
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fechaLocal.day)}/${dos(fechaLocal.month)}/${fechaLocal.year}';
  }
}

/// Respuesta de GET /dashboard/resumen: totales de las tarjetas + actividad.
class ResumenAdminModel {
  final int ejercicios;
  final int productos;
  final int productosConStock;
  final int membresias;
  final int membresiasActivas;
  final int usuarios;
  final List<ActividadModel> actividad;

  const ResumenAdminModel({
    this.ejercicios = 0,
    this.productos = 0,
    this.productosConStock = 0,
    this.membresias = 0,
    this.membresiasActivas = 0,
    this.usuarios = 0,
    this.actividad = const [],
  });

  factory ResumenAdminModel.fromJson(Map<String, dynamic> json) {
    final totales = json['totales'] is Map
        ? Map<String, dynamic>.from(json['totales'] as Map)
        : <String, dynamic>{};
    final rawActividad = json['actividad'] is List ? json['actividad'] as List : [];

    int entero(String clave) => int.tryParse(totales[clave].toString()) ?? 0;

    return ResumenAdminModel(
      ejercicios: entero('ejercicios'),
      productos: entero('productos'),
      productosConStock: entero('productosConStock'),
      membresias: entero('membresias'),
      membresiasActivas: entero('membresiasActivas'),
      usuarios: entero('usuarios'),
      actividad: rawActividad
          .whereType<Map>()
          .map((a) => ActividadModel.fromJson(Map<String, dynamic>.from(a)))
          .toList(),
    );
  }
}
