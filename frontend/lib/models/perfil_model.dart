/// Datos de un usuario con su foto (GET /perfil/:id_usuario).
/// Sirve tanto para la pantalla "Mi perfil" como para el detalle que ve el admin.
class PerfilModel {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String cedula;
  final int? edad;
  final double? peso;
  final double? altura;
  final String rol;
  final String fechaRegistro;
  final String? fotoPerfil;

  const PerfilModel({
    required this.idUsuario,
    required this.nombre,
    this.apellido = '',
    this.correo = '',
    this.telefono = '',
    this.cedula = '',
    this.edad,
    this.peso,
    this.altura,
    this.rol = 'cliente',
    this.fechaRegistro = '',
    this.fotoPerfil,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  /// "2026-10-06T14:30:00" -> "06/10/2026"
  String get fechaRegistroFormateada {
    final f = DateTime.tryParse(fechaRegistro);
    if (f == null) return fechaRegistro.isEmpty ? '—' : fechaRegistro;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year}';
  }

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    // "perfil" es la relación con la tabla perfil: según cómo esté definida
    // en Supabase llega como objeto o como lista de un elemento.
    Map<String, dynamic> perfil = {};
    final rawPerfil = json['perfil'];
    if (rawPerfil is Map) {
      perfil = Map<String, dynamic>.from(rawPerfil);
    } else if (rawPerfil is List && rawPerfil.isNotEmpty && rawPerfil.first is Map) {
      perfil = Map<String, dynamic>.from(rawPerfil.first as Map);
    }

    final foto = perfil['foto_perfil']?.toString() ?? '';

    return PerfilModel(
      idUsuario: int.tryParse(json['id_usuario'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      cedula: (json['cedula'] ?? '').toString(),
      edad: json['edad'] == null ? null : int.tryParse(json['edad'].toString()),
      peso: json['peso'] == null ? null : double.tryParse(json['peso'].toString()),
      altura: json['altura'] == null ? null : double.tryParse(json['altura'].toString()),
      rol: (json['rol'] ?? 'cliente').toString(),
      fechaRegistro: (json['fecha_registro'] ?? '').toString(),
      fotoPerfil: foto.isEmpty ? null : foto,
    );
  }
}
