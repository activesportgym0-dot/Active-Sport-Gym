import '../core/formato.dart';

/// Categoría de productos de la tienda (tabla categorias_productos).
class CategoriaProductoModel {
  final int idCategoria;
  final String nombre;

  const CategoriaProductoModel({
    required this.idCategoria,
    required this.nombre,
  });

  factory CategoriaProductoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaProductoModel(
      idCategoria: int.tryParse(json['id_categoria'].toString()) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_categoria': idCategoria,
        'nombre': nombre,
      };
}

/// Producto de la tienda (tabla productos).
class ProductoModel {
  final int idProducto;
  final int idCategoria;
  final String nombre;
  final String marca;
  final String tipoProducto; // 'consumible' o 'material'
  final String sabor;
  final String pesoNeto;
  final String servicios;
  final num precio;
  final int stock;
  final String descripcion;
  final String beneficios;
  final String modoUso;
  final String imagenUrl;

  const ProductoModel({
    required this.idProducto,
    required this.idCategoria,
    required this.nombre,
    this.marca = '',
    this.tipoProducto = 'consumible',
    this.sabor = '',
    this.pesoNeto = '',
    this.servicios = '',
    required this.precio,
    this.stock = 0,
    this.descripcion = '',
    this.beneficios = '',
    this.modoUso = '',
    this.imagenUrl = '',
  });

  /// Mapa con las claves que usan TarjetaProductoCliente y DetalleProductoClienteScreen
  /// (nombre, marca, stock, precio, imagen, categoria...), así esos componentes
  /// siguen funcionando con el mismo diseño. El producto solo trae el id de la
  /// categoría, por eso el nombre se recibe aparte.
  Map<String, dynamic> toMapaCliente({String nombreCategoria = ''}) {
    return {
      'id_producto': idProducto,
      'nombre': nombre,
      'marca': marca.isEmpty ? 'Sin marca' : marca,
      'stock': stock > 0 ? 'Stock: $stock' : 'Agotado',
      'stock_int': stock,
      'precio': Formato.precio(precio), // texto: "$120.000"
      'precio_num': precio, // número, para cálculos
      'imagen': imagenUrl, // URL de Cloudinary (vacía si no tiene foto)
      'categoria': nombreCategoria,
      'tipo_producto': tipoProducto,
      'sabor': sabor,
      'peso_neto': pesoNeto,
      'servicios': servicios,
      'descripcion': descripcion,
      'beneficios': beneficios,
      'modo_uso': modoUso,
    };
  }

  bool get esConsumible => tipoProducto == 'consumible';
  bool get agotado => stock <= 0;

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    String texto(String clave) => (json[clave] ?? '').toString();

    return ProductoModel(
      idProducto: int.tryParse(json['id_producto'].toString()) ?? 0,
      idCategoria: int.tryParse(json['id_categoria'].toString()) ?? 0,
      nombre: texto('nombre'),
      marca: texto('marca'),
      tipoProducto: texto('tipo_producto').isEmpty
          ? 'consumible'
          : texto('tipo_producto'),
      sabor: texto('sabor'),
      pesoNeto: texto('peso_neto'),
      servicios: texto('servicios'),
      precio: num.tryParse(json['precio'].toString()) ?? 0,
      stock: (num.tryParse(json['stock'].toString()) ?? 0).round(),
      descripcion: texto('descripcion'),
      beneficios: texto('beneficios'),
      modoUso: texto('modo_uso'),
      imagenUrl: texto('imagen_url'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_producto': idProducto,
        'id_categoria': idCategoria,
        'nombre': nombre,
        'marca': marca,
        'tipo_producto': tipoProducto,
        'sabor': sabor,
        'peso_neto': pesoNeto,
        'servicios': servicios,
        'precio': precio,
        'stock': stock,
        'descripcion': descripcion,
        'beneficios': beneficios,
        'modo_uso': modoUso,
        'imagen_url': imagenUrl,
      };
}