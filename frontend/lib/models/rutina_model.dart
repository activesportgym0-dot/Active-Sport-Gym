/// Modelos para CREAR una rutina (POST /rutinas).
/// Reflejan las tablas rutinas -> rutina_dias -> rutina_ejercicios -> rutina_series.
/// Las pantallas guardan lo que el usuario escribe en mapas; aquí esos mapas se
/// validan y se convierten al JSON que espera el backend. Si algo está mal se lanza
/// una FormatException con un mensaje listo para mostrar al usuario.

class SerieRutinaModel {
  final int repeticiones;
  final double? peso;
  final int? descansoEntreSeries;

  const SerieRutinaModel({
    required this.repeticiones,
    this.peso,
    this.descansoEntreSeries,
  });

  Map<String, dynamic> toJson() => {
        'repeticiones': repeticiones,
        'peso': peso,
        'descanso_entre_series': descansoEntreSeries,
      };

  /// Serie nueva para las pantallas. Lleva el tipo explícito <String, dynamic>:
  /// si se escribiera como literal sin tipo, Dart la inferiría como Map<String, int>
  /// y fallaría al guardar un peso decimal o un campo vacío (null).
  static Map<String, dynamic> mapaNuevo({int descansoEntreSeries = 30}) {
    return <String, dynamic>{
      'repeticiones': 10,
      'peso': 0,
      'descanso_entre_series': descansoEntreSeries,
    };
  }
}

class EjercicioRutinaModel {
  final int idEjercicio;
  final int? descansoFinal;
  final List<SerieRutinaModel> series;

  const EjercicioRutinaModel({
    required this.idEjercicio,
    this.descansoFinal,
    required this.series,
  });

  /// Convierte el mapa de una tarjeta de ejercicio de la pantalla. [numero] es la
  /// posición (1, 2, 3...) y solo se usa para armar mensajes de error claros.
  factory EjercicioRutinaModel.desdeMapaPantalla(Map<String, dynamic> mapa, {required int numero}) {
    final id = int.tryParse(mapa['id_ejercicio'].toString());
    if (id == null || id <= 0) {
      throw FormatException('Elige el ejercicio $numero o elimínalo de la lista.');
    }

    final rawSeries = mapa['series'] is List ? mapa['series'] as List : const [];
    if (rawSeries.isEmpty) {
      throw FormatException('El ejercicio $numero debe tener al menos una serie.');
    }

    final series = <SerieRutinaModel>[];
    for (var i = 0; i < rawSeries.length; i++) {
      final serie = rawSeries[i] is Map ? Map<String, dynamic>.from(rawSeries[i] as Map) : <String, dynamic>{};
      final repeticiones = int.tryParse(serie['repeticiones'].toString());
      if (repeticiones == null || repeticiones <= 0) {
        throw FormatException('Ejercicio $numero, serie ${i + 1}: las repeticiones deben ser mayores que cero.');
      }

      double? peso;
      if (serie['peso'] != null && serie['peso'].toString().trim().isNotEmpty) {
        peso = double.tryParse(serie['peso'].toString().replaceAll(',', '.'));
        if (peso == null || peso < 0) {
          throw FormatException('Ejercicio $numero, serie ${i + 1}: el peso no es válido.');
        }
      }

      series.add(
        SerieRutinaModel(
          repeticiones: repeticiones,
          peso: peso,
          descansoEntreSeries: int.tryParse(serie['descanso_entre_series'].toString()),
        ),
      );
    }

    return EjercicioRutinaModel(
      idEjercicio: id,
      descansoFinal: int.tryParse(mapa['descanso_final'].toString()),
      series: series,
    );
  }

  /// Convierte la lista de tarjetas de ejercicio de una pantalla.
  static List<EjercicioRutinaModel> listaDesdePantalla(List<dynamic> ejercicios) {
    final resultado = <EjercicioRutinaModel>[];
    for (var i = 0; i < ejercicios.length; i++) {
      resultado.add(
        EjercicioRutinaModel.desdeMapaPantalla(
          Map<String, dynamic>.from(ejercicios[i] as Map),
          numero: i + 1,
        ),
      );
    }
    return resultado;
  }

  /// Tarjeta de ejercicio vacía para las pantallas: todavía sin ejercicio elegido
  /// (id_ejercicio null), por eso la tarjeta muestra el mini buscador.
  static Map<String, dynamic> mapaPantallaVacio() {
    return <String, dynamic>{
      'id_ejercicio': null,
      'descanso_final': 60,
      'series': <Map<String, dynamic>>[SerieRutinaModel.mapaNuevo()],
    };
  }

  Map<String, dynamic> toJson() => {
        'id_ejercicio': idEjercicio,
        'descanso_final': descansoFinal,
        'series': series.map((s) => s.toJson()).toList(),
      };
}

class DiaRutinaModel {
  final String diaSemana; // lunes, martes, miércoles, jueves, viernes, sábado, domingo
  final String nombreDia; // nombre de la rutina de ese día (ej. "Espalda")
  final List<EjercicioRutinaModel> ejercicios;

  const DiaRutinaModel({
    required this.diaSemana,
    required this.nombreDia,
    required this.ejercicios,
  });

  Map<String, dynamic> toJson() => {
        'dia_semana': diaSemana,
        'nombre_dia': nombreDia,
        'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
      };
}

/// Rutina nueva lista para enviar al backend.
class RutinaNuevaModel {
  final String nombre;
  final String tipo; // 'diaria' o 'semanal'
  final String? fecha; // YYYY-MM-DD (el backend la valida con new Date())
  final List<EjercicioRutinaModel> ejercicios; // solo rutinas diarias
  final List<DiaRutinaModel> dias; // solo rutinas semanales

  const RutinaNuevaModel._({
    required this.nombre,
    required this.tipo,
    this.fecha,
    this.ejercicios = const [],
    this.dias = const [],
  });

  /// Rutina diaria: [ejercicios] son las tarjetas de la pantalla.
  factory RutinaNuevaModel.diaria({
    required String nombre,
    String? fecha,
    required List<dynamic> ejercicios,
  }) {
    final lista = EjercicioRutinaModel.listaDesdePantalla(ejercicios);
    if (lista.isEmpty) throw const FormatException('Agrega al menos un ejercicio.');
    return RutinaNuevaModel._(
      nombre: nombre.trim(),
      tipo: 'diaria',
      fecha: _fechaONull(fecha),
      ejercicios: lista,
    );
  }

  /// Rutina semanal: [dias] ya viene armada por la pantalla (solo los días con ejercicios).
  factory RutinaNuevaModel.semanal({
    required String nombre,
    String? fecha,
    required List<DiaRutinaModel> dias,
  }) {
    if (dias.length < 2) {
      throw const FormatException('Un plan semanal debe tener ejercicios en al menos 2 días.');
    }
    return RutinaNuevaModel._(
      nombre: nombre.trim(),
      tipo: 'semanal',
      fecha: _fechaONull(fecha),
      dias: dias,
    );
  }

  static String? _fechaONull(String? fecha) {
    if (fecha == null || fecha.trim().isEmpty) return null;
    return fecha.trim();
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'nombre': nombre, 'tipo': tipo};
    if (fecha != null) json['fecha'] = fecha;
    if (tipo == 'diaria') {
      json['ejercicios'] = ejercicios.map((e) => e.toJson()).toList();
    } else {
      json['dias'] = dias.map((d) => d.toJson()).toList();
    }
    return json;
  }

  /// "2026-10-31" desde un DateTime (el formato que acepta el backend).
  static String fechaIso(DateTime fecha) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${fecha.year}-${dos(fecha.month)}-${dos(fecha.day)}';
  }
}
