/// Regla o horario del gimnasio (tabla reglas_horarios).
/// Columnas: id_regla_horario, tipo, titulo, contenido.
class ReglaHorarioModel {
  static const String tipoHorario = 'Horario';
  static const String tipoRegla = 'Regla';
  static const List<String> tipos = [tipoHorario, tipoRegla];

  final int idReglaHorario;
  final String tipo; // 'Horario' o 'Regla'
  final String titulo;
  final String contenido;

  const ReglaHorarioModel({
    required this.idReglaHorario,
    required this.tipo,
    required this.titulo,
    required this.contenido,
  });

  bool get esHorario => tipo == tipoHorario;
  bool get esRegla => tipo == tipoRegla;

  factory ReglaHorarioModel.fromJson(Map<String, dynamic> json) {
    return ReglaHorarioModel(
      idReglaHorario: int.tryParse(json['id_regla_horario'].toString()) ?? 0,
      tipo: normalizarTipo((json['tipo'] ?? '').toString()),
      titulo: (json['titulo'] ?? '').toString(),
      contenido: (json['contenido'] ?? '').toString(),
    );
  }

  /// La pantalla filtra con "Horario" y "Regla" (con mayúscula inicial). Si algún
  /// registro se guardó como "horario" o "REGLA", se normaliza para que no se pierda.
  static String normalizarTipo(String valor) {
    final limpio = valor.trim().toLowerCase();
    if (limpio == 'horario') return tipoHorario;
    if (limpio == 'regla') return tipoRegla;
    return valor.trim();
  }

  /// Mapa con las claves que ya usan ReglaHorarioCard y ModalReglaHorario
  /// (id, tipo, titulo, contenido), así esos componentes no cambian.
  Map<String, dynamic> toMapaTarjeta() {
    return {
      'id': idReglaHorario,
      'tipo': tipo,
      'titulo': titulo,
      'contenido': contenido,
    };
  }
}
