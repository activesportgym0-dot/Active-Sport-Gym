/// Registro de membresía (tabla membresias).
class MembresiaModel {
  static const List<String> estados = ['activa', 'inactiva', 'vencida'];

  final int idMembresia;
  final int idUsuario;
  final String estado; // 'activa', 'inactiva' o 'vencida'
  final String fechaInicio;
  final String fechaFin;

  const MembresiaModel({
    required this.idMembresia,
    required this.idUsuario,
    required this.estado,
    this.fechaInicio = '',
    this.fechaFin = '',
  });

  String get fechaInicioFormateada => formatearFecha(fechaInicio);
  String get fechaFinFormateada => formatearFecha(fechaFin);

  factory MembresiaModel.fromJson(Map<String, dynamic> json) {
    return MembresiaModel(
      idMembresia: int.tryParse(json['id_membresia'].toString()) ?? 0,
      idUsuario: int.tryParse(json['id_usuario'].toString()) ?? 0,
      estado: (json['estado'] ?? '').toString().toLowerCase(),
      fechaInicio: (json['fecha_inicio'] ?? '').toString(),
      fechaFin: (json['fecha_fin'] ?? '').toString(),
    );
  }

  /// "2026-10-16" (o con hora) -> "16/10/2026". Son fechas de calendario,
  /// no instantes, por eso no se convierten a la hora local.
  static String formatearFecha(String valor) {
    final fecha = DateTime.tryParse(valor);
    if (fecha == null) return valor.isEmpty ? '—' : valor;
    return fechaCorta(fecha);
  }

  /// DateTime -> "16/10/2026"
  static String fechaCorta(DateTime fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}';
  }

  /// DateTime -> "2026-10-16" (el formato que valida el backend).
  static String fechaIso(DateTime fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${fecha.year}-${dos(fecha.month)}-${dos(fecha.day)}';
  }
}

/// Un cliente con su membresía más reciente (GET /membresias/admin).
/// Si nunca ha tenido plan, [membresia] es null.
class ClienteMembresiaModel {
  final int idUsuario;
  final String nombre;
  final String correo;
  final MembresiaModel? membresia;

  const ClienteMembresiaModel({
    required this.idUsuario,
    required this.nombre,
    this.correo = '',
    this.membresia,
  });

  /// Texto del estado para mostrar: 'activa', 'inactiva', 'vencida' o 'sin membresía'.
  String get estadoVisible => membresia?.estado ?? 'sin membresía';

  factory ClienteMembresiaModel.fromJson(Map<String, dynamic> json) {
    return ClienteMembresiaModel(
      idUsuario: int.tryParse(json['id_usuario'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      membresia: json['membresia'] is Map
          ? MembresiaModel.fromJson(
              Map<String, dynamic>.from(json['membresia'] as Map),
            )
          : null,
    );
  }
}
