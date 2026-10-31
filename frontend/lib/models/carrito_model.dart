/// Producto dentro del carrito (GET /carrito -> items).
class CarritoItemModel {
  final int idCarrito;
  final int idProducto;
  final String nombre;
  final num precio;
  final String imagenUrl;
  final int cantidad;
  final int stockDisponible;

  const CarritoItemModel({
    required this.idCarrito,
    required this.idProducto,
    required this.nombre,
    required this.precio,
    this.imagenUrl = '',
    required this.cantidad,
    this.stockDisponible = 0,
  });

  num get subtotal => precio * cantidad;

  factory CarritoItemModel.fromJson(Map<String, dynamic> json) {
    return CarritoItemModel(
      idCarrito: int.tryParse(json['id_carrito'].toString()) ?? 0,
      idProducto: int.tryParse(json['id_producto'].toString()) ?? 0,
      nombre: (json['nombre'] ?? 'Producto').toString(),
      precio: num.tryParse(json['precio'].toString()) ?? 0,
      imagenUrl: (json['imagen_url'] ?? '').toString(),
      cantidad: int.tryParse(json['cantidad'].toString()) ?? 1,
      stockDisponible: int.tryParse(json['stock_disponible'].toString()) ?? 0,
    );
  }

  /// Mapa con las claves que ya usan CarritoScreen y ResumenCompraScreen
  /// (id_carrito, id_producto, nombre, precio, imagen_url, cantidad,
  /// stock_disponible, subtotal), así las pantallas conservan su diseño.
  Map<String, dynamic> toMapaPantalla() {
    return {
      'id_carrito': idCarrito,
      'id_producto': idProducto,
      'nombre': nombre,
      'precio': precio,
      'imagen_url': imagenUrl,
      'cantidad': cantidad,
      'stock_disponible': stockDisponible,
      'subtotal': subtotal,
    };
  }
}

/// Carrito completo del cliente (respuesta de GET /carrito).
class CarritoModel {
  final List<CarritoItemModel> items;
  final int totalItems;
  final num totalPagar;

  const CarritoModel({
    this.items = const [],
    this.totalItems = 0,
    this.totalPagar = 0,
  });

  factory CarritoModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] is List ? json['items'] as List : [];
    return CarritoModel(
      items: rawItems
          .whereType<Map>()
          .map((i) => CarritoItemModel.fromJson(Map<String, dynamic>.from(i)))
          .toList(),
      totalItems: int.tryParse(json['total_items'].toString()) ?? rawItems.length,
      totalPagar: num.tryParse(json['total_pagar'].toString()) ?? 0,
    );
  }
}
