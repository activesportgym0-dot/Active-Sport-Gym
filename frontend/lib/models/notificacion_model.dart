/// MODELO ÚNICO DE NOTIFICACIONES: lo usan el administrador (crear y gestionar)
/// y el cliente (ver y marcar como leídas), para no crear modelos separados.
/// Notificación creada por el administrador (tabla notificaciones).
/// Si [idUsuario] es null, la notificación es global (para todos los clientes).
class NotificacionModel {
  static const List<String> _meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  final int idNotificacion;
  final int? idUsuario;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String imagenUrl;
  final bool leida;
  final String fecha;
  final String destinatarioNombre;

  const NotificacionModel({
    required this.idNotificacion,
    this.idUsuario,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.imagenUrl = '',
    this.leida = false,
    this.fecha = '',
    this.destinatarioNombre = '',
  });

  bool get esGlobal => idUsuario == null;

  String get destino {
    if (esGlobal) return 'Todos los clientes';
    if (destinatarioNombre.isNotEmpty) {
      return 'Usuario: $destinatarioNombre (ID $idUsuario)';
    }
    return 'Usuario ID: $idUsuario';
  }

  /// "2026-10-06T14:30:00+00:00" -> "06 Oct 2026" (hora local del teléfono).
  String get fechaFormateada {
    final f = DateTime.tryParse(fecha)?.toLocal();
    if (f == null) return fecha.isEmpty ? 'Sin fecha' : fecha;
    return '${f.day.toString().padLeft(2, '0')} ${_meses[f.month - 1]} ${f.year}';
  }

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      idNotificacion: int.tryParse(json['id_notificacion'].toString()) ?? 0,
      idUsuario: json['id_usuario'] == null
          ? null
          : int.tryParse(json['id_usuario'].toString()),
      titulo: (json['titulo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      imagenUrl: (json['imagen_url'] ?? '').toString(),
      leida: json['leida'] == true,
      fecha: (json['fecha'] ?? '').toString(),
      destinatarioNombre: (json['destinatario_nombre'] ?? '').toString(),
    );
  }

  // ADMINISTRADOR

  /// Mapa con las mismas claves que usa TarjetaNotificacionAdmin
  /// (id, titulo, mensaje, tipo, destino, fecha), así la tarjeta no cambia.
  Map<String, dynamic> toMapaTarjeta() {
    return {
      'id': idNotificacion,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'destino': destino,
      'fecha': fechaFormateada,
      'imagen_url': imagenUrl,
    };
  }

  // CLIENTE

  /// Copia de la notificación con la marca de leída cambiada (para actualizar la lista al instante).
  NotificacionModel copyWith({bool? leida}) {
    return NotificacionModel(
      idNotificacion: idNotificacion,
      idUsuario: idUsuario,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      imagenUrl: imagenUrl,
      leida: leida ?? this.leida,
      fecha: fecha,
      destinatarioNombre: destinatarioNombre,
    );
  }

  /// Mapa con las claves que usa TarjetaNotificacionCliente
  /// (id, titulo, mensaje, tipo, fecha, leido, imagen_url), así la tarjeta conserva su diseño.
  Map<String, dynamic> toMapaTarjetaCliente() {
    return {
      'id': idNotificacion,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'fecha': fechaFormateada,
      'leido': leida,
      'imagen_url': imagenUrl,
    };
  }
}