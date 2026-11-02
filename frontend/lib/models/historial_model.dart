/// Entrenamientos que el cliente ya completó (GET /historial).
/// Estructura del backend: historial_rutinas -> historial_ejercicios.
/// Los tiempos se guardan en SEGUNDOS (columnas tiempo_total y tiempo_ejercicio).

/// "45 s", "12 min", "5 min 10 s", "1 h 05 min"
String formatearDuracion(int segundos) {
  if (segundos < 60) return '$segundos s';

  final horas = segundos ~/ 3600;
  final minutos = (segundos % 3600) ~/ 60;
  final resto = segundos % 60;

  if (horas > 0) return '$horas h ${minutos.toString().padLeft(2, '0')} min';
  return resto == 0 ? '$minutos min' : '$minutos min $resto s';
}

class HistorialEjercicioModel {
  final int idEjercicio;
  final String nombre;
  final int tiempoSegundos;

  const HistorialEjercicioModel({
    required this.idEjercicio,
    required this.nombre,
    required this.tiempoSegundos,
  });

  String get tiempoFormateado => formatearDuracion(tiempoSegundos);

  factory HistorialEjercicioModel.fromJson(Map<String, dynamic> json) {
    final ejercicio = json['ejercicios'] is Map ? json['ejercicios'] as Map : const {};
    return HistorialEjercicioModel(
      idEjercicio: int.tryParse(json['id_ejercicio'].toString()) ?? 0,
      nombre: (ejercicio['nombre'] ?? 'Ejercicio').toString(),
      tiempoSegundos: int.tryParse(json['tiempo_ejercicio'].toString()) ?? 0,
    );
  }
}

class HistorialModel {
  final int idHistorial;
  final int idRutina;
  final String nombreRutina;
  final String tipo; // 'diaria' o 'semanal'
  final String fechaRealizacion;
  final int tiempoTotalSegundos;
  final List<HistorialEjercicioModel> ejercicios;

  const HistorialModel({
    required this.idHistorial,
    required this.idRutina,
    required this.nombreRutina,
    this.tipo = '',
    this.fechaRealizacion = '',
    this.tiempoTotalSegundos = 0,
    this.ejercicios = const [],
  });

  String get tiempoTotalFormateado => formatearDuracion(tiempoTotalSegundos);

  /// "2026-10-19T14:30:00+00:00" -> "19/10/2026" (hora local del teléfono)
  String get fechaFormateada {
    final f = DateTime.tryParse(fechaRealizacion)?.toLocal();
    if (f == null) return fechaRealizacion.isEmpty ? 'Sin fecha' : fechaRealizacion;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year}';
  }

  factory HistorialModel.fromJson(Map<String, dynamic> json) {
    final rutina = json['rutinas'] is Map ? json['rutinas'] as Map : const {};
    final rawEjercicios = json['historial_ejercicios'] is List ? json['historial_ejercicios'] as List : const [];

    return HistorialModel(
      idHistorial: int.tryParse(json['id_historial'].toString()) ?? 0,
      idRutina: int.tryParse(rutina['id_rutina'].toString()) ?? 0,
      nombreRutina: (rutina['nombre'] ?? 'Rutina').toString(),
      tipo: (rutina['tipo'] ?? '').toString(),
      fechaRealizacion: (json['fecha_realizacion'] ?? '').toString(),
      tiempoTotalSegundos: int.tryParse(json['tiempo_total'].toString()) ?? 0,
      ejercicios: rawEjercicios
          .whereType<Map>()
          .map((e) => HistorialEjercicioModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
