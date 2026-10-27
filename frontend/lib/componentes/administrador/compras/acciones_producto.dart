import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/componentes/administrador/compras/modal_crear_producto.dart';
import 'package:frontend/componentes/administrador/compras/modal_editar_producto.dart';
import 'package:frontend/core/colores.dart';
import 'package:frontend/services/producto_service.dart';

class _DatosCrear {
  final int idCategoria;
  final String tipo;
  final XFile imagen;
  final Map<String, String> textos;

  _DatosCrear(this.idCategoria, this.tipo, this.imagen, this.textos);
}

class _DatosEditar {
  final int idProducto;
  final int idCategoria;
  final String tipo;
  final XFile? imagen;
  final Map<String, String> textos;

  _DatosEditar(this.idProducto, this.idCategoria, this.tipo, this.imagen, this.textos);
}

/// Crear, editar y eliminar productos se hacen desde dos pantallas distintas
/// (la lista y el detalle). Para no repetir la lógica, vive aquí una sola vez.
class AccionesProducto {
  AccionesProducto._();

  static void _mostrarMensaje(
    BuildContext context,
    String mensaje, {
    required bool exito,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: exito ? Colors.green : Colors.redAccent,
      ),
    );
  }

  /// Abre el formulario de crear. Devuelve true si el producto se creó.
  static Future<bool> crear(
    BuildContext context, {
    required List<dynamic> categorias,
  }) async {
    if (categorias.isEmpty) {
      _mostrarMensaje(
        context,
        'Primero crea al menos una categoría (icono de categorías arriba).',
        exito: false,
      );
      return false;
    }

    _DatosCrear? datos;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ModalCrearProducto(
        categoriasDisponibles: categorias,
        onCrear: (idCategoria, tipo, imagen, textos) {
          datos = _DatosCrear(idCategoria, tipo, imagen, textos);
          Navigator.pop(sheetContext);
        },
      ),
    );

    final d = datos;
    if (d == null || !context.mounted) return false;

    final resultado = await ProductoService.crearProducto(
      idCategoria: d.idCategoria,
      nombre: d.textos['nombre']!,
      marca: d.textos['marca']!,
      tipoProducto: d.tipo,
      sabor: d.textos['sabor']!,
      pesoNeto: d.textos['peso_neto']!,
      servicios: d.textos['servicios']!,
      precio: int.tryParse(d.textos['precio']!) ?? 0,
      stock: int.tryParse(d.textos['stock']!) ?? 0,
      descripcion: d.textos['descripcion']!,
      beneficios: d.textos['beneficios']!,
      modoUso: d.textos['modo_uso']!,
      imagenFile: d.imagen,
    );

    if (!context.mounted) return false;
    _mostrarMensaje(
      context,
      resultado['message']?.toString() ?? 'Operación finalizada',
      exito: resultado['success'] == true,
    );
    return resultado['success'] == true;
  }

  /// Abre el formulario de editar. Devuelve el producto actualizado
  /// (o un mapa vacío si el backend no lo devolvió) y null si no se guardó.
  static Future<Map<String, dynamic>?> editar(
    BuildContext context, {
    required Map<String, dynamic> producto,
    required List<dynamic> categorias,
  }) async {
    _DatosEditar? datos;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ModalEditarProducto(
        productoAEditar: producto,
        categoriasDisponibles: categorias,
        onEditar: (idProducto, idCategoria, tipo, imagen, textos) {
          datos = _DatosEditar(idProducto, idCategoria, tipo, imagen, textos);
          Navigator.pop(sheetContext);
        },
      ),
    );

    final d = datos;
    if (d == null || !context.mounted) return null;

    final resultado = await ProductoService.actualizarProducto(
      idProducto: d.idProducto,
      idCategoria: d.idCategoria,
      nombre: d.textos['nombre']!,
      marca: d.textos['marca']!,
      tipoProducto: d.tipo,
      sabor: d.textos['sabor']!,
      pesoNeto: d.textos['peso_neto']!,
      servicios: d.textos['servicios']!,
      precio: int.tryParse(d.textos['precio']!) ?? 0,
      stock: int.tryParse(d.textos['stock']!) ?? 0,
      descripcion: d.textos['descripcion']!,
      beneficios: d.textos['beneficios']!,
      modoUso: d.textos['modo_uso']!,
      imagenFile: d.imagen,
    );

    if (!context.mounted) return null;
    final exito = resultado['success'] == true;
    _mostrarMensaje(
      context,
      resultado['message']?.toString() ?? 'Operación finalizada',
      exito: exito,
    );
    if (!exito) return null;

    final data = resultado['data'];
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  /// Pide confirmación y elimina. Devuelve true si el producto se eliminó.
  static Future<bool> eliminar(
    BuildContext context,
    Map<String, dynamic> producto,
  ) async {
    final nombre = (producto['nombre'] ?? 'este producto').toString();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.grisOscuro,
        title: const Text(
          'Eliminar Producto',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás segura de que deseas eliminar "$nombre"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return false;

    final id = int.tryParse(producto['id_producto'].toString()) ?? 0;
    final resultado = await ProductoService.eliminarProducto(id);

    if (!context.mounted) return false;
    _mostrarMensaje(
      context,
      resultado['message']?.toString() ?? 'Operación finalizada',
      exito: resultado['success'] == true,
    );
    return resultado['success'] == true;
  }
}
