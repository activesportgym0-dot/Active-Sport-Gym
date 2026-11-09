/// Medida de progreso del cliente (tabla progreso en Supabase).
/// Columnas que devuelve el backend: id_progreso, id_historial_medida, id_usuario,
/// fecha_registro, peso_actual, altura, imc, pecho, cintura, cadera, brazo_izquierdo,
/// brazo_derecho, muslo_izquierdo, muslo_derecho, pantorrilla_izquierda, pantorrilla_derecha.
class ProgresoModel {
  final int idProgreso;
  final int? idHistorialMedida;
  final int? idUsuario;
  final String fechaRegistro; // YYYY-MM-DD
  final double pesoActual; // Kg
  final double altura; // metros
  final double? imc;
  final double pecho;
  final double cintura;
  final double cadera;
  final double brazoIzquierdo;
  final double brazoDerecho;
  final double musloIzquierdo;
  final double musloDerecho;
  final double pantorrillaIzquierda;
  final double pantorrillaDerecha;

  const ProgresoModel({
    required this.idProgreso,
    this.idHistorialMedida,
    this.idUsuario,
    required this.fechaRegistro,
    required this.pesoActual,
    required this.altura,
    this.imc,
    required this.pecho,
    required this.cintura,
    required this.cadera,
    required this.brazoIzquierdo,
    required this.brazoDerecho,
    required this.musloIzquierdo,
    required this.musloDerecho,
    required this.pantorrillaIzquierda,
    required this.pantorrillaDerecha,
  });

  factory ProgresoModel.fromJson(Map<String, dynamic> json) {
    return ProgresoModel(
      idProgreso: _aInt(json['id_progreso']) ?? 0,
      idHistorialMedida: _aInt(json['id_historial_medida']),
      idUsuario: _aInt(json['id_usuario']),
      fechaRegistro: (json['fecha_registro'] ?? '').toString(),
      pesoActual: _aDouble(json['peso_actual']) ?? 0,
      altura: _aDouble(json['altura']) ?? 0,
      imc: _aDouble(json['imc']),
      pecho: _aDouble(json['pecho']) ?? 0,
      cintura: _aDouble(json['cintura']) ?? 0,
      cadera: _aDouble(json['cadera']) ?? 0,
      brazoIzquierdo: _aDouble(json['brazo_izquierdo']) ?? 0,
      brazoDerecho: _aDouble(json['brazo_derecho']) ?? 0,
      musloIzquierdo: _aDouble(json['muslo_izquierdo']) ?? 0,
      musloDerecho: _aDouble(json['muslo_derecho']) ?? 0,
      pantorrillaIzquierda: _aDouble(json['pantorrilla_izquierda']) ?? 0,
      pantorrillaDerecha: _aDouble(json['pantorrilla_derecha']) ?? 0,
    );
  }

  /// Cuerpo que espera POST /progreso. El backend exige los 11 campos > 0
  /// y calcula el IMC y la fecha por su cuenta.
  static Map<String, dynamic> toJsonCrear({
    required double pesoActual,
    required double altura,
    required double brazoIzquierdo,
    required double brazoDerecho,
    required double pecho,
    required double cintura,
    required double cadera,
    required double musloIzquierdo,
    required double musloDerecho,
    required double pantorrillaIzquierda,
    required double pantorrillaDerecha,
  }) {
    return {
      'peso_actual': pesoActual,
      'altura': altura,
      'brazo_izquierdo': brazoIzquierdo,
      'brazo_derecho': brazoDerecho,
      'pecho': pecho,
      'cintura': cintura,
      'cadera': cadera,
      'muslo_izquierdo': musloIzquierdo,
      'muslo_derecho': musloDerecho,
      'pantorrilla_izquierda': pantorrillaIzquierda,
      'pantorrilla_derecha': pantorrillaDerecha,
    };
  }

  /// Mapa con las claves que ya usa DetalleMedidaScreen ('created_at', 'peso_actual', ...),
  /// así esa pantalla no cambia.
  Map<String, dynamic> toMapaTarjeta() {
    return {
      'id': idProgreso,
      'created_at': fechaRegistro,
      'peso_actual': pesoActual,
      'altura': altura,
      'imc': imc,
      'brazo_izquierdo': brazoIzquierdo,
      'brazo_derecho': brazoDerecho,
      'pecho': pecho,
      'cintura': cintura,
      'cadera': cadera,
      'muslo_izquierdo': musloIzquierdo,
      'muslo_derecho': musloDerecho,
      'pantorrilla_izquierda': pantorrillaIzquierda,
      'pantorrilla_derecha': pantorrillaDerecha,
    };
  }

  // Supabase puede devolver los numeric como número o como texto: se aceptan ambos.
  static double? _aDouble(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());

  static int? _aInt(dynamic v) => v == null ? null : int.tryParse(v.toString());
}
