/// Rutina ya guardada en la base de datos (GET /rutinas/usuario/:id).
/// Estructura del backend: rutinas -> rutina_dias -> rutina_ejercicios -> rutina_series.
/// (Para CREAR una rutina se usa RutinaNuevaModel, en rutina_model.dart.)

class SerieGuardadaModel {
  final int numeroSerie;
  final int repeticiones;
  final num peso;
  final int descansoEntreSeries;

  const SerieGuardadaModel({
    required this.numeroSerie,
    required this.repeticiones,
    required this.peso,
    required this.descansoEntreSeries,
  });

  factory SerieGuardadaModel.fromJson(Map<String, dynamic> json) {
    return SerieGuardadaModel(
      numeroSerie: int.tryParse(json['numero_serie'].toString()) ?? 0,
      repeticiones: int.tryParse(json['repeticiones'].toString()) ?? 0,
      peso: num.tryParse(json['peso'].toString()) ?? 0,
      descansoEntreSeries: int.tryParse(json['descanso_entre_series'].toString()) ?? 30,
    );
  }

  Map<String, dynamic> toMapaPantalla() => <String, dynamic>{
        'repeticiones': repeticiones,
        'peso': peso,
        'descanso_entre_series': descansoEntreSeries,
      };
}

class EjercicioGuardadoModel {
  final int idEjercicio;
  final String nombre;
  final String maquina;
  final String gifUrl;
  final int orden;
  final int descansoFinal;
  final List<SerieGuardadaModel> series;

  const EjercicioGuardadoModel({
    required this.idEjercicio,
    required this.nombre,
    this.maquina = '',
    this.gifUrl = '',
    this.orden = 0,
    this.descansoFinal = 60,
    this.series = const [],
  });

  factory EjercicioGuardadoModel.fromJson(Map<String, dynamic> json) {
    final ejercicio = json['ejercicios'] is Map
        ? Map<String, dynamic>.from(json['ejercicios'] as Map)
        : <String, dynamic>{};
    final rawSeries = json['rutina_series'] is List ? json['rutina_series'] as List : const [];

    // El backend no garantiza el orden de las series: se ordenan por numero_serie
    final series = rawSeries
        .whereType<Map>()
        .map((s) => SerieGuardadaModel.fromJson(Map<String, dynamic>.from(s)))
        .toList()
      ..sort((a, b) => a.numeroSerie.compareTo(b.numeroSerie));

    return EjercicioGuardadoModel(
      idEjercicio: int.tryParse(json['id_ejercicio'].toString()) ?? 0,
      nombre: (ejercicio['nombre'] ?? 'Ejercicio').toString(),
      maquina: (ejercicio['maquina'] ?? '').toString(),
      gifUrl: (ejercicio['gif_url'] ?? '').toString(),
      orden: int.tryParse(json['orden'].toString()) ?? 0,
      descansoFinal: int.tryParse(json['descanso_final'].toString()) ?? 60,
      series: series,
    );
  }

  /// Mapa con las claves que usan las pantallas de detalle y de entrenamiento
  /// (title, category, gif_url, descanso_final, series).
  /// El backend no devuelve la categoría del ejercicio, por eso en "category" va la máquina.
  /// "gif_url" es la demostración (GIF o video) que se muestra al entrenar.
  Map<String, dynamic> toMapaPantalla() => <String, dynamic>{
        'id_ejercicio': idEjercicio,
        'title': nombre,
        'category': maquina,
        'gif_url': gifUrl,
        'descanso_final': descansoFinal,
        'series': series.map((s) => s.toMapaPantalla()).toList(),
      };
}

class DiaGuardadoModel {
  /// Orden y letra con las que las pantallas identifican cada día de la semana.
  static const List<String> _ordenSemana = ['L', 'M', 'Mi', 'J', 'V', 'S', 'D'];

  final int idRutinaDia;
  final String diaSemana; // 'lunes', 'martes', ... o 'diario' (rutinas diarias)
  final String nombreDia;
  final List<EjercicioGuardadoModel> ejercicios;

  const DiaGuardadoModel({
    required this.idRutinaDia,
    required this.diaSemana,
    required this.nombreDia,
    this.ejercicios = const [],
  });

  factory DiaGuardadoModel.fromJson(Map<String, dynamic> json) {
    final rawEjercicios = json['rutina_ejercicios'] is List ? json['rutina_ejercicios'] as List : const [];

    final ejercicios = rawEjercicios
        .whereType<Map>()
        .map((e) => EjercicioGuardadoModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));

    return DiaGuardadoModel(
      idRutinaDia: int.tryParse(json['id_rutina_dia'].toString()) ?? 0,
      diaSemana: (json['dia_semana'] ?? '').toString().toLowerCase(),
      nombreDia: (json['nombre_dia'] ?? '').toString(),
      ejercicios: ejercicios,
    );
  }

  /// lunes -> 'L', miércoles -> 'Mi'... (null si no es un día de la semana)
  String? get claveSemana {
    switch (diaSemana) {
      case 'lunes':
        return 'L';
      case 'martes':
        return 'M';
      case 'miércoles':
      case 'miercoles':
        return 'Mi';
      case 'jueves':
        return 'J';
      case 'viernes':
        return 'V';
      case 'sábado':
      case 'sabado':
        return 'S';
      case 'domingo':
        return 'D';
      default:
        return null;
    }
  }

  int get posicionSemana {
    final clave = claveSemana;
    final posicion = clave == null ? -1 : _ordenSemana.indexOf(clave);
    return posicion < 0 ? 99 : posicion;
  }

  List<Map<String, dynamic>> get ejerciciosPantalla =>
      ejercicios.map((e) => e.toMapaPantalla()).toList();
}

class RutinaGuardadaModel {
  final int idRutina;
  final String nombre;
  final String tipo; // 'diaria' o 'semanal'
  final String fechaCreacion;
  final List<DiaGuardadoModel> dias;

  const RutinaGuardadaModel({
    required this.idRutina,
    required this.nombre,
    required this.tipo,
    this.fechaCreacion = '',
    this.dias = const [],
  });

  bool get esDiaria => tipo == 'diaria';
  bool get esSemanal => tipo == 'semanal';

  /// "2026-10-31T10:20:00" -> "31/10/2026"
  String get fechaFormateada {
    final f = DateTime.tryParse(fechaCreacion)?.toLocal();
    if (f == null) return fechaCreacion.isEmpty ? 'Sin fecha' : fechaCreacion;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year}';
  }

  factory RutinaGuardadaModel.fromJson(Map<String, dynamic> json) {
    final rawDias = json['rutina_dias'] is List ? json['rutina_dias'] as List : const [];

    final dias = rawDias
        .whereType<Map>()
        .map((d) => DiaGuardadoModel.fromJson(Map<String, dynamic>.from(d)))
        .toList()
      ..sort((a, b) => a.posicionSemana.compareTo(b.posicionSemana));

    return RutinaGuardadaModel(
      idRutina: int.tryParse(json['id_rutina'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString().toLowerCase(),
      fechaCreacion: (json['fecha_creacion'] ?? '').toString(),
      dias: dias,
    );
  }

  /// Mapa con la estructura que ya usan EntrenamientoScreen, los detalles y el
  /// entrenamiento en vivo:
  ///  - diaria:  {id_rutina, nombre_rutina, tipo, fecha, ejercicios: [...]}
  ///  - semanal: {id_rutina, nombre_plan, tipo, fecha, estructura_semanal: {L: {nombre_rutina, ejercicios}}}
  Map<String, dynamic> toMapaEntrenamiento() {
    if (esDiaria) {
      return <String, dynamic>{
        'id_rutina': idRutina,
        'nombre_rutina': nombre,
        'tipo': 'diaria',
        'fecha': fechaFormateada,
        'ejercicios': dias.isNotEmpty ? dias.first.ejerciciosPantalla : <Map<String, dynamic>>[],
      };
    }

    final estructura = <String, dynamic>{};
    for (final dia in dias) {
      final clave = dia.claveSemana;
      if (clave == null) continue;
      estructura[clave] = <String, dynamic>{
        'nombre_rutina': dia.nombreDia,
        'ejercicios': dia.ejerciciosPantalla,
      };
    }

    return <String, dynamic>{
      'id_rutina': idRutina,
      'nombre_plan': nombre,
      'tipo': 'semanal',
      'fecha': fechaFormateada,
      'estructura_semanal': estructura,
    };
  }
}