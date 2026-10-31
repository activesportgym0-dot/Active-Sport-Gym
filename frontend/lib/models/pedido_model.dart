/// Línea de un pedido (tabla detalle_pedidos).
/// La lista del admin no trae el detalle; sí lo trae "mis pedidos" del cliente.
class DetallePedidoModel {
  final int idDetalle;
  final int idProducto;
  final int cantidad;
  final num precioUnitario;
  final String nombreProducto;

  const DetallePedidoModel({
    required this.idDetalle,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    this.nombreProducto = '',
  });

  num get subtotal => precioUnitario * cantidad;

  factory DetallePedidoModel.fromJson(Map<String, dynamic> json) {
    final producto = json['productos'] is Map
        ? Map<String, dynamic>.from(json['productos'] as Map)
        : <String, dynamic>{};

    return DetallePedidoModel(
      idDetalle: int.tryParse(json['id_detalle'].toString()) ?? 0,
      idProducto: int.tryParse(json['id_producto'].toString()) ?? 0,
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 0,
      precioUnitario: num.tryParse(json['precio_unitario'].toString()) ?? 0,
      nombreProducto: (producto['nombre'] ?? json['nombre'] ?? '').toString(),
    );
  }
}

/// Pedido de la tienda (tabla pedidos) con los datos del cliente.
class PedidoModel {
  static const List<String> estados = [
    'Pendiente',
    'Aceptado',
    'Completado',
    'Cancelado',
  ];

  final int idPedido;
  final int idUsuario;
  final num total;
  final String estado;
  final String fechaPedido;
  final String nombreCliente;
  final String correoCliente;
  final List<DetallePedidoModel> detalles;

  const PedidoModel({
    required this.idPedido,
    required this.idUsuario,
    required this.total,
    required this.estado,
    this.fechaPedido = '',
    this.nombreCliente = '',
    this.correoCliente = '',
    this.detalles = const [],
  });

  /// El backend solo deja cancelar al cliente un pedido en estado Pendiente.
  bool get puedeCancelarse => estado == 'Pendiente';

  /// "2026-10-16T13:30:00+00:00" -> "16/10/2026 08:30" (hora local del teléfono).
  String get fechaFormateada {
    final fecha = DateTime.tryParse(fechaPedido)?.toLocal();
    if (fecha == null) return fechaPedido.isEmpty ? 'Sin fecha' : fechaPedido;
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
        '${dos(fecha.hour)}:${dos(fecha.minute)}';
  }

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuarios'] is Map
        ? Map<String, dynamic>.from(json['usuarios'] as Map)
        : <String, dynamic>{};
    final rawDetalles =
        json['detalle_pedidos'] is List ? json['detalle_pedidos'] as List : [];

    return PedidoModel(
      idPedido: int.tryParse(json['id_pedido'].toString()) ?? 0,
      idUsuario: int.tryParse(
            (json['id_usuario'] ?? usuario['id_usuario']).toString(),
          ) ??
          0,
      total: num.tryParse(json['total'].toString()) ?? 0,
      estado: (json['estado'] ?? 'Pendiente').toString(),
      fechaPedido: (json['fecha_pedido'] ?? '').toString(),
      nombreCliente: (usuario['nombre'] ?? '').toString(),
      correoCliente: (usuario['correo'] ?? '').toString(),
      detalles: rawDetalles
          .whereType<Map>()
          .map((d) => DetallePedidoModel.fromJson(Map<String, dynamic>.from(d)))
          .toList(),
    );
  }
}